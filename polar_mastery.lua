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

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = nil
pcall(function() Mouse = LocalPlayer:GetMouse() end)

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

local function getMouseModule()
    if not MouseModule then
        pcall(function()
            local m = ReplicatedStorage:FindFirstChild("Mouse")
            if m then MouseModule = require(m) end
        end)
    end
    return MouseModule
end

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
    Z = 0.4,
    X = 0.6,
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

-- Mechanics & Hover Lock (Safe above melee reach while staying in hit range)
PolarMastery.BringMonster = true
PolarMastery.BringRadius = 250
PolarMastery.HoverHeight = 16.5
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
-- PURE SILENT AIM & ADVANCED INTERNAL VIRTUAL MOUSE ENGINE (MULTI-LAYER INTERCEPTION)
-- ZERO PHYSICAL MOUSE HIJACKING - USER CURSOR STAYS 100% FREE TO MOVE ANYWHERE
-- ==============================================================================

-- Desactivar cualquier handler previo de namecall (previene recursión C-stack de sesiones anteriores)
getgenv().__PolarAimNamecallHandler = nil

-- SAFE & LIGHTWEIGHT METAMETHOD HOOK FOR game.__index (PLAYERMOUSE SILENT AIM)
-- Reglas estrictas: solo key == "Hit" y key == "Target", ZERO llamadas a engine methods o WorldToViewportPoint
pcall(function()
    getgenv().__PolarAimIndexHandler = function(self, key, oldIndex)
        if key == "Hit" or key == "Target" then
            local pm = getgenv().PolarMastery
            if pm and pm.CurrentAimPos then
                local pMouse = Mouse
                if not pMouse and LocalPlayer then
                    pcall(function() Mouse = LocalPlayer:GetMouse(); pMouse = Mouse end)
                end
                if self == pMouse then
                    if key == "Hit" then
                        return CFrame.new(pm.CurrentAimPos)
                    elseif key == "Target" then
                        return pm.CurrentTargetRoot
                    end
                end
            end
        end
        return oldIndex(self, key)
    end

    if hookmetamethod and not getgenv().__PolarAimHooked then
        getgenv().__PolarAimHooked = true
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if getgenv().__PolarAimIndexHandler then
                return getgenv().__PolarAimIndexHandler(self, key, oldIndex)
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

    -- Sincronizar ReplicatedStorage.Mouse con coordenadas del objetivo
    local mm = getMouseModule()
    if mm and type(mm) == "table" then
        pcall(function()
            mm.Hit = CFrame.new(aimPos)
            mm.Target = targetRoot
        end)
    end

    -- Sincronizar Vector3Value MousePos en Tool y Character
    local tool = self:GetEquippedTool()
    if tool then
        local mousePos = tool:FindFirstChild("MousePos") or tool:FindFirstChild("Mouse")
        if mousePos and mousePos:IsA("Vector3Value") then
            mousePos.Value = aimPos
        end
    end
    local char = LocalPlayer.Character
    if char then
        local charMousePos = char:FindFirstChild("MousePos") or char:FindFirstChild("Mouse")
        if charMousePos and charMousePos:IsA("Vector3Value") then
            charMousePos.Value = aimPos
        end
    end

    -- Orientación horizontal segura: solo aplicar si la distancia horizontal > 1.5 studs
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local deltaX = aimPos.X - root.Position.X
        local deltaZ = aimPos.Z - root.Position.Z
        if (deltaX * deltaX + deltaZ * deltaZ) > 2.25 then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(aimPos.X, root.Position.Y, aimPos.Z))
        end
    end
end

-- ==============================================================================
-- CONTINUOUS ANTI-FALL HOVER LOCK & MOB CLUSTERING STATE
-- ==============================================================================
local hoverVelocity = nil
local cachedCharRef = nil
local cachedCharParts = {}
local savedCharCanCollide = {}
local charDescAddedConn = nil
PolarMastery.ClusterCenterPos = nil
PolarMastery.ActiveClusterMobs = {}

local function trackHoverCharPart(inst)
    if inst and inst:IsA("BasePart") and savedCharCanCollide[inst] == nil then
        savedCharCanCollide[inst] = inst.CanCollide
        table.insert(cachedCharParts, inst)
    end
end

local function ensureHoverCharCache(char)
    if not char then return end
    if cachedCharRef ~= char then
        if charDescAddedConn then
            pcall(function() charDescAddedConn:Disconnect() end)
            charDescAddedConn = nil
        end
        cachedCharRef = char
        cachedCharParts = {}
        savedCharCanCollide = {}
        for _, v in ipairs(char:GetDescendants()) do
            trackHoverCharPart(v)
        end
        charDescAddedConn = char.DescendantAdded:Connect(trackHoverCharPart)
    end
end

local function restoreHoverCharCollisions()
    if next(savedCharCanCollide) == nil then return end
    for part, orig in pairs(savedCharCanCollide) do
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function() part.CanCollide = orig end)
        end
    end
    cachedCharRef = nil
    cachedCharParts = {}
    savedCharCanCollide = {}
    if charDescAddedConn then
        pcall(function() charDescAddedConn:Disconnect() end)
        charDescAddedConn = nil
    end
end

local function clearHoverInstances()
    if hoverVelocity and hoverVelocity.Parent then
        pcall(function() hoverVelocity:Destroy() end)
    end
    hoverVelocity = nil
    PolarMastery.ClusterCenterPos = nil
    PolarMastery.ActiveClusterMobs = {}
    restoreHoverCharCollisions()
end

local function needsPortalOrDimensionJump(fromPos, toPos)
    if not fromPos or not toPos then return false end
    if (fromPos.X > 50000) ~= (toPos.X > 50000) then return true end
    if (fromPos.Z > 25000) ~= (toPos.Z > 25000) then return true end
    local fromSub = fromPos.Y < -1000 and (Vector2.new(fromPos.X - 10533, fromPos.Z - 9940).Magnitude < 4500)
    local toSub = toPos.Y < -1000 and (Vector2.new(toPos.X - 10533, toPos.Z - 9940).Magnitude < 4500)
    if fromSub ~= toSub then return true end
    local domCenter = Vector3.new(5366.5, 71.1, -225.9)
    local fromDom = fromPos.Y >= -50 and fromPos.Y <= 250 and (fromPos - domCenter).Magnitude <= 320
    local toDom = toPos.Y >= -50 and toPos.Y <= 250 and (toPos - domCenter).Magnitude <= 320
    if fromDom ~= toDom then return true end
    return false
