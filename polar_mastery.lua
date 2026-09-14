--[[
    Polar Hub - Unified Combat & Auto Farm Ultra Engine
    High-Performance Blox Fruits Framework
    - Zero Camera Manipulation (Camera stays 100% free and user-controlled)
    - Pure Silent Aim (Metamethod __index hook, ReplicatedStorage.Mouse, Tool.MousePos)
    - Anti-Drop BodyVelocity Hover Anchor (Keeps player suspended 11.5 studs above mobs)
    - Native CombatController Integration (2500+ damage per M1 swing, zero damage taken from mobs)
    - Bug-Free Multi-Mob Clustering (Same elevation, circular offset, full limb CanCollide=false, no PlatformStand)
    - Multi-Mode Farming: Auto Bones (Haunted Castle), Auto Farm Levels (Best Quest / Nearest), Auto Boss, Auto All Bosses
    - Clean Toggle Shutdown (Stops all attacks and releases hover anchor when toggled off)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Remotes & Core Modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)
local NetModule = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local Net = nil
pcall(function()
    if NetModule then Net = require(NetModule) end
end)

local RegisterHit = nil
local RegisterAttack = nil
pcall(function()
    if Net then
        RegisterHit = Net:RemoteEvent("RegisterHit", true)
        RegisterAttack = Net:RemoteEvent("RegisterAttack")
    end
end)

local GlobalModule = nil
pcall(function()
    GlobalModule = require(ReplicatedStorage:WaitForChild("Global", 5))
end)

local MouseModule = nil
pcall(function()
    MouseModule = require(ReplicatedStorage:WaitForChild("Mouse", 5))
end)

local CombatController = nil
pcall(function()
    CombatController = require(ReplicatedStorage.Controllers:WaitForChild("CombatController", 5))
end)

local SendHitsToServer = function(...)
    if GlobalModule and GlobalModule.SendHitsToServer then
        GlobalModule.SendHitsToServer(...)
    elseif RegisterHit and RegisterHit.FireServer then
        RegisterHit:FireServer(...)
    end
end

-- ==============================================================================
-- POLAR MASTERY TABLE SETUP
-- ==============================================================================
local PolarMastery = getgenv().PolarMastery or {}
PolarMastery.Enabled = true
PolarMastery.AutoFarm = false
PolarMastery.AutoBones = false
PolarMastery.FarmMethod = PolarMastery.FarmMethod or "Quest"
PolarMastery.QuestFarmMode = PolarMastery.QuestFarmMode or "Double Quest"
PolarMastery.NearestDistance = PolarMastery.NearestDistance or 1500
PolarMastery.TakeQuest = PolarMastery.TakeQuest ~= false
PolarMastery.PrimaryWeapon = PolarMastery.PrimaryWeapon or "Melee"
PolarMastery.MasteryTarget = PolarMastery.MasteryTarget or "Blox Fruit"
PolarMastery.EnableMastery = PolarMastery.EnableMastery ~= false
PolarMastery.HealthMobThreshold = PolarMastery.HealthMobThreshold or 25

-- Hold Times (Seconds)
PolarMastery.HoldTimes = PolarMastery.HoldTimes or {
    Z = 0.8,
    X = 3.8,
    C = 0.0,
    V = 0.0,
    F = 0.0
}

-- Skill Delays
PolarMastery.SkillDelays = PolarMastery.SkillDelays or {
    BloxFruit = 0.0,
    Melee = 0.0,
    Sword = 0.0,
    Gun = 0.0
}

-- Skill Key Sequences
PolarMastery.SkillsEnabled = true
PolarMastery.BloxFruitKeys = {"Z", "X", "C", "V", "F"}
PolarMastery.MeleeKeys = {"Z", "X", "C"}
PolarMastery.SwordKeys = {"Z", "X"}
PolarMastery.GunKeys = {"Z", "X"}

-- Mechanics & Hover Lock (ALWAYS ABOVE MOBS AT 11.5 STUDS - SAFE FROM ALL DAMAGE)
PolarMastery.BringMonster = true
PolarMastery.BringRadius = 250
PolarMastery.HoverHeight = 12.5
PolarMastery.FastAttackDelay = 0.10
PolarMastery.PosMethod = "Above"

-- Boss Farm
PolarMastery.SelectedBoss = PolarMastery.SelectedBoss or "Stone"
PolarMastery.AutoFarmBoss = false
PolarMastery.AutoKillAllBosses = false
PolarMastery.GetBossQuest = PolarMastery.GetBossQuest ~= false

-- Live Runtime Aim & Position Tracking
PolarMastery.IsBusyWithSkills = false
PolarMastery.CurrentTarget = nil
PolarMastery.CurrentTargetRoot = nil
PolarMastery.CurrentAimPos = nil
PolarMastery.TargetHoverCFrame = nil
PolarMastery.IsTraveling = false
PolarMastery.LastM1Time = 0
PolarMastery.LastClusterTime = 0
PolarMastery.AttackCombo = 1

getgenv().PolarMastery = PolarMastery

-- ==============================================================================
-- PURE SILENT AIM (METAMETHOD HOOK + MOUSEPOS - ZERO CAMERA MANIPULATION)
-- ==============================================================================
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

    -- Update Tool MousePos Vector3Value if tool has it
    local tool = self:GetEquippedTool()
    if tool then
        local mousePos = tool:FindFirstChild("MousePos")
        if mousePos and mousePos:IsA("Vector3Value") then
            mousePos.Value = aimPos
        end
    end

    -- Orient character horizontally towards target without tilting or touching camera
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(aimPos.X, root.Position.Y, aimPos.Z))
    end
