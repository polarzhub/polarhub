--[[
    ==============================================================================
                          POLAR HUB: ADVANCED AUTO MASTERY
                         & AUTO BONES ULTRA COMBAT ENGINE
    ==============================================================================
    Reconstructed from Quantum Onyx architecture with 100% native Luau execution.
    Features:
      - Continuous Anti-Fall Hover Lock (Heartbeat + Stepped + BodyVelocity)
      - True Enemy Aim Redirection (metamethod Mouse hook + MousePos + Camera aim)
      - Universal M1 Combat (Native Fruit M1 for Gravity & all fruits, Melee, Sword)
      - 2-Phase Adaptive Combat (M1 Shredding -> Weapon Swap & Skill Burst at <=25% HP)
      - Decimal Hold Times in Seconds (0.0s - 5.0s with 0.1s step)
      - Haunted Castle Auto Bones with Single & Double Quest modes
      - Mob Clustering (Bring Monster radius 400 studs)
      - Boss Farm Automation
    ==============================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Remotes & Modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)
local NetModule = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local Net = nil
pcall(function()
    if NetModule then Net = require(NetModule) end
end)
local RegisterHit = Net and Net:RemoteEvent("RegisterHit", true)
local RegisterAttack = Net and Net:RemoteEvent("RegisterAttack")

local GlobalModule = nil
pcall(function()
    GlobalModule = require(ReplicatedStorage:WaitForChild("Global", 5))
end)

local MouseModule = nil
pcall(function()
    MouseModule = require(ReplicatedStorage:WaitForChild("Mouse", 5))
end)

local function SendHitsToServer(...)
    if GlobalModule and GlobalModule.SendHitsToServer then
        GlobalModule.SendHitsToServer(...)
    elseif RegisterHit and RegisterHit.FireServer then
        RegisterHit:FireServer(...)
    end
end

-- ==============================================================================
-- ENGINE CONFIGURATION STATE
-- ==============================================================================
local PolarMastery = {
    -- Master toggles
    Enabled = false,
    AutoBones = false,
    AutoFarm = false,
    TakeQuest = true,
    EnableMastery = true,
    
    -- Farm Settings
    FarmMethod = "Quest",             -- "Quest" or "Nearest"
    QuestFarmMode = "Double Quest",   -- "Normal" or "Double Quest"
    NearestDistance = 1500,
    HealthMobThreshold = 25,          -- HP% to swap to mastery weapon (default 25%)
    PrimaryWeapon = "Melee",          -- Used for fast M1 shredding ("Melee", "Sword", "Blox Fruit")
    MasteryTarget = "Blox Fruit",     -- Target weapon for killing blow
    
    -- Skills selection & hold times (in SECONDS with decimals)
    SkillsEnabled = true,
    BloxFruitKeys = {"Z", "X", "C", "V", "F"},
    MeleeKeys = {"Z", "X", "C"},
    SwordKeys = {"Z", "X"},
    GunKeys = {"Z", "X"},
    
    HoldTimes = {
        Z = 0.8,                      -- 0.8s
        X = 3.8,                      -- 3.8s (Gravity orbital charge)
        C = 0.0,
        V = 0.0,
        F = 0.0
    },
    
    SkillDelays = {
        BloxFruit = 0.0,
        Melee = 0.0,
        Sword = 0.0,
        Gun = 0.0
    },
    
    -- Mechanics & Hover Lock
    BringMonster = true,
    BringRadius = 400,
    HoverHeight = 22,
    PosMethod = "Above",
    
    -- Boss Farm
    SelectedBoss = "Stone",
    AutoFarmBoss = false,
    AutoKillAllBosses = false,
    GetBossQuest = true,
    
    -- Live Runtime Aim & Position Tracking
    IsBusyWithSkills = false,
    CurrentTarget = nil,
    CurrentTargetRoot = nil,
    CurrentAimPos = nil,
    TargetHoverCFrame = nil
}

getgenv().PolarMastery = PolarMastery

-- ==============================================================================
-- DUAL-LAYER ENEMY AIMING & MOUSE INTERCEPTION
-- ==============================================================================
-- Hook metamethod for Mouse.Hit and Mouse.Target
pcall(function()
    if hookmetamethod and not getgenv().__PolarAimHooked then
        getgenv().__PolarAimHooked = true
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and (self == Mouse or tostring(self) == "Mouse") then
                if key == "Hit" and PolarMastery.CurrentAimPos then
                    return CFrame.new(PolarMastery.CurrentAimPos)
                elseif key == "Target" and PolarMastery.CurrentTargetRoot then
                    return PolarMastery.CurrentTargetRoot
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

function PolarMastery:SetAimTarget(targetRoot)
    if not targetRoot then
        self.CurrentAimPos = nil
        self.CurrentTargetRoot = nil
        return
    end

    local aimPos = targetRoot.Position
    self.CurrentAimPos = aimPos
    self.CurrentTargetRoot = targetRoot

    -- Update Blox Fruits internal Mouse module
    if MouseModule and type(MouseModule) == "table" then
        pcall(function()
            MouseModule.Hit = CFrame.new(aimPos)
            MouseModule.Target = targetRoot
        end)
    end

    -- Update Tool MousePos if present
    local tool = self:GetEquippedTool()
    if tool then
        local mousePos = tool:FindFirstChild("MousePos")
        if mousePos and mousePos:IsA("Vector3Value") then
            mousePos.Value = aimPos
        end
    end

    -- Turn Camera towards target
    pcall(function()
        if Camera then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimPos)
        end
    end)
end

-- ==============================================================================
-- CONTINUOUS ANTI-FALL HOVER LOCK (HEARTBEAT + STEPPED ENGINE)
-- ==============================================================================
local hoverVelocity = nil

local function updateHoverEngine()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.EnableMastery
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not isActive or not root or not hum or hum.Health <= 0 or not PolarMastery.TargetHoverCFrame then
        if hoverVelocity then
            pcall(function() hoverVelocity:Destroy() end)
            hoverVelocity = nil
        end
        return
    end

    -- Ensure BodyVelocity anchor
    if not hoverVelocity or hoverVelocity.Parent ~= root then
        if hoverVelocity then pcall(function() hoverVelocity:Destroy() end) end
        hoverVelocity = Instance.new("BodyVelocity")
        hoverVelocity.Name = "PolarHoverAnchor"
        hoverVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hoverVelocity.Velocity = Vector3.zero
        hoverVelocity.Parent = root
    end

    -- Lock position and kill velocity
    root.CFrame = PolarMastery.TargetHoverCFrame
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

-- Stepped: Disable collision so character never gets bumped or pushed down
RunService.Stepped:Connect(function()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.EnableMastery
    if isActive and PolarMastery.TargetHoverCFrame then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Heartbeat: Solid CFrame lock every frame (60+ times/second)
RunService.Heartbeat:Connect(function()
    pcall(updateHoverEngine)
end)

-- ==============================================================================
-- WEAPON MANAGEMENT
-- ==============================================================================
function PolarMastery:GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

function PolarMastery:EquipWeapon(category)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end

    local current = self:GetEquippedTool()
    if current then
        if category == "Blox Fruit" and current.ToolTip == "Blox Fruit" then
            return current
        elseif current.ToolTip == category or current.Name == category then
            return current
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if category == "Blox Fruit" and tool.ToolTip == "Blox Fruit" then
                hum:EquipTool(tool)
                return tool
            elseif tool.ToolTip == category or tool.Name == category then
                hum:EquipTool(tool)
                return tool
            end
        end
    end
    return nil
end

-- ==============================================================================
-- UNIVERSAL M1 ATTACK (FRUIT M1, MELEE, SWORD)
-- ==============================================================================
function PolarMastery:PerformM1(targetMob, targetRoot)
    if not targetMob or not targetRoot then return end
    local char = LocalPlayer.Character
    if not char then return end

    local tool = self:GetEquippedTool()
    if not tool then return end

    -- Direct aim at target
    self:SetAimTarget(targetRoot)

    local isFruit = tool.ToolTip == "Blox Fruit" or tool:GetAttribute("WeaponType") == "Demon Fruit"

    if isFruit then
        -- Native Blox Fruits Fruit M1
        pcall(function()
            if GlobalModule and GlobalModule.casFunc then
                local u15 = {
                    KeyCode = Enum.KeyCode.G,
                    UserInputState = Enum.UserInputState.Begin,
                    Position = UserInputService:GetMouseLocation(),
                    Changed = tool.Deactivated
                }
                GlobalModule.casFunc("DevilFruit", Enum.UserInputState.Begin, u15, Enum.KeyCode.G)
            end
            tool:Activate()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.zero)
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.zero)
        end)
    else
        -- Standard Melee / Sword / Gun M1
        pcall(function()
            tool:Activate()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.zero)
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.zero)
        end)
    end

    -- Server Damage Synchronization
    pcall(function()
        if RegisterAttack then RegisterAttack:FireServer(0) end
        SendHitsToServer(targetRoot, {{targetMob, targetRoot}})
    end)
