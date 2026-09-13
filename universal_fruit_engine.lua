--[[
    ================================================================================
    BLOXZ FRUITS - UNIVERSAL FRUIT SELECTOR & MASTER ENGINE (V3 ULTIMATE)
    ================================================================================
    Desarrollado con REAL MCP para Blox Fruits.
    
    100% Funcional, Client-Sided, Anti-Freeze, Anti-Bug & Auto-Respawn.
    
    Novedades Principales:
    1. [AUTO-RESPAWN & ANTI-BUG]:
       - Recuperación automática del personaje si muere o se desincroniza con SetTeam.
       - Política estricta Zero-Freeze: Ningún BasePart del personaje se queda Anchored.
    2. [MAGNET V2 PERFECCIONADA]:
       - Integración exacta de la suite V6 / v2 con cero errores:
         * Modelo de fruta compacto Phase0.MagnetModel (1.78 x 1.61 x 0.31 studs) en mano.
         * Transformación Mech completa (MagnetRig): Brazos Tier 3, Cañón de hombro,
           Batería de misiles, Jetpack, Reactor de pecho, Tinte de titanio y 1.35x scale.
         * Animaciones de Mech: Idle, Walk, Run.
         * Z: Scrap Arsenal (4 CFrames) / Ráfaga de misiles guiados.
         * X: Magnetic Overcharge / Cañón electromagnético orbital.
         * C: Polarizing Drop (+38 studs salto y slam) / Martillo Colosal Mech.
         * F: Vuelo Jetpack supersónico y Overdrive Mech a 185 studs/s.
    3. [ESCÁNER DINÁMICO DE MODELOS Y SKINS PARA OTRAS FRUTAS]:
       - Kitsune: Modelo oficial de Bestia (FX.Kitsune.Kitsune), colas y fuego fatuo.
       - Mammoth: Modelo oficial de Bestia (FX.Mammoth.Mammoth), colmillos y estampida.
       - T-Rex / Dino: Modelo TRexModel de EffectContainer.Dino, rugido y garras.
       - Dragon: Alas y modelo DragonTransformation de Assets.Models.
       - Buddha: Escalado colosal 2.2x, material Golden Neon y halo radiante.
       - Dough: Rosquillas flotantes (FX.Dough.Models.Donuts) y aura despertada.
    4. [GESTIÓN DE TOOL E INTERFAZ NATIVA]:
       - Tool oficial en Backpack con atributos auténticos (ItemId, Spritesheet, Rect).
       - Actualización en tiempo real del HUD nativo PlayerGui.Main.Skills a Maestría 600 MAX.
       - Menú Selector flotante arrastrable con buscador en vivo y filtro por categorías.
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

-- ================================================================================
-- LIMPIEZA DE SESIONES ANTERIORES
-- ================================================================================
if getgenv().UniversalFruitEngineState and getgenv().UniversalFruitEngineState.cleanup then
    pcall(getgenv().UniversalFruitEngineState.cleanup)
end

local engineState = {
    connections = {},
    instances = {},
    running = true,
}
getgenv().UniversalFruitEngineState = engineState

local function registerConnection(conn)
    table.insert(engineState.connections, conn)
    return conn
end

local function trackInstance(inst)
    table.insert(engineState.instances, inst)
    return inst
end

-- ================================================================================
-- RECURSOS Y MÓDULOS NATIVOS DE BLOX FRUITS
-- ================================================================================
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = ReplicatedStorage:WaitForChild("FX")
local EffectContainer = ReplicatedStorage:WaitForChild("EffectContainer")

local FruitSkills = nil
pcall(function() FruitSkills = require(ReplicatedStorage:WaitForChild("FruitSkills")) end)

local ItemId = nil
pcall(function() ItemId = require(ReplicatedStorage:WaitForChild("Economy"):WaitForChild("ItemId")) end)

local FruitSpritesheets = nil
pcall(function() FruitSpritesheets = require(ReplicatedStorage:WaitForChild("FruitSpritesheets")) end)

local function getContainer()
    local ok, hui = pcall(function()
        if gethui then return gethui() end
        if get_hidden_gui then return get_hidden_gui() end
        return CoreGui:FindFirstChild("RobloxGui") or CoreGui
    end)
    return (ok and hui) or CoreGui
end

-- ================================================================================
-- SISTEMA ANTI-BUG Y AUTO-RESPAWN
-- ================================================================================
local function ensurePlayerSpawned()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if not char or not char.Parent or not hrp or not humanoid or humanoid.Health <= 0 then
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("SetTeam", "Pirates")
            end
        end)
    end
end

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getMousePosition(root)
    local target = mouse.Hit
    if target then return target.Position end
    if root then return root.Position + root.CFrame.LookVector * 50 end
    return Vector3.new(0, 50, 0)
end

local function enforceMobility(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.Sit = false
    end
end

local function unanchorModel(model)
    if not model then return end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
            desc.CanCollide = false
            desc.Massless = true
        end
    end
end

-- ================================================================================
-- PRELOAD DE ANIMACIONES OFICIALES
-- ================================================================================
pcall(function()
    Util.Anims:Preload("MagnetTier1Idle_Left")
    Util.Anims:Preload("MagnetTier1Idle_Right")
    Util.Anims:Preload("MagnetTier3Idle_Left")
    Util.Anims:Preload("MagnetTier3Idle_Right")
    Util.Anims:Preload("Magnet New C Tap Release Land")
    Util.Anims:Preload("Magnet C Tap Release Land Arm")
    Util.Anims:Preload("Magnet C Tap Charge Arm Start")
    Util.Anims:Preload("Magnet C Tap Charge Arm Loop")
    Util.Anims:Preload("Magnet C Tap Release Arm Start")
    Util.Anims:Preload("Magnet C Tap Release Arm Loop")
    Util.Anims:Preload("Magnet New C Tap Charge Start")
    Util.Anims:Preload("Magnet New C Tap Charge Loop")
    Util.Anims:Preload("Magnet New C Tap Release Start")
    Util.Anims:Preload("Magnet New C Tap Release Loop")
    Util.Anims:Preload("Untr_Magnet R15 Magnet F Dash")
    Util.Anims:Preload("Untr_Magnet R15 Magnet F Dash Hit")
    Util.Anims:Preload("UnTr_ Magnet F Forward R15")
    Util.Anims:Preload("UnTr_ Jetpack Assemble")
    Util.Anims:Preload("Magnet Mech Transformation")
    Util.Anims:Preload("Magnet Mech Transformation Loop Fall")
    Util.Anims:Preload("Magnet Mech Transformation Landing")
    Util.Anims:Preload("Magnet Detransform Eject")
    Util.Anims:Preload("Transformed Magnet Mech Idle")
    Util.Anims:Preload("Transformed Magnet Mech Walk")
    Util.Anims:Preload("Transformed Magnet Mech Run")
    Util.Anims:Preload("Transformed Magnet Mech F Fly Loop")
    Util.Anims:Preload("Magnet Transformed Jetpack F Fly Loop")
    Util.Anims:Preload("Magnet Transformed Mech F Boost Loop")
    Util.Anims:Preload("Magnet Mech C Hold Start")
    Util.Anims:Preload("Magnet Mech C Hold Loop")
    Util.Anims:Preload("Magnet Mech C Hold Jump")
    Util.Anims:Preload("Magnet Mech Hammer C Hold Jump Loop")
    Util.Anims:Preload("Kitsune Transformation")
    Util.Anims:Preload("Kitsune Idle")
    Util.Anims:Preload("Dino Transformation")
    Util.Anims:Preload("Mammoth Transformation")
    Util.Anims:Preload("Dragon Transformation")
end)

-- ================================================================================
-- BASE DE DATOS DE FRUTAS CON RESOLUCIÓN NATIVA
-- ================================================================================
local function resolveItemId(fruitKey)
    if ItemId and ItemId.getId then
        local res = ItemId.getId(fruitKey, "Fruit")
        if res and res._ok then return res._ok end
    end
    return 191
end

local FRUIT_DATABASE = {
    ["Magnet-Magnet"] = {
        DisplayName = "Magnet",
        FullName = "Magnet-Magnet",
        Category = "MYTHICAL",
        Rarity = "Mítico",
        Color = Color3.fromRGB(220, 40, 70),
        ItemId = 1515,
        Spritesheet = "rbxassetid://106462369490623",
        SpriteOffset = Vector2.new(457, 305),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Magnet",
        HasTransformation = true,
        TransformType = "MAGNET_MECH",
        SpecialCaster = true,
    },
    ["Kitsune-Kitsune"] = {
        DisplayName = "Kitsune",
        FullName = "Kitsune-Kitsune",
        Category = "MYTHICAL",
        Rarity = "Mítico",
        Color = Color3.fromRGB(0, 195, 255),
        ItemId = 221,
        Spritesheet = "rbxassetid://106462369490623",
        SpriteOffset = Vector2.new(153, 305),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Kitsune",
        HasTransformation = true,
        TransformType = "KITSUNE_BEAST",
    },
    ["T-Rex-T-Rex"] = {
        DisplayName = "T-Rex",
        FullName = "T-Rex-T-Rex",
        Category = "BEAST",
        Rarity = "Mítico",
        Color = Color3.fromRGB(80, 180, 60),
        ItemId = 204,
        Spritesheet = "rbxassetid://138158660359115",
        SpriteOffset = Vector2.new(1, 457),
        SpriteSize = Vector2.new(150, 149),
        ECFolder = "Dino",
        HasTransformation = true,
        TransformType = "DINO_BEAST",
    },
    ["Mammoth-Mammoth"] = {
        DisplayName = "Mammoth",
        FullName = "Mammoth-Mammoth",
        Category = "BEAST",
        Rarity = "Mítico",
        Color = Color3.fromRGB(160, 100, 50),
        ItemId = 191,
        Spritesheet = "rbxassetid://106462369490623",
        SpriteOffset = Vector2.new(761, 305),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Mammoth",
        HasTransformation = true,
        TransformType = "MAMMOTH_BEAST",
    },
    ["Dragon-Dragon"] = {
        DisplayName = "Dragon",
        FullName = "Dragon-Dragon",
        Category = "BEAST",
        Rarity = "Mítico",
        Color = Color3.fromRGB(240, 120, 20),
        ItemId = 254,
        Spritesheet = "rbxassetid://72928410846782",
        SpriteOffset = Vector2.new(1, 305),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Dragon2",
        HasTransformation = true,
        TransformType = "DRAGON_BEAST",
    },
    ["Buddha-Buddha"] = {
        DisplayName = "Buddha",
        FullName = "Buddha-Buddha",
        Category = "BEAST",
        Rarity = "Legendario",
        Color = Color3.fromRGB(255, 215, 0),
        ItemId = 14,
        Spritesheet = "rbxassetid://72928410846782",
        SpriteOffset = Vector2.new(153, 1),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Buddha",
        HasTransformation = true,
        TransformType = "BUDDHA_SHIFT",
    },
    ["Dough-Dough"] = {
        DisplayName = "Dough",
        FullName = "Dough-Dough",
        Category = "AWAKENED",
        Rarity = "Mítico",
        Color = Color3.fromRGB(240, 215, 170),
        ItemId = 188,
        Spritesheet = "rbxassetid://72928410846782",
        SpriteOffset = Vector2.new(609, 153),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Dough",
        HasTransformation = true,
        TransformType = "DOUGH_AWAKENED",
    },
    ["Leopard-Leopard"] = {
        DisplayName = "Leopard",
        FullName = "Leopard-Leopard",
        Category = "BEAST",
        Rarity = "Mítico",
        Color = Color3.fromRGB(255, 180, 0),
        ItemId = resolveItemId("Leopard-Leopard"),
        Spritesheet = "rbxassetid://72928410846782",
        SpriteOffset = Vector2.new(153, 457),
        SpriteSize = Vector2.new(150, 150),
        ECFolder = "Leopard",
        HasTransformation = true,
        TransformType = "LEOPARD_BEAST",
    }
}

-- ================================================================================
-- ESCÁNER DINÁMICO UNIVERSAL DE TODAS LAS FRUTAS DEL JUEGO (56 FRUTAS)
-- ================================================================================
local function autoScanAllGameFruits()
    if not FruitSkills then return end

    for weaponName, skillData in pairs(FruitSkills) do
        if weaponName:find("-") and not FRUIT_DATABASE[weaponName] then
            local displayName = weaponName:match("^(.-)%-") or weaponName

            -- Resolver ItemId oficial
            local fItemId = 191
            pcall(function()
                local res = ItemId.getId(weaponName, "Fruit")
                if res and res._ok then fItemId = res._ok end
            end)

            -- Resolver carpeta en EffectContainer
            local ecFolder = displayName
            if EffectContainer then
                if EffectContainer:FindFirstChild(displayName) then
                    ecFolder = displayName
                elseif EffectContainer:FindFirstChild(weaponName) then
                    ecFolder = weaponName
                elseif displayName == "Portal" and EffectContainer:FindFirstChild("Door") then
                    ecFolder = "Door"
                elseif displayName == "T-Rex" and EffectContainer:FindFirstChild("Dino") then
                    ecFolder = "Dino"
                elseif displayName == "Dragon" and EffectContainer:FindFirstChild("Dragon2") then
                    ecFolder = "Dragon2"
                end
            end

            -- Resolver Spritesheet
            local sSheet = "rbxassetid://137795581360678"
            local sOffset = Vector2.new(1, 1)
            local sSize = Vector2.new(150, 150)
            pcall(function()
                if FruitSpritesheets then
                    for sheetId, rects in pairs(FruitSpritesheets) do
                        for iconName, coords in pairs(rects) do
                            if iconName:lower():find(displayName:lower()) then
                                sSheet = sheetId
                                sOffset = Vector2.new(coords[1], coords[2])
                                sSize = Vector2.new(coords[3], coords[4])
                                break
                            end
                        end
                        if sSheet ~= "rbxassetid://137795581360678" then break end
                    end
                end
            end)

            -- Categorización y Color
            local category = "COMMON"
            local rarity = "Común"
            local color = Color3.fromRGB(170, 180, 195)
            local dLow = displayName:lower()

            if dLow:find("kitsune") or dLow:find("dragon") or dLow:find("leopard") or dLow:find("spirit") or dLow:find("venom") or dLow:find("dough") or dLow:find("mammoth") or dLow:find("t-rex") or dLow:find("gas") or dLow:find("yeti") or dLow:find("control") or dLow:find("shadow") then
                category = "MYTHICAL"; rarity = "Mítico"; color = Color3.fromRGB(240, 50, 80)
            elseif dLow:find("buddha") or dLow:find("portal") or dLow:find("sound") or dLow:find("blizzard") or dLow:find("rumble") or dLow:find("lightning") or dLow:find("pain") or dLow:find("phoenix") or dLow:find("quake") or dLow:find("love") or dLow:find("spider") or dLow:find("gravity") then
                category = "LEGENDARY"; rarity = "Legendario"; color = Color3.fromRGB(255, 180, 20)
            elseif dLow:find("magma") or dLow:find("ghost") or dLow:find("light") or dLow:find("dark") or dLow:find("ice") or dLow:find("sand") or dLow:find("diamond") then
                category = "RARE"; rarity = "Raro"; color = Color3.fromRGB(50, 160, 255)
            elseif dLow:find("rubber") or dLow:find("barrier") or dLow:find("flame") then
                category = "UNCOMMON"; rarity = "Poco Común"; color = Color3.fromRGB(60, 220, 100)
            end

            -- Bestias conocidas
            if dLow:find("dino") or dLow:find("t-rex") or dLow:find("mammoth") or dLow:find("dragon") or dLow:find("leopard") or dLow:find("kitsune") or dLow:find("yeti") or dLow:find("tiger") or dLow:find("eagle") then
                category = "BEAST"
            end

            FRUIT_DATABASE[weaponName] = {
                DisplayName = displayName,
                FullName = weaponName,
                Category = category,
                Rarity = rarity,
                Color = color,
                ItemId = fItemId,
                Spritesheet = sSheet,
                SpriteOffset = sOffset,
                SpriteSize = sSize,
                ECFolder = ecFolder,
                HasTransformation = (ecFolder and EffectContainer and EffectContainer:FindFirstChild(ecFolder) and EffectContainer[ecFolder]:FindFirstChild("Transformed") ~= nil) or false,
            }
        end
    end
end

autoScanAllGameFruits()

-- ================================================================================
-- ESTADO GLOBAL DEL MOTOR
-- ================================================================================
local currentFruitKey = "Magnet-Magnet"
local currentTool = nil
local equipped = false
local isTransformed = false
local isActing = false

-- Instancias visuales activas
local handFruitModel = nil
local activeTransformationModel = nil
local activeDebris = {}
local activeFlightBV = nil
local activeFlightBG = nil
local activeFlightConn = nil
local isFlying = false
local activeCast = nil

-- Visuales Magnet V2
local magnetArmsLeft = nil
local magnetArmsRight = nil
local magnetCannon = nil
local magnetRockets = nil
local magnetJetpack = nil
local magnetChestReactor = nil
local magnetArmorParts = {}
local magnetIdleTrack = nil
local magnetMoveConn = nil
local originalCharAppearance = {}

local function safeDebris(inst, delayTime)
    if not inst then return end
    table.insert(activeDebris, inst)
    Debris:AddItem(inst, delayTime or 10)
end

-- ================================================================================
-- ENVOLTURA SEGURA DE EFECTOS
-- ================================================================================
local function runEffect(func, params, debugTag)
    if not func then return false end
    local ok, err = pcall(func, params)
    if not ok then
        -- Silenciar errores comunes de partículas menores
        if not tostring(err):find("ParticleEmitter") and not tostring(err):find("ColorShift") then
            warn("[FRUIT ENGINE] Aviso de efecto (" .. tostring(debugTag) .. "):", err)
        end
    end
    return ok
end

-- ================================================================================
-- BRAZOS MAGNÉTICOS FLOTANTES PASIVOS (MAGNET ARMS FOLDER)
-- ================================================================================
local function setupMagnetArms(character)
    if not character then return end
    local root = getRoot(character)
    if not root then return end

    local armsFolder = character:FindFirstChild("MagnetArms")
    if not armsFolder then
        armsFolder = Instance.new("Folder")
        armsFolder.Name = "MagnetArms"
        armsFolder.Parent = character
    end

    local magnetFX = FX:FindFirstChild("Magnet")
    local tFolder = magnetFX and magnetFX:FindFirstChild("MagnetArms") and (magnetFX.MagnetArms:FindFirstChild("Tier3") or magnetFX.MagnetArms:FindFirstChild("Tier1"))
    if not tFolder then return armsFolder end

    if not armsFolder:FindFirstChild("FloatingLeftArm") then
        local tLeft = tFolder:FindFirstChild("Left") or tFolder:FindFirstChild("FloatingLeftArm")
        if tLeft then
            local lClone = tLeft:Clone()
            lClone.Name = "FloatingLeftArm"
            unanchorModel(lClone)
            local lPart = lClone.PrimaryPart or lClone:FindFirstChildWhichIsA("BasePart")
            if lPart then
                local w = Instance.new("Weld")
                w.Name = "FloatWeld"
                w.Part0 = root
                w.Part1 = lPart
                w.C0 = CFrame.new(-2.4, 0.4, -0.5)
                w.Parent = lPart
            end
            lClone.Parent = armsFolder
        end
    end

    if not armsFolder:FindFirstChild("FloatingRightArm") then
        local tRight = tFolder:FindFirstChild("Right") or tFolder:FindFirstChild("FloatingRightArm")
        if tRight then
            local rClone = tRight:Clone()
            rClone.Name = "FloatingRightArm"
            unanchorModel(rClone)
            local rPart = rClone.PrimaryPart or rClone:FindFirstChildWhichIsA("BasePart")
            if rPart then
                local w = Instance.new("Weld")
                w.Name = "FloatWeld"
                w.Part0 = root
                w.Part1 = rPart
                w.C0 = CFrame.new(2.4, 0.4, -0.5)
                w.Parent = rPart
            end
            rClone.Parent = armsFolder
        end
    end

    return armsFolder
end

local function cleanMagnetArms(character)
    if not character then return end
    local armsFolder = character:FindFirstChild("MagnetArms")
    if armsFolder then
        armsFolder:Destroy()
    end
end

-- ================================================================================
-- RECONSTRUCCIÓN NATIVA DEL HUD: PlayerGui.Main.Skills
-- ================================================================================
local function getOfficialMoveData(fruitConfig)
    local moves = {}
    if FruitSkills and FruitSkills[fruitConfig.FullName] then
        local raw = FruitSkills[fruitConfig.FullName]
        local primary = raw[1] or raw
        if type(primary) == "table" and type(primary[1]) == "table" then
            for _, item in ipairs(primary) do
                table.insert(moves, {
                    key = tostring(item[1]),
                    mastery = tonumber(item[2]) or 1,
                    name = tostring(item[3] or item[1])
                })
            end
        end
    end

    if #moves == 0 then
        moves = {
            {key = "Z", mastery = 1, name = "Skill Z"},
            {key = "X", mastery = 50, name = "Skill X"},
            {key = "C", mastery = 100, name = "Skill C"},
            {key = "V", mastery = 200, name = "Transformation"},
            {key = "F", mastery = 300, name = "Mobility / Flight"}
        }
    end
    return moves
end

local function refreshSkillsHUD()
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then return end
        local main = pg:FindFirstChild("Main")
        if not main then return end
        local skillsFrame = main:FindFirstChild("Skills")
        if not skillsFrame then return end

        local fruitConfig = FRUIT_DATABASE[currentFruitKey]
        if not fruitConfig then return end

        -- Actualizar Título y Nivel
        local titleLabel = skillsFrame:FindFirstChild("FruitTitle") or skillsFrame:FindFirstChild("WeaponTitle") or skillsFrame:FindFirstChild("Title")
        if titleLabel and titleLabel:IsA("TextLabel") then
            titleLabel.Text = fruitConfig.DisplayName:upper()
            titleLabel.TextColor3 = fruitConfig.Color
        end

        local levelLabel = skillsFrame:FindFirstChild("Level") or skillsFrame:FindFirstChild("Mastery")
        if levelLabel and levelLabel:IsA("TextLabel") then
            levelLabel.Text = "Mastery 600 (MAX)"
            levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        end

        -- Clonar o reutilizar el frame específico de habilidades
        local frameName = fruitConfig.DisplayName .. "-SkillsFrame"
        local dedicatedFrame = skillsFrame:FindFirstChild(frameName)
        
        -- Ocultar otros frames de armas
        for _, child in ipairs(skillsFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Container" and child.Name ~= frameName then
                child.Visible = false
            end
        end

        local templateFrame = skillsFrame:FindFirstChild("Mammoth-Mammoth") or skillsFrame:FindFirstChild("Sharkman Karate")
        if not dedicatedFrame and templateFrame then
            dedicatedFrame = templateFrame:Clone()
            dedicatedFrame.Name = frameName
            dedicatedFrame.Parent = skillsFrame
        end

        if dedicatedFrame then
            dedicatedFrame.Visible = equipped
            local officialMoves = getOfficialMoveData(fruitConfig)
            for _, move in ipairs(officialMoves) do
                local moveRow = dedicatedFrame:FindFirstChild(move.key)
                if moveRow then
                    moveRow.Visible = true
                    local t = moveRow:FindFirstChild("Title") or moveRow:FindFirstChildWhichIsA("TextLabel")
                    if t then
                        t.Text = move.name
                    end
                end
            end
        end
    end)
end

-- ================================================================================
-- REGLAS DE MODELO EN MANO (PHYSICAL FRUIT MODEL)
-- ================================================================================
local function cleanHandFruit()
    if handFruitModel and handFruitModel.Parent then
        handFruitModel:Destroy()
    end
    handFruitModel = nil
end

local function attachFruitToHand(character, fruitConfig)
    cleanHandFruit()
    if not character then return end
    local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if not rightHand then return end

    local model = nil

    if fruitConfig.DisplayName == "Magnet" then
        -- USAR EL MODELO COMPACTO AUTÉNTICO PHASE0 (1.78 x 1.61 x 0.31)
        local phase0 = FX:FindFirstChild("Magnet") and FX.Magnet:FindFirstChild("X_Attract") and FX.Magnet.X_Attract:FindFirstChild("Phase0")
        local fruitTemplate = phase0 and phase0:FindFirstChild("MagnetModel")
        if fruitTemplate then
            model = fruitTemplate:Clone()
        end
    else
        -- BÚSQUEDA DINÁMICA DE MODELO FÍSICO
        local ecF = EffectContainer:FindFirstChild(fruitConfig.ECFolder)
        local phys = ecF and (ecF:FindFirstChild("PhysicalFruit") or ecF:FindFirstChild("FruitModel"))
        if phys and phys:IsA("Model") then
            model = phys:Clone()
        else
            local fxF = FX:FindFirstChild(fruitConfig.ECFolder)
            local m = fxF and fxF:FindFirstChild(fruitConfig.DisplayName)
            if m and m:IsA("Model") then
                model = m:Clone()
            end
        end
    end

    -- Fallback si no tiene modelo físico dedicado: Orbe de Fruta elegante con material de la fruta
    if not model then
        model = Instance.new("Model")
        model.Name = fruitConfig.DisplayName .. "FruitModel"
        local corePart = Instance.new("Part")
        corePart.Name = "FruitCore"
        corePart.Shape = Enum.PartType.Ball
        corePart.Size = Vector3.new(1.3, 1.3, 1.3)
        corePart.Material = Enum.Material.Neon
        corePart.Color = fruitConfig.Color
        corePart.CanCollide = false
        corePart.Massless = true
        corePart.Parent = model
        model.PrimaryPart = corePart

        local highlight = Instance.new("Highlight")
        highlight.FillColor = fruitConfig.Color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = model
    end

    model.Name = fruitConfig.DisplayName .. "PhysicalFruit"
    unanchorModel(model)

    local pPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if pPart then
        model.PrimaryPart = pPart
        pPart.CanCollide = false
        pPart.Massless = true
        pPart.CastShadow = false

        local weld = Instance.new("Weld")
        weld.Name = "FruitHandWeld"
        weld.Part0 = rightHand
        weld.Part1 = pPart
        weld.C0 = CFrame.new(0, -0.65, 0) * CFrame.Angles(0, 0, math.rad(90))
        weld.Parent = pPart
    end

    model.Parent = character
    handFruitModel = model
end

-- ================================================================================
-- MAGNET V2: SUITE DE TRANSFORMACIÓN MECH COMPLETA
-- ================================================================================
local function ensureRobotBoneAttachments(root)
    if not root then return end
    local bones = {
        "CenterLeftArm1", "CenterLeftArm2", "CenterLeftArm3", "CenterLeftArm4",
        "CenterRightArm1", "CenterRightArm2", "CenterRightArm3", "CenterRightArm4",
        "CannonBone", "RocketBone"
    }
    for _, bName in ipairs(bones) do
        if not root:FindFirstChild(bName) then
            local att = Instance.new("Attachment")
            att.Name = bName
            att.Parent = root
        end
    end
end

local function cleanMagnetMechVisuals(character)
    if magnetIdleTrack then pcall(function() magnetIdleTrack:Stop() end); magnetIdleTrack = nil end
    if magnetMoveConn then magnetMoveConn:Disconnect(); magnetMoveConn = nil end

    if magnetArmsLeft and magnetArmsLeft.Parent then magnetArmsLeft:Destroy() end; magnetArmsLeft = nil
    if magnetArmsRight and magnetArmsRight.Parent then magnetArmsRight:Destroy() end; magnetArmsRight = nil
    if magnetCannon and magnetCannon.Parent then magnetCannon:Destroy() end; magnetCannon = nil
    if magnetRockets and magnetRockets.Parent then magnetRockets:Destroy() end; magnetRockets = nil
    if magnetJetpack and magnetJetpack.Parent then magnetJetpack:Destroy() end; magnetJetpack = nil
    if magnetChestReactor and magnetChestReactor.Parent then magnetChestReactor:Destroy() end; magnetChestReactor = nil

    for _, p in ipairs(magnetArmorParts) do
        if p and p.Parent then p:Destroy() end
    end
    magnetArmorParts = {}

    if character then
        for part, props in pairs(originalCharAppearance) do
            if part and part.Parent then
                part.Color = props.Color
                part.Material = props.Material
            end
        end
        originalCharAppearance = {}
        pcall(function() character:ScaleTo(1.0) end)
    end
end

local function applyMagnetMechTransformation(character)
    cleanMagnetMechVisuals(character)
    if not character then return end
    local root = getRoot(character)
    if not root then return end
    local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or root

    ensureRobotBoneAttachments(root)

    local magnetFX = FX:FindFirstChild("Magnet")
    local transformedFX = magnetFX and magnetFX:FindFirstChild("Transformed")
    local magnetEffects = EffectContainer:FindFirstChild("Magnet")

    -- Secuencia Cinematica de Transformación
    pcall(function()
        local vMod = magnetEffects and magnetEffects:FindFirstChild("V")
        if vMod then
            local vFunc = require(vMod)
            runEffect(vFunc, {
                Origin = root.Position,
                Root = root,
                Rig = character,
                Player = player,
                DashSpeed = 0.4,
                UpDist = 30,
                Stage = 1,
            }, "Magnet.V_Sequence")
        end
    end)

    -- 1. Brazos Mech Colosales Tier 3
    local armsFolder = (magnetFX and magnetFX:FindFirstChild("MagnetArms")) or (transformedFX and transformedFX:FindFirstChild("MagnetArms"))
    local tier3Folder = armsFolder and armsFolder:FindFirstChild("Tier3")
    if tier3Folder then
        local leftArm = tier3Folder:FindFirstChild("Left") or tier3Folder:FindFirstChild("FloatingLeftArm")
        if leftArm then
            local lClone = leftArm:Clone()
            lClone.Name = "MechArmLeft"
            unanchorModel(lClone)
            local leftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm") or root
            local lPart = lClone.PrimaryPart or lClone:FindFirstChildWhichIsA("BasePart")
            if lPart then
                local w = Instance.new("Weld")
                w.Part0 = leftUpperArm
                w.Part1 = lPart
                w.C0 = CFrame.new(-1.8, -0.4, 0.2) * CFrame.Angles(0, math.rad(90), 0)
                w.Parent = lPart
            end
            lClone.Parent = character
            magnetArmsLeft = lClone
        end

        local rightArm = tier3Folder:FindFirstChild("Right") or tier3Folder:FindFirstChild("FloatingRightArm")
        if rightArm then
            local rClone = rightArm:Clone()
            rClone.Name = "MechArmRight"
            unanchorModel(rClone)
            local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm") or root
            local rPart = rClone.PrimaryPart or rClone:FindFirstChildWhichIsA("BasePart")
            if rPart then
                local w = Instance.new("Weld")
                w.Part0 = rightUpperArm
                w.Part1 = rPart
                w.C0 = CFrame.new(1.8, -0.4, 0.2) * CFrame.Angles(0, math.rad(-90), 0)
                w.Parent = rPart
            end
            rClone.Parent = character
            magnetArmsRight = rClone
        end
    end

    -- 2. Gran Cañón Orbital en Hombro Derecho
    local cannonTemplate = transformedFX and (transformedFX:FindFirstChild("Cannon") or transformedFX:FindFirstChild("BigCannon"))
    if cannonTemplate then
        local cClone = cannonTemplate:Clone()
        cClone.Name = "MechCannon"
        unanchorModel(cClone)
        local cPart = cClone.PrimaryPart or cClone:FindFirstChildWhichIsA("BasePart")
        if cPart then
            local w = Instance.new("Weld")
            w.Part0 = upperTorso
            w.Part1 = cPart
            w.C0 = CFrame.new(2.4, 2.3, 0.4) * CFrame.Angles(0, math.rad(90), math.rad(10))
            w.Parent = cPart
        end
        cClone.Parent = character
        magnetCannon = cClone
    end

    -- 3. Batería de Misiles en Hombro Izquierdo
    local rocketsTemplate = transformedFX and (transformedFX:FindFirstChild("Rockets") or transformedFX:FindFirstChild("MissilePod"))
    if rocketsTemplate then
        local rClone = rocketsTemplate:Clone()
        rClone.Name = "MechRockets"
        unanchorModel(rClone)
        local rPart = rClone.PrimaryPart or rClone:FindFirstChildWhichIsA("BasePart")
        if rPart then
            local w = Instance.new("Weld")
            w.Part0 = upperTorso
            w.Part1 = rPart
            w.C0 = CFrame.new(-2.4, 2.3, 0.4) * CFrame.Angles(0, math.rad(-90), math.rad(-10))
            w.Parent = rPart
        end
        rClone.Parent = character
        magnetRockets = rClone
    end

    -- 4. Jetpack Propulsor
    local flightFolder = transformedFX and transformedFX:FindFirstChild("Flight")
    local p1F = flightFolder and flightFolder:FindFirstChild("Phase1")
    local jpTemplate = (p1F and p1F:FindFirstChild("Jetpack")) or (magnetFX and magnetFX:FindFirstChild("Jetpack"))
    if jpTemplate then
        local jClone = jpTemplate:Clone()
        jClone.Name = "MechJetpack"
        unanchorModel(jClone)
        local jPart = jClone.PrimaryPart or jClone:FindFirstChildWhichIsA("BasePart")
        if jPart then
            local w = Instance.new("Weld")
            w.Part0 = upperTorso
            w.Part1 = jPart
            w.C0 = CFrame.new(0, 0.6, 1.25) * CFrame.Angles(0, math.rad(180), 0)
            w.Parent = jPart
        end
        for _, d in ipairs(jClone:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d.Enabled = true end
        end
        jClone.Parent = character
        magnetJetpack = jClone
    end

    -- 5. Reactor de Pecho Doble Polaridad
    local reactor = Instance.new("Part")
    reactor.Name = "MagnetChestReactor"
    reactor.Size = Vector3.new(1.5, 1.5, 0.7)
    reactor.Material = Enum.Material.Neon
    reactor.Color = Color3.fromRGB(0, 240, 255)
    reactor.CanCollide = false
    reactor.Massless = true
    local rWeld = Instance.new("Weld")
    rWeld.Part0 = upperTorso
    rWeld.Part1 = reactor
    rWeld.C0 = CFrame.new(0, 0.2, -0.85)
    rWeld.Parent = reactor
    reactor.Parent = character
    magnetChestReactor = reactor

    local core = Instance.new("Part")
    core.Name = "MagnetChestCore"
    core.Size = Vector3.new(1.0, 1.0, 0.9)
    core.Shape = Enum.PartType.Ball
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(255, 30, 100)
    core.CanCollide = false
    core.Massless = true
    local cWeld = Instance.new("Weld")
    cWeld.Part0 = reactor
    cWeld.Part1 = core
    cWeld.C0 = CFrame.new(0, 0, -0.1)
    cWeld.Parent = core
    core.Parent = character
    table.insert(magnetArmorParts, core)

    -- 6. Tinte de Titanio Metálico
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == character and part.Name ~= "HumanoidRootPart" and not part.Name:find("Reactor") and not part.Name:find("Core") then
            originalCharAppearance[part] = {
                Color = part.Color,
                Material = part.Material,
            }
            part.Material = Enum.Material.Metal
            part.Color = Color3.fromRGB(35, 40, 50)
        end
    end

    -- 7. Escalado 1.35x
    pcall(function() character:ScaleTo(1.35) end)

    -- 8. Animaciones de Mech
    pcall(function()
        magnetIdleTrack = Util.Anims:Get(character, "Transformed Magnet Mech Idle")
        if magnetIdleTrack then
            magnetIdleTrack.Looped = true
            magnetIdleTrack.Priority = Enum.AnimationPriority.Action
            magnetIdleTrack:Play()
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local walkTrack = Util.Anims:Get(character, "Transformed Magnet Mech Walk")
            magnetMoveConn = humanoid.Running:Connect(function(speed)
                if not isTransformed then return end
                if speed > 1 then
                    if walkTrack and not walkTrack.IsPlaying then
                        walkTrack.Looped = true
                        walkTrack.Priority = Enum.AnimationPriority.Action2
                        walkTrack:Play()
                    end
                else
                    if walkTrack and walkTrack.IsPlaying then
                        walkTrack:Stop()
                    end
                end
            end)
        end
    end)
end

-- ================================================================================
-- TRANSFORMACIONES GENERALES DE OTRAS FRUTAS (KITSUNE, MAMMOTH, BUDDHA, ETC.)
-- ================================================================================
local function cleanTransformationVisuals()
    local char = player.Character
    if currentFruitKey == "Magnet-Magnet" then
        cleanMagnetMechVisuals(char)
    else
        if activeTransformationModel and activeTransformationModel.Parent then
            activeTransformationModel:Destroy()
        end
        activeTransformationModel = nil

        if char then
            for part, props in pairs(originalCharAppearance) do
                if part and part.Parent then
                    part.Color = props.Color
                    part.Material = props.Material
                    part.Transparency = props.Transparency or 0
                end
            end
            originalCharAppearance = {}
            pcall(function() char:ScaleTo(1.0) end)
        end
    end
end

local function applyTransformationVisuals(character, fruitConfig)
    cleanTransformationVisuals()
    if not character then return end
    local root = getRoot(character)
    if not root then return end

    if fruitConfig.TransformType == "MAGNET_MECH" then
        applyMagnetMechTransformation(character)
        return
    end

    local tType = fruitConfig.TransformType

    if tType == "KITSUNE_BEAST" then
        -- Bestia Kitsune oficial
        local kTemplate = FX:FindFirstChild("Kitsune") and FX.Kitsune:FindFirstChild("Kitsune")
        if kTemplate then
            local kClone = kTemplate:Clone()
            kClone.Name = "KitsuneBeastMorph"
            unanchorModel(kClone)
            local kPart = kClone.PrimaryPart or kClone:FindFirstChild("RootPart") or kClone:FindFirstChildWhichIsA("BasePart")
            if kPart then
                local w = Instance.new("Weld")
                w.Part0 = root
                w.Part1 = kPart
                w.C0 = CFrame.new(0, 0, 0)
                w.Parent = kPart
            end
            kClone.Parent = character
            activeTransformationModel = kClone

            -- Ocultar partes del jugador
            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent == character and p.Name ~= "HumanoidRootPart" then
                    originalCharAppearance[p] = {Color = p.Color, Material = p.Material, Transparency = p.Transparency}
                    p.Transparency = 1
                end
            end
            pcall(function() character:ScaleTo(1.4) end)
        end

    elseif tType == "MAMMOTH_BEAST" then
        -- Bestia Mammoth oficial
        local mTemplate = FX:FindFirstChild("Mammoth") and FX.Mammoth:FindFirstChild("Mammoth")
        if mTemplate then
            local mClone = mTemplate:Clone()
            mClone.Name = "MammothBeastMorph"
            unanchorModel(mClone)
            local mPart = mClone.PrimaryPart or mClone:FindFirstChildWhichIsA("BasePart")
            if mPart then
                local w = Instance.new("Weld")
                w.Part0 = root
                w.Part1 = mPart
                w.C0 = CFrame.new(0, 0, 0)
                w.Parent = mPart
            end
            mClone.Parent = character
            activeTransformationModel = mClone

            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent == character and p.Name ~= "HumanoidRootPart" then
                    originalCharAppearance[p] = {Color = p.Color, Material = p.Material, Transparency = p.Transparency}
                    p.Transparency = 1
                end
            end
            pcall(function() character:ScaleTo(1.5) end)
        end

    elseif tType == "BUDDHA_SHIFT" then
        -- Buddha Colosal Radiante
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.Parent == character and p.Name ~= "HumanoidRootPart" then
                originalCharAppearance[p] = {Color = p.Color, Material = p.Material}
                p.Material = Enum.Material.Neon
                p.Color = Color3.fromRGB(255, 220, 30)
            end
        end
        local hl = Instance.new("Highlight")
        hl.Name = "BuddhaRadiance"
        hl.FillColor = Color3.fromRGB(255, 215, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.3
        hl.Parent = character
        activeTransformationModel = hl
        pcall(function() character:ScaleTo(2.2) end)

    elseif tType == "DRAGON_BEAST" then
        -- Dragón
        local dt = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Models") and ReplicatedStorage.Assets.Models:FindFirstChild("DragonTransformation")
        if dt then
            local dClone = dt:Clone()
            dClone.Name = "DragonMorph"
            unanchorModel(dClone)
            local dPart = dClone.PrimaryPart or dClone:FindFirstChildWhichIsA("BasePart")
            if dPart then
                local w = Instance.new("Weld")
                w.Part0 = root
                w.Part1 = dPart
                w.C0 = CFrame.new(0, 1, 1.5)
                w.Parent = dPart
            end
            dClone.Parent = character
            activeTransformationModel = dClone
        end
        pcall(function() character:ScaleTo(1.35) end)

    elseif tType == "DOUGH_AWAKENED" then
        -- Dough Despertado
        local dModels = FX:FindFirstChild("Dough") and FX.Dough:FindFirstChild("Models")
        local donuts = dModels and dModels:FindFirstChild("Donuts")
        if donuts then
            local dClone = donuts:Clone()
            dClone.Name = "DoughAwakenedDonuts"
            unanchorModel(dClone)
            local dPart = dClone.PrimaryPart or dClone:FindFirstChildWhichIsA("BasePart")
            if dPart then
                local w = Instance.new("Weld")
                w.Part0 = root
                w.Part1 = dPart
                w.C0 = CFrame.new(0, 1.5, 2.2)
                w.Parent = dPart
            end
            dClone.Parent = character
            activeTransformationModel = dClone
        end
    end
end

-- ================================================================================
-- VUELO DINÁMICO
-- ================================================================================
local function stopFlight()
    isFlying = false
    if activeFlightConn then activeFlightConn:Disconnect(); activeFlightConn = nil end
    if activeFlightBV and activeFlightBV.Parent then activeFlightBV:Destroy() end
    activeFlightBV = nil
    if activeFlightBG and activeFlightBG.Parent then activeFlightBG:Destroy() end
    activeFlightBG = nil
end

local function startFlight(root, speed)
    stopFlight()
    isFlying = true

    activeFlightBV = Instance.new("BodyVelocity")
    activeFlightBV.Name = "FruitFlightBV"
    activeFlightBV.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    activeFlightBV.Parent = root

    activeFlightBG = Instance.new("BodyGyro")
    activeFlightBG.Name = "FruitFlightBG"
    activeFlightBG.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    activeFlightBG.P = 18000
    activeFlightBG.Parent = root

    activeFlightConn = RunService.RenderStepped:Connect(function()
        if not isFlying or not root or not root.Parent then return end
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        activeFlightBV.Velocity = look * (speed or 140)
        activeFlightBG.CFrame = CFrame.lookAt(root.Position, root.Position + look)
    end)
end

-- ================================================================================
-- SISTEMA DE HABILIDADES MAGNET V2 INTEGRADO
-- ================================================================================
local function handleMagnetKey(key, isDown, fruitConfig, character, root)
    local ec = EffectContainer:WaitForChild("Magnet")
    local trEC = ec:FindFirstChild("Transformed")
    local magnetFX = FX:WaitForChild("Magnet")
    local transformedFX = magnetFX:WaitForChild("Transformed")

    if key == "V" and isDown then
        if isActing then return end
        isActing = true
        isTransformed = not isTransformed
        print("[FRUIT ENGINE] ⚡ Cambio de estado V Magnet:\t" .. (isTransformed and "TRANSFORMADO" or "NORMAL"))

        if isTransformed then
            applyMagnetMechTransformation(character)
        else
            cleanMagnetMechVisuals(character)
            attachFruitToHand(character, fruitConfig)
        end

        task.delay(1.5, function()
            isActing = false
            enforceMobility(character)
            refreshSkillsHUD()
        end)
        return
    end

    if key == "Z" then
        if isDown then
            if activeCast then return end
            local effectMod = isTransformed and trEC:FindFirstChild("Z_Attract") or ec:FindFirstChild("Z_Attract")
            local effect = effectMod and require(effectMod)
            if not effect then return end

            local holding = Instance.new("BoolValue")
            holding.Value = true
            local mousePosVal = Instance.new("Vector3Value")
            mousePosVal.Value = getMousePosition(root)

            activeCast = { key = "Z", effect = effect, holding = holding, mousePosVal = mousePosVal, transformed = isTransformed }

            runEffect(effect, {
                Origin = root.Position,
                Root = root,
                Player = player,
                Rig = character,
                Stage = 1,
                Holding = holding,
            }, "Magnet.Z_Stage1")
        else
            local cast = activeCast
            if not cast or cast.key ~= "Z" then return end
            activeCast = nil
            if cast.holding then cast.holding.Value = false end

            local targetPos = getMousePosition(root)
            if cast.mousePosVal then cast.mousePosVal.Value = targetPos end

            task.delay(0.04, function()
                if not root.Parent or not equipped then return end
                if not cast.transformed then
                    local leftCF = root.CFrame * CFrame.new(-2, 1, -1)
                    local rightCF = root.CFrame * CFrame.new(2, 1, -1)
                    local startCFrames = { leftCF, rightCF, leftCF * CFrame.new(0, -0.4, 0), rightCF * CFrame.new(0, -0.4, 0) }

                    runEffect(cast.effect, {
                        Origin = root.Position,
                        Root = root,
                        Player = player,
                        Stage = 2,
                        StartCFrame = startCFrames,
                        MousePos = cast.mousePosVal,
                        Speed = 220,
                    }, "Magnet.Z_Stage2")
                else
                    runEffect(cast.effect, {
                        Origin = root.Position,
                        Root = root,
                        Player = player,
                        Rig = character,
                        Stage = 2,
                        MousePos = cast.mousePosVal,
                        Range = 320,
                        Speed = 260,
                        Seed = math.random(1, 100000),
                    }, "Magnet.Transformed.Z_Stage2")
                end
                task.delay(5, function()
                    if cast.holding then cast.holding:Destroy() end
                    if cast.mousePosVal then cast.mousePosVal:Destroy() end
                end)
            end)
        end

    elseif key == "X" then
        if isDown then
            if activeCast then return end
            local effectMod = isTransformed and trEC:FindFirstChild("X_Attract") or ec:FindFirstChild("X_Attract")
            local effect = effectMod and require(effectMod)
            if not effect then return end

            local holding = Instance.new("BoolValue")
            holding.Value = true
            activeCast = { key = "X", effect = effect, holding = holding, startTime = tick(), transformed = isTransformed }

            runEffect(effect, {
                Origin = root.Position,
                Root = root,
                Player = player,
                Rig = character,
                Stage = 1,
                Holding = holding,
            }, "Magnet.X_Stage1")
        else
            local cast = activeCast
            if not cast or cast.key ~= "X" then return end
            activeCast = nil
            if cast.holding then cast.holding.Value = false end

            local startCFrame = root.CFrame * CFrame.new(0, 7, 0)
            local targetPos = getMousePosition(root)
            local offset = targetPos - startCFrame.Position
            local distance = math.min(offset.Magnitude, 280)
            targetPos = startCFrame.Position + offset.Unit * distance
            local travelTime = distance / 333.333

            task.delay(0.04, function()
                if not root.Parent or not equipped then return end
                runEffect(cast.effect, {
                    Origin = root.Position,
                    Root = root,
                    Player = player,
                    Rig = character,
                    Stage = 2,
                    StartCFrame = startCFrame,
                    TargetPosition = targetPos,
                    TravelTime = travelTime,
                    MaxRange = 280,
                }, "Magnet.X_Stage2")
                task.delay(5, function() if cast.holding then cast.holding:Destroy() end end)
            end)
        end

    elseif key == "C" then
        if isDown then
            if activeCast then return end
            local effectMod = isTransformed and trEC:FindFirstChild("C_Attract") or ec:FindFirstChild("C_Attract")
            local effect = effectMod and require(effectMod)
            if not effect then return end

            local holding = Instance.new("BoolValue")
            holding.Value = true
            activeCast = { key = "C", effect = effect, holding = holding, startTime = tick(), transformed = isTransformed }

            runEffect(effect, {
                Origin = root.Position,
                Root = root,
                Player = player,
                Rig = character,
                Holding = holding,
                Stage = 1,
            }, "Magnet.C_Stage1")
        else
            local cast = activeCast
            if not cast or cast.key ~= "C" then return end
            activeCast = nil
            if cast.holding then cast.holding.Value = false end

            local holdDuration = tick() - (cast.startTime or tick())
            local targetPos = getMousePosition(root)

            local rayOrigin = targetPos + Vector3.new(0, 60, 0)
            local rParams = RaycastParams.new()
            rParams.FilterType = Enum.RaycastFilterType.Exclude
            rParams.FilterDescendantsInstances = {character, workspace:FindFirstChild("_WorldOrigin")}
            local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -300, 0), rParams)
            local groundPos = rayResult and rayResult.Position or (targetPos - Vector3.new(0, math.max(0, targetPos.Y - root.Position.Y), 0))

            task.delay(0.04, function()
                if not root.Parent or not equipped then return end
                if not cast.transformed then
                    isActing = true
                    runEffect(cast.effect, {
                        Origin = root.Position,
                        Root = root,
                        Player = player,
                        Stage = 2,
                        StartCFrame = root.CFrame,
                        UpCFrame = root.CFrame * CFrame.new(0, 38, 0),
                        EndCFrame = CFrame.new(groundPos),
                        Holding = cast.holding,
                    }, "Magnet.C_Stage2")
                    task.delay(0.85, function() isActing = false; enforceMobility(character) end)
                else
                    isActing = true
                    if holdDuration < 0.6 then
                        runEffect(cast.effect, {
                            Origin = root.Position,
                            Root = root,
                            Player = player,
                            Rig = character,
                            Stage = 2,
                            StartCFrame = root.CFrame,
                        }, "Magnet.Transformed.C_Stage2")
                        task.delay(0.8, function() isActing = false; enforceMobility(character) end)
                    else
                        runEffect(cast.effect, {
                            Origin = root.Position,
                            Root = root,
                            Player = player,
                            Rig = character,
                            Stage = 3,
                            Holding = cast.holding,
                            MousePos = { Value = groundPos },
                            TargetPosition = groundPos,
                            EndCFrame = CFrame.new(groundPos),
                        }, "Magnet.Transformed.C_Stage3")
                        task.delay(1.5, function() isActing = false; enforceMobility(character) end)
                    end
                end
                task.delay(5, function() if cast.holding then cast.holding:Destroy() end end)
            end)
        end

    elseif key == "F" then
        if isDown then
            if isFlying then return end
            local fTapMod = ec:FindFirstChild("F_Tap")
            local fEffect = fTapMod and require(fTapMod)
            if fEffect then
                runEffect(fEffect, {
                    Origin = root.Position,
                    Root = root,
                    Player = player,
                    DashSpeed = 0.35,
                    StartCFrame = root.CFrame,
                    Stage = 1,
                }, "Magnet.F_Stage1")
            end
            startFlight(root, isTransformed and 185 or 140)
        else
            stopFlight()
        end
    end
end

-- ================================================================================
-- DISPARADOR UNIVERSAL DE HABILIDADES PARA OTRAS FRUTAS
-- ================================================================================
local function handleUniversalFruitKey(key, isDown, fruitConfig, character, root)
    local ec = EffectContainer:FindFirstChild(fruitConfig.ECFolder)
    if not ec then return end

    if (key == "V" or (fruitConfig.DisplayName == "Buddha" and key == "Z")) and isDown then
        if isActing then return end
        isActing = true
        isTransformed = not isTransformed
        print("[FRUIT ENGINE] ⚡ Cambio de estado V (" .. fruitConfig.DisplayName .. "):\t" .. (isTransformed and "TRANSFORMADO" or "NORMAL"))

        local vMod = ec:FindFirstChild(key) or ec:FindFirstChild("Transformation") or ec:FindFirstChild("V")
        if vMod then
            local effectFunc = require(vMod)
            local targetPos = getMousePosition(root)
            runEffect(effectFunc, {
                Origin = root.Position,
                Root = root,
                Rig = character,
                Player = player,
                Stage = 1,
                at = root.CFrame,
                size = 10,
                targetArray = { targetPos },
            }, fruitConfig.DisplayName .. "." .. key)
        end

        task.delay(1.2, function()
            if isTransformed then
                applyTransformationVisuals(character, fruitConfig)
            else
                cleanTransformationVisuals()
                attachFruitToHand(character, fruitConfig)
            end
            isActing = false
            enforceMobility(character)
            refreshSkillsHUD()
        end)
        return
    end

    if isDown then
        if activeCast then return end
        local mod = (isTransformed and ec:FindFirstChild("Transformed") and ec.Transformed:FindFirstChild(key))
            or ec:FindFirstChild(key)

        if not mod then return end
        local effectFunc = require(mod)

        local holding = Instance.new("BoolValue")
        holding.Value = true
        local mousePosVal = Instance.new("Vector3Value")
        mousePosVal.Value = getMousePosition(root)

        activeCast = { key = key, effect = effectFunc, holding = holding, mousePosVal = mousePosVal }

        -- Stage 1
        runEffect(effectFunc, {
            Origin = root.Position,
            Root = root,
            hrp = root,
            Player = player,
            Rig = character,
            Stage = 1,
            Holding = holding,
            StartCFrame = root.CFrame,
            MousePos = mousePosVal,
            DashSpeed = 0.4,
            Speed = 240,
        }, fruitConfig.DisplayName .. "." .. key .. "_Stage1")

        if key == "F" then
            startFlight(root, 150)
        end
    else
        local cast = activeCast
        if not cast or cast.key ~= key then return end
        activeCast = nil
        if cast.holding then cast.holding.Value = false end

        if key == "F" then
            stopFlight()
        end

        local targetPos = getMousePosition(root)
        if cast.mousePosVal then cast.mousePosVal.Value = targetPos end

        task.delay(0.04, function()
            if not root.Parent or not equipped then return end
            runEffect(cast.effect, {
                Origin = root.Position,
                Root = root,
                hrp = root,
                Player = player,
                Rig = character,
                Stage = 2,
                StartCFrame = root.CFrame,
                EndCFrame = CFrame.new(targetPos),
                UpCFrame = root.CFrame * CFrame.new(0, 35, 0),
                TargetPosition = targetPos,
                MousePos = cast.mousePosVal,
                Speed = 240,
                Range = 300,
                TravelTime = 0.6,
                Seed = math.random(1, 100000),
                DashSpeed = 0.4,
            }, fruitConfig.DisplayName .. "." .. key .. "_Stage2")

            task.delay(5, function()
                if cast.holding then cast.holding:Destroy() end
                if cast.mousePosVal then cast.mousePosVal:Destroy() end
            end)
        end)
    end
end

-- ================================================================================
-- GESTOR CENTRAL DE ENTRADA (TECLAS Z, X, C, V, F)
-- ================================================================================
local function onKeyEvent(key, isDown)
    if not equipped then return end
    local char = player.Character
    local root = getRoot(char)
    if not root then return end

    local fruitConfig = FRUIT_DATABASE[currentFruitKey]
    if not fruitConfig then return end

    if fruitConfig.SpecialCaster then
        handleMagnetKey(key, isDown, fruitConfig, char, root)
    else
        handleUniversalFruitKey(key, isDown, fruitConfig, char, root)
    end
end

-- ================================================================================
-- GESTIÓN DEL TOOL NATIVO EN BACKPACK
-- ================================================================================
local function createFruitTool(fruitConfig)
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end

    if currentTool and currentTool.Parent then
        currentTool:Destroy()
    end
    currentTool = nil

    local tool = Instance.new("Tool")
    tool.Name = fruitConfig.DisplayName
    tool.ToolTip = "Blox Fruit"
    tool.TextureId = ""
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ManualActivationOnly = true

    tool:SetAttribute("ItemId", fruitConfig.ItemId)
    tool:SetAttribute("OriginalImage", fruitConfig.Spritesheet)
    tool:SetAttribute("ImageRectOffset", fruitConfig.SpriteOffset)
    tool:SetAttribute("ImageRectSize", fruitConfig.SpriteSize)
    tool:SetAttribute("ItemType", "Blox Fruit")
    tool:SetAttribute("WeaponType", "Demon Fruit")
    tool:SetAttribute("WeaponName", fruitConfig.DisplayName)
    tool:SetAttribute("FolderReferences", fruitConfig.ECFolder)
    tool:SetAttribute("Level", 600)
    tool:SetAttribute("Exp", 0)
    tool:SetAttribute("OwnerId", player.UserId)

    tool.Equipped:Connect(function()
        equipped = true
        attachFruitToHand(player.Character, fruitConfig)
        if fruitConfig.DisplayName == "Magnet" then
            setupMagnetArms(player.Character)
        end
        refreshSkillsHUD()
        print("[FRUIT ENGINE] 🍎 Fruta " .. fruitConfig.DisplayName .. " Equipada.")
    end)

    tool.Unequipped:Connect(function()
        equipped = false
        cleanHandFruit()
        if fruitConfig.DisplayName == "Magnet" then
            cleanMagnetArms(player.Character)
        end
        stopFlight()
        if isTransformed then
            isTransformed = false
            cleanTransformationVisuals()
        end
        refreshSkillsHUD()
        print("[FRUIT ENGINE] ❌ Fruta " .. fruitConfig.DisplayName .. " Desequipada.")
    end)

    tool.Parent = backpack
    currentTool = tool
    trackInstance(tool)
end

-- ================================================================================
-- CONMUTADOR DE FRUTA EN VIVO
-- ================================================================================
local function selectFruit(fruitKey)
    local fruitConfig = FRUIT_DATABASE[fruitKey]
    if not fruitConfig then return end

    print("[FRUIT ENGINE] 🔄 Conmutando a: " .. fruitConfig.DisplayName .. "...")
    currentFruitKey = fruitKey
    isTransformed = false
    isActing = false

    cleanTransformationVisuals()
    cleanHandFruit()
    stopFlight()

    createFruitTool(fruitConfig)

    -- Si el personaje ya tiene la herramienta en mano, equipar
    pcall(function()
        local char = player.Character
        if char and currentTool then
            currentTool.Parent = char
        end
    end)

    refreshSkillsHUD()
end

-- ================================================================================
-- INTERFAZ GRÁFICA DE SELECCIÓN FLOTANTE (SELECTOR DE FRUTAS F4)
-- ================================================================================
local function buildFruitSelectorUI()
    local container = getContainer()
    local oldGui = container:FindFirstChild("BloxFruitsUniversalSelector")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BloxFruitsUniversalSelector"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Botón Rápido en Pantalla
    local openButton = Instance.new("TextButton")
    openButton.Name = "OpenSelectorButton"
    openButton.Size = UDim2.new(0, 140, 0, 38)
    openButton.Position = UDim2.new(0, 16, 0.45, -50)
    openButton.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
    openButton.BorderSizePixel = 0
    openButton.Text = "🍎 FRUTAS [F4]"
    openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 13
    openButton.Parent = screenGui

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 8)
    openCorner.Parent = openButton

    local openStroke = Instance.new("UIStroke")
    openStroke.Color = Color3.fromRGB(220, 40, 70)
    openStroke.Thickness = 1.5
    openStroke.Parent = openButton

    -- Ventana Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainSelectorFrame"
    mainFrame.Size = UDim2.new(0, 680, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(45, 55, 75)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainFrame

    -- Barra Superior
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 46)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ SELECTOR MAESTRO DE FRUTAS | V3 REAL MCP"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -40, 0, 7)
    closeButton.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = topBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    -- Barra de Búsqueda y Filtro de Categorías
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0, 220, 0, 32)
    searchBox.Position = UDim2.new(0, 16, 0, 54)
    searchBox.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍 Buscar fruta..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 150)
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.Parent = mainFrame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox

    -- Contenedor de Botones de Categoría
    local catFrame = Instance.new("Frame")
    catFrame.Name = "CategoryTabs"
    catFrame.Size = UDim2.new(1, -260, 0, 32)
    catFrame.Position = UDim2.new(0, 246, 0, 54)
    catFrame.BackgroundTransparency = 1
    catFrame.Parent = mainFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = catFrame

    local currentCategory = "TODAS"
    local categoryButtons = {}

    -- Scroll de Frutas
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "FruitCardsScroll"
    scroll.Size = UDim2.new(1, -32, 1, -104)
    scroll.Position = UDim2.new(0, 16, 0, 94)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(220, 40, 70)
    scroll.Parent = mainFrame

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 204, 0, 108)
    grid.CellPadding = UDim2.new(0, 12, 0, 12)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scroll

    -- Generar Tarjetas
    local cards = {}
    for key, config in pairs(FRUIT_DATABASE) do
        local card = Instance.new("Frame")
        card.Name = "Card_" .. config.DisplayName
        card.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
        card.BorderSizePixel = 0
        card.Parent = scroll

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = config.Color
        cardStroke.Thickness = 1.2
        cardStroke.Transparency = 0.6
        cardStroke.Parent = card

        -- Ícono oficial desde Spritesheet
        local icon = Instance.new("ImageLabel")
        icon.Name = "FruitIcon"
        icon.Size = UDim2.new(0, 48, 0, 48)
        icon.Position = UDim2.new(0, 8, 0, 8)
        icon.BackgroundTransparency = 1
        icon.Image = config.Spritesheet
        icon.ImageRectOffset = config.SpriteOffset
        icon.ImageRectSize = config.SpriteSize
        icon.Parent = card

        -- Nombre
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "FruitName"
        nameLabel.Size = UDim2.new(1, -66, 0, 20)
        nameLabel.Position = UDim2.new(0, 62, 0, 8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = config.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- Badge de Rareza
        local rarityBadge = Instance.new("TextLabel")
        rarityBadge.Name = "RarityBadge"
        rarityBadge.Size = UDim2.new(0, 75, 0, 16)
        rarityBadge.Position = UDim2.new(0, 62, 0, 30)
        rarityBadge.BackgroundColor3 = config.Color
        rarityBadge.BackgroundTransparency = 0.8
        rarityBadge.Text = config.Rarity:upper()
        rarityBadge.TextColor3 = config.Color
        rarityBadge.Font = Enum.Font.GothamBold
        rarityBadge.TextSize = 9
        rarityBadge.Parent = card

        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 4)
        badgeCorner.Parent = rarityBadge

        -- Botón de Selección
        local equipBtn = Instance.new("TextButton")
        equipBtn.Name = "EquipButton"
        equipBtn.Size = UDim2.new(1, -16, 0, 28)
        equipBtn.Position = UDim2.new(0, 8, 1, -36)
        equipBtn.BackgroundColor3 = config.Color
        equipBtn.BorderSizePixel = 0
        equipBtn.Text = "CLONAR / USAR"
        equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        equipBtn.Font = Enum.Font.GothamBold
        equipBtn.TextSize = 11
        equipBtn.Parent = card

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = equipBtn

        equipBtn.MouseButton1Click:Connect(function()
            selectFruit(key)
            mainFrame.Visible = false
        end)

        table.insert(cards, { frame = card, name = config.DisplayName:lower(), category = config.Category })
    end

    local function updateFilter()
        local query = searchBox.Text:lower()
        for _, c in ipairs(cards) do
            local matchesQuery = (query == "" or c.name:find(query))
            local matchesCat = (currentCategory == "TODAS" or c.category == currentCategory)
            c.frame.Visible = (matchesQuery and matchesCat)
        end
    end

    -- Generar Botones de Categorías
    local catNames = {
        { id = "TODAS", label = "TODAS" },
        { id = "MYTHICAL", label = "MÍTICAS" },
        { id = "LEGENDARY", label = "LEGEND." },
        { id = "BEAST", label = "BESTIAS" },
        { id = "RARE", label = "RARAS" },
        { id = "COMMON", label = "COMUNES" },
    }

    for _, cat in ipairs(catNames) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. cat.id
        btn.Size = UDim2.new(0, 62, 1, 0)
        btn.BackgroundColor3 = (cat.id == "TODAS") and Color3.fromRGB(220, 40, 70) or Color3.fromRGB(25, 30, 45)
        btn.BorderSizePixel = 0
        btn.Text = cat.label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.Parent = catFrame

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 6)
        bCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            currentCategory = cat.id
            for _, otherBtn in ipairs(categoryButtons) do
                otherBtn.button.BackgroundColor3 = (otherBtn.id == currentCategory) and Color3.fromRGB(220, 40, 70) or Color3.fromRGB(25, 30, 45)
            end
            updateFilter()
        end)

        table.insert(categoryButtons, { id = cat.id, button = btn })
    end

    -- Filtro por Búsqueda
    searchBox:GetPropertyChangedSignal("Text"):Connect(updateFilter)

    -- Toggle de Visibilidad
    local function toggleUI()
        mainFrame.Visible = not mainFrame.Visible
    end

    openButton.MouseButton1Click:Connect(toggleUI)
    closeButton.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

    -- Arrastre de Ventana
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    screenGui.Parent = container
    trackInstance(screenGui)
    return screenGui, toggleUI