end

-- ==============================================================================
-- NETWORK OWNERSHIP & CLEAN MOB STATE TRACKING
-- ==============================================================================
local savedMobStates = {}
local unhittableUntil = {}
local targetDamageWatch = {}

local function isMobOwned(hrp)
    if not hrp or not hrp.Parent then return false end
    if isnetworkowner then
        local ok, owned = pcall(isnetworkowner, hrp)
        return ok and (owned == true)
    end
    local char = LocalPlayer.Character
    local pRoot = char and char:FindFirstChild("HumanoidRootPart")
    return (pRoot and (hrp.Position - pRoot.Position).Magnitude <= 35) or false
end

local function recordAndLockMobState(mob, hum)
    local entry = savedMobStates[mob]
    if not entry then
        entry = {
            hum = hum,
            ws = (hum.WalkSpeed and hum.WalkSpeed > 0) and hum.WalkSpeed or 30,
            jp = (hum.JumpPower and hum.JumpPower > 0) and hum.JumpPower or 50,
            parts = {}
        }
        for _, part in ipairs(mob:GetChildren()) do
            if part:IsA("BasePart") then
                entry.parts[part] = part.CanCollide
            end
        end
        savedMobStates[mob] = entry
    end

    for _, part in ipairs(mob:GetChildren()) do
        if part:IsA("BasePart") then
            if entry.parts[part] == nil then
                entry.parts[part] = part.CanCollide
            end
            part.CanCollide = false
            part.CanTouch = true
            part.CanQuery = true
        end
    end

    hum.WalkSpeed = 0
    hum.JumpPower = 0
end

local function releaseMob(mob)
    local entry = savedMobStates[mob]
    savedMobStates[mob] = nil
    if not mob or not mob.Parent then return end

    local hum = (entry and entry.hum) or mob:FindFirstChildOfClass("Humanoid")
    if hum and hum.Parent then
        local targetWS = (entry and entry.ws and entry.ws > 0) and entry.ws or 30
        local targetJP = (entry and entry.jp and entry.jp > 0) and entry.jp or 50
        pcall(function()
            hum.WalkSpeed = targetWS
            hum.JumpPower = targetJP
        end)
    end

    if entry and entry.parts then
        for part, origCollide in pairs(entry.parts) do
            if part and part.Parent then
                pcall(function()
                    part.CanCollide = (origCollide ~= nil) and origCollide or true
                    part.CanTouch = true
                    part.CanQuery = true
                end)
            end
        end
    else
        for _, part in ipairs(mob:GetChildren()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = true
                    part.CanTouch = true
                    part.CanQuery = true
                end)
            end
        end
    end
end

local function releaseAllTrackedMobs()
    local toRelease = {}
    for mob in pairs(savedMobStates) do
        table.insert(toRelease, mob)
    end
    for _, mob in ipairs(toRelease) do
        releaseMob(mob)
    end
    if PolarMastery.ActiveClusterMobs then
        for _, mob in ipairs(PolarMastery.ActiveClusterMobs) do
            releaseMob(mob)
        end
    end
    PolarMastery.ActiveClusterMobs = {}
    table.clear(targetDamageWatch)
end

-- ==============================================================================
-- SAFE TELEPORTATION HELPER
-- ==============================================================================
function PolarMastery:TeleportTo(cf)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not cf then return end
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end

    local dist = (root.Position - cf.Position).Magnitude
    local crossDim = needsPortalOrDimensionJump(root.Position, cf.Position)
    if dist <= 4 and not crossDim then return end

    -- Solo snap directo para micro-ajustes locales (<= 40 studs) sin salir de rango de servidor
    if dist <= 40 and not crossDim then
        root.CFrame = cf
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        return
    end

    -- Distancias medianas/largas o cambios de dimension/portal: delegar al tween seguro de Polar.Teleport
    self.IsTraveling = true
    self.TargetHoverCFrame = nil
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
    self.ClusterCenterPos = nil
    self.CurrentTarget = nil
    self.CurrentTargetRoot = nil
    self.CurrentAimPos = nil
    self.IsBusyWithSkills = false
    getgenv().PolarAutoFarmEnabled = false
    getgenv().PolarAutoBonesEnabled = false
    getgenv().PolarFastAttackEnabled = false

    releaseAllTrackedMobs()
    clearHoverInstances()
    restoreHoverCharCollisions()

    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    local Polar = getgenv().Polar
    local combat = (Polar and Polar.Combat) or getgenv().PolarCombat
    if combat then
        combat:ReleaseHover()
        combat.Enabled = false
    end

    pcall(function()
        local PolarUI = getgenv().PolarUI or (Polar and Polar.UI)
        if PolarUI and PolarUI.Notify then
            PolarUI:Notify({
                Title = "Polar Hub",
                Content = "Auto Farm deactivated.",
                Duration = 2
            })
        end
    end)
end

