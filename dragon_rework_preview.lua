--[[
    ================================================================================
    BLOX FRUITS - DRAGON REWORK (V2) COMPLETE VISUAL & COMBAT PREVIEW ENGINE
    ================================================================================
    Desarrollado y Verificado mediante Decompilacion Real MCP.
    
    Arquitectura Descubierta:
    1. Skinned Rigs & Modelos:
       - Dragon East: ReplicatedStorage.Assets.SkinnedRigs.Transformations["Dragon (East)-Dragon (East)"]
       - Dragon West: ReplicatedStorage.Assets.SkinnedRigs.Transformations["Dragon (West)-Dragon (West)"]
       - Alas: ReplicatedStorage.Assets.SkinnedRigs.Wings.DracoWings
       - Cola: ReplicatedStorage.Assets.SkinnedRigs.Tails.DracoTail
       - Halo & Escamas: require(ReplicatedStorage.FX):Get("EasternDragon")
       - Aura de Viento: ReplicatedStorage.Assets.Models.DragonTransformation
    2. 14 Skins Oficiales:
       - Blue, Violet Night, Eclipse, Ember, Purple, Blood Moon, Emerald,
         Black, Green, Frostbite, Yellow, Orange, Red, Phoenix Sky
    3. Habilidades & VFX:
       - ReplicatedStorage.EffectContainer.Dragon2 (Z, X, C, V, F, M1, Wings, Hybrid, Transformed)
    4. Animaciones Oficiales:
       - ReplicatedStorage.Storage.Anims.2.Dragon2 (23 animaciones)
    
    100% Client-Sided: Permite probar el cuerpo completo, transformaciones,
    skins y efectos de ataque sin necesidad de poseer la fruta en el servidor.
    ================================================================================
--]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Limpieza de sesion previa
if getgenv().DragonPreviewEngine and getgenv().DragonPreviewEngine.Cleanup then
    pcall(getgenv().DragonPreviewEngine.Cleanup)
end

local Engine = {
    Connections = {},
    SpawnedInstances = {},
    ActiveTracks = {},
    CurrentMode = "None", -- "East", "West", "Hybrid", "None"
    CurrentSkin = "Phoenix Sky",
    IsFlying = false,
    FlyBodyVelocity = nil,
    FlyBodyGyro = nil,
    FlightSpeed = 150,
    ActiveHalo = nil,
    ActiveWings = nil,
    ActiveTail = nil,
    ActiveMorph = nil,
    ActiveAura = nil,
}
getgenv().DragonPreviewEngine = Engine

local function trackConn(c)
    table.insert(Engine.Connections, c)
    return c
end

local function trackInst(i)
    table.insert(Engine.SpawnedInstances, i)
    return i
end

-- ================================================================================
-- RECURSOS DE REPLICATEDSTORAGE
-- ================================================================================
local Util = nil
pcall(function() Util = require(ReplicatedStorage:WaitForChild("Util")) end)

local FXModule = nil
pcall(function() FXModule = require(ReplicatedStorage:WaitForChild("FX")) end)

local EffectContainer = ReplicatedStorage:FindFirstChild("EffectContainer")
local Dragon2EC = EffectContainer and EffectContainer:FindFirstChild("Dragon2")
local DragonAnims = ReplicatedStorage:FindFirstChild("Storage")
    and ReplicatedStorage.Storage:FindFirstChild("Anims")
    and ReplicatedStorage.Storage.Anims:FindFirstChild("2")
    and ReplicatedStorage.Storage.Anims["2"]:FindFirstChild("Dragon2")

local SkinnedRigs = ReplicatedStorage:FindFirstChild("Assets")
    and ReplicatedStorage.Assets:FindFirstChild("SkinnedRigs")

local SKINS_LIST = {
    "Phoenix Sky", "Red", "Ember", "Blue", "Eclipse", "Violet Night",
    "Purple", "Blood Moon", "Emerald", "Black", "Green", "Frostbite",
    "Yellow", "Orange"
}

-- ================================================================================
-- UTILIDADES DE PERSONAJE
-- ================================================================================
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    return char, root, hum
end

local function getAnimator()
    local char, _, hum = getChar()
    if not hum then return nil end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then
        anim = Instance.new("Animator")
        anim.Parent = hum
    end
    return anim
end

local function playAnim(animName, speed, looped)
    if not DragonAnims then return nil end
    local animObj = DragonAnims:FindFirstChild(animName)
    if not animObj then return nil end
    local animator = getAnimator()
    if not animator then return nil end

    local track = animator:LoadAnimation(animObj)
    track.Looped = (looped == true)
    track:Play(0.1, 1, speed or 1)
    table.insert(Engine.ActiveTracks, track)
    return track
end

local function stopAllAnims()
    for _, t in ipairs(Engine.ActiveTracks) do
        pcall(function() t:Stop(0.1) end)
    end
    table.clear(Engine.ActiveTracks)
end

local function unanchorDescendants(model)
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = false
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.Massless = true
        end
    end
end

-- ================================================================================
-- GESTION DE MODELOS 3D Y TRANSFORMACIONES
-- ================================================================================
local function cleanModels()
    if Engine.ActiveHalo then pcall(function() Engine.ActiveHalo:Destroy() end); Engine.ActiveHalo = nil end
    if Engine.ActiveWings then pcall(function() Engine.ActiveWings:Destroy() end); Engine.ActiveWings = nil end
    if Engine.ActiveTail then pcall(function() Engine.ActiveTail:Destroy() end); Engine.ActiveTail = nil end
    if Engine.ActiveMorph then pcall(function() Engine.ActiveMorph:Destroy() end); Engine.ActiveMorph = nil end
    if Engine.ActiveAura then pcall(function() Engine.ActiveAura:Destroy() end); Engine.ActiveAura = nil end

    local char = player.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            if c.Name:find("Dragon_") then
                pcall(function() c:Destroy() end)
            end
        end
        pcall(function() char:ScaleTo(1.0) end)
    end
    stopAllAnims()
    Engine.CurrentMode = "None"
end

-- Aplicar Skin a Modelo Rig Skinned
local function applySkinToRig(rigModel, skinName)
    if not SkinnedRigs then return end
    local transModule = SkinnedRigs:FindFirstChild("Transformations")
        and SkinnedRigs.Transformations:FindFirstChild("Dragon (East)-Dragon (East)")
    if not transModule then return end

    local ok, skinData = pcall(require, transModule)
    if not ok or type(skinData) ~= "table" then return end

    local chosenSkin = skinData[skinName]
    if not chosenSkin then return end

    for partName, partData in pairs(chosenSkin) do
        local targetPart = rigModel:FindFirstChild(partName, true)
        if targetPart and targetPart:IsA("BasePart") then
            if partData.Properties then
                for prop, val in pairs(partData.Properties) do
                    pcall(function() targetPart[prop] = val end)
                end
            end
            if partData.Children and partData.Children.SurfaceAppearance and targetPart:FindFirstChildOfClass("SurfaceAppearance") then
                local sa = targetPart:FindFirstChildOfClass("SurfaceAppearance")
                for prop, val in pairs(partData.Children.SurfaceAppearance.Properties or {}) do
                    pcall(function() sa[prop] = val end)
                end
            end
        end
    end
end

-- 1. Transformacion Oriental (Dragon East)
local function applyEastDragon(skinName)
    cleanModels()
    local char, root, hum = getChar()
    if not char or not root then return end
    Engine.CurrentMode = "East"
    Engine.CurrentSkin = skinName or Engine.CurrentSkin

    -- Efecto de transformacion inicial
    pcall(function()
        if Dragon2EC and Dragon2EC:FindFirstChild("V") then
            local vMod = require(Dragon2EC.V)
            vMod({ player = player, hrp = root, Rig = char, Stage = 1 })
        end
    end)

    -- Halo de Dragon Oriental (FX.EasternDragon.Halo)
    pcall(function()
        if FXModule then
            local edFX = FXModule:Get("EasternDragon")
            if edFX and edFX:FindFirstChild("Halo") then
                local haloClone = edFX.Halo:Clone()
                haloClone.Name = "Dragon_Halo"
                unanchorDescendants(haloClone)
                local haloPart = haloClone.PrimaryPart or haloClone:FindFirstChild("RootPart") or haloClone:FindFirstChildWhichIsA("BasePart")
                if haloPart then
                    local weld = Instance.new("Weld")
                    weld.Part0 = root
                    weld.Part1 = haloPart
                    weld.C0 = CFrame.new(0, 5.5, -0.5) * CFrame.Angles(math.rad(90), 0, 0)
                    weld.Parent = haloPart
                end
                haloClone.Parent = char
                Engine.ActiveHalo = haloClone
            end
        end
    end)

    -- Rig de Dragon Oriental
    pcall(function()
        if SkinnedRigs and SkinnedRigs:FindFirstChild("Transformations") then
            local eastMod = SkinnedRigs.Transformations:FindFirstChild("Dragon (East)-Dragon (East)")
            local rigFolder = eastMod and eastMod:FindFirstChild("Rig")
            if rigFolder then
                local rigClone = Instance.new("Model")
                rigClone.Name = "Dragon_EastRig"
                for _, part in ipairs(rigFolder:GetChildren()) do
                    local pc = part:Clone()
                    pc.Parent = rigClone
                end
                unanchorDescendants(rigClone)
                applySkinToRig(rigClone, Engine.CurrentSkin)

                local pPart = rigClone:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    local w = Instance.new("Weld")
                    w.Part0 = root
                    w.Part1 = pPart
                    w.C0 = CFrame.new(0, 2, 0)
                    w.Parent = pPart
                end
                rigClone.Parent = char
                Engine.ActiveMorph = rigClone
            end
        end
    end)

    -- Aura & Escamas (ArmourVFX)
    pcall(function()
        if FXModule then
            local edFX = FXModule:Get("EasternDragon")
            if edFX and edFX:FindFirstChild("ArmourVFX") then
                local hl = edFX.ArmourVFX:FindFirstChildOfClass("Highlight")
                if hl then
                    local hlClone = hl:Clone()
                    hlClone.Name = "Dragon_Highlight"
                    hlClone.Parent = char
                    Engine.ActiveAura = hlClone
                end
            end
        end
    end)

    -- Escalar personaje
    pcall(function() char:ScaleTo(1.6) end)
end

-- 2. Transformacion Occidental (Dragon West - Wyvern con Alas y Cola)
local function applyWestDragon(skinName)
    cleanModels()
    local char, root, hum = getChar()
    if not char or not root then return end
    Engine.CurrentMode = "West"
    Engine.CurrentSkin = skinName or Engine.CurrentSkin

    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root

    -- DracoWings
    pcall(function()
        if SkinnedRigs and SkinnedRigs:FindFirstChild("Wings") and SkinnedRigs.Wings:FindFirstChild("DracoWings") then
            local wings = SkinnedRigs.Wings.DracoWings:Clone()
            wings.Name = "Dragon_Wings"
            unanchorDescendants(wings)
            local wPart = wings.PrimaryPart or wings:FindFirstChildWhichIsA("BasePart")
            if wPart then
                local w = Instance.new("Weld")
                w.Part0 = torso
                w.Part1 = wPart
                w.C0 = CFrame.new(0, 0.5, 1.2) * CFrame.Angles(0, math.rad(180), 0)
                w.Parent = wPart
            end
            wings.Parent = char
            Engine.ActiveWings = wings
        end
    end)

    -- DracoTail
    pcall(function()
        if SkinnedRigs and SkinnedRigs:FindFirstChild("Tails") and SkinnedRigs.Tails:FindFirstChild("DracoTail") then
            local tail = SkinnedRigs.Tails.DracoTail:Clone()
            tail.Name = "Dragon_Tail"
            unanchorDescendants(tail)
            local tPart = tail.PrimaryPart or tail:FindFirstChildWhichIsA("BasePart")
            if tPart then
                local w = Instance.new("Weld")
                w.Part0 = torso
                w.Part1 = tPart
                w.C0 = CFrame.new(0, -1.2, 1.0) * CFrame.Angles(math.rad(-25), math.rad(180), 0)
                w.Parent = tPart
            end
            tail.Parent = char
            Engine.ActiveTail = tail
        end
    end)

    -- Aura de Transformacion (Wind & Fire)
    pcall(function()
        local dt = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Models")
            and ReplicatedStorage.Assets.Models:FindFirstChild("DragonTransformation")
        if dt then
            local dtClone = dt:Clone()
            dtClone.Name = "Dragon_WindAura"
            unanchorDescendants(dtClone)
            local dtPart = dtClone.PrimaryPart or dtClone:FindFirstChildWhichIsA("BasePart")
            if dtPart then
                local w = Instance.new("Weld")
                w.Part0 = root
                w.Part1 = dtPart
                w.C0 = CFrame.new(0, 0, 0)
                w.Parent = dtPart
            end
            dtClone.Parent = char
            Engine.ActiveAura = dtClone
        end
    end)

    pcall(function() char:ScaleTo(1.35) end)
end

-- 3. Modo Hibrido
local function applyHybridDragon()
    cleanModels()
    local char, root, hum = getChar()
    if not char or not root then return end
    Engine.CurrentMode = "Hybrid"

    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root

    -- DracoWings compactas
    pcall(function()
        if SkinnedRigs and SkinnedRigs:FindFirstChild("Wings") and SkinnedRigs.Wings:FindFirstChild("DracoWings") then
            local wings = SkinnedRigs.Wings.DracoWings:Clone()
            wings.Name = "Dragon_Wings"
            unanchorDescendants(wings)
            local wPart = wings.PrimaryPart or wings:FindFirstChildWhichIsA("BasePart")
            if wPart then
                local w = Instance.new("Weld")
                w.Part0 = torso
                w.Part1 = wPart
                w.C0 = CFrame.new(0, 0.4, 0.9) * CFrame.Angles(0, math.rad(180), 0)
                w.Parent = wPart
            end
            wings.Parent = char
            Engine.ActiveWings = wings
        end
    end)

    -- DracoTail
    pcall(function()
        if SkinnedRigs and SkinnedRigs:FindFirstChild("Tails") and SkinnedRigs.Tails:FindFirstChild("DracoTail") then
            local tail = SkinnedRigs.Tails.DracoTail:Clone()
            tail.Name = "Dragon_Tail"
            unanchorDescendants(tail)
            local tPart = tail.PrimaryPart or tail:FindFirstChildWhichIsA("BasePart")
            if tPart then
                local w = Instance.new("Weld")
                w.Part0 = torso
                w.Part1 = tPart
                w.C0 = CFrame.new(0, -1.0, 0.8) * CFrame.Angles(math.rad(-20), math.rad(180), 0)
                w.Parent = tPart
            end
            tail.Parent = char
            Engine.ActiveTail = tail
        end
    end)

    -- Animacion Hibrida
    playAnim("Dragon2VHybrid", 1, true)
end

-- ================================================================================
-- DISPARADOR DE HABILIDADES Y ATAQUES (Z, X, C, V, F, M1)
-- ================================================================================
local m1ComboIndex = 1
local lastM1Time = 0

local function fireSkill(skillKey)
    local char, root, hum = getChar()
    if not char or not root or not Dragon2EC then return end

    local targetPos = mouse.Hit and mouse.Hit.Position or (root.Position + root.CFrame.LookVector * 50)
    local skillMod = Dragon2EC:FindFirstChild(skillKey)
    if not skillMod then return end

    local ok, effectFunc = pcall(require, skillMod)
    if not ok or type(effectFunc) ~= "function" then return end

    if skillKey == "Z" then
        -- Heatwave Beam
        playAnim("Dragon2ZCharge", 1.2, false)
        task.spawn(function()
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 1,
            })
            task.wait(0.3)
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 2,
            })
        end)

    elseif skillKey == "X" then
        -- Roaring Claw Dash
        playAnim("Dragon2XCharge", 1, false)
        task.spawn(function()
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 1,
            })
            task.wait(0.25)
            playAnim("Dragon2XDash", 1.2, false)
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 2,
            })
        end)

    elseif skillKey == "C" then
        -- Skyward Volley / Leap
        playAnim("Dragon2CJump", 1, false)
        task.spawn(function()
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 1,
            })
            task.wait(0.2)
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                MousePos = { Value = targetPos },
                Stage = 2,
            })
        end)

    elseif skillKey == "V" then
        -- Ciclo de Transformacion
        if Engine.CurrentMode == "None" then
            applyEastDragon(Engine.CurrentSkin)
        elseif Engine.CurrentMode == "East" then
            applyWestDragon(Engine.CurrentSkin)
        elseif Engine.CurrentMode == "West" then
            applyHybridDragon()
        else
            cleanModels()
        end

    elseif skillKey == "F" then
        -- Vuelo de Dragon
        if Engine.IsFlying then
            -- Detener vuelo
            Engine.IsFlying = false
            if Engine.FlyBodyVelocity then Engine.FlyBodyVelocity:Destroy(); Engine.FlyBodyVelocity = nil end
            if Engine.FlyBodyGyro then Engine.FlyBodyGyro:Destroy(); Engine.FlyBodyGyro = nil end
            playAnim("Dragon2FEnd", 1, false)
        else
            -- Iniciar vuelo
            Engine.IsFlying = true
            playAnim("Dragon2FLoop", 1, true)
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                Stage = 1,
            })

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = root
            Engine.FlyBodyVelocity = bv

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bg.P = 15000
            bg.CFrame = root.CFrame
            bg.Parent = root
            Engine.FlyBodyGyro = bg

            trackConn(RunService.Heartbeat:Connect(function()
                if not Engine.IsFlying or not root.Parent then return end
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    bv.Velocity = moveDir.Unit * Engine.FlightSpeed
                    bg.CFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
                else
                    bv.Velocity = Vector3.zero
                end
            end))
        end

    elseif skillKey == "M1" then
        -- Combo de Ataque Basico M1
        local now = tick()
        if now - lastM1Time > 1.2 then m1ComboIndex = 1 end
        lastM1Time = now

        local animName = "Dragon2M" .. tostring(m1ComboIndex)
        playAnim(animName, 1.2, false)

        task.spawn(function()
            pcall(effectFunc, {
                player = player,
                hrp = root,
                Rig = char,
                Origin = root.Position,
                StartCFrame = root.CFrame,
                Combo = m1ComboIndex,
                Stage = 1,
            })
        end)

        m1ComboIndex = (m1ComboIndex % 5) + 1
    end