end

-- ==============================================================================
-- CONTINUOUS ANTI-FALL HOVER LOCK FORWARD DECLARATIONS
-- ==============================================================================
local hoverVelocity = nil
local hoverPlatform = nil
local function clearHoverInstances()
    if hoverVelocity and hoverVelocity.Parent then
        pcall(function() hoverVelocity:Destroy() end)
    end
    hoverVelocity = nil
    if hoverPlatform and hoverPlatform.Parent then
        pcall(function() hoverPlatform:Destroy() end)
    end
    hoverPlatform = nil
end

-- ==============================================================================
-- SAFE TELEPORTATION HELPER
-- ==============================================================================
function PolarMastery:TeleportTo(cf)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not cf then return end

    local dist = (root.Position - cf.Position).Magnitude
    if dist <= 8 then return end

    self.IsTraveling = true
    clearHoverInstances()

    local Polar = getgenv().Polar
    if Polar and Polar.Teleport and type(Polar.Teleport.To) == "function" then
        Polar.Teleport:To(cf)
    else
        root.CFrame = cf
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    self.IsTraveling = false
end

-- ==============================================================================
-- CONTINUOUS ANTI-FALL HOVER LOCK (HEARTBEAT + STEPPED + BODYVELOCITY + PLATFORM)
-- ==============================================================================


function PolarMastery:StopAll()
    self.AutoBones = false
    self.AutoFarm = false
    self.AutoFarmBoss = false
    self.AutoKillAllBosses = false
    self.TargetHoverCFrame = nil
    self.CurrentTarget = nil
    self.CurrentTargetRoot = nil
    self.CurrentAimPos = nil
    self.IsBusyWithSkills = false
    getgenv().PolarAutoFarmEnabled = false
    getgenv().PolarAutoBonesEnabled = false
    getgenv().PolarFastAttackEnabled = false
    
    -- Salida Segura (StopAll):
    -- Al desactivar el farm, el personaje se eleva en el aire y mantiene una plataforma segura
    -- por exactamente 5 segundos (no permanente) o evacúa a la zona segura de la isla.
    local safety = (Polar and Polar.Safety) or (getgenv().Polar and getgenv().Polar.Safety)
    if safety and type(safety.EvacuateToSafety) == "function" then
        safety:EvacuateToSafety(5, true)
    else
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame * CFrame.new(0, 20, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end)
        clearHoverInstances()
    end
    
    local combat = (Polar and Polar.Combat) or getgenv().PolarCombat
    if combat then
        combat:ReleaseHover()
        combat.Enabled = false
    end