-- Inmovilizador continuo de NPCs (solo cuando el cliente tiene network ownership real)
local function stabilizeClusterMobs()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
    if not isActive or not PolarMastery.ActiveClusterMobs then return end

    -- Si CurrentTarget no tiene network ownership, seguir su posicion real en el servidor
    local curTarget = PolarMastery.CurrentTarget
    if curTarget and curTarget.Parent then
        local cHum = curTarget:FindFirstChildOfClass("Humanoid")
        local cRoot = curTarget:FindFirstChild("HumanoidRootPart")
        if cHum and cHum.Health > 0 and cRoot and not isMobOwned(cRoot) then
            PolarMastery.ClusterCenterPos = cRoot.Position
            if PolarMastery.TargetHoverCFrame and not PolarMastery.IsTraveling then
                PolarMastery.TargetHoverCFrame = CFrame.new(cRoot.Position + Vector3.new(0, PolarMastery.HoverHeight or 16.5, 0))
            end
        end
    end

    local cluster = PolarMastery.ActiveClusterMobs
    local center = PolarMastery.ClusterCenterPos
    if not center or #cluster == 0 then return end

    -- Filtrar primero los mobs que realmente poseen network ownership
    local ownedMobs = {}
    for _, mob in ipairs(cluster) do
        if mob and mob.Parent and mob:IsA("Model") then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and isMobOwned(hrp) then
                table.insert(ownedMobs, mob)
            elseif savedMobStates[mob] then
                releaseMob(mob)
            end
        elseif savedMobStates[mob] then
            releaseMob(mob)
        end
    end

    local ownedCount = #ownedMobs
    for i, mob in ipairs(ownedMobs) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            for _, ch in ipairs(hrp:GetChildren()) do
                if ch:IsA("BodyVelocity") or ch:IsA("BodyPosition") or ch:IsA("BodyGyro") or ch:IsA("BodyThrust")
                   or ch:IsA("LinearVelocity") or ch:IsA("VectorForce") or ch:IsA("AlignPosition") or ch:IsA("AlignOrientation") then
                    pcall(function() ch:Destroy() end)
                end
            end

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            local angle = (i - 1) * (2 * math.pi / math.max(1, ownedCount))
            local offset = (ownedCount > 1) and Vector3.new(math.cos(angle) * 0.75, 0, math.sin(angle) * 0.75) or Vector3.zero
            hrp.CFrame = CFrame.new(center + offset)

            recordAndLockMobState(mob, hum)

            pcall(function()
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                end
            end)
        end
    end
end

local function updateHoverEngine()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local Polar = getgenv().Polar
    local isTeleporting = (Polar and Polar.Teleport and Polar.Teleport.IsTeleporting) or PolarMastery.IsTraveling
    if not isActive or not root or not hum or hum.Health <= 0 or not PolarMastery.TargetHoverCFrame or isTeleporting then
        clearHoverInstances()
        return
    end

    -- Ancla BodyVelocity cinemtico permanente (inmune a cambios de fruta o animaciones)
    if not hoverVelocity or hoverVelocity.Parent ~= root then
        if hoverVelocity then pcall(function() hoverVelocity:Destroy() end) end
        hoverVelocity = Instance.new("BodyVelocity")
        hoverVelocity.Name = "PolarHoverAnchor"
        hoverVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hoverVelocity.Velocity = Vector3.zero
        hoverVelocity.Parent = root
    end

    -- Fijacin directa sin oscilacin
    root.CFrame = PolarMastery.TargetHoverCFrame
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    -- Prevenir estados de cada libre generados por herramientas de fruta
    pcall(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end)
end

-- Limpieza y registro de conexiones seguras para recarga en vivo
if PolarMastery._Connections then
    for _, conn in ipairs(PolarMastery._Connections) do
        pcall(function() conn:Disconnect() end)
    end
end
PolarMastery._Connections = {}

-- Stepped: Sin colisiones usando cache de partes y estabilizacion previa a la fisica
table.insert(PolarMastery._Connections, RunService.Stepped:Connect(function()
    local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
    if isActive and PolarMastery.TargetHoverCFrame then
        local char = LocalPlayer.Character
        if char then
            ensureHoverCharCache(char)
            for _, part in ipairs(cachedCharParts) do
                if part.Parent then
                    part.CanCollide = false
                end
            end
        end
        pcall(stabilizeClusterMobs)
    else
        restoreHoverCharCollisions()
    end
end))

-- Heartbeat: CFrame solid lock y estabilización posterior
table.insert(PolarMastery._Connections, RunService.Heartbeat:Connect(function()
    pcall(updateHoverEngine)
    pcall(stabilizeClusterMobs)
end))

