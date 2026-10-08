--[[
    ================================================================================
    POLAR DRAGON REWORK ENGINE (V3 - FULL 3D VISUAL & COMBAT SUITE)
    ================================================================================
    Desarrollado y Verificado mediante Decompilacion Real MCP en Blox Fruits.
    
    100% VISIBLE, 100% CLIENT-SIDED, ZERO-FREEZE, SIN EMOJIS:
    1. Dragon Oriental (Kaido Beast Form):
       - Cabeza colosal de Dragon (12 studs) y cuerpo serpentino multi-segmento.
       - Halo orbital flameante de FX.EasternDragon.
       - Aura de vortice de viento (DragonTransformation).
       - Shader Highlight corporal con tinte de escamas.
       - Escalado 2.0x de bestia colosal.
    2. Dragon Occidental (Wyvern Beast Form):
       - Alas gigantes WingV2 (Cube.008, Cube.007, Cube.001, Cube.002) escaladas 3.5x.
       - Llamas vivas en alas (WingFlame).
       - Cresta de cabeza de dragon y cola segmentada.
       - Escalado 1.6x.
    3. Forma Hibrida:
       - Alas compactas, cola, aura en manos y postura oficial Dragon2VHybrid.
    4. 14 Skins Oficiales con Colorimetria Dinamica:
       - Phoenix Sky, Red, Blue, Frostbite, Eclipse, Blood Moon, Emerald,
         Black, Purple, Yellow, Orange, Ember, Green, Violet Night.
       - Recoloracion automatica de mallas, halos, alas, highlight y particulas.
    5. Habilidades y Combate Completo (Z, X, C, V, F, M1):
       - Z: Heatwave Cannon (Aliento de Dragon + Proyectil + Anillo de Calor).
       - X: Infernal Pincer (Embestida con garras + FireRing + Crater GrabSlam).
       - C: Scorching Downfall (Salto aereo + Proyectil volcanico + Shockwave).
       - V: Imperial Evolution (Cinematica de transformacion + Cambio de forma).
       - F: Draconic Soar (Vuelo supersonico 3D a 170 studs/s guiado por camara).
       - M1: Combo de Garras (Animaciones Dragon2M1 a M5 con cortes cortantes).
    ================================================================================
--]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Limpieza de sesion previa
if getgenv().PolarDragonEngine and getgenv().PolarDragonEngine.Cleanup then
    pcall(getgenv().PolarDragonEngine.Cleanup)
end

local Engine = {
    Connections = {},
    SpawnedInstances = {},
    ActiveTracks = {},
    CurrentMode = "None", -- "East", "West", "Hybrid", "None"
    CurrentSkin = "Phoenix Sky",
    IsFlying = false,
    FlightSpeed = 170,
    ActiveModel = nil,
    M1Combo = 1,
    LastM1Time = 0,
}
getgenv().PolarDragonEngine = Engine

local function trackConn(c)
    table.insert(Engine.Connections, c)
    return c
end

-- ================================================================================
-- TABLA DE 14 SKINS OFICIALES (COLORES Y MATERIALES)
-- ================================================================================
local SKINS_DATA = {
    ["Phoenix Sky"] = {
        Primary = Color3.fromRGB(108, 171, 188),
        Secondary = Color3.fromRGB(248, 120, 180),
        Neon = Color3.fromRGB(147, 252, 236),
        Material = Enum.Material.Neon,
    },
    ["Red"] = {
        Primary = Color3.fromRGB(220, 30, 20),
        Secondary = Color3.fromRGB(255, 120, 30),
        Neon = Color3.fromRGB(255, 50, 20),
        Material = Enum.Material.Neon,
    },
    ["Blue"] = {
        Primary = Color3.fromRGB(25, 118, 210),
        Secondary = Color3.fromRGB(66, 165, 245),
        Neon = Color3.fromRGB(0, 229, 255),
        Material = Enum.Material.Neon,
    },
    ["Frostbite"] = {
        Primary = Color3.fromRGB(178, 235, 242),
        Secondary = Color3.fromRGB(255, 255, 255),
        Neon = Color3.fromRGB(128, 222, 234),
        Material = Enum.Material.ForceField,
    },
    ["Eclipse"] = {
        Primary = Color3.fromRGB(18, 18, 24),
        Secondary = Color3.fromRGB(103, 58, 183),
        Neon = Color3.fromRGB(142, 68, 173),
        Material = Enum.Material.Neon,
    },
    ["Blood Moon"] = {
        Primary = Color3.fromRGB(136, 14, 79),
        Secondary = Color3.fromRGB(183, 28, 28),
        Neon = Color3.fromRGB(255, 23, 68),
        Material = Enum.Material.Neon,
    },
    ["Emerald"] = {
        Primary = Color3.fromRGB(0, 150, 80),
        Secondary = Color3.fromRGB(0, 230, 118),
        Neon = Color3.fromRGB(105, 240, 174),
        Material = Enum.Material.Neon,
    },
    ["Black"] = {
        Primary = Color3.fromRGB(28, 28, 32),
        Secondary = Color3.fromRGB(60, 60, 70),
        Neon = Color3.fromRGB(120, 120, 140),
        Material = Enum.Material.Glass,
    },
    ["Purple"] = {
        Primary = Color3.fromRGB(123, 31, 162),
        Secondary = Color3.fromRGB(171, 71, 188),
        Neon = Color3.fromRGB(224, 64, 251),
        Material = Enum.Material.Neon,
    },
    ["Yellow"] = {
        Primary = Color3.fromRGB(255, 214, 0),
        Secondary = Color3.fromRGB(255, 171, 0),
        Neon = Color3.fromRGB(255, 238, 88),
        Material = Enum.Material.Neon,
    },
    ["Orange"] = {
        Primary = Color3.fromRGB(245, 124, 0),
        Secondary = Color3.fromRGB(255, 87, 34),
        Neon = Color3.fromRGB(255, 138, 101),
        Material = Enum.Material.Neon,
    },
    ["Ember"] = {
        Primary = Color3.fromRGB(255, 111, 0),
        Secondary = Color3.fromRGB(255, 160, 0),
        Neon = Color3.fromRGB(255, 213, 79),
        Material = Enum.Material.Neon,
    },
    ["Green"] = {
        Primary = Color3.fromRGB(46, 125, 50),
        Secondary = Color3.fromRGB(76, 175, 80),
        Neon = Color3.fromRGB(129, 199, 132),
        Material = Enum.Material.Neon,
    },
    ["Violet Night"] = {
        Primary = Color3.fromRGB(74, 20, 140),
        Secondary = Color3.fromRGB(0, 188, 212),
        Neon = Color3.fromRGB(156, 39, 176),
        Material = Enum.Material.Neon,
    },
}

-- ================================================================================
-- RECURSOS NATIVOS DE BLOX FRUITS
-- ================================================================================
local FX = nil
pcall(function() FX = require(ReplicatedStorage:WaitForChild("FX")) end)

local Util = nil
pcall(function() Util = require(ReplicatedStorage:WaitForChild("Util")) end)

local Dragon2FX = nil
pcall(function() if FX then Dragon2FX = FX:Get("Dragon2") end end)

local EasternFX = nil
pcall(function() if FX then EasternFX = FX:Get("EasternDragon") end end)

local DragonAnims = ReplicatedStorage:FindFirstChild("Storage")
    and ReplicatedStorage.Storage:FindFirstChild("Anims")
    and ReplicatedStorage.Storage.Anims:FindFirstChild("2")
    and ReplicatedStorage.Storage.Anims["2"]:FindFirstChild("Dragon2")

-- ================================================================================
-- UTILIDADES DE PERSONAJE Y ANIMACIONES
-- ================================================================================
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or root
    return char, root, hum, torso
end

local function playAnim(name, speed, looped)
    if not DragonAnims then return nil end
    local animObj = DragonAnims:FindFirstChild(name)
    if not animObj then return nil end
    local char, _, hum = getChar()
    if not hum then return nil end

    local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 2)
    if not animator then return nil end

    local track = animator:LoadAnimation(animObj)
    track.Looped = (looped == true)
    track:Play(0.1, 1, speed or 1)
    table.insert(Engine.ActiveTracks, track)
    return track