end

-- ==============================================================================
-- SKILL EXECUTION WITH DECIMAL SECOND HOLD TIMES & CONTINUOUS HOVER LOCK
-- ==============================================================================
function PolarMastery:CastKey(key, holdSeconds, targetRoot)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end

    pcall(function()
        -- Direct aim before casting
        if targetRoot then
            self:SetAimTarget(targetRoot)
        end

        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)

        local duration = holdSeconds or 0
        if duration > 0 then
            local startTime = os.clock()
            while (os.clock() - startTime) < duration do
                -- Keep aim refreshed during charging
                if targetRoot and targetRoot.Parent then
                    self:SetAimTarget(targetRoot)
                    local targetPos = targetRoot.Position
                    self.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, self.HoverHeight, 0), targetPos)
                end
                task.wait(0.05)
            end
        else
            task.wait(0.05)
        end

        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

function PolarMastery:ExecuteSkillBurst(targetMob)
    if self.IsBusyWithSkills then return end
    self.IsBusyWithSkills = true

    pcall(function()
        local tRoot = targetMob:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end

        -- 1. Equip mastery target
        self:EquipWeapon(self.MasteryTarget)
        task.wait(0.12)

        -- 2. Select keys
        local keys = self.BloxFruitKeys
        if self.MasteryTarget == "Melee" then keys = self.MeleeKeys
        elseif self.MasteryTarget == "Sword" then keys = self.SwordKeys
        elseif self.MasteryTarget == "Gun" then keys = self.GunKeys
        end

        local delay = self.SkillDelays[self.MasteryTarget] or 0

        for _, key in ipairs(keys) do
            local hum = targetMob and targetMob:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or not targetMob.Parent then break end

            local holdSec = self.HoldTimes[key] or 0
            self:CastKey(key, holdSec, tRoot)

            if delay > 0 then task.wait(delay) else task.wait(0.08) end
        end

        -- Finish with Fruit M1 if mob still has remaining health and fruit is equipped
        local humAfter = targetMob and targetMob:FindFirstChildOfClass("Humanoid")
        if humAfter and humAfter.Health > 0 and targetMob.Parent then
            self:PerformM1(targetMob, tRoot)
        end
    end)

    self.IsBusyWithSkills = false