-- RenderStepped: Sincronización continua de Mouse Virtual interno
table.insert(PolarMastery._Connections, RunService.RenderStepped:Connect(function()
    local pm = getgenv().PolarMastery
    if pm and pm.CurrentAimPos then
        local aimPos = pm.CurrentAimPos
        local targetRoot = pm.CurrentTargetRoot

        -- Sincronizar ReplicatedStorage.Mouse
        local mm = getMouseModule()
        if mm and type(mm) == "table" then
            pcall(function()
                mm.Hit = CFrame.new(aimPos)
                if targetRoot then
                    mm.Target = targetRoot
                end
            end)
        end

        -- Sincronizar Vector3Value MousePos en Tool y Character
        local tool = pm:GetEquippedTool()
        if tool then
            local mousePos = tool:FindFirstChild("MousePos") or tool:FindFirstChild("Mouse")
            if mousePos and mousePos:IsA("Vector3Value") then
                mousePos.Value = aimPos
            end
        end
        local char = LocalPlayer.Character
        if char then
            local charMousePos = char:FindFirstChild("MousePos") or char:FindFirstChild("Mouse")
            if charMousePos and charMousePos:IsA("Vector3Value") then
                charMousePos.Value = aimPos
            end
        end
    end
end))

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
            if (category == "Blox Fruit" and tool.ToolTip == "Blox Fruit")
                or tool.ToolTip == category or tool.Name == category or tool:GetAttribute("WeaponType") == category then
                hum:EquipTool(tool)
                task.wait(0.15)
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
    local minCooldown = math.max(0.04, delay * 0.5)
    if (now - (self.LastM1Time or 0)) < minCooldown then return end
    self.LastM1Time = now

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
    local hits = {}
    if (targetRoot.Position - hrp.Position).Magnitude <= 55 then
        table.insert(hits, {targetMob, hitPart})
    end

    -- 1. Incluir otros NPCs del cluster activo que realmente esten dentro del alcance cuerpo a cuerpo
    if self.ActiveClusterMobs then
        for _, cMob in ipairs(self.ActiveClusterMobs) do
            if #hits >= 6 then break end
            if cMob ~= targetMob and cMob:IsA("Model") and cMob.Parent then
                local cHum = cMob:FindFirstChildOfClass("Humanoid")
                local cRoot = cMob:FindFirstChild("HumanoidRootPart")
                if cHum and cHum.Health > 0 and cRoot and (cRoot.Position - hrp.Position).Magnitude <= 55 then
                    local cPart = cMob:FindFirstChild("Head") or cMob:FindFirstChild("UpperTorso") or cRoot
                    table.insert(hits, {cMob, cPart})
                end
            end
        end
    end

    -- 2. Escanear enemigos cercanos si hay menos de 4
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies and #hits < 4 then
        for _, otherMob in ipairs(enemies:GetChildren()) do
            if #hits >= 6 then break end
            if otherMob ~= targetMob and otherMob:IsA("Model") then
                local isAlready = false
                for _, existing in ipairs(hits) do
                    if existing[1] == otherMob then isAlready = true break end
                end
                if not isAlready then
                    local oHum = otherMob:FindFirstChildOfClass("Humanoid")
                    local oRoot = otherMob:FindFirstChild("HumanoidRootPart")
                    if oHum and oHum.Health > 0 and oRoot then
                        local d = (oRoot.Position - hrp.Position).Magnitude
                        if d <= 55 then
                            local oPart = otherMob:FindFirstChild("Head") or otherMob:FindFirstChild("UpperTorso") or oRoot
                            table.insert(hits, {otherMob, oPart})
                        end
                    end
                end
            end
        end
    end

    if #hits == 0 then return end

    self.AttackCombo = ((self.AttackCombo or 1) % 4) + 1
    local cd = math.max(delay, 0.12)
    local combo = self.AttackCombo

    -- Despacho mediante CombatUtil/Global con token de sesion v3 (evitar RegisterHit crudo sin v3)
    pcall(function()
        if RegisterAttack then RegisterAttack:FireServer(cd, combo) end
        if GlobalModule and GlobalModule.SendHitsToServer then
            GlobalModule.SendHitsToServer(hits[1][2], hits)
        elseif RegisterHit then
            RegisterHit:FireServer(hits[1][2], hits)
        end
    end)

    -- Activacion nativa del arma / M1 de fruta
    local isFruit = tool.ToolTip == "Blox Fruit" or tool:GetAttribute("WeaponType") == "Demon Fruit"
    if isFruit then
        pcall(function()
            local mousePos = tool:FindFirstChild("MousePos") or tool:FindFirstChild("Mouse")
            if mousePos and mousePos:IsA("Vector3Value") then
                mousePos.Value = hitPart.Position
            end
            local remFunc = tool:FindFirstChild("RemoteFunction") or tool:FindFirstChildWhichIsA("RemoteFunction")
            if remFunc then
                task.spawn(function()
                    pcall(function() remFunc:InvokeServer("TAP", nil, hitPart.Position) end)
                end)
            end
            local remEvent = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteEvent")
            if remEvent then remEvent:FireServer(hitPart.Position) end
            tool:Activate()
        end)
    else
        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end
            tool:Activate()
        end)
    end
end

-- ==============================================================================
-- SKILL EXECUTION VIA MOVESET CLIENT RUNNER (SAFE NO-CAPABILITY FALLBACK)
-- ==============================================================================
function PolarMastery:CastKey(key, holdSeconds, targetRoot)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return false end

    local activated = false
    pcall(function()
        if targetRoot then
            self:SetAimTarget(targetRoot)
        end

        local tool = self:GetEquippedTool()
        if GlobalModule and type(GlobalModule.casFunc) == "function" and tool then
            local ev = Instance.new("BindableEvent")
            local fakeInput = {
                UserInputState = Enum.UserInputState.Begin,
                KeyCode = keyCode,
                UserInputType = Enum.UserInputType.Keyboard,
                Changed = ev.Event
            }

            GlobalModule.casFunc("DevilFruit", Enum.UserInputState.Begin, fakeInput)
            task.wait(0.08)
            activated = (GlobalModule.busy ~= nil and GlobalModule.busy ~= false)

            local duration = math.min(holdSeconds or 0, 0.8)
            if activated and duration > 0.08 then
                local startTime = os.clock()
                while (os.clock() - startTime) < duration and GlobalModule.busy do
                    local center = self.ClusterCenterPos or (targetRoot and targetRoot.Parent and targetRoot.Position)
                    if center then
                        self.TargetHoverCFrame = CFrame.new(center + Vector3.new(0, self.HoverHeight or 16.5, 0))
                    end
                    if hoverVelocity and hoverVelocity.Parent then
                        hoverVelocity.Velocity = Vector3.zero
                    end
                    task.wait(0.04)
                end
            end

            fakeInput.UserInputState = Enum.UserInputState.End
            pcall(function() ev:Fire("UserInputState") end)
            pcall(function() GlobalModule.casFunc("DevilFruit", Enum.UserInputState.End, fakeInput) end)
            ev:Destroy()
        else
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(math.min(holdSeconds or 0.05, 0.3))
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                activated = true
            end)
        end

        if GlobalModule then
            GlobalModule.tapCooldown = 0
            GlobalModule.busy = nil
            GlobalModule.castTimer = 0
        end
    end)

    return activated
end

-- Verificacin en tiempo real de cooldown de habilidades
function PolarMastery:IsSkillReady(key)
    local tool = self:GetEquippedTool()
    if not tool then return true end

    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pgui and pgui:FindFirstChild("Main")
    local skills = main and main:FindFirstChild("Skills")
    if not skills then return true end

    local toolSkills = skills:FindFirstChild(tool.Name)
    if not toolSkills then
        for _, ch in ipairs(skills:GetChildren()) do
            if ch:FindFirstChild(key) then
                toolSkills = ch
                break
            end
        end
    end

    if toolSkills then
        local kFrame = toolSkills:FindFirstChild(key)
        if kFrame then
            local cd = kFrame:FindFirstChild("Cooldown")
            if cd and cd.Visible and cd.Size.X.Scale > 0.05 then
                return false -- En cooldown!
            end
        end
    end

    return true -- Lista para lanzar!
end