end

local function stopAllAnims()
    for _, t in ipairs(Engine.ActiveTracks) do
        pcall(function() t:Stop(0.15) end)
    end
    table.clear(Engine.ActiveTracks)
end

local function cleanActiveModel()
    if Engine.ActiveModel then
        pcall(function() Engine.ActiveModel:Destroy() end)
        Engine.ActiveModel = nil
    end
    local char = player.Character
    if char then
        local old = char:FindFirstChild("PolarDragonContainer")
        if old then pcall(function() old:Destroy() end) end
        pcall(function() char:ScaleTo(1.0) end)
    end
    stopAllAnims()
    Engine.CurrentMode = "None"
end

-- ================================================================================
-- CONSTRUCCION DE TRANSFORMACIONES 3D VISIBLES
-- ================================================================================

-- 1. DRAGON ORIENTAL (KAIDO SERPENTINE BEAST)
local function spawnEastDragon(skinName)
    cleanActiveModel()
    local char, root, hum, torso = getChar()
    if not char or not root then return end

    skinName = skinName or Engine.CurrentSkin
    Engine.CurrentSkin = skinName
    Engine.CurrentMode = "East"
    local skin = SKINS_DATA[skinName] or SKINS_DATA["Phoenix Sky"]

    local container = Instance.new("Model")
    container.Name = "PolarDragonContainer"
    container.Parent = char
    Engine.ActiveModel = container

    -- A. Highlight Corporal
    local hl = Instance.new("Highlight")
    hl.Name = "DragonSkinHighlight"
    hl.FillColor = skin.Primary
    hl.OutlineColor = skin.Neon
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0.1
    hl.Parent = container

    -- B. Cuerpo Serpentino Completo con Cabeza (Lightning2 DragonModel)
    pcall(function()
        local dmSource = ReplicatedStorage:FindFirstChild("FX")
            and ReplicatedStorage.FX:FindFirstChild("Lightning2")
            and ReplicatedStorage.FX.Lightning2:FindFirstChild("ZHeld")
            and ReplicatedStorage.FX.Lightning2.ZHeld:FindFirstChild("Assets")
            and ReplicatedStorage.FX.Lightning2.ZHeld.Assets:FindFirstChild("Phase0A")
            and ReplicatedStorage.FX.Lightning2.ZHeld.Assets.Phase0A:FindFirstChild("DragonModel")

        if dmSource then
            local dragonRig = dmSource:Clone()
            dragonRig.Name = "SerpentineBody"

            for _, p in ipairs(dragonRig:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Primary
                    p.Material = skin.Material
                elseif p:IsA("ParticleEmitter") then
                    p.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                end
            end

            local dHead = dragonRig:FindFirstChild("DragonHead") or dragonRig.PrimaryPart or dragonRig:FindFirstChildWhichIsA("BasePart")
            if dHead then
                dHead.CFrame = root.CFrame * CFrame.new(0, 4.5, -7.5) * CFrame.Angles(0, math.rad(180), 0)
                local w = Instance.new("WeldConstraint")
                w.Part0 = root
                w.Part1 = dHead
                w.Parent = dHead
            end
            dragonRig.Parent = container
        end
    end)

    -- C. Halo Flameante Oriental (EasternDragon.Halo)
    pcall(function()
        if EasternFX and EasternFX:FindFirstChild("Halo") then
            local halo = EasternFX.Halo:Clone()
            halo.Name = "DragonHalo"
            for _, p in ipairs(halo:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Neon
                elseif p:IsA("ParticleEmitter") then
                    p.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                end
            end
            halo:ScaleTo(1.6)
            local hRoot = halo.PrimaryPart or halo:FindFirstChild("RootPart") or halo:FindFirstChildWhichIsA("BasePart")
            if hRoot then
                hRoot.CFrame = root.CFrame * CFrame.new(0, 8.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
                local hw = Instance.new("WeldConstraint")
                hw.Part0 = root
                hw.Part1 = hRoot
                hw.Parent = hRoot
            end
            halo.Parent = container
        end
    end)

    -- D. Vortice de Viento y Fuego (DragonTransformation)
    pcall(function()
        local dt = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Models")
            and ReplicatedStorage.Assets.Models:FindFirstChild("DragonTransformation")
        if dt then
            local dtClone = dt:Clone()
            dtClone.Name = "WindAura"
            for _, p in ipairs(dtClone:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Secondary
                    p.Transparency = 0.5
                end
            end
            dtClone:ScaleTo(1.8)
            local dtRoot = dtClone.PrimaryPart or dtClone:FindFirstChild("Root") or dtClone:FindFirstChildWhichIsA("BasePart")
            if dtRoot then
                dtRoot.CFrame = root.CFrame
                local dw = Instance.new("WeldConstraint")
                dw.Part0 = root
                dw.Part1 = dtRoot
                dw.Parent = dtRoot
            end
            dtClone.Parent = container
        end
    end)

    -- E. Escalar a Bestia Colosal 2.0x
    pcall(function() char:ScaleTo(2.0) end)
end

-- 2. DRAGON OCCIDENTAL (WYVERN CON ALAS GIGANTES)
local function spawnWestDragon(skinName)
    cleanActiveModel()
    local char, root, hum, torso = getChar()
    if not char or not root then return end

    skinName = skinName or Engine.CurrentSkin
    Engine.CurrentSkin = skinName
    Engine.CurrentMode = "West"
    local skin = SKINS_DATA[skinName] or SKINS_DATA["Phoenix Sky"]

    local container = Instance.new("Model")
    container.Name = "PolarDragonContainer"
    container.Parent = char
    Engine.ActiveModel = container

    -- A. Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "DragonSkinHighlight"
    hl.FillColor = skin.Primary
    hl.OutlineColor = skin.Neon
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0.1
    hl.Parent = container

    -- B. Alas Gigantes WingV2 (3.5x Scale)
    pcall(function()
        local wingsSource = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Wings")
            and ReplicatedStorage.Assets.Wings:FindFirstChild("WingV2")
        if wingsSource then
            local wings = wingsSource:Clone()
            wings.Name = "ColossalWings"
            for _, p in ipairs(wings:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Primary
                    p.Material = skin.Material
                end
            end
            wings:ScaleTo(3.2)
            local wRoot = wings:FindFirstChild("RootPart") or wings.PrimaryPart or wings:FindFirstChildWhichIsA("BasePart")
            if wRoot then
                wRoot.CFrame = torso.CFrame * CFrame.new(0, 1.2, 1.3) * CFrame.Angles(0, math.rad(180), 0)
                local w = Instance.new("WeldConstraint")
                w.Part0 = torso
                w.Part1 = wRoot
                w.Parent = wRoot
            end
            wings.Parent = container
        end
    end)

    -- C. Llamas Vivas en Alas
    pcall(function()
        local flameSource = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Wings")
            and ReplicatedStorage.Assets.Wings:FindFirstChild("WingFlame")
        if flameSource then
            local flame = flameSource:Clone()
            flame.Name = "WingFlames"
            flame.Anchored = false
            flame.CanCollide = false
            for _, p in ipairs(flame:GetDescendants()) do
                if p:IsA("ParticleEmitter") then
                    p.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                end
            end
            flame.CFrame = torso.CFrame * CFrame.new(0, 1.8, 1.5)
            local fw = Instance.new("WeldConstraint")
            fw.Part0 = torso
            fw.Part1 = flame
            fw.Parent = flame
            flame.Parent = container
        end
    end)

    -- D. Cabeza Crestada en Pecho (DragonHeadBig)
    pcall(function()
        local dhSource = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Models")
            and (ReplicatedStorage.Assets.Models:FindFirstChild("DragonHeadBig") or ReplicatedStorage.Assets.Models:FindFirstChild("DragonHead"))
        if dhSource then
            local dh = dhSource:Clone()
            dh.Name = "CrestHead"
            dh.Anchored = false
            dh.CanCollide = false
            dh.Massless = true
            dh.Color = skin.Primary
            dh.Material = skin.Material
            dh.Size = Vector3.new(4, 4, 4.5)
            dh.CFrame = torso.CFrame * CFrame.new(0, 0.4, -1.3) * CFrame.Angles(0, math.rad(180), 0)
            local dw = Instance.new("WeldConstraint")
            dw.Part0 = torso
            dw.Part1 = dh
            dw.Parent = dh
            dh.Parent = container
        end
    end)

    -- E. Vortice de Viento
    pcall(function()
        local dt = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Models")
            and ReplicatedStorage.Assets.Models:FindFirstChild("DragonTransformation")
        if dt then
            local dtClone = dt:Clone()
            dtClone.Name = "WindAura"
            for _, p in ipairs(dtClone:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Secondary
                    p.Transparency = 0.5
                end
            end
            dtClone:ScaleTo(1.5)
            local dtRoot = dtClone.PrimaryPart or dtClone:FindFirstChild("Root") or dtClone:FindFirstChildWhichIsA("BasePart")
            if dtRoot then
                dtRoot.CFrame = root.CFrame
                local dw = Instance.new("WeldConstraint")
                dw.Part0 = root
                dw.Part1 = dtRoot
                dw.Parent = dtRoot
            end
            dtClone.Parent = container
        end
    end)

    pcall(function() char:ScaleTo(1.6) end)
end

-- 3. FORMA HIBRIDA
local function spawnHybridDragon()
    cleanActiveModel()
    local char, root, hum, torso = getChar()
    if not char or not root then return end

    Engine.CurrentMode = "Hybrid"
    local skin = SKINS_DATA[Engine.CurrentSkin] or SKINS_DATA["Phoenix Sky"]

    local container = Instance.new("Model")
    container.Name = "PolarDragonContainer"
    container.Parent = char
    Engine.ActiveModel = container

    -- Alas compactas
    pcall(function()
        local wingsSource = ReplicatedStorage:FindFirstChild("Assets")
            and ReplicatedStorage.Assets:FindFirstChild("Wings")
            and ReplicatedStorage.Assets.Wings:FindFirstChild("WingV2")
        if wingsSource then
            local wings = wingsSource:Clone()
            wings.Name = "HybridWings"
            for _, p in ipairs(wings:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                    p.Color = skin.Primary
                    p.Material = skin.Material
                end
            end
            wings:ScaleTo(1.8)
            local wRoot = wings:FindFirstChild("RootPart") or wings.PrimaryPart or wings:FindFirstChildWhichIsA("BasePart")
            if wRoot then
                wRoot.CFrame = torso.CFrame * CFrame.new(0, 0.5, 0.9) * CFrame.Angles(0, math.rad(180), 0)
                local w = Instance.new("WeldConstraint")
                w.Part0 = torso
                w.Part1 = wRoot
                w.Parent = wRoot
            end
            wings.Parent = container
        end
    end)

    -- Aura en Manos (EasternDragon.HandAura)
    pcall(function()
        if EasternFX and EasternFX:FindFirstChild("HandAura") then
            local rArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            if rArm then
                local ha = EasternFX.HandAura:Clone()
                ha.Name = "HandAura"
                ha.Anchored = false
                ha.CanCollide = false
                ha.CFrame = rArm.CFrame
                local w = Instance.new("WeldConstraint")
                w.Part0 = rArm
                w.Part1 = ha
                w.Parent = ha
                ha.Parent = container
            end
        end
    end)

    -- Postura oficial de combate hibrido
    playAnim("Dragon2VHybrid", 1, true)
end

-- ================================================================================
-- DISPARADOR DE HABILIDADES AUTENTICAS (Z, X, C, V, F, M1)
-- ================================================================================
local function castSkill(key)
    local char, root, hum, torso = getChar()
    if not char or not root then return end

    local skin = SKINS_DATA[Engine.CurrentSkin] or SKINS_DATA["Phoenix Sky"]
    local targetPos = mouse.Hit and mouse.Hit.Position or (root.Position + root.CFrame.LookVector * 100)

    if key == "Z" then
        -- HEATWAVE CANNON (Aliento de Dragon)
        playAnim("Dragon2ZCharge", 1.2, false)

        task.spawn(function()
            -- Boca de fuego
            if Dragon2FX and Dragon2FX:FindFirstChild("Z") and Dragon2FX.Z:FindFirstChild("MouthFlame") then
                local mf = Dragon2FX.Z.MouthFlame:Clone()
                for _, p in ipairs(mf:GetDescendants()) do
                    if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false end
                    if p:IsA("ParticleEmitter") then
                        p.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                        p.Enabled = true
                    end
                end
                mf:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 2, -5))
                mf.Parent = workspace._WorldOrigin
                Debris:AddItem(mf, 1.5)
            end

            task.wait(0.2)

            -- Proyectil y Rayo
            local beamPart = Instance.new("Part")
            beamPart.Name = "DragonHeatBeam"
            beamPart.Anchored = true
            beamPart.CanCollide = false
            beamPart.Material = Enum.Material.Neon
            beamPart.Color = skin.Neon
            beamPart.Size = Vector3.new(6, 6, 80)
            local beamDir = (targetPos - root.Position).Unit
            beamPart.CFrame = CFrame.lookAt(root.Position + beamDir * 40, root.Position + beamDir * 100)
            beamPart.Parent = workspace._WorldOrigin
            Debris:AddItem(beamPart, 0.4)

            -- Impacto y Anillo de Calor
            if Dragon2FX and Dragon2FX.Z:FindFirstChild("HeatwaveRing") then
                local ring = Dragon2FX.Z.HeatwaveRing:Clone()
                ring.Anchored = true
                ring.CanCollide = false
                ring.Color = skin.Primary
                ring.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
                ring.Parent = workspace._WorldOrigin
                TweenService:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
                    Size = Vector3.new(90, 8, 90),
                    Transparency = 1
                }):Play()
                Debris:AddItem(ring, 0.7)
            end

            -- Particulas de Explosion
            if Dragon2FX and Dragon2FX.Z:FindFirstChild("BlastParticles") then
                local bp = Dragon2FX.Z.BlastParticles:Clone()
                bp.Anchored = true
                bp.CanCollide = false
                bp.CFrame = CFrame.new(targetPos)
                for _, pe in ipairs(bp:GetDescendants()) do
                    if pe:IsA("ParticleEmitter") then
                        pe.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                        pe:Emit(25)
                    end
                end
                bp.Parent = workspace._WorldOrigin
                Debris:AddItem(bp, 2)
            end
        end)

    elseif key == "X" then
        -- INFERNAL PINCER (Embestida & Garras)
        playAnim("Dragon2XCharge", 1, false)

        task.spawn(function()
            task.wait(0.15)
            playAnim("Dragon2XDash", 1.3, false)

            -- Embestida hacia adelante
            local forwardDir = root.CFrame.LookVector
            root.AssemblyLinearVelocity = forwardDir * 180

            -- Fire Ring en el inicio
            if Dragon2FX and Dragon2FX:FindFirstChild("X") and Dragon2FX.X:FindFirstChild("FireRing") then
                local ring = Dragon2FX.X.FireRing:Clone()
                ring.Anchored = true
                ring.CanCollide = false
                ring.CFrame = root.CFrame
                ring.Parent = workspace._WorldOrigin
                TweenService:Create(ring, TweenInfo.new(0.4), {
                    Size = Vector3.new(40, 6, 40),
                    Transparency = 1
                }):Play()
                Debris:AddItem(ring, 0.5)
            end

            task.wait(0.3)

            -- Crater GrabSlam en destino
            if Dragon2FX and Dragon2FX.X:FindFirstChild("GrabSlam") then
                local slam = Dragon2FX.X.GrabSlam:Clone()
                slam.Anchored = true
                slam.CanCollide = false
                slam.CFrame = root.CFrame * CFrame.new(0, -2, 0)
                for _, pe in ipairs(slam:GetDescendants()) do
                    if pe:IsA("ParticleEmitter") then
                        pe.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                        pe:Emit(30)
                    end
                end
                slam.Parent = workspace._WorldOrigin
                Debris:AddItem(slam, 2.5)
            end
        end)

    elseif key == "C" then
        -- SCORCHING DOWNFALL (Salto y Proyectil Volcanico)
        playAnim("Dragon2CJump", 1, false)

        task.spawn(function()
            -- Salto de dragon
            root.AssemblyLinearVelocity = Vector3.new(0, 140, 0)
            task.wait(0.35)

            -- Proyectil descendente
            if Dragon2FX and Dragon2FX:FindFirstChild("C") and Dragon2FX.C:FindFirstChild("Projectile") then
                local proj = Dragon2FX.C.Projectile:Clone()
                proj.Anchored = true
                proj.CanCollide = false
                proj.Color = skin.Neon
                proj.CFrame = CFrame.lookAt(root.Position, targetPos)
                proj.Parent = workspace._WorldOrigin

                local tween = TweenService:Create(proj, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    CFrame = CFrame.new(targetPos)
                })
                tween:Play()
                tween.Completed:Wait()
                proj:Destroy()
            end

            -- Onda de choque colosal (ShockwaveMesh)
            if Dragon2FX and Dragon2FX.C:FindFirstChild("ShockwaveMesh") then
                local sw = Dragon2FX.C.ShockwaveMesh:Clone()
                sw.Anchored = true
                sw.CanCollide = false
                sw.Color = skin.Primary
                sw.CFrame = CFrame.new(targetPos)
                sw.Parent = workspace._WorldOrigin
                TweenService:Create(sw, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
                    Size = Vector3.new(120, 8, 120),
                    Transparency = 1
                }):Play()
                Debris:AddItem(sw, 0.8)
            end
        end)

    elseif key == "V" then
        -- IMPERIAL EVOLUTION (Alternar Transformacion con Cinematica)
        pcall(function()
            if EasternFX and EasternFX:FindFirstChild("Transform") and EasternFX.Transform:FindFirstChild("Phase1") then
                local p1 = EasternFX.Transform.Phase1:Clone()
                for _, pe in ipairs(p1:GetDescendants()) do
                    if pe:IsA("ParticleEmitter") then pe:Emit(40) end
                end
                p1.Parent = workspace._WorldOrigin
                Debris:AddItem(p1, 2)
            end
        end)

        if Engine.CurrentMode == "None" then
            spawnEastDragon(Engine.CurrentSkin)
        elseif Engine.CurrentMode == "East" then
            spawnWestDragon(Engine.CurrentSkin)
        elseif Engine.CurrentMode == "West" then
            spawnHybridDragon()
        else
            cleanActiveModel()
        end

    elseif key == "F" then
        -- DRACONIC SOAR (Vuelo 3D Libre Supersónico)
        if Engine.IsFlying then
            Engine.IsFlying = false
            if Engine.FlyBV then Engine.FlyBV:Destroy(); Engine.FlyBV = nil end
            if Engine.FlyBG then Engine.FlyBG:Destroy(); Engine.FlyBG = nil end
            stopAllAnims()
            playAnim("Dragon2FEnd", 1.2, false)
        else
            Engine.IsFlying = true
            playAnim("Dragon2FLoop", 1, true)

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            bv.Velocity = Vector3.zero
            bv.Parent = root
            Engine.FlyBV = bv

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            bg.P = 20000
            bg.CFrame = root.CFrame
            bg.Parent = root
            Engine.FlyBG = bg

            trackConn(RunService.Heartbeat:Connect(function()
                if not Engine.IsFlying or not root.Parent then return end
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

                if dir.Magnitude > 0 then
                    bv.Velocity = dir.Unit * Engine.FlightSpeed
                    bg.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
                else
                    bv.Velocity = Vector3.zero
                end
            end))
        end

    elseif key == "M1" then
        -- COMBO DE ATAQUE BASICO (1-5)
        local now = tick()
        if now - Engine.LastM1Time > 1.2 then Engine.M1Combo = 1 end
        Engine.LastM1Time = now

        local animName = "Dragon2M" .. tostring(Engine.M1Combo)
        playAnim(animName, 1.25, false)

        -- Efecto cortante
        if Dragon2FX and Dragon2FX:FindFirstChild("M1") and Dragon2FX.M1:FindFirstChild("DragonBasicAttack") then
            local slash = Dragon2FX.M1.DragonBasicAttack:Clone()
            for _, pe in ipairs(slash:GetDescendants()) do
                if pe:IsA("ParticleEmitter") then
                    pe.Color = ColorSequence.new(skin.Neon, skin.Secondary)
                    pe:Emit(15)
                end
            end
            slash.Parent = workspace._WorldOrigin
            Debris:AddItem(slash, 1)
        end

        Engine.M1Combo = (Engine.M1Combo % 5) + 1
    end
end

-- ================================================================================
-- CONEXIONES DE TECLADO Y RATON
-- ================================================================================
trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then castSkill("Z")
    elseif input.KeyCode == Enum.KeyCode.X then castSkill("X")
    elseif input.KeyCode == Enum.KeyCode.C then castSkill("C")
    elseif input.KeyCode == Enum.KeyCode.V then castSkill("V")
    elseif input.KeyCode == Enum.KeyCode.F then castSkill("F")
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then castSkill("M1")
    end
end))

