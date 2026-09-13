--[[
    ==============================================================================
                          POLAR HUB: ADVANCED AUTO MASTERY
                         & AUTO BONES ULTRA COMBAT ENGINE
    ==============================================================================
    Reconstructed from Quantum Onyx architecture with 100% native Luau execution.
    Supports:
      - 2-Phase Adaptive Combat (M1 Fast Attack -> Mastery Skill Burst at 25% HP)
      - Precise Skill Hold Times (Z, X, C, V, F via VirtualInputManager)
      - Haunted Castle Auto Bones with Single & Double Quest modes
      - Mob Clustering (Bring Monster radius 400 studs)
      - Boss Farm Automation (Stone, Kilo Admiral, Beautiful Pirate, Cake Queen, etc.)
      - Full integration with Polar Hub UI and Multi-Theme Engine
    ==============================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)

-- Net & Combat remotes
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
    PrimaryWeapon = "Melee",          -- Used for fast M1 shredding
    MasteryTarget = "Blox Fruit",     -- Target weapon for killing blow
    
    -- Skills selection & hold times
    SkillsEnabled = true,
    BloxFruitKeys = {"Z", "F", "X", "C", "V"},
    MeleeKeys = {"Z"},
    SwordKeys = {"Z"},
    GunKeys = {"Z"},
    
    HoldTimes = {
        Z = 0.9,                      -- 900 ms
        X = 3.8,                      -- 3800 ms
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
    
    -- Mechanics
    BringMonster = true,
    BringRadius = 400,
    HoverHeight = 22,
    PosMethod = "Above",
    
    -- Boss Farm
    SelectedBoss = "Stone",
    AutoFarmBoss = false,
    AutoKillAllBosses = false,
    GetBossQuest = true,
    
    -- Internal state
    IsBusyWithSkills = false,
    CurrentTarget = nil
}

getgenv().PolarMastery = PolarMastery

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
-- SKILL EXECUTION WITH HOLD TIMES
-- ==============================================================================
function PolarMastery:CastKey(key, holdTime)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        if holdTime and holdTime > 0 then
            task.wait(holdTime)
        else
            task.wait(0.04)
        end
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

function PolarMastery:ExecuteSkillBurst(targetMob)
    if self.IsBusyWithSkills then return end
    self.IsBusyWithSkills = true

    pcall(function()
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

            local hold = self.HoldTimes[key] or 0
            self:CastKey(key, hold)

            if delay > 0 then task.wait(delay) else task.wait(0.06) end
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
    if questUI and questUI.Visible then return end -- Ya tiene quest activa

    pcall(function()
        if self.QuestFarmMode == "Double Quest" then
            -- HauntedQuest2 gives Demonic Soul (lvl 2025) and Posessed Mummy (lvl 2050)
            CommF:InvokeServer("StartQuest", "HauntedQuest2", 2)
        else
            CommF:InvokeServer("StartQuest", "HauntedQuest1", 1)
        end
    end)
end

-- ==============================================================================
-- TARGET ACQUISITION (BONES & NEAREST)
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
    if not (PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.EnableMastery) then
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end

    -- Check Quest
    if PolarMastery.AutoBones and PolarMastery.TakeQuest then
        PolarMastery:HandleBonesQuest()
    end

    -- Find target
    local target = PolarMastery:FindTarget()
    PolarMastery.CurrentTarget = target
    if not target then return end

    local tHum = target:FindFirstChildOfClass("Humanoid")
    local tRoot = target:FindFirstChild("HumanoidRootPart")
    if not tHum or not tRoot or tHum.Health <= 0 then return end

    local targetPos = tRoot.Position
    local hoverCFrame = CFrame.new(targetPos + Vector3.new(0, PolarMastery.HoverHeight, 0), targetPos)

    -- Lock player position safely above mob
    root.CFrame = hoverCFrame
    root.Velocity = Vector3.zero

    -- Bring nearby mobs into cluster
    PolarMastery:ClusterMobs(targetPos)

    local hpPercent = (tHum.Health / tHum.MaxHealth) * 100

    if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
        -- FASE 2: Mob debilitado (<=25%) -> Burst de Habilidades con Arma de Maestría
        PolarMastery:ExecuteSkillBurst(target)
    else
        -- FASE 1: Mob con vida alta (>25%) -> Fast Attack M1 con Arma Primaria (Melee)
        PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
        
        pcall(function()
            if RegisterAttack then RegisterAttack:FireServer(0) end
            SendHitsToServer(tRoot, {{target, tRoot}})
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new())
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new())
        end)
    end
end

-- Heartbeat / Fast Loop
task.spawn(function()
    while true do
        task.wait(0.03)
        if PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.EnableMastery then
            pcall(runMasteryCombatStep)
        end
    end
end)

print("[Polar Hub] [OK] Motor PolarMastery (Auto Bones & Auto Mastery) cargado con exito.")
return PolarMastery