function PolarMastery:ExecuteSkillBurst(targetMob)
    if self.IsBusyWithSkills then return end
    self.IsBusyWithSkills = true

    pcall(function()
        local tRoot = targetMob:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end

        local now = os.clock()
        if (now - (self.LastSkillBurstAttempt or 0)) < 1.2 then
            self:EquipWeapon(self.PrimaryWeapon)
            self:PerformM1(targetMob, tRoot)
            return
        end
        self.LastSkillBurstAttempt = now

        -- 1. Equipar objetivo de maestria brevemente
        local masteryTool = self:EquipWeapon(self.MasteryTarget)
        if not masteryTool then
            self:EquipWeapon(self.PrimaryWeapon)
            self:PerformM1(targetMob, tRoot)
            return
        end

        -- 2. Seleccionar teclas correspondientes
        local keys = self.BloxFruitKeys
        if self.MasteryTarget == "Melee" then keys = self.MeleeKeys
        elseif self.MasteryTarget == "Sword" then keys = self.SwordKeys
        elseif self.MasteryTarget == "Gun" then keys = self.GunKeys
        end

        local delay = self.SkillDelays[self.MasteryTarget] or 0

        -- Intentar a lo sumo 1 habilidad lista para no bloquear M1 durante segundos
        local launchedAny = false
        for _, key in ipairs(keys) do
            local hum = targetMob and targetMob:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or not targetMob.Parent then break end

            if self:IsSkillReady(key) then
                local holdSec = self.HoldTimes[key] or 0
                local okCast = self:CastKey(key, holdSec, tRoot)
                if okCast then
                    launchedAny = true
                    if delay > 0 then task.wait(delay) end
                    break
                end
            end
        end

        -- Re-equipar arma primaria y rematar inmediatamente con M1 si el NPC sigue vivo
        local hum = targetMob and targetMob:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and targetMob.Parent then
            self:EquipWeapon(self.PrimaryWeapon)
            self:PerformM1(targetMob, tRoot)
        end
    end)

    self.IsBusyWithSkills = false
end

-- ==============================================================================
-- SAFE MOB CLUSTERING & SEA 1 ALIASES
-- ==============================================================================
local MASTERY_ENEMY_ALIASES = {
    {"chef", "bobby"},
    {"magma admiral", "magma general"},
    {"wysper", "sky warlord"},
    {"mob leader", "mob boss"},
    {"posessed mummy", "possessed mummy"},
    {"pirate millionaire", "pirata millonario"},
    {"pistol billionaire", "pistolero multimillonario"},
    {"dragon crew warrior", "guerrero de la tripulacion dragon"},
    {"dragon crew archer", "arquero de la tripulacion dragon"},
    {"forest pirate", "pirata del bosque"},
    {"mythological pirate", "pirata mitologico"},
    {"jungle pirate", "pirata de la jungla"},
    {"musketeer pirate", "pirata mosquetero"},
    {"reborn skeleton", "esqueleto renacido"},
    {"living zombie", "zombi viviente"},
    {"demonic soul", "alma demoniaca"},
    {"posessed mummy", "momia poseida"},
    {"peanut scout", "explorador de mani"},
    {"peanut president", "presidente de mani"},
    {"ice cream chef", "chef de helados"},
    {"ice cream commander", "comandante de helados"},
    {"cookie crafter", "creador de galletas"},
    {"cake guard", "guardia del pastel"},
    {"baking staff", "personal de panaderia"},
    {"head baker", "jefe panadero"},
    {"cocoa warrior", "guerrero del cacao"},
    {"chocolate bar battler", "luchador de barra de chocolate"},
    {"sweet thief", "ladron de dulces"},
    {"candy rebel", "rebelde de caramelo"},
    {"candy pirate", "pirata de caramelo"},
    {"snow demon", "demonio de nieve"},
    {"isle outlaw", "forajido de la isla"},
    {"island boy", "chico de la isla"},
    {"sun-kissed warrior", "guerrero bronceado"},
    {"isle champion", "campeon de la isla"},
    {"serpent hunter", "cazador de serpientes"},
    {"skull slayer", "asesino de calaveras"},
    {"reef bandit", "bandido del arrecife"},
    {"coral pirate", "pirata de coral"},
    {"sea chanter", "cantor del mar"},
    {"ocean prophet", "profeta del oceano"},
    {"high disciple", "alto discipulo"},
    {"grand devotee", "gran devoto"}
}

local function MatchesEnemyName(mobName, targetName)
    if not mobName or not targetName then return false end
    if mobName == targetName then return true end
    local mobLower = string.lower(mobName)
    local targetLower = string.lower(targetName)
    if string.find(mobLower, targetLower, 1, true) then
        if targetLower == "gorilla" and string.find(mobLower, "king", 1, true) then return false end
        if targetLower == "bandit" and (string.find(mobLower, "desert", 1, true) or string.find(mobLower, "snow", 1, true) or string.find(mobLower, "sky", 1, true)) then return false end
        if targetLower == "prisoner" and (string.find(mobLower, "dangerous", 1, true) or string.find(mobLower, "ruthless", 1, true)) then return false end
        if targetLower == "warden" and (string.find(mobLower, "chief", 1, true) or string.find(mobLower, "ruthless", 1, true)) then return false end
        if targetLower == "pirate" and (string.find(mobLower, "galley", 1, true) or string.find(mobLower, "beautiful", 1, true)) then return false end
        return true
    end
    for _, pair in ipairs(MASTERY_ENEMY_ALIASES) do
        if (targetLower == pair[1] and string.find(mobLower, pair[2], 1, true))
            or (targetLower == pair[2] and string.find(mobLower, pair[1], 1, true))
            or (string.find(targetLower, pair[1], 1, true) and string.find(mobLower, pair[2], 1, true))
            or (string.find(targetLower, pair[2], 1, true) and string.find(mobLower, pair[1], 1, true)) then
            return true
        end
    end
    return false
end

local function SafeMasteryTeleport(cf, root)
    PolarMastery:TeleportTo(cf)
end