end

-- ================================================================================
-- TECLAS DE CONTROL
-- ================================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then fireSkill("Z")
    elseif input.KeyCode == Enum.KeyCode.X then fireSkill("X")
    elseif input.KeyCode == Enum.KeyCode.C then fireSkill("C")
    elseif input.KeyCode == Enum.KeyCode.V then fireSkill("V")
    elseif input.KeyCode == Enum.KeyCode.F then fireSkill("F")
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then fireSkill("M1")
    end
end))

-- ================================================================================
-- INTERFAZ GRAFICA (POLAR DRAGON REWORK CONTROLLER)
-- Sin emojis, estilizada, compacta y responsiva.
-- ================================================================================
local function createUI()
    local oldUI = CoreGui:FindFirstChild("PolarDragonUI")
    if oldUI then oldUI:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PolarDragonUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 360, 0, 480)
    mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 52, 68)
    stroke.Thickness = 1.2
    stroke.Parent = mainFrame

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "POLAR DRAGON REWORK ENGINE"
    title.TextColor3 = Color3.fromRGB(230, 235, 245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180, 185, 195)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)

    -- Contenedor de Controles con Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 44)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 68, 88)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 680)
    scroll.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local function createSectionTitle(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text:upper()
        lbl.TextColor3 = Color3.fromRGB(110, 125, 150)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = scroll
        return lbl
    end

    local function createButton(text, bgCol, order, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = bgCol or Color3.fromRGB(28, 32, 44)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(225, 230, 240)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.LayoutOrder = order
        btn.Parent = scroll

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 6)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromRGB(45, 52, 68)
        bStroke.Thickness = 1
        bStroke.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Seccion 1: Formas de Dragon
    createSectionTitle("Transformaciones", 1)
    createButton("Dragon Oriental (Cuerpo Completo & Halo)", Color3.fromRGB(35, 45, 65), 2, function()
        applyEastDragon(Engine.CurrentSkin)
    end)
    createButton("Dragon Occidental (Alas Draco & Cola)", Color3.fromRGB(35, 45, 65), 3, function()
        applyWestDragon(Engine.CurrentSkin)
    end)
    createButton("Modo Hibrido (Alas, Cola & Aura)", Color3.fromRGB(35, 45, 65), 4, function()
        applyHybridDragon()
    end)
    createButton("Desactivar Transformacion", Color3.fromRGB(55, 30, 35), 5, function()
        cleanModels()
    end)

    -- Seccion 2: Habilidades
    createSectionTitle("Ataques & Habilidades (Keybinds: Z, X, C, V, F, M1)", 6)
    createButton("Z: Heatwave Beam (Aliento de Dragon)", Color3.fromRGB(30, 35, 48), 7, function() fireSkill("Z") end)
    createButton("X: Roaring Claw (Garras & Slam)", Color3.fromRGB(30, 35, 48), 8, function() fireSkill("X") end)
    createButton("C: Skyward Volley (Salto & Proyectil)", Color3.fromRGB(30, 35, 48), 9, function() fireSkill("C") end)
    createButton("V: Alternar Transformacion", Color3.fromRGB(30, 35, 48), 10, function() fireSkill("V") end)
    createButton("F: Dragon Soar (Alternar Vuelo Libre)", Color3.fromRGB(30, 35, 48), 11, function() fireSkill("F") end)
    createButton("M1: Combo de Ataque Basico (1-5)", Color3.fromRGB(30, 35, 48), 12, function() fireSkill("M1") end)

    -- Seccion 3: Skins Oficiales
    createSectionTitle("Skins Oficiales (14 Variantes)", 13)
    for idx, skin in ipairs(SKINS_LIST) do
        createButton("Skin: " .. skin, Color3.fromRGB(24, 28, 38), 14 + idx, function()
            Engine.CurrentSkin = skin
            if Engine.CurrentMode == "East" then
                applyEastDragon(skin)
            elseif Engine.CurrentMode == "West" then
                applyWestDragon(skin)
            end
        end)
    end

    return screenGui
end

createUI()

-- Limpieza global al detener
Engine.Cleanup = function()
    for _, c in ipairs(Engine.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Engine.Connections)
    cleanModels()
    local ui = CoreGui:FindFirstChild("PolarDragonUI")
    if ui then ui:Destroy() end
    getgenv().DragonPreviewEngine = nil
end

print("[POLAR DRAGON REWORK] Engine iniciado con exito. Presiona Z, X, C, V, F o usa el panel UI.")
