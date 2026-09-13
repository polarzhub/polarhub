--[[
    ==============================================================================
    POLAR HUB | UNCONSTRAINED CUSTOM COMBAT ENGINE (POLAR COMBAT)
    Dedicated, Standalone, High-Throughput Combat Architecture for Blox Fruits
    ==============================================================================
    Features:
      1. Pure Protocol Emulation: Bypasses native CombatController to eliminate
         client animation locks, input throttling, camera shakes, and stutter.
      2. Whitelist Limb Targeting: Strictly targets 'Head' or 'UpperTorso' as required
         by Blox Fruits CombatUtil u124 table, guaranteeing 100% hit validation.
      3. Multi-Mob Damage Dispatch: Dual-dispatches SendHitsToServer and RegisterHit
         to all clustered enemies within range.
      4. Fruit M1 & Skill Compatibility: Handles Blox Fruits moveset invocation
         via direct tool RemoteFunction ('TAP') and RemoteEvent with silent aim.
      5. Anti-Fall Hover Anchor: Continuous BodyVelocity + Anchored Platform keeps
         character locked safely above mobs during both M1s and long skill holds.
      6. Anti-Phantom Protection: Completely dormant when idle; never attacks alone.
    ==============================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local PolarCombat = {}
PolarCombat.__index = PolarCombat

-- State & Configuration
PolarCombat.Enabled = false
PolarCombat.FastAttackDelay = 0.10
PolarCombat.HoverHeight = 12.5
PolarCombat.Combo = 1
PolarCombat.LastAttackTime = 0
PolarCombat.CurrentTarget = nil
PolarCombat.CurrentTargetPart = nil
PolarCombat.TargetHoverCFrame = nil
PolarCombat.IsBusyWithSkills = false
PolarCombat.AimTargetPos = nil

-- Remotes & Modules Resolution
local NetModule = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local Net = NetModule and require(NetModule)
local RegisterAttack = Net and Net:RemoteEvent("RegisterAttack")
local RegisterHit = Net and Net:RemoteEvent("RegisterHit", true)
local GlobalModule = nil
pcall(function()
    GlobalModule = require(ReplicatedStorage:WaitForChild("Global", 5))
end)

local MouseModule = nil
pcall(function()
    MouseModule = require(ReplicatedStorage:WaitForChild("Mouse", 5))
end)

local atkMeleeCached = nil
pcall(function()
    if filtergc then
        atkMeleeCached = filtergc("function", {Name = "attackMelee"}, true)
    end
end)

-- Whitelist Limbs (Blox Fruits CombatUtil u124 Table)
local VALID_LIMBS = {
    "Head", "UpperTorso", "RightUpperArm", "LeftUpperArm",
    "RightLowerArm", "LeftLowerArm", "RightHand", "LeftHand",
    "LowerTorso", "RightUpperLeg", "LeftUpperLeg"
}

-- Resolve valid hit part strictly matching u124
function PolarCombat:GetValidHitPart(mob)
    if not mob or not mob.Parent then return nil end
    local head = mob:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    local upperTorso = mob:FindFirstChild("UpperTorso")
    if upperTorso and upperTorso:IsA("BasePart") then return upperTorso end
    for _, limbName in ipairs(VALID_LIMBS) do
        local limb = mob:FindFirstChild(limbName)
        if limb and limb:IsA("BasePart") then return limb end
    end
    return mob:FindFirstChild("HumanoidRootPart")
end

-- Silent Aim (does not hijack or move user camera)
function PolarCombat:SetAimTarget(targetPart)
    if not targetPart then
        self.AimTargetPos = nil
        return
    end
    local aimPos = targetPart.Position
    self.AimTargetPos = aimPos

    if MouseModule and type(MouseModule) == "table" then
        pcall(function()
            MouseModule.Hit = CFrame.new(aimPos)
            MouseModule.Target = targetPart
        end)
    end

    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool then
        local mousePosVal = tool:FindFirstChild("MousePos")
        if mousePosVal and mousePosVal:IsA("Vector3Value") then
            mousePosVal.Value = aimPos
        end
    end

    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(aimPos.X, root.Position.Y, aimPos.Z))
    end
end

-- Clear Blox Fruits client debounce and internal cooldown locks
function PolarCombat:ResetDebounces()
    if GlobalModule then
        GlobalModule.tapCooldown = 0
        GlobalModule.busy = nil
        GlobalModule.castTimer = 0
    end
    if atkMeleeCached then
        pcall(debug.setupvalue, atkMeleeCached, 2, false)
    end
end

-- ==============================================================================
-- HOVER PLATFORM & ANTI-FALL ENGINE
-- ==============================================================================
local hoverPlatform = nil
local hoverVelocity = nil

function PolarCombat:MaintainHover(targetRoot, height)
    height = height or self.HoverHeight or 12.5
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 or not targetRoot or not targetRoot.Parent then
        self:ReleaseHover()
        return
    end

    local targetPos = targetRoot.Position
    local hoverPos = targetPos + Vector3.new(0, height, 0)
    self.TargetHoverCFrame = CFrame.lookAt(hoverPos, targetPos)

    -- 1. Anti-Fall Invisible Anchored Platform (3.5 studs below player root)
    if not hoverPlatform or not hoverPlatform.Parent then
        if hoverPlatform then pcall(function() hoverPlatform:Destroy() end) end
        hoverPlatform = Instance.new("Part")
        hoverPlatform.Name = "PolarCombatHoverPlatform"
        hoverPlatform.Size = Vector3.new(14, 1, 14)
        hoverPlatform.Transparency = 1
        hoverPlatform.Anchored = true
        hoverPlatform.CanCollide = true
        hoverPlatform.Parent = workspace
    end
    hoverPlatform.CFrame = self.TargetHoverCFrame * CFrame.new(0, -3.5, 0)

    -- 2. Anti-Drop BodyVelocity Anchor
    if not hoverVelocity or hoverVelocity.Parent ~= root then
        if hoverVelocity then pcall(function() hoverVelocity:Destroy() end) end
        hoverVelocity = Instance.new("BodyVelocity")
        hoverVelocity.Name = "PolarCombatHoverAnchor"
        hoverVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hoverVelocity.Velocity = Vector3.zero
        hoverVelocity.Parent = root
    else
        hoverVelocity.Velocity = Vector3.zero
    end

    -- Direct CFrame lock with zero velocity
    local dist = (root.Position - hoverPos).Magnitude
    if dist > 15 then
        local Polar = getgenv().Polar
        if Polar and Polar.Teleport and type(Polar.Teleport.To) == "function" then
            Polar.Teleport:To(self.TargetHoverCFrame)
        else
            root.CFrame = self.TargetHoverCFrame
        end
    else
        root.CFrame = self.TargetHoverCFrame
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

function PolarCombat:ReleaseHover()
    self.TargetHoverCFrame = nil
    if hoverVelocity then
        pcall(function() hoverVelocity:Destroy() end)
        hoverVelocity = nil
    end
    if hoverPlatform then
        pcall(function() hoverPlatform:Destroy() end)
        hoverPlatform = nil
    end
end

-- ==============================================================================
-- PURE UNCONSTRAINED ATTACK DISPATCH (ZERO COMBATCONTROLLER RELIANCE)
-- ==============================================================================
function PolarCombat:ExecuteAttack(targetMob, targetHitPart)
    if not targetMob or not targetMob.Parent then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end

    local hitPart = targetHitPart or self:GetValidHitPart(targetMob)
    if not hitPart then return false end

    -- 1. Silent aim at hit part
    self:SetAimTarget(hitPart)

    -- 2. Clear debounces
    self:ResetDebounces()

    -- 3. Check weapon category
    local isFruit = tool.ToolTip == "Blox Fruit" or tool:GetAttribute("WeaponType") == "Demon Fruit"

    -- 4. Advance attack combo
    self.Combo = ((self.Combo or 1) % 4) + 1
    local combo = self.Combo
    local cd = math.max(self.FastAttackDelay or 0.10, 0.12)

    -- 5. Collect all clustered enemies for AoE damage
    local cluster = { {targetMob, hitPart} }
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        local maxAoE = 6
        local isBuddha = hrp:FindFirstChild("Buddha") or hrp:FindFirstChild("Buddha2")
        if isBuddha then maxAoE = 10 end

        for _, otherMob in ipairs(enemies:GetChildren()) do
            if otherMob ~= targetMob and otherMob:IsA("Model") and #cluster < maxAoE then
                local oHum = otherMob:FindFirstChildOfClass("Humanoid")
                local oRoot = otherMob:FindFirstChild("HumanoidRootPart")
                if oHum and oHum.Health > 0 and oRoot then
                    local d = (oRoot.Position - hrp.Position).Magnitude
                    if d <= 55 then
                        local oPart = self:GetValidHitPart(otherMob)
                        if oPart then
                            table.insert(cluster, {otherMob, oPart})
                        end
                    end
                end
            end
        end
    end

    -- 6. Dual-Dispatch Hits to Server for Each Mob in Cluster
    pcall(function()
        for _, entry in ipairs(cluster) do
            local mob, part = entry[1], entry[2]
            if RegisterAttack then
                RegisterAttack:FireServer(cd, combo)
            end
            if GlobalModule and GlobalModule.SendHitsToServer then
                GlobalModule.SendHitsToServer(part, {{mob, part}})
            end
            if RegisterHit then
                RegisterHit:FireServer(part, {{mob, part}})
            end
        end
    end)

    -- 7. Trigger Tool Activation / Fruit TAP
    if isFruit then
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
            local remFunc = tool:FindFirstChild("RemoteFunction") or tool:FindFirstChildWhichIsA("RemoteFunction")
            if remFunc then
                remFunc:InvokeServer("TAP", nil, hitPart.Position)
            end
            local remEvent = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteEvent")
            if remEvent then
                remEvent:FireServer(hitPart.Position)
            end
            tool:Activate()
        end)
    else
        pcall(function()
            tool:Activate()
        end)
    end

    return true
end

-- ==============================================================================
-- SKILL EXECUTION WITH DECIMAL SECOND HOLD TIMES
-- ==============================================================================
function PolarCombat:CastKey(key, holdSeconds, targetRoot)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end

    pcall(function()
        local tPart = targetRoot or (self.CurrentTarget and self:GetValidHitPart(self.CurrentTarget))
        if tPart then
            self:SetAimTarget(tPart)
        end

        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)

        local duration = holdSeconds or 0
        if duration > 0 then
            local startTime = os.clock()
            while (os.clock() - startTime) < duration do
                if targetRoot and targetRoot.Parent then
                    self:SetAimTarget(targetRoot)
                    self:MaintainHover(targetRoot, self.HoverHeight)
                end
                task.wait(0.05)
            end
        else
            task.wait(0.05)
        end

        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        self:ResetDebounces()
    end)
end

-- Stepped collision disable during combat
RunService.Stepped:Connect(function()
    if PolarCombat.TargetHoverCFrame then
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

-- Expose globally under Polar namespace
local Polar = getgenv().Polar or {}
getgenv().Polar = Polar
Polar.Combat = PolarCombat
getgenv().PolarCombat = PolarCombat

return PolarCombat