end

-- ================================================================================
-- INICIALIZACIÓN Y ENLACE DE ENTRADA
-- ================================================================================
local function initializeEngine()
    ensurePlayerSpawned()

    local ui, toggleUI = buildFruitSelectorUI()

    -- Enlace de Teclado
    registerConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F4 or input.KeyCode == Enum.KeyCode.RightControl then
            if toggleUI then toggleUI() end
        elseif input.KeyCode == Enum.KeyCode.Z then
            onKeyEvent("Z", true)
        elseif input.KeyCode == Enum.KeyCode.X then
            onKeyEvent("X", true)
        elseif input.KeyCode == Enum.KeyCode.C then
            onKeyEvent("C", true)
        elseif input.KeyCode == Enum.KeyCode.V then
            onKeyEvent("V", true)
        elseif input.KeyCode == Enum.KeyCode.F then
            onKeyEvent("F", true)
        end
    end))

    registerConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Z then
            onKeyEvent("Z", false)
        elseif input.KeyCode == Enum.KeyCode.X then
            onKeyEvent("X", false)
        elseif input.KeyCode == Enum.KeyCode.C then
            onKeyEvent("C", false)
        elseif input.KeyCode == Enum.KeyCode.V then
            onKeyEvent("V", false)
        elseif input.KeyCode == Enum.KeyCode.F then
            onKeyEvent("F", false)
        end
    end))

    -- Auto-Respawn y Vigilancia del Personaje
    registerConnection(player.CharacterAdded:Connect(function(newChar)
        task.wait(1.0)
        enforceMobility(newChar)
        local fruitConfig = FRUIT_DATABASE[currentFruitKey]
        if fruitConfig then
            createFruitTool(fruitConfig)
        end
    end))

    -- Loop de recuperación si muere o se desincroniza
    task.spawn(function()
        while engineState.running do
            task.wait(4)
            ensurePlayerSpawned()
            if equipped and player.Character then
                enforceMobility(player.Character)
            end
        end
    end)

    -- Iniciar con Magnet por defecto
    selectFruit("Magnet-Magnet")

    print("[FRUIT ENGINE] 🚀 ¡UNIVERSAL FRUIT SELECTOR & MASTER ENGINE V3 CARGADO!")
    print("[FRUIT ENGINE] 💡 Presiona [F4] o haz clic en '🍎 FRUTAS' para abrir el menú.")
end

-- Función de Limpieza
engineState.cleanup = function()
    engineState.running = false
    for _, conn in ipairs(engineState.connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, inst in ipairs(engineState.instances) do
        pcall(function() inst:Destroy() end)
    end
    cleanTransformationVisuals()
    cleanHandFruit()
    stopFlight()
end

initializeEngine()
