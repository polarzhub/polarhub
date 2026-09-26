--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                 POLAR HUB - OFFICIAL CONTROL DOMAIN (ROOM)                   ║
    ║        Full 1:1 Deep Authentic Blox Fruits Control Move [Z] Clone           ║
    ║                                                                              ║
    ║  Keybind: [M] Toggle / Hold & Release Domain                                ║
    ║  - Press/Hold [M]: Dramatic Casting Pose (Walk frozen, CRRoomOpeningStart    ║
    ║    + CRRoomOpeningLoop, Glowing DoubleNeonEye, ShaderScreen Vignette,       ║
    ║    Rotating FloorStarCollide magic circles, rising terrain rocks,            ║
    ║    bezier lightning sparks, cosmic waves & audio).                           ║
    ║  - Release / Auto-Cast: CRRoomOpeningEnd Snap, Cam Shake, Domain Bubble      ║
    ║    Expands (280 studs), curved perimeter beams AB/BB, ground spiky ring,     ║
    ║    OpeGlobe blue atmospheric shift, Room Idle Hum.                           ║
    ║  - Character Combat Mode: Dual Glowing Control Daggers + Body Control Aura   ║
    ║    with floating cyber cubes & orbiting glowing rock chunks!                 ║
    ║  - Press [M] again: Complete clean collapse with disable audio 01-04,        ║
    ║    daggers unequipped, aura turned off, and lighting restored.               ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
--]]

-- Cleanup previous instance if running
if getgenv().ControlDomainCleanup then
    pcall(getgenv().ControlDomainCleanup)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Verify Blox Fruits modules
local EffectContainer = ReplicatedStorage:WaitForChild("EffectContainer", 10)
if not EffectContainer then
    warn("[ControlDomain] Error: EffectContainer not found!")
    return
end

local ControlRework = EffectContainer:WaitForChild("ControlRework", 10)
if not ControlRework then
    warn("[ControlDomain] Error: ControlRework not found!")
    return
end

local DomainModule = ControlRework:WaitForChild("Domain", 10)
local DomainChargeModule = ControlRework:WaitForChild("DomainCharge", 10)

if not DomainModule or not DomainChargeModule then
    warn("[ControlDomain] Error: Domain or DomainCharge module missing!")
    return
end

local DomainEffect = require(DomainModule)
local DomainCharge = require(DomainChargeModule)
local Util = require(ReplicatedStorage:WaitForChild("Util"))

-- State Management
local State = {
    IsOpen = false,
    IsCharging = false,
    IsTransitioning = false,
    ChargeStartTime = 0,
    MaxHoldDuration = 3.5,
    DefaultChargeTime = 0.95,
    DomainRadius = 280,
    RoomTag = nil,
    FreezeBodyVel = nil,
    OriginalWalkSpeed = 16,
    OriginalJumpPower = 50,
}

-- Notification Helper
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Control Domain",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

-- Camera Shake Helper
local function ShakeCamera(style)
    pcall(function()
        if Util and Util.CameraShaker then
            Util.CameraShaker:Shake(style or "Fast")
        elseif ReplicatedStorage:FindFirstChild("Effect") then
            local Effect = require(ReplicatedStorage.Effect)
            local shake = Effect.new("ShakeCam")
            shake:replicate({ 12, 12, 0, 0.9, Vector3.new(0.3, 0.3, 0), Vector3.new(0, 0, 1) })
        end
    end)
end