function PolarMastery:ClusterMobs(pivotPos, targetMobName)
    if not targetMobName or not pivotPos then return end
    local now = os.clock()
    if (now - (self.LastClusterTime or 0)) < 0.25 then return end
    self.LastClusterTime = now

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    pcall(function()
        if setsimulationradius then
            setsimulationradius(math.huge, math.huge)
        end
        if sethiddenproperty and LocalPlayer then
            sethiddenproperty(LocalPlayer, "SimulationRadius", 2000)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 3000)
        end
    end)

    local cluster = {}
    if self.CurrentTarget and self.CurrentTarget.Parent then
        local cHum = self.CurrentTarget:FindFirstChildOfClass("Humanoid")
        local cHrp = self.CurrentTarget:FindFirstChild("HumanoidRootPart")
        if cHum and cHum.Health > 0 and cHrp and isMobOwned(cHrp) then
            table.insert(cluster, self.CurrentTarget)
        elseif savedMobStates[self.CurrentTarget] then
            releaseMob(self.CurrentTarget)
        end
    end

    local maxTotal = 4 -- Estrictamente 3 a 4 mobs en total con ownership real

    if self.BringMonster then
        local nowCluster = os.clock()
        for _, mob in ipairs(enemies:GetChildren()) do
            if #cluster >= maxTotal then break end
            if mob ~= self.CurrentTarget and mob:IsA("Model") and (unhittableUntil[mob] or 0) <= nowCluster then
                if MatchesEnemyName(mob.Name, targetMobName) then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and hrp then
                        local yDiff = math.abs(hrp.Position.Y - pivotPos.Y)
                        local dist = (hrp.Position - pivotPos).Magnitude
                        if yDiff < 45 and dist <= (self.BringRadius or 250) and isMobOwned(hrp) then
                            table.insert(cluster, mob)
                        elseif savedMobStates[mob] then
                            releaseMob(mob)
                        end
                    end
                end
            end
        end
    end

    -- Liberar mobs que ya salieron del cluster activo para evitar NPCs congelados/desincronizados
    local inCluster = {}
    for _, mob in ipairs(cluster) do
        inCluster[mob] = true
    end
    local stale = {}
    for mob in pairs(savedMobStates) do
        if not inCluster[mob] then
            table.insert(stale, mob)
        end
    end
    for _, mob in ipairs(stale) do
        releaseMob(mob)
    end

    self.ActiveClusterMobs = cluster
end

-- ==============================================================================
-- QUEST VERIFICATION & DETECTION
-- ==============================================================================
function PolarMastery:GetActiveQuestTarget()
    local Polar = getgenv().Polar
    if Polar and Polar.QuestEngine and Polar.QuestEngine.HasActiveQuest then
        if not Polar.QuestEngine:HasActiveQuest() then
            return nil
        end
        if Polar.Quest and Polar.Quest.GetTargetEnemyNameFromQuest then
            local resolved = Polar.Quest:GetTargetEnemyNameFromQuest()
            if resolved and resolved ~= "" then
                return resolved
            end
        end
    end

    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return nil end

    -- Fallback directo a TrackedQuestFrame (incluye objective:* rows)
    local tq = pgui:FindFirstChild("TrackedQuestFrame")
    if tq and tq:FindFirstChild("Frame") and tq.Frame.Visible then
        local progress = tq.Frame:FindFirstChild("progress")
        if progress and progress.Text then
            local c, m = string.match(progress.Text, "(%d+)%s*/%s*(%d+)")
            if c and m and tonumber(c) >= tonumber(m) then
                return nil
            end
        end
        local parts = {}
        for _, child in ipairs(tq.Frame:GetChildren()) do
            if string.sub(child.Name, 1, 10) == "objective:" then
                local lbl = child:FindFirstChild("label")
                if lbl and lbl:IsA("TextLabel") and lbl.Text ~= "" then
                    table.insert(parts, lbl.Text)
                end
            elseif child:IsA("TextLabel") and child.Visible and child.Text ~= "" then
                table.insert(parts, child.Text)
            end
        end
        local fullText = string.lower(table.concat(parts, " "))
        if string.find(fullText, "momi") or string.find(fullText, "mummy") then return "Posessed Mummy"
        elseif string.find(fullText, "alma") or string.find(fullText, "demonic") or string.find(fullText, "soul") then return "Demonic Soul"
        elseif string.find(fullText, "zomb") then return "Living Zombie"
        elseif string.find(fullText, "esquelet") or string.find(fullText, "skeleton") then return "Reborn Skeleton"
        end
    end

    -- Fallback Main.Quest
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
            return title.Text
        end
    end

    local guide = main and main:FindFirstChild("Guide")
    if guide and guide:FindFirstChild("LeftFrame") and guide.LeftFrame:FindFirstChild("Abandon") and guide.LeftFrame.Abandon.Visible then
        return "HAS_QUEST"
    end

    return nil
end

-- ==============================================================================
-- MAIN ADAPTIVE COMBAT & FARM STEP
-- ==============================================================================
local function findNearestMob(enemiesFolder, originPos, maxDist, enemyName)
    local now = os.clock()
    local bestFresh, minFreshDist = nil, maxDist
    local bestFallback, minFallbackDist = nil, maxDist

    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        local mHum = mob:FindFirstChildOfClass("Humanoid")
        local mRoot = mob:FindFirstChild("HumanoidRootPart")
        if mHum and mRoot and mHum.Health > 0 then
            local matches = true
            if enemyName then
                matches = MatchesEnemyName(mob.Name, enemyName)
            end
            if matches then
                local d = (originPos - mRoot.Position).Magnitude
                if (unhittableUntil[mob] or 0) > now then
                    if d < minFallbackDist then
                        minFallbackDist = d
                        bestFallback = mob
                    end
                elseif d < minFreshDist then
                    minFreshDist = d
                    bestFresh = mob
                end
            end
        end
    end

    if bestFresh then return bestFresh end
    return bestFallback
end