end

-- ==============================================================================
-- BRING MONSTER CLUSTERING
-- ==============================================================================
function PolarMastery:ClusterMobs(pivotPos)
    if not self.BringMonster then return end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob ~= self.CurrentTarget and mob:IsA("Model") then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local dist = (hrp.Position - pivotPos).Magnitude
                if dist <= self.BringRadius then
                    hrp.CFrame = CFrame.new(pivotPos)
                    hrp.CanCollide = false
                    hrp.Velocity = Vector3.zero
                end
            end
        end
    end
end

-- ==============================================================================
-- QUEST HANDLER (HAUNTED CASTLE & BONES)
-- ==============================================================================
function PolarMastery:HandleBonesQuest()
    if not self.TakeQuest or not CommF then return end

    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local questUI = pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest")
    if questUI and questUI.Visible then return end

    pcall(function()
        if self.QuestFarmMode == "Double Quest" then
            CommF:InvokeServer("StartQuest", "HauntedQuest2", 2)
        else
            CommF:InvokeServer("StartQuest", "HauntedQuest1", 1)
        end
    end)
end

-- ==============================================================================
-- TARGET ACQUISITION (BONES, FARM & BOSS)
-- ==============================================================================
local BoneMobNames = {
    ["reborn skeleton"] = true,
    ["living zombie"] = true,
    ["demonic soul"] = true,
    ["posessed mummy"] = true
}