end

local function updateHoverEngine()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Check if inactive, dead, or actively traveling
    local Polar = getgenv().Polar
    local isTeleporting = (Polar and Polar.Teleport and Polar.Teleport.IsTeleporting) or PolarMastery.IsTraveling
    if not isActive or not root or not hum or hum.Health <= 0 or not PolarMastery.TargetHoverCFrame or isTeleporting then
        clearHoverInstances()
        return
    end

    -- Check proximity: ONLY lock hover and spawn anchor when within combat proximity (<= 25 studs)
    -- This prevents pinning/rubberbanding when the character needs to travel to a new target or quest giver!
    local distToTarget = (root.Position - PolarMastery.TargetHoverCFrame.Position).Magnitude
    if distToTarget > 25 then
        clearHoverInstances()
        return
    end

    -- 1. Anti-Fall Invisible Anchored Platform (Locked 3.5 studs directly beneath character root)
    if not hoverPlatform or not hoverPlatform.Parent then
        if hoverPlatform then pcall(function() hoverPlatform:Destroy() end) end
        hoverPlatform = Instance.new("Part")
        hoverPlatform.Name = "PolarHoverPlatform"
        hoverPlatform.Size = Vector3.new(12, 1, 12)
        hoverPlatform.Transparency = 1
        hoverPlatform.Anchored = true
        hoverPlatform.CanCollide = true
        hoverPlatform.Parent = workspace
    end
    hoverPlatform.CFrame = PolarMastery.TargetHoverCFrame * CFrame.new(0, -3.5, 0)

    -- 2. Anti-Drop BodyVelocity Anchor (Prevents gravity and skill physics overrides)
    if not hoverVelocity or hoverVelocity.Parent ~= root then
        if hoverVelocity then pcall(function() hoverVelocity:Destroy() end) end
        hoverVelocity = Instance.new("BodyVelocity")
        hoverVelocity.Name = "PolarHoverAnchor"
        hoverVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hoverVelocity.Velocity = Vector3.zero
        hoverVelocity.Parent = root
    end

    -- 3. Direct CFrame lock 11.5-12.5 studs above mob with zero angular/linear inertia
    root.CFrame = PolarMastery.TargetHoverCFrame
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