local function engageCombatTarget(targetMob, root, clusterName, useClustering)
    local tHum = targetMob:FindFirstChildOfClass("Humanoid")
    local tRoot = targetMob:FindFirstChild("HumanoidRootPart")
    if not tHum or not tRoot or tHum.Health <= 0 then return end

    local prevTarget = PolarMastery.CurrentTarget
    PolarMastery.CurrentTarget = targetMob
    PolarMastery.CurrentTargetRoot = tRoot
    local targetPos = tRoot.Position

    local owned = isMobOwned(tRoot)
    if useClustering then
        if not owned then
            PolarMastery.ClusterCenterPos = targetPos
        elseif not PolarMastery.ClusterCenterPos or (prevTarget ~= targetMob) or (PolarMastery.ClusterCenterPos - targetPos).Magnitude > 30 then
            PolarMastery.ClusterCenterPos = targetPos
        end
        PolarMastery:ClusterMobs(PolarMastery.ClusterCenterPos, clusterName or targetMob.Name)
    else
        if owned then
            recordAndLockMobState(targetMob, tHum)
            if not PolarMastery.ClusterCenterPos or (prevTarget ~= targetMob) or (PolarMastery.ClusterCenterPos - targetPos).Magnitude > 30 then
                PolarMastery.ClusterCenterPos = targetPos
            end
            PolarMastery.ActiveClusterMobs = { targetMob }
        else
            if savedMobStates[targetMob] then
                releaseMob(targetMob)
            end
            PolarMastery.ClusterCenterPos = targetPos
            PolarMastery.ActiveClusterMobs = {}
        end
    end

    local hoverY = PolarMastery.HoverHeight or 16.5
    local desiredHover = CFrame.new(PolarMastery.ClusterCenterPos + Vector3.new(0, hoverY, 0))
    local distToTarget = (root.Position - desiredHover.Position).Magnitude
    if distToTarget > 6 then
        PolarMastery:TeleportTo(desiredHover)
        if not targetMob.Parent or tHum.Health <= 0 then return end
        PolarMastery.ClusterCenterPos = tRoot.Position
        desiredHover = CFrame.new(PolarMastery.ClusterCenterPos + Vector3.new(0, hoverY, 0))
        distToTarget = (root.Position - desiredHover.Position).Magnitude
    end
    PolarMastery.TargetHoverCFrame = desiredHover

    -- Anti-stall guard: if an NPC takes 0 damage for 2.5s of active hits (phantom/desynced), skip it
    local now = os.clock()
    if distToTarget <= 24 and not PolarMastery.IsTraveling then
        local watch = targetDamageWatch[targetMob]
        if not watch or prevTarget ~= targetMob then
            targetDamageWatch[targetMob] = { lastHp = tHum.Health, stallSince = now }
        elseif tHum.Health < (watch.lastHp - 0.5) then
            watch.lastHp = tHum.Health
            watch.stallSince = now
        elseif (now - watch.stallSince) >= 2.5 then
            unhittableUntil[targetMob] = now + 18
            targetDamageWatch[targetMob] = nil
            releaseMob(targetMob)
            PolarMastery.TargetHoverCFrame = nil
            PolarMastery.ClusterCenterPos = nil
            PolarMastery.CurrentTarget = nil
            PolarMastery.CurrentTargetRoot = nil
            PolarMastery.CurrentAimPos = nil
            return
        end
    else
        targetDamageWatch[targetMob] = { lastHp = tHum.Health, stallSince = now }
    end

    PolarMastery:SetAimTarget(tRoot)

    local hpPercent = (tHum.Health / tHum.MaxHealth) * 100
    if PolarMastery.EnableMastery and hpPercent <= PolarMastery.HealthMobThreshold then
        PolarMastery:ExecuteSkillBurst(targetMob)
    else
        PolarMastery:EquipWeapon(PolarMastery.PrimaryWeapon)
        PolarMastery:PerformM1(targetMob, tRoot)
    end