-- ================================================================================
-- PANEL DE CONTROL COMPACTO Y ELEGANTE (SIN EMOJIS)
-- ================================================================================
local function buildUI()
    local old = CoreGui:FindFirstChild("PolarDragonV3UI")
    if old then old:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "PolarDragonV3UI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 370, 0, 520)
    frame.Position = UDim2.new(0.04, 0, 0.18, 0)
    frame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(42, 48, 64)
    stroke.Thickness = 1.2
    stroke.Parent = frame

    -- Barra Superior
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
    topBar.BorderSizePixel = 0
    topBar.Parent = frame

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 8)
    tbCorner.Parent = topBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -45, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "POLAR DRAGON REWORK V3"
    title.TextColor3 = Color3.fromRGB(235, 240, 250)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -34, 0, 3)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180, 185, 195)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = topBar
    closeBtn.MouseButton1Click:Connect(function()
        sg.Enabled = not sg.Enabled
    end)

    -- Scroll de Contenidos
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -46)
    scroll.Position = UDim2.new(0, 8, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(55, 62, 82)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local function addHeader(txt, order)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = txt:upper()
        lbl.TextColor3 = Color3.fromRGB(115, 130, 155)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = scroll
    end

    local function addBtn(txt, bgCol, order, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 31)
        btn.BackgroundColor3 = bgCol or Color3.fromRGB(26, 30, 42)
        btn.BorderSizePixel = 0
        btn.Text = txt
        btn.TextColor3 = Color3.fromRGB(230, 235, 245)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.LayoutOrder = order
        btn.Parent = scroll

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = btn

        local bs = Instance.new("UIStroke")
        bs.Color = Color3.fromRGB(42, 48, 64)
        bs.Thickness = 1
        bs.Parent = btn

        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    -- Seccion 1: Transformaciones
    addHeader("Transformaciones 3D", 1)
    addBtn("Dragon Oriental (Cuerpo Completo & Halo)", Color3.fromRGB(36, 48, 70), 2, function()
        spawnEastDragon(Engine.CurrentSkin)
    end)
    addBtn("Dragon Occidental (Alas Wyvern & Cresta)", Color3.fromRGB(36, 48, 70), 3, function()
        spawnWestDragon(Engine.CurrentSkin)
    end)
    addBtn("Modo Hibrido (Alas, Manos & Postura)", Color3.fromRGB(36, 48, 70), 4, function()
        spawnHybridDragon()
    end)
    addBtn("Desactivar Transformacion", Color3.fromRGB(60, 28, 32), 5, function()
        cleanActiveModel()
    end)

    -- Seccion 2: Habilidades
    addHeader("Ataques & Habilidades (Z, X, C, V, F, M1)", 6)
    addBtn("Z: Heatwave Cannon (Aliento de Dragon)", Color3.fromRGB(28, 34, 46), 7, function() castSkill("Z") end)
    addBtn("X: Infernal Pincer (Embestida & Crater)", Color3.fromRGB(28, 34, 46), 8, function() castSkill("X") end)
    addBtn("C: Scorching Downfall (Salto & Shockwave)", Color3.fromRGB(28, 34, 46), 9, function() castSkill("C") end)
    addBtn("V: Imperial Evolution (Ciclo de Formas)", Color3.fromRGB(28, 34, 46), 10, function() castSkill("V") end)
    addBtn("F: Draconic Soar (Alternar Vuelo Libre)", Color3.fromRGB(28, 34, 46), 11, function() castSkill("F") end)
    addBtn("M1: Combo de Garras (1-5)", Color3.fromRGB(28, 34, 46), 12, function() castSkill("M1") end)

    -- Seccion 3: 14 Skins Oficiales
    addHeader("Skins Oficiales (Recolorean Todo en Vivo)", 13)
    local skinOrder = 14
    for skinName, skinInfo in pairs(SKINS_DATA) do
        addBtn("Skin: " .. skinName, Color3.fromRGB(22, 26, 36), skinOrder, function()
            Engine.CurrentSkin = skinName
            if Engine.CurrentMode == "East" then
                spawnEastDragon(skinName)
            elseif Engine.CurrentMode == "West" then
                spawnWestDragon(skinName)
            elseif Engine.CurrentMode == "Hybrid" then
                spawnHybridDragon()
            end
        end)
        skinOrder = skinOrder + 1
    end

    return sg
end

buildUI()

-- Limpieza global
Engine.Cleanup = function()
    for _, c in ipairs(Engine.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Engine.Connections)
    cleanActiveModel()
    local old = CoreGui:FindFirstChild("PolarDragonV3UI")
    if old then old:Destroy() end
    getgenv().PolarDragonEngine = nil
end

print("[POLAR DRAGON REWORK V3] Motor cargado y listo. Presiona Z, X, C, V, F o usa el panel UI.")