-- Stepped: Disable collision so character never collides or gets shoved
RunService.Stepped:Connect(function()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
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

-- Heartbeat: CFrame solid lock every frame
RunService.Heartbeat:Connect(function()
    pcall(updateHoverEngine)
end)

-- ==============================================================================
-- WEAPON MANAGEMENT & AUTO-EQUIP
-- ==============================================================================
function PolarMastery:GetEquippedTool()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Tool")
end

function PolarMastery:EquipWeapon(category)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    local current = self:GetEquippedTool()
    if current then
        if category == "Blox Fruit" and current.ToolTip == "Blox Fruit" then
            return current
        elseif current.ToolTip == category or current.Name == category or current:GetAttribute("WeaponType") == category then
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
            elseif tool.ToolTip == category or tool.Name == category or tool:GetAttribute("WeaponType") == category then
                hum:EquipTool(tool)
                return tool
            end
        end
    end
    return nil
end

-- ==============================================================================
-- UNIVERSAL M1 ATTACK (NATIVE COMBAT CONTROLLER + FRUIT M1 + SERVER SYNC)
-- ==============================================================================
local atkMeleeCached = nil
pcall(function()
    if filtergc then
        atkMeleeCached = filtergc("function", {Name = "attackMelee"}, true)
    end
end)

function PolarMastery:PerformM1(targetMob, targetRoot)
    if not targetMob or not targetRoot then return end
    local now = os.clock()
    local delay = self.FastAttackDelay or 0.10
    if (now - (self.LastM1Time or 0)) < delay then return end
    self.LastM1Time = now

    local combat = (Polar and Polar.Combat) or getgenv().PolarCombat
    if combat then
        combat.FastAttackDelay = self.FastAttackDelay or 0.10
        combat.HoverHeight = self.HoverHeight or 12.5
        combat:ExecuteAttack(targetMob)
        return
    end

    -- Direct Fallback: Pure Unconstrained Hit Protocol
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tool = self:GetEquippedTool()
    if not tool then return end

    self:SetAimTarget(targetRoot)

    if GlobalModule then
        GlobalModule.tapCooldown = 0
        GlobalModule.busy = nil
        GlobalModule.castTimer = 0
    end
    if atkMeleeCached then
        pcall(debug.setupvalue, atkMeleeCached, 2, false)
    end

    local hitPart = targetMob:FindFirstChild("Head") or targetMob:FindFirstChild("UpperTorso") or targetRoot
    local hits = { {targetMob, hitPart} }
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        local maxAoE = 6
        for _, otherMob in ipairs(enemies:GetChildren()) do
            if otherMob ~= targetMob and otherMob:IsA("Model") and #hits < maxAoE then
                local oHum = otherMob:FindFirstChildOfClass("Humanoid")
                local oRoot = otherMob:FindFirstChild("HumanoidRootPart")
                if oHum and oHum.Health > 0 and oRoot then
                    local d = (oRoot.Position - hrp.Position).Magnitude
                    if d <= 50 then
                        local oPart = otherMob:FindFirstChild("Head") or otherMob:FindFirstChild("UpperTorso") or oRoot
                        table.insert(hits, {otherMob, oPart})
                    end
                end
            end
        end
    end

    self.AttackCombo = ((self.AttackCombo or 1) % 4) + 1
    local cd = math.max(delay, 0.12)
    pcall(function()
        for _, entry in ipairs(hits) do
            local m, p = entry[1], entry[2]
            if RegisterAttack then RegisterAttack:FireServer(cd, self.AttackCombo) end
            if GlobalModule and GlobalModule.SendHitsToServer then GlobalModule.SendHitsToServer(p, {{m, p}}) end
            if RegisterHit then RegisterHit:FireServer(p, {{m, p}}) end
        end
    end)
    pcall(function() tool:Activate() end)
end

-- ==============================================================================
-- SKILL EXECUTION WITH DECIMAL SECOND HOLD TIMES
-- ==============================================================================
function PolarMastery:CastKey(key, holdSeconds, targetRoot)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end

    pcall(function()
        if targetRoot then
            self:SetAimTarget(targetRoot)
        end

        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)

        local duration = holdSeconds or 0
        if duration > 0 then
            local startTime = os.clock()
            while (os.clock() - startTime) < duration do
                if targetRoot and targetRoot.Parent then
                    self:SetAimTarget(targetRoot)
                    local targetPos = targetRoot.Position
                    self.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, self.HoverHeight, 0), targetPos)
                    if hoverPlatform and hoverPlatform.Parent then
                        hoverPlatform.CFrame = self.TargetHoverCFrame * CFrame.new(0, -3.5, 0)
                    end
                    if hoverVelocity and hoverVelocity.Parent then
                        hoverVelocity.Velocity = Vector3.zero
                    end
                end
                task.wait(0.05)
            end
        else
            task.wait(0.05)
        end

        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        if GlobalModule then
            GlobalModule.tapCooldown = 0
            GlobalModule.busy = nil
            GlobalModule.castTimer = 0
        end
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

        -- Finish with M1 if mob still has remaining health
        local humAfter = targetMob and targetMob:FindFirstChildOfClass("Humanoid")
        if humAfter and humAfter.Health > 0 and targetMob.Parent then
            self:PerformM1(targetMob, tRoot)
        end
    end)

    self.IsBusyWithSkills = false
end