end

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
        local Polar = getgenv().Polar
        local targetMobName = "Posessed Mummy"
        local qName = "HauntedQuest2"
        local qIndex = 2
        local giverCF = CFrame.new(-9517.0, 172.0, 6078.4)
        local mobAreaCF = CFrame.new(-9517.0, 172.0, 6078.4)

        if PolarMastery.QuestFarmMode == "Normal" then
            targetMobName = "Reborn Skeleton"
            qName = "HauntedQuest1"
            qIndex = 1
            giverCF = CFrame.new(-9479.3, 141.2, 5566.0)
            mobAreaCF = CFrame.new(-8763.7, 165.0, 6159.9)
        end

        if Polar and Polar.World and Polar.World.GetQuestGiverCFrame then
            local liveGiver = Polar.World:GetQuestGiverCFrame(qName, qIndex, targetMobName)
            if liveGiver then giverCF = liveGiver end
        end

        local activeQuestMob = PolarMastery:GetActiveQuestTarget()
        if activeQuestMob and activeQuestMob ~= "HAS_QUEST" then
            targetMobName = activeQuestMob
            if targetMobName == "Demonic Soul" or targetMobName == "Posessed Mummy" then
                mobAreaCF = CFrame.new(-9517.0, 172.0, 6078.4)
            elseif targetMobName == "Living Zombie" or targetMobName == "Reborn Skeleton" then
                mobAreaCF = CFrame.new(-9479.3, 141.2, 5566.0)
            end
        end

        if Polar and Polar.World and Polar.World.GetEnemySpawnPosition then
            local liveSpawn = Polar.World:GetEnemySpawnPosition(targetMobName)
            if liveSpawn then
                mobAreaCF = CFrame.new(liveSpawn + Vector3.new(0, 12, 0))
            end
        end

        -- Take Quest if needed
        if PolarMastery.TakeQuest and not activeQuestMob then
            PolarMastery.TargetHoverCFrame = nil
            clearHoverInstances()
            PolarMastery.CurrentTarget = nil
            PolarMastery.CurrentTargetRoot = nil
            PolarMastery.CurrentAimPos = nil

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
        local targetMob = findNearestMob(enemies, root.Position, 2500, targetMobName)

        if not targetMob then
            PolarMastery.TargetHoverCFrame = nil
            clearHoverInstances()
            releaseAllTrackedMobs()
            PolarMastery.ClusterCenterPos = nil
            PolarMastery.CurrentTarget = nil
            PolarMastery.CurrentTargetRoot = nil
            PolarMastery.CurrentAimPos = nil
            PolarMastery:TeleportTo(mobAreaCF)
            task.wait(0.4)
            return
        end

        engageCombatTarget(targetMob, root, targetMobName, true)
        return
    end

    -- ==========================================================================
    -- MODE 2: AUTO FARM BOSS / ALL BOSSES
    -- ==========================================================================
    if PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses then
        local Polar = getgenv().Polar
        local BS = Polar and Polar.BossSystem
        local targetBossName = PolarMastery.SelectedBoss
        if PolarMastery.AutoKillAllBosses then
            if Polar and Polar.Data and Polar.Data.Bosses then
                for _, b in ipairs(Polar.Data.Bosses) do
                    local bObj = (BS and BS.FindLiveBoss and BS.FindLiveBoss(b.name)) or enemies:FindFirstChild(b.name) or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(b.name))
                    if bObj and bObj:FindFirstChild("HumanoidRootPart") and bObj:FindFirstChildOfClass("Humanoid") and bObj.Humanoid.Health > 0 then
                        targetBossName = b.name
                        break
                    end
                end
            end
        end

        local bData = BS and BS.FindBossData and BS.FindBossData(targetBossName)
        local boss = (BS and BS.FindLiveBoss and BS.FindLiveBoss(targetBossName)) or enemies:FindFirstChild(targetBossName) or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(targetBossName))
        if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChildOfClass("Humanoid") and boss.Humanoid.Health > 0 then
            if PolarMastery.GetBossQuest and bData and bData.q and Polar and Polar.Quest and not Polar.Quest:HasQuest() then
                local giverCF = (Polar.World and Polar.World.GetQuestGiverCFrame and Polar.World:GetQuestGiverCFrame(bData.q, bData.ql, bData.name))
                    or (bData.giver and Polar.World and Polar.World.FindNPC and Polar.World:FindNPC(bData.giver))
                if giverCF then
                    PolarMastery.TargetHoverCFrame = nil
                    local distG = (root.Position - giverCF.Position).Magnitude
                    if distG > 15 then
                        SafeMasteryTeleport(giverCF, root)
                        task.wait(0.3)
                        return
                    else
                        root.CFrame = giverCF
                        root.AssemblyLinearVelocity = Vector3.zero
                        if CommF then
                            pcall(function() CommF:InvokeServer("StartQuest", bData.q, bData.ql or 1) end)
                        end
                        task.wait(0.3)
                        return
                    end
                end
            end

            engageCombatTarget(boss, root, boss.Name, false)
        elseif not PolarMastery.AutoKillAllBosses and bData and bData.pos then
            PolarMastery.TargetHoverCFrame = nil
            releaseAllTrackedMobs()
            PolarMastery.ClusterCenterPos = nil
            local waitCF = CFrame.new(bData.pos + Vector3.new(0, 15, 0))
            if (root.Position - bData.pos).Magnitude > 300 or needsPortalOrDimensionJump(root.Position, bData.pos) then
                SafeMasteryTeleport(waitCF, root)
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
        local bestQuest = nil

        if PolarMastery.FarmMethod == "Quest" then
            local Polar = getgenv().Polar
            bestQuest = Polar and Polar.Quest and Polar.Quest:GetBestQuest()
            if bestQuest then
                targetEnemyName = bestQuest.enemyName

                -- Take quest if needed
                local hasQuest = Polar.Quest:HasQuest()
                if PolarMastery.TakeQuest and not hasQuest then
                    PolarMastery.TargetHoverCFrame = nil
                    local giverName = bestQuest.giverName
                    local giverCF = (Polar.World and Polar.World.GetQuestGiverCFrame and Polar.World:GetQuestGiverCFrame(bestQuest.qName, bestQuest.index, bestQuest.enemyName))
                        or (giverName and Polar.World and Polar.World.FindNPC and Polar.World:FindNPC(giverName))
                        or bestQuest.pos
                        or (Polar.Data and Polar.Data.NPCCache and Polar.Data.NPCCache[giverName])
                        or (Polar.NPCCache and Polar.NPCCache[giverName])
                    if giverCF then
                        local dist = (root.Position - giverCF.Position).Magnitude
                        if dist > 15 then
                            SafeMasteryTeleport(giverCF, root)
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

        -- Find Target Mob (saltando automaticamente NPCs que no reciben dano)
        targetMob = findNearestMob(enemies, root.Position, PolarMastery.NearestDistance or 1500, targetEnemyName)

        if not targetMob and bestQuest and bestQuest.island then
            local Polar = getgenv().Polar
            if Polar and Polar.Teleport and Polar.Teleport.ToIsland then
                PolarMastery.TargetHoverCFrame = nil
                releaseAllTrackedMobs()
                PolarMastery.ClusterCenterPos = nil
                Polar.Teleport:ToIsland(bestQuest.island)
                return
            end
        end

        if targetMob then
            engageCombatTarget(targetMob, root, targetMob.Name, true)
        else
            PolarMastery.TargetHoverCFrame = nil
            releaseAllTrackedMobs()
            PolarMastery.ClusterCenterPos = nil
        end
        return
    end
end

-- Fast combat loop con sesin controlada para recargas limpias
PolarMastery._CombatSessionId = (PolarMastery._CombatSessionId or 0) + 1
local curSession = PolarMastery._CombatSessionId

task.spawn(function()
    while PolarMastery._CombatSessionId == curSession do
        task.wait(PolarMastery.FastAttackDelay or 0.10)
        local isActive = PolarMastery.AutoBones or PolarMastery.AutoFarm or PolarMastery.AutoFarmBoss or PolarMastery.AutoKillAllBosses
        if isActive then
            pcall(runMasteryCombatStep)
        else
            clearHoverInstances()
            if next(savedMobStates) or (PolarMastery.ActiveClusterMobs and #PolarMastery.ActiveClusterMobs > 0) then
                releaseAllTrackedMobs()
            end
        end
    end
end)

print("[Polar Hub] [OK] Motor PolarMastery (Safe Hover, Ownership Sync, Silent Aim) cargado con exito.")
return PolarMastery