-- Deactivate Domain (Full Cleanup & Dissolve)
local function DeactivateDomain()
    if not State.IsOpen and not State.IsTransitioning and not State.IsCharging then return end
    State.IsTransitioning = true

    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")

        -- 1. Unequip Control Daggers
        pcall(function()
            DomainCharge({
                Player = LocalPlayer,
                Character = character,
                Root = hrp,
                Dagger = "Unequip"
            })
        end)

        -- 2. Turn off Character Aura & floating rocks
        pcall(function()
            DomainCharge({
                Player = LocalPlayer,
                Character = character,
                Root = hrp,
                Aura = true,
                AURA_OFF = true
            })
        end)

        -- 3. Deactivate Domain: This triggers Blox Fruits official collapse:
        -- - Plays Sound "CTRLFRT_Z_Disable_Room_0X" (1 to 4)
        -- - Fades out idle loop hum "CTRLFRT_Z_Room_Idle_Loop_01"
        -- - Shrinks & dissolves Globe, Beams AB/BB, and Spiky ground meshes
        -- - Smoothly returns Lighting.OpeGlobe back to normal
        character:SetAttribute("ControlRoomActive", false)

        local tag = character:FindFirstChild("__Room")
        if tag then
            task.delay(0.6, function()
                if tag and tag.Parent then
                    tag:Destroy()
                end
            end)
        end

        -- Ensure any lingering eye effects or screen shaders are cleaned
        pcall(function()
            local eye = character:FindFirstChild("Head") and character.Head:FindFirstChild("Double-Neon-Eye")
            if eye then eye:Destroy() end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local shader = pg:FindFirstChild("Shader-Screen")
                if shader then shader:Destroy() end
            end
        end)
    end

    State.IsOpen = false
    State.IsCharging = false
    State.RoomTag = nil
    Notify("Control [Z]", "Room / Dominio Desactivado", 2.5)

    task.wait(0.5)
    State.IsTransitioning = false
end

-- Finish Charge & Expand Domain
local function ExpandDomain()
    if State.IsOpen or not State.IsCharging then return end
    State.IsCharging = false
    State.IsTransitioning = true

    local character = LocalPlayer.Character
    if not character or not character.Parent then
        State.IsTransitioning = false
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then
        State.IsTransitioning = false
        return
    end

    -- 1. Unfreeze character movement
    if State.FreezeBodyVel and State.FreezeBodyVel.Parent then
        State.FreezeBodyVel:Destroy()
        State.FreezeBodyVel = nil
    end
    hum.WalkSpeed = State.OriginalWalkSpeed > 0 and State.OriginalWalkSpeed or 16
    hum.JumpPower = State.OriginalJumpPower > 0 and State.OriginalJumpPower or 50

    -- 2. Climax Release Animation: Stop loop and play CRRoomOpeningEnd
    pcall(function()
        local endTrack = Util.Anims:Get(character, "CRRoomOpeningEnd")
        if endTrack then
            endTrack.Looped = false
            endTrack.Priority = Enum.AnimationPriority.Action4
            endTrack:Play()
        end
    end)

    -- Camera impact shake
    ShakeCamera("Fast")

    -- 3. Create authentic __Room tag for DomainEffect
    local targetCFrame = hrp.CFrame
    local roomTag = character:FindFirstChild("__Room")
    if not roomTag then
        roomTag = Instance.new("Configuration")
        roomTag.Name = "__Room"
        roomTag.Parent = character
    end

    roomTag:SetAttribute("CFrame", targetCFrame)
    roomTag:SetAttribute("Radius", State.DomainRadius)
    roomTag:SetAttribute("MaxRadius", State.DomainRadius)
    roomTag:SetAttribute("HoldDuration", 1.0)
    roomTag:SetAttribute("Active", true)

    -- Flag the character as having an active room
    character:SetAttribute("ControlRoomActive", true)

    -- 4. Invoke the official Blox Fruits Domain Effect:
    -- - Hexagonal bubble sphere with camera offset
    -- - Curved perimeter beams AB and BB
    -- - Rotating spiky ground ring meshes
    -- - Dust cloud ring cache
    -- - Ambient hum loop: CTRLFRT_Z_Room_Idle_Loop_01
    -- - Distant bubble grow sound: CTRLFRT_Z_Activate_DistantBubbleGrow_02
    -- - Atmospheric blue lighting via Lighting.OpeGlobe
    pcall(function()
        DomainEffect({ LocalPlayer, character, 0.5 })
    end)

    -- 5. Equip Character Combat Mode (Control Aura + Dual Glowing Daggers)
    task.spawn(function()
        pcall(function()
            -- Dual Control Daggers with blade glow and spinning winds
            DomainCharge({
                Player = LocalPlayer,
                Character = character,
                Root = hrp,
                Dagger = "Equip"
            })
        end)
    end)

    task.spawn(function()
        pcall(function()
            -- Full Control Aura with floating ground rocks & body particles
            DomainCharge({
                Player = LocalPlayer,
                Character = character,
                Root = hrp,
                Aura = true
            })
        end)
    end)

    State.RoomTag = roomTag
    State.IsOpen = true
    Notify("Control [Z]", "Dominio Expandido! [M] para desactivar", 3)

    task.wait(0.3)
    State.IsTransitioning = false