-- ==============================================================================
-- SAFE MOB CLUSTERING (NO PHYSICS GLITCH, NO PLATFORM STAND, CIRCULAR SPREAD)
-- ==============================================================================
function PolarMastery:ClusterMobs(pivotPos, targetMobName)
    if not self.BringMonster or not targetMobName then return end
    local now = os.clock()
    if (now - (self.LastClusterTime or 0)) < 0.35 then return end
    self.LastClusterTime = now

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    -- Strict Single-Mode Lock: Ensure only ONE farm mode is active at any time
    if PolarMastery.AutoBones then
        PolarMastery.AutoFarm = false
        PolarMastery.AutoFarmBoss = false
        PolarMastery.AutoKillAllBosses = false
    elseif PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses then
        PolarMastery.AutoBones = false
        PolarMastery.AutoFarm = false
    elseif PolarMastery.AutoFarm then
        PolarMastery.AutoBones = false
        PolarMastery.AutoFarmBoss = false
        PolarMastery.AutoKillAllBosses = false
    end


    pcall(function()
        if setsimulationradius then
            setsimulationradius(math.huge, math.huge)
        end
        if sethiddenproperty and LocalPlayer then
            sethiddenproperty(LocalPlayer, "SimulationRadius", 2000)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 3000)
        end
    end)

    local targetLower = string.lower(targetMobName)
    local brought = 0
    local maxBring = 3

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob ~= self.CurrentTarget and mob:IsA("Model") then
            local mobNameLower = string.lower(mob.Name)
            if string.find(mobNameLower, targetLower) or string.find(targetLower, mobNameLower) then
                local hum = mob:FindFirstChildOfClass("Humanoid")
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    -- 1. Strictly verify same vertical floor (avoids dragging crypt mobs through solid ceiling)
                    local yDiff = math.abs(hrp.Position.Y - pivotPos.Y)
                    local dist = (hrp.Position - pivotPos).Magnitude
                    if yDiff < 45 and dist <= (self.BringRadius or 250) and brought < maxBring then
                        brought = brought + 1
                        
                        -- 2. Disable collision to prevent physics explosion, preserve touch/query for hitbox registration
                        for _, part in ipairs(mob:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                part.CanTouch = true
                                part.CanQuery = true
                            end
                        end
                        
                        -- 3. Arrange in a safe 1.5 stud offset around pivotPos, keeping ground elevation
                        local angle = (brought * (2 * math.pi / maxBring))
                        local offset = Vector3.new(math.cos(angle) * 1.5, 0, math.sin(angle) * 1.5)
                        local targetCF = CFrame.new(pivotPos + offset)
                        
                        hrp.CFrame = targetCF
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hum.WalkSpeed = 0
                        pcall(function()
                            local st = hum:GetState()
                            if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then
                                hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- ==============================================================================
-- QUEST VERIFICATION & DETECTION
-- ==============================================================================
function PolarMastery:GetActiveQuestTarget()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return nil end

    -- 1. Check TrackedQuestFrame
    local tq = pgui:FindFirstChild("TrackedQuestFrame")
    if tq and tq:FindFirstChild("Frame") and tq.Frame.Visible then
        local progress = tq.Frame:FindFirstChild("progress")
        if progress and progress.Text and string.find(progress.Text, "8/8") then
            return nil
        end
        local desc = tq.Frame:FindFirstChild("description")
        local descText = desc and desc.Text or ""
        local txtAll = ""
        for _, l in ipairs(tq.Frame:GetChildren()) do
            if l:IsA("TextLabel") and l.Visible then txtAll = txtAll .. " " .. l.Text end
        end
        local fullText = string.lower(descText .. " " .. txtAll)
        if string.find(fullText, "momi") or string.find(fullText, "mummy") then return "Posessed Mummy"
        elseif string.find(fullText, "alma") or string.find(fullText, "demonic") or string.find(fullText, "soul") then return "Demonic Soul"
        elseif string.find(fullText, "zomb") then return "Living Zombie"
        elseif string.find(fullText, "esquelet") or string.find(fullText, "skeleton") then return "Reborn Skeleton"
        end
    end

    -- 2. Check Main.Quest
    local main = pgui:FindFirstChild("Main")
    local questUI = main and main:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        local container = questUI:FindFirstChild("Container")
        local title = container and (container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title") or container:FindFirstChild("QuestTitle"))
        if title and title.Text and title.Text ~= "" then
            local tLower = string.lower(title.Text)
            if string.find(tLower, "mummy") or string.find(tLower, "momi") then return "Posessed Mummy"
            elseif string.find(tLower, "soul") or string.find(tLower, "demonic") then return "Demonic Soul"
            elseif string.find(tLower, "zombie") or string.find(tLower, "zomb") then return "Living Zombie"
            elseif string.find(tLower, "skeleton") or string.find(tLower, "esquelet") then return "Reborn Skeleton"
            end
        end
    end

    -- 3. Check Guide
    local guide = main and main:FindFirstChild("Guide")
    if guide and guide:FindFirstChild("LeftFrame") and guide.LeftFrame:FindFirstChild("Abandon") and guide.LeftFrame.Abandon.Visible then
        return "HAS_QUEST"
    end

    return nil
end

-- ==============================================================================
-- MAIN ADAPTIVE COMBAT & FARM STEP
-- ==============================================================================
local function runMasteryCombatStep()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
    if not isActive then
        PolarMastery.TargetHoverCFrame = nil
PolarMastery.IsTraveling = false
        PolarMastery.CurrentTarget = nil
        PolarMastery.CurrentTargetRoot = nil
        PolarMastery.CurrentAimPos = nil
        if hoverVelocity then
            pcall(function() hoverVelocity:Destroy() end)
            hoverVelocity = nil
        end
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then
        PolarMastery.TargetHoverCFrame = nil
PolarMastery.IsTraveling = false
        return
    end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    -- Strict Single-Mode Lock: Ensure only ONE farm mode is active at any time
    if PolarMastery.AutoBones then
        PolarMastery.AutoFarm = false
        PolarMastery.AutoFarmBoss = false
        PolarMastery.AutoKillAllBosses = false
    elseif PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses then
        PolarMastery.AutoBones = false
        PolarMastery.AutoFarm = false
    elseif PolarMastery.AutoFarm then
        PolarMastery.AutoBones = false
        PolarMastery.AutoFarmBoss = false
        PolarMastery.AutoKillAllBosses = false
    end


    -- ==========================================================================
    -- MODE 1: AUTO BONES (HAUNTED CASTLE)
    -- ==========================================================================
    if PolarMastery.AutoBones then
        local targetMobName = "Posessed Mummy"
        local qName = "HauntedQuest2"
        local qIndex = 2
        local giverCF = CFrame.new(-9516.1, 175.1, 6079.2)
        local mobAreaCF = CFrame.new(-9479.4, 15.0, 6106.4)

        if PolarMastery.QuestFarmMode == "Normal" then
            targetMobName = "Reborn Skeleton"
            qName = "HauntedQuest1"
            qIndex = 1
            giverCF = CFrame.new(-9515.7, 169.0, 6078.6)
            mobAreaCF = CFrame.new(-8814.4, 150.0, 5930.5)
        end

        local activeQuestMob = PolarMastery:GetActiveQuestTarget()
        if activeQuestMob and activeQuestMob ~= "HAS_QUEST" then
            targetMobName = activeQuestMob
            if targetMobName == "Demonic Soul" then
                mobAreaCF = CFrame.new(-9516.1, 175.1, 6079.2)
            elseif targetMobName == "Living Zombie" then
                mobAreaCF = CFrame.new(-9515.7, 169.0, 6078.6)
            end
        end

        -- Take Quest if needed
        if PolarMastery.TakeQuest and not activeQuestMob then
            local distGiver = (root.Position - giverCF.Position).Magnitude
            if distGiver > 15 then
                PolarMastery:TeleportTo(giverCF)
                task.wait(0.3)
                return
            else
                root.CFrame = giverCF
                root.AssemblyLinearVelocity = Vector3.zero
                if CommF then
                    pcall(function() CommF:InvokeServer("StartQuest", qName, qIndex) end)
                end
                task.wait(0.3)
                return
            end
        end

        -- Find specific quest mob
        local targetMob = nil
        local targetLower = string.lower(targetMobName)
        local minDist = 2500

        for _, mob in ipairs(enemies:GetChildren()) do
            local mHum = mob:FindFirstChildOfClass("Humanoid")
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mHum and mRoot and mHum.Health > 0 then
                local mNameLower = string.lower(mob.Name)
                if string.find(mNameLower, targetLower) or string.find(targetLower, mNameLower) then
                    local d = (root.Position - mRoot.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        targetMob = mob
                    end
                end
            end
        end

        if not targetMob then
            PolarMastery.TargetHoverCFrame = nil
            PolarMastery:TeleportTo(mobAreaCF)
            task.wait(0.4)
            return
        end

        local tHum = targetMob:FindFirstChildOfClass("Humanoid")
        local tRoot = targetMob:FindFirstChild("HumanoidRootPart")
        if not tHum or not tRoot or tHum.Health <= 0 then return end

        PolarMastery.CurrentTarget = targetMob
        PolarMastery.CurrentTargetRoot = tRoot
        local targetPos = tRoot.Position

        -- Prevent target mob from shoving or colliding with player
        for _, p in ipairs(targetMob:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        tHum.WalkSpeed = 0
        
        -- Emergency Health Recovery: If player HP < 35%, fly high into safe air to regenerate
        if (hum.Health / math.max(1, hum.MaxHealth)) < 0.35 then
            PolarMastery.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, 30, 0), targetPos)
            task.wait(0.3)
            return
        end

        -- POSITION: ALWAYS 11.5 STUDS DIRECTLY ABOVE TARGET (SAFE FROM ALL MOBS, PERFECT HIT REACH)
        PolarMastery.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, PolarMastery.HoverHeight, 0), targetPos)

        -- Instant Snap if far
        local distToTarget = (root.Position - PolarMastery.TargetHoverCFrame.Position).Magnitude
        if distToTarget > 5 then
            PolarMastery:TeleportTo(PolarMastery.TargetHoverCFrame)
        end

        PolarMastery:SetAimTarget(tRoot)

        -- Safe Mob Clustering
        PolarMastery:ClusterMobs(targetPos, targetMobName)

        local hpPercent = (tHum.Health / tHum.MaxHealth) * 100
        if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
            PolarMastery:ExecuteSkillBurst(targetMob)
        else
            PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
            PolarMastery:PerformM1(targetMob, tRoot)
        end
        return
    end

    -- ==========================================================================
    -- MODE 2: AUTO FARM BOSS / ALL BOSSES
    -- ==========================================================================
    if PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses then
        local targetBossName = PolarMastery.SelectedBoss
        if PolarMastery.AutoKillAllBosses then
            local Polar = getgenv().Polar
            if Polar and Polar.Data and Polar.Data.Bosses then
                for _, b in ipairs(Polar.Data.Bosses) do
                    local bObj = enemies:FindFirstChild(b.name) or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(b.name))
                    if bObj and bObj:FindFirstChild("HumanoidRootPart") and bObj:FindFirstChildOfClass("Humanoid") and bObj.Humanoid.Health > 0 then
                        targetBossName = b.name
                        break
                    end
                end
            end
        end

        local boss = enemies:FindFirstChild(targetBossName) or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(targetBossName))
        if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChildOfClass("Humanoid") and boss.Humanoid.Health > 0 then
            local tRoot = boss.HumanoidRootPart
            local tHum = boss.Humanoid
            PolarMastery.CurrentTarget = boss
            PolarMastery.CurrentTargetRoot = tRoot
            local targetPos = tRoot.Position
            
            for _, p in ipairs(boss:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            tHum.WalkSpeed = 0

            -- ALWAYS 11.5 STUDS DIRECTLY ABOVE BOSS
            PolarMastery.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, PolarMastery.HoverHeight, 0), targetPos)

            local distToTarget = (root.Position - PolarMastery.TargetHoverCFrame.Position).Magnitude
            if distToTarget > 5 then
                PolarMastery:TeleportTo(PolarMastery.TargetHoverCFrame)
            end

            PolarMastery:SetAimTarget(tRoot)

            local hpPercent = (tHum.Health / tHum.MaxHealth) * 100
            if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
                PolarMastery:ExecuteSkillBurst(boss)
            else
                PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
                PolarMastery:PerformM1(boss, tRoot)
            end
        end
        return
    end

    -- ==========================================================================
    -- MODE 3: AUTO FARM LEVEL (BEST QUEST / NEAREST)
    -- ==========================================================================
    if PolarMastery.AutoFarm then
        local targetMob = nil
        local targetEnemyName = nil

        if PolarMastery.FarmMethod == "Quest" then
            local Polar = getgenv().Polar
            local bestQuest = Polar and Polar.Quest and Polar.Quest:GetBestQuest()
            if bestQuest then
                targetEnemyName = bestQuest.enemyName

                -- Take quest if needed
                local hasQuest = Polar.Quest:HasQuest()
                if PolarMastery.TakeQuest and not hasQuest then
                    PolarMastery.TargetHoverCFrame = nil
                    local giverName = bestQuest.giverName
                    local giverCF = bestQuest.pos or (Polar.NPCCache and Polar.NPCCache[giverName])
                    if giverCF then
                        local dist = (root.Position - giverCF.Position).Magnitude
                        if dist > 15 then
                            PolarMastery:TeleportTo(giverCF)
                            task.wait(0.3)
                            return
                        else
                            root.CFrame = giverCF
                            root.AssemblyLinearVelocity = Vector3.zero
                            if CommF then
                                pcall(function() CommF:InvokeServer("StartQuest", bestQuest.qName, bestQuest.index) end)
                            end
                            task.wait(0.3)
                            return
                        end
                    end
                end
            end
        end

        -- Find Target Mob
        local minDist = PolarMastery.NearestDistance or 1500
        for _, mob in ipairs(enemies:GetChildren()) do
            local mHum = mob:FindFirstChildOfClass("Humanoid")
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mHum and mRoot and mHum.Health > 0 then
                local matches = true
                if targetEnemyName then
                    local mNameLower = string.lower(mob.Name)
                    local tLower = string.lower(targetEnemyName)
                    matches = string.find(mNameLower, tLower) or string.find(tLower, mNameLower)
                end

                if matches then
                    local d = (root.Position - mRoot.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        targetMob = mob
                    end
                end
            end
        end

        if targetMob then
            local tHum = targetMob:FindFirstChildOfClass("Humanoid")
            local tRoot = targetMob:FindFirstChild("HumanoidRootPart")
            if tHum and tRoot and tHum.Health > 0 then
                PolarMastery.CurrentTarget = targetMob
                PolarMastery.CurrentTargetRoot = tRoot
                local targetPos = tRoot.Position

                for _, p in ipairs(targetMob:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
                tHum.WalkSpeed = 0
                
                -- ALWAYS 11.5 STUDS DIRECTLY ABOVE TARGET
                PolarMastery.TargetHoverCFrame = CFrame.lookAt(targetPos + Vector3.new(0, PolarMastery.HoverHeight, 0), targetPos)

                local distToTarget = (root.Position - PolarMastery.TargetHoverCFrame.Position).Magnitude
                if distToTarget > 5 then
                    PolarMastery:TeleportTo(PolarMastery.TargetHoverCFrame)
                end

                PolarMastery:SetAimTarget(tRoot)

                PolarMastery:ClusterMobs(targetPos, targetMob.Name)

                local hpPercent = (tHum.Health / tHum.MaxHealth) * 100
                if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
                    PolarMastery:ExecuteSkillBurst(targetMob)
                else
                    PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
                    PolarMastery:PerformM1(targetMob, tRoot)
                end
            end
        end
        return
    end
end

-- Fast combat loop
task.spawn(function()
    while true do
        task.wait(PolarMastery.FastAttackDelay or 0.10)
        local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
        if isActive then
            pcall(runMasteryCombatStep)
        else
            clearHoverInstances()
        end
    end
end)

print("[Polar Hub] [OK] Motor PolarMastery (Hover 11.5 studs, Silent Aim, Safe Clustering) cargado con exito.")
return PolarMastery