function PolarMastery:FindTarget()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    local bestMob = nil
    local minDist = self.NearestDistance or 1500

    -- 1. Boss Farm Priority
    if self.AutoFarmBoss and self.SelectedBoss then
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name == self.SelectedBoss and mob:IsA("Model") then
                local hum = mob:FindFirstChildOfClass("Humanoid")
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    return mob
                end
            end
        end
    end

    -- 2. Bones or Normal Farm
    for _, mob in ipairs(enemies:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and hrp then
            local nameLower = mob.Name:lower()
            local isBoneMob = BoneMobNames[nameLower] ~= nil
            
            if self.AutoBones then
                if isBoneMob then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        bestMob = mob
                    end
                end
            elseif self.AutoFarm then
                local d = (root.Position - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                    bestMob = mob
                end
            end
        end
    end
    return bestMob
end

-- ==============================================================================
-- MAIN ADAPTIVE COMBAT LOOP
-- ==============================================================================
local function runMasteryCombatStep()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.EnableMastery
    if not isActive then
        PolarMastery.TargetHoverCFrame = nil
        PolarMastery.CurrentTarget = nil
        PolarMastery.CurrentTargetRoot = nil
        PolarMastery.CurrentAimPos = nil
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then
        PolarMastery.TargetHoverCFrame = nil
        return
    end

    -- Quest check
    if PolarMastery.AutoBones and PolarMastery.TakeQuest then
        PolarMastery:HandleBonesQuest()
    end

    -- Target acquisition
    local target = PolarMastery:FindTarget()
    PolarMastery.CurrentTarget = target
    if not target then
        PolarMastery.TargetHoverCFrame = nil
        PolarMastery.CurrentTargetRoot = nil
        PolarMastery.CurrentAimPos = nil
        return
    end

    local tHum = target:FindFirstChildOfClass("Humanoid")
    local tRoot = target:FindFirstChild("HumanoidRootPart")
    if not tHum or not tRoot or tHum.Health <= 0 then
        PolarMastery.TargetHoverCFrame = nil
        return
    end

    PolarMastery.CurrentTargetRoot = tRoot
    local targetPos = tRoot.Position
    PolarMastery.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, PolarMastery.HoverHeight, 0), targetPos)
    PolarMastery:SetAimTarget(tRoot)

    -- Bring nearby mobs into cluster
    PolarMastery:ClusterMobs(targetPos)

    local hpPercent = (tHum.Health / tHum.MaxHealth) * 100

    if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
        -- PHASE 2: Weakened mob (<=25% HP) -> Skill Burst with Mastery Target Weapon
        PolarMastery:ExecuteSkillBurst(target)
    else
        -- PHASE 1: Full/High HP mob (>25% HP) -> Fast M1 Shredding with Primary Weapon
        PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
        PolarMastery:PerformM1(target, tRoot)
    end
end

-- Combat heartbeat loop
task.spawn(function()
    while true do
        task.wait(0.02)
        local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.EnableMastery
        if isActive then
            pcall(runMasteryCombatStep)
        end
    end
end)

print("[Polar Hub] [OK] Motor PolarMastery (Anti-Fall Lock, Aiming & Fruit M1) cargado con exito.")
return PolarMastery