end

-- Start Charge Sequence
local function StartCharge()
    if State.IsOpen or State.IsCharging or State.IsTransitioning then return end
    State.IsCharging = true
    State.ChargeStartTime = os.clock()

    local character = LocalPlayer.Character
    if not character then
        State.IsCharging = false
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then
        State.IsCharging = false
        return
    end

    Notify("Control [Z]", "Cargando Dominio / Room...", 1.5)

    -- 1. Freeze character in dramatic casting posture
    State.OriginalWalkSpeed = hum.WalkSpeed
    State.OriginalJumpPower = hum.JumpPower
    hum.WalkSpeed = 0
    hum.JumpPower = 0

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Parent = hrp
    State.FreezeBodyVel = bodyVel

    -- 2. Trigger Official Startup Charge VFX & Audio via DomainCharge
    -- Clones DoubleNeonEye on head, ShaderScreen on PlayerGui, DarkNeonRotation on torso,
    -- FloorStarCollide & EndFloorStarCollide magic circles beneath feet,
    -- bezier lightning sparks, floating ground rocks, cosmic waves, and sound CTRLFRT_Z_Activate_CloseToPlayer_01!
    task.spawn(function()
        pcall(function()
            DomainCharge({
                Player = LocalPlayer,
                Character = character,
                Root = hrp,
                Duration = State.MaxHoldDuration
            })
        end)
    end)

    -- Auto-expand after default duration if not held or released
    task.delay(State.DefaultChargeTime, function()
        if State.IsCharging and (os.clock() - State.ChargeStartTime >= State.DefaultChargeTime) then
            ExpandDomain()
        end
    end)
end

-- Handle Key Press / Release
local function HandleInputBegan()
    if State.IsTransitioning then return end
    if State.IsOpen then
        DeactivateDomain()
    else
        StartCharge()
    end
end

local function HandleInputEnded()
    if State.IsCharging then
        -- User released key [M]: if they charged for at least 0.5s, expand immediately!
        local elapsed = os.clock() - State.ChargeStartTime
        if elapsed >= 0.45 then
            ExpandDomain()
        else
            -- If released very quickly, wait for minimum charge to finish cleanly
            task.delay(0.45 - elapsed, function()
                if State.IsCharging then
                    ExpandDomain()
                end
            end)
        end
    end
end

-- Input Listeners
local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        HandleInputBegan()
    end
end)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        HandleInputEnded()
    end
end)

-- Character Respawn Handling
local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    State.IsOpen = false
    State.IsCharging = false
    State.IsTransitioning = false
    State.RoomTag = nil
    if State.FreezeBodyVel and State.FreezeBodyVel.Parent then
        State.FreezeBodyVel:Destroy()
        State.FreezeBodyVel = nil
    end
end)

-- Register Cleanup Handler
getgenv().ControlDomainCleanup = function()
    if inputBeganConn then inputBeganConn:Disconnect() inputBeganConn = nil end
    if inputEndedConn then inputEndedConn:Disconnect() inputEndedConn = nil end
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    if State.FreezeBodyVel and State.FreezeBodyVel.Parent then
        State.FreezeBodyVel:Destroy()
        State.FreezeBodyVel = nil
    end
    DeactivateDomain()
    print("[ControlDomain] Cleaned up previous instance successfully.")
end

getgenv().ControlDomainToggle = function()
    if State.IsOpen then
        DeactivateDomain()
    else
        StartCharge()
        task.wait(State.DefaultChargeTime)
        if State.IsCharging then
            ExpandDomain()
        end
    end
end

Notify("Control [Z] Master Clone Ready", "Mantén o Presiona [M] para Activar Dominio", 5)
print("[ControlDomain] Master clone loaded successfully! Press or hold [M] to toggle.")
