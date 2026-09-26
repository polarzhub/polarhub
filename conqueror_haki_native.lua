--[[
    ================================================================================
    POLAR HUB | NATIVE CONQUEROR'S HAKI (HAOSHOKU INFUSION) V7 - ISLAND-WIDE STORM
    ================================================================================
    Novedades V7:
      1. RAYOS CERCANOS Y LEJANOS SIMULTÁNEOS (COBERTURA TOTAL DE LA ISLA):
         - DE CERCA (CONSERVADO AL 100%):
           * Rayos de alta tensión que chocan contra paredes, columnas y techos.
           * Chispas de Yama y ElectroSmog.Shocks de CDK en el punto de contacto.
           * Arcos secundarios reptantes por la superficie de las paredes.
         - DE LEJOS (EXPANSIÓN SEGUNDO A SEGUNDO):
           * Cada segundo de carga genera MÁS rayos lejanos a mayor distancia.
           * Desde 120 studs hasta más de 2500 studs (toda la isla y el horizonte).
           * Columnas colosales de relámpago de 250-320 studs de altura descendiendo
             de las nubes sobre montañas, bosques, castillos y el océano.
           * En carga alta, más de 30-50 rayos gigantescos azotan la isla a la vez.
      2. ESCALADO EXACTO AL SOLTAR [H] (57% AL MINUTO):
         - Duración máxima: 120 segundos.
         - Potencia proporcional continua segundo a segundo: f(t) = (t / 120)^0.81
           * A 1 minuto: Exactamente el 57% de potencia (radio ~1450 studs, 5 anillos).
           * A 120 segundos: 100% ABSURDAMENTE COLOSAL (2500+ studs, 8 anillos concéntricos,
             Squash de 480 studs, 550+ relámpagos, cubriendo toda la isla y el mar).
      3. VISIBILIDAD CRISTALINA Y SOMBRÍA:
         - Eclipse atmosférico sombrío (Brightness -0.35 máx, Contraste +0.22).
         - 100% visible: los rayos rojos carmesí y negros de vacío resaltan al máximo.
      4. CÁMARA ULTRA-ESTABILIZADA:
         - Sacudida de impacto pesada con CERO balanceo lateral (roll = 0).
    ================================================================================
    Controles:
      - Mantén presionada [G]: ¡Carga y sostiene la ETAPA MÁXIMA de la H permanentemente!
      - Suelta [G]: Desata el Estallido Máximo Absoluto (100% de la H, 120s colosal).
      - Mantén presionada [H]: Concentra el Haki progresivamente (0 a 120 segundos).
      - Suelta [H]: Desata el Estallido Proporcional al tiempo cargado (57% a 1 min).
      - Equipar/Desequipar espadas: El aura se transfiere automáticamente.
      - _G.ConquerorMaxBurst(): Detonar instantáneamente el nivel máximo vía código.
      - _G.ConquerorBurst(mult, ratio): Detonar directamente vía código.
      - _G.ConquerorHakiCleanup(): Desmontar y limpiar todo.
    ================================================================================
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Global Environment Handler
local G = (getgenv and getgenv()) or _G

-- Limpieza preventiva
if G.ConquerorHakiCleanup then pcall(G.ConquerorHakiCleanup) end
if _G.ConquerorHakiCleanup and _G.ConquerorHakiCleanup ~= G.ConquerorHakiCleanup then
    pcall(_G.ConquerorHakiCleanup)
end

-- Limpieza de efectos de iluminación previos
pcall(function()
    for _, c in ipairs(Lighting:GetChildren()) do
        if c:IsA("ColorCorrectionEffect") and (c.Name:find("Polar") or c.Name:find("Slayer")) then
            c:Destroy()
        end
        if c:IsA("BloomEffect") and (c.Name:find("Polar") or c.Name:find("Slayer")) then
            c:Destroy()
        end
    end
end)

-- Limpiar instancias previas en el personaje
pcall(function()
    local char = LocalPlayer.Character
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc.Name == "PolarNativeHaki" or desc.Name == "PolarConquerorAmbient" then
                desc:Destroy()
            end
        end
    end
end)

local Engine = {
    Active = true,
    AuraEnabled = true,
    Connections = {},
    ActiveAttachments = {},
    
    -- Sistema de Carga
    IsCharging = false,
    ChargeStartTime = 0,
    MaxChargeDuration = 120.0,
    ChargeSound = nil,
    ActiveColorCorr = nil,
    
    LastBurstTime = 0,
    Cooldown = 0.5
}

-- ================================================================================
-- RECURSOS OFICIALES NATIVOS DE BLOX FRUITS
-- ================================================================================
local EffectContainer = ReplicatedStorage:WaitForChild("EffectContainer", 5)
local FX = ReplicatedStorage:WaitForChild("FX", 5)

-- CDK
local CDK_Folder = EffectContainer and EffectContainer:FindFirstChild("CursedDualKatana")
local CDK_Z = CDK_Folder and CDK_Folder:FindFirstChild("Z")
local CDK_X = CDK_Folder and CDK_Folder:FindFirstChild("X")

local CDKCursedAuraTemplate = CDK_Z and CDK_Z:FindFirstChild("CDKCursedAura")
local CDKAuraParticles = CDKCursedAuraTemplate and CDKCursedAuraTemplate:FindFirstChild("Particles")
local TornadoExplosionTemplate = CDK_Z and CDK_Z:FindFirstChild("TornadoExplosion")
local StaticImpactTemplate = CDK_Z and CDK_Z:FindFirstChild("StaticImpact")
local SlayerHitTemplate = CDK_X and CDK_X:FindFirstChild("SlayerHit")

local ElectroSmog = CDK_X and CDK_X:FindFirstChild("ElectroSmog")
local CDKElectricShocks = ElectroSmog and ElectroSmog:FindFirstChild("Shocks")

-- Yama
local Yama_FX = FX and FX:FindFirstChild("Yama")
local YamaSkill1 = Yama_FX and Yama_FX:FindFirstChild("YamaSkill1")
local YamaGroundSparks = YamaSkill1 and YamaSkill1:FindFirstChild("GroundSparks")

-- ActivateAura
local ActivateAuraFolder = EffectContainer and EffectContainer:FindFirstChild("ActivateAura")
local Phase1 = ActivateAuraFolder and ActivateAuraFolder:FindFirstChild("Assets") and ActivateAuraFolder.Assets:FindFirstChild("Phase1")
local StartImpactTemplate = Phase1 and Phase1:FindFirstChild("StartImpact")

-- ================================================================================
-- 1. FÓRMULA DE ESCALADO DINÁMICO PROPORCIONAL (57% A 1 MINUTO)
-- ================================================================================
local function GetChargeStats(elapsed)
    local t = math.clamp(elapsed, 0, 120)
    local linearProgress = t / 120.0
    local powerRatio = (linearProgress) ^ 0.81

    -- Multiplicador de potencia (de 1.0x hasta 35.0x)
    local mult = 1.0 + (powerRatio * 34.0)

    -- Radio del estallido: desde 60 studs hasta 2500+ studs (isla entera)
    local blastRadius = 60.0 + (powerRatio * 2440.0)

    return mult, powerRatio, blastRadius, linearProgress
end

-- ================================================================================
-- 1.1 FÓRMULA DE CARGA ACELERADA PARA [G] (COMIENZA AL 77% Y LLEGA RÁPIDO AL MÁXIMO)
-- ================================================================================
local function GetGChargeStats(elapsed)
    -- G comienza directamente al 77% (0.77 del poder máximo de la H)
    -- Al mantenerlo, escala rápidamente hasta el 100% Máximo Absoluto en ~7 segundos
    local rampDuration = 7.0 -- segundos para pasar del 77% al 100%
    local fraction = math.clamp(elapsed / rampDuration, 0, 1)

    local powerRatio = 0.77 + (fraction * 0.23) -- Rango: 0.77 -> 1.00 (100%)
    local linearProgress = 0.724 + (fraction * 0.276) -- Rango: 0.724 -> 1.00

    local mult = 1.0 + (powerRatio * 34.0) -- Rango: 27.18x -> 35.0x
    local blastRadius = 60.0 + (powerRatio * 2440.0) -- Rango: 1938.8 studs -> 2500+ studs

    return mult, powerRatio, blastRadius, linearProgress
end

-- ================================================================================
-- 2. AUDIO SÍSMICO Y RETUMBE DE ISLA
-- ================================================================================
local function PlayConquerorBurstAudio(parent, multiplier)
    local mult = multiplier or 1.0

    -- Sonido 1: Bajo de Haki del Conquistador (Blox Fruits)
    local s1 = Instance.new("Sound")
    s1.SoundId = "rbxassetid://9069609200"
    s1.Volume = math.clamp(4.0 + (mult * 0.18), 4.0, 9.0)
    s1.PlaybackSpeed = math.clamp(0.90 - (mult * 0.006), 0.65, 0.95)
    s1.Parent = parent or Workspace
    s1:Play()
    Debris:AddItem(s1, 6)

    -- Sonido 2: Impacto CDK
    local s2 = Instance.new("Sound")
    s2.SoundId = "rbxassetid://6026998623"
    s2.Volume = math.clamp(2.8 + (mult * 0.15), 2.8, 8.0)
    s2.PlaybackSpeed = 0.94
    s2.Parent = parent or Workspace
    s2:Play()
    Debris:AddItem(s2, 6)

    -- Sonido 3: Trueno expansivo de alta tensión
    local s3 = Instance.new("Sound")
    s3.SoundId = "rbxassetid://5801257793"
    s3.Volume = math.clamp(2.2 + (mult * 0.12), 2.2, 7.0)
    s3.PlaybackSpeed = 1.0
    s3.Parent = parent or Workspace
    s3:Play()
    Debris:AddItem(s3, 5)
end

-- ================================================================================
-- 3. SACUDIDA ESTABILIZADA DE CÁMARA (CERO VOLTEO / ROLL = 0)
-- ================================================================================
local function ShakeScreenStabilized(intensity, duration)
    task.spawn(function()
        local start = os.clock()
        local prevOffset = CFrame.new()

        while os.clock() - start < duration do
            local elapsed = os.clock() - start
            local progress = elapsed / duration
            local damp = (1 - progress) * (1 - progress)

            Camera.CFrame = Camera.CFrame * prevOffset:Inverse()

            local offsetX = (math.random() - 0.5) * intensity * damp * 0.45
            local offsetY = (math.random() - 0.5) * intensity * damp * 0.65
            local pitch = math.rad((math.random() - 0.5) * intensity * damp * 0.75)
            local yaw = math.rad((math.random() - 0.5) * intensity * damp * 0.55)

            prevOffset = CFrame.new(offsetX, offsetY, 0) * CFrame.Angles(pitch, yaw, 0)
            Camera.CFrame = Camera.CFrame * prevOffset

            RunService.RenderStepped:Wait()
        end

        Camera.CFrame = Camera.CFrame * prevOffset:Inverse()
    end)
end

-- ================================================================================
-- 4. ELECTRICIDAD PURA NATIVA: VIGAS GRUESAS Y CHOQUE EN PAREDES
-- ================================================================================
local function SpawnThickBeam(posA, posB, widthMult)
    local wMult = widthMult or 1.0

    local pA = Instance.new("Part")
    pA.Anchored = true
    pA.CanCollide = false
    pA.Transparency = 1
    pA.Size = Vector3.new(1, 1, 1)
    pA.Position = posA
    pA.Parent = Workspace

    local pB = Instance.new("Part")
    pB.Anchored = true
    pB.CanCollide = false
    pB.Transparency = 1
    pB.Size = Vector3.new(1, 1, 1)
    pB.Position = posB
    pB.Parent = Workspace

    local attA = Instance.new("Attachment", pA)
    local attB = Instance.new("Attachment", pB)

    local curveA = math.random(-8, 8) * math.clamp(wMult * 0.75, 1, 3.5)
    local curveB = math.random(-8, 8) * math.clamp(wMult * 0.75, 1, 3.5)

    -- Capa 1: Núcleo Rojo Carmesí Eléctrico
    local beamRed = Instance.new("Beam")
    beamRed.Texture = "rbxassetid://13002793471"
    beamRed.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 15, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 10))
    })
    beamRed.Width0 = math.clamp(4.8 * wMult, 4.8, 25.0)
    beamRed.Width1 = math.clamp(3.0 * wMult, 3.0, 18.0)
    beamRed.FaceCamera = true
    beamRed.Segments = 10
    beamRed.CurveSize0 = curveA
    beamRed.CurveSize1 = curveB
    beamRed.LightEmission = 1
    beamRed.Attachment0 = attA
    beamRed.Attachment1 = attB
    beamRed.Parent = pA

    -- Capa 2: Vacío Negro de Conquistador
    local beamBlack = Instance.new("Beam")
    beamBlack.Texture = "rbxassetid://13002793471"
    beamBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beamBlack.Width0 = math.clamp(7.2 * wMult, 7.2, 35.0)
    beamBlack.Width1 = math.clamp(4.5 * wMult, 4.5, 24.0)
    beamBlack.FaceCamera = true
    beamBlack.Segments = 10
    beamBlack.CurveSize0 = curveA
    beamBlack.CurveSize1 = curveB
    beamBlack.LightEmission = 0
    beamBlack.ZOffset = -0.3
    beamBlack.Attachment0 = attA
    beamBlack.Attachment1 = attB
    beamBlack.Parent = pA

    Debris:AddItem(pA, 0.22)
    Debris:AddItem(pB, 0.22)
end

-- Detona el impacto de electricidad pura que choca contra una pared o superficie
local function SpawnWallImpactElectricity(originPos, hitPos, hitNormal, widthMult)
    local wMult = widthMult or 1.0

    -- 1. Rayo grueso que viaja del jugador/arma al punto de impacto en la pared
    SpawnThickBeam(originPos, hitPos, wMult)

    -- 2. Parte de anclaje orientada según la superficie de la pared
    local pWall = Instance.new("Part")
    pWall.Anchored = true
    pWall.CanCollide = false
    pWall.Transparency = 1
    pWall.Size = Vector3.new(1, 1, 1)
    pWall.CFrame = CFrame.lookAt(hitPos, hitPos + hitNormal)
    pWall.Parent = Workspace
    Debris:AddItem(pWall, 0.8)

    local attWall = Instance.new("Attachment", pWall)

    -- 3. Chispas de Yama orientadas a la pared
    if YamaGroundSparks then
        local sparks = YamaGroundSparks:Clone()
        sparks.CFrame = pWall.CFrame
        sparks.Anchored = true
        sparks.CanCollide = false
        sparks.Transparency = 1
        sparks.Parent = Workspace
        Debris:AddItem(sparks, 0.8)

        for _, pe in ipairs(sparks:GetDescendants()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(math.floor(15 * math.clamp(wMult, 1, 3)))
                task.delay(0.2, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    -- 4. CDK ElectroSmog Shocks nativo (electricidad pura) explotando contra la pared
    if CDKElectricShocks then
        local cdkShockClone = CDKElectricShocks:Clone()
        cdkShockClone.Enabled = true
        cdkShockClone.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 6.0 * math.clamp(wMult, 1, 3.5)),
            NumberSequenceKeypoint.new(1, 0)
        })
        cdkShockClone.Parent = attWall
        cdkShockClone:Emit(math.floor(12 * math.clamp(wMult, 1, 3)))
        task.delay(0.25, function() pcall(function() cdkShockClone.Enabled = false end) end)
    end

    -- 5. Rayos secundarios reptando por la superficie de la pared
    task.spawn(function()
        local up = math.abs(hitNormal.Y) < 0.9 and Vector3.new(0, 1, 0) or Vector3.new(1, 0, 0)
        local tangent = hitNormal:Cross(up).Unit
        local bitangent = hitNormal:Cross(tangent).Unit

        local crawlCount = math.random(2, 3)
        for _ = 1, crawlCount do
            local offsetDist = math.random(4, math.floor(8 * math.clamp(wMult, 1, 2.5)))
            local angle = math.random() * math.pi * 2
            local crawlTarget = hitPos + (tangent * (math.cos(angle) * offsetDist)) + (bitangent * (math.sin(angle) * offsetDist))
            SpawnThickBeam(hitPos, crawlTarget, wMult * 0.55)
        end
    end)
end

-- ================================================================================
-- 5. COLUMNAS DE RELÁMPAGOS LEJANOS EN TODA LA ISLA (DISTANT LIGHTNING PILLARS)
-- ================================================================================
local function SpawnIslandDistantLightning(targetGround, skyHeight, widthMult, distance)
    local sH = skyHeight or 260.0
    local wM = widthMult or 1.0
    local dist = distance or 300.0

    -- Escalar grosor según la distancia para que no se vea delgado a lo lejos
    local distFactor = math.clamp(dist / 320.0, 1.0, 3.8)
    local finalWidth = wM * distFactor

    local skyPos = targetGround + Vector3.new(math.random(-20, 20), sH, math.random(-20, 20))

    local pG = Instance.new("Part")
    pG.Anchored = true
    pG.CanCollide = false
    pG.Transparency = 1
    pG.Size = Vector3.new(1, 1, 1)
    pG.Position = targetGround
    pG.Parent = Workspace

    local pS = Instance.new("Part")
    pS.Anchored = true
    pS.CanCollide = false
    pS.Transparency = 1
    pS.Size = Vector3.new(1, 1, 1)
    pS.Position = skyPos
    pS.Parent = Workspace

    local aG = Instance.new("Attachment", pG)
    local aS = Instance.new("Attachment", pS)

    local cA = math.random(-12, 12) * math.clamp(finalWidth * 0.4, 1, 4)
    local cB = math.random(-12, 12) * math.clamp(finalWidth * 0.4, 1, 4)

    -- Viga Roja Lejana
    local bRed = Instance.new("Beam")
    bRed.Texture = "rbxassetid://13002793471"
    bRed.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 10))
    })
    bRed.Width0 = math.clamp(8.0 * finalWidth, 8.0, 40.0)
    bRed.Width1 = math.clamp(4.5 * finalWidth, 4.5, 24.0)
    bRed.FaceCamera = true
    bRed.Segments = 12
    bRed.CurveSize0 = cA
    bRed.CurveSize1 = cB
    bRed.LightEmission = 1
    bRed.Attachment0 = aS
    bRed.Attachment1 = aG
    bRed.Parent = pG

    -- Viga Negra de Vacío Lejana
    local bBlack = Instance.new("Beam")
    bBlack.Texture = "rbxassetid://13002793471"
    bBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    bBlack.Width0 = math.clamp(12.0 * finalWidth, 12.0, 55.0)
    bBlack.Width1 = math.clamp(6.8 * finalWidth, 6.8, 32.0)
    bBlack.FaceCamera = true
    bBlack.Segments = 12
    bBlack.CurveSize0 = cA
    bBlack.CurveSize1 = cB
    bBlack.LightEmission = 0
    bBlack.ZOffset = -0.3
    bBlack.Attachment0 = aS
    bBlack.Attachment1 = aG
    bBlack.Parent = pG

    -- Chispas de impacto de Yama en el suelo lejano
    if YamaGroundSparks then
        local sparks = YamaGroundSparks:Clone()
        sparks.CFrame = CFrame.new(targetGround)
        sparks.Anchored = true
        sparks.CanCollide = false
        sparks.Transparency = 1
        sparks.Parent = Workspace
        Debris:AddItem(sparks, 1.0)

        for _, pe in ipairs(sparks:GetDescendants()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(20)
                task.delay(0.25, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    Debris:AddItem(pG, 0.35)
    Debris:AddItem(pS, 0.35)
end

-- Relámpagos que rasgan las esquinas de la pantalla
local function SpawnScreenLightning(widthMult)
    local w = widthMult or 1.0
    local cf = Camera.CFrame
    local angle = math.random() * math.pi * 2
    local dist = math.random(4, 7)
    local p1Pos = (cf * CFrame.new(math.cos(angle) * dist, math.sin(angle) * dist, -5.0)).Position
    local p2Pos = (cf * CFrame.new((math.cos(angle) * dist) * 0.35 + (math.random() - 0.5) * 2, (math.sin(angle) * dist) * 0.35 + (math.random() - 0.5) * 2, -4.5)).Position

    local p1 = Instance.new("Part")
    p1.Anchored = true
    p1.CanCollide = false
    p1.Transparency = 1
    p1.Position = p1Pos
    p1.Parent = Camera

    local p2 = Instance.new("Part")
    p2.Anchored = true
    p2.CanCollide = false
    p2.Transparency = 1
    p2.Position = p2Pos
    p2.Parent = Camera

    local a1 = Instance.new("Attachment", p1)
    local a2 = Instance.new("Attachment", p2)

    local bRed = Instance.new("Beam")
    bRed.Texture = "rbxassetid://13002793471"
    bRed.Color = ColorSequence.new(Color3.fromRGB(255, 45, 55))
    bRed.Width0 = math.clamp(2.0 * w, 2.0, 6.5)
    bRed.Width1 = math.clamp(1.2 * w, 1.2, 4.0)
    bRed.FaceCamera = true
    bRed.Attachment0 = a1
    bRed.Attachment1 = a2
    bRed.LightEmission = 1
    bRed.Parent = p1

    local bBlack = Instance.new("Beam")
    bBlack.Texture = "rbxassetid://13002793471"
    bBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    bBlack.Width0 = math.clamp(3.0 * w, 3.0, 9.5)
    bBlack.Width1 = math.clamp(1.8 * w, 1.8, 6.0)
    bBlack.FaceCamera = true
    bBlack.Attachment0 = a1
    bBlack.Attachment1 = a2
    bBlack.LightEmission = 0
    bBlack.ZOffset = -0.2
    bBlack.Parent = p1

    Debris:AddItem(p1, 0.18)
    Debris:AddItem(p2, 0.18)
end

-- ================================================================================
-- 6. AURA NATIVA CON ELECTRICIDAD PURA (ESPADA Y MANOS)
-- ================================================================================
local function ApplyConquerorAura(targetPart)
    if not targetPart or targetPart:FindFirstChild("PolarNativeHaki") then return end
    if not CDKAuraParticles then return end

    local clonedAtt = CDKAuraParticles:Clone()
    clonedAtt.Name = "PolarNativeHaki"
    clonedAtt.Parent = targetPart

    for _, em in ipairs(clonedAtt:GetChildren()) do
        if em:IsA("ParticleEmitter") then
            em.Enabled = true
            if em.Name == "Red" then
                em.Rate = 140
                em.LightEmission = 0.9
                em.Brightness = 3
            elseif em.Name == "Black" then
                em.Rate = 140
                em.ZOffset = -0.45
                em.LightEmission = 0
                em.Brightness = 0
            elseif em.Name == "Orbs" then
                em.Rate = 50
                em.Brightness = 6
                em.LightEmission = 1
            elseif em.Name == "Air" then
                em.Rate = 18
            end
        end
    end

    -- Relámpago Rojo Dentado de Yama (Gigante)
    local redLightning = Instance.new("ParticleEmitter")
    redLightning.Name = "OverloadRedLightning"
    redLightning.Texture = "rbxassetid://13002793471"
    redLightning.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 15, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 0, 15))
    })
    redLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.4),
        NumberSequenceKeypoint.new(0.3, 6.0),
        NumberSequenceKeypoint.new(1, 0)
    })
    redLightning.Lifetime = NumberRange.new(0.2, 0.42)
    redLightning.Rate = 50
    redLightning.Speed = NumberRange.new(10, 26)
    redLightning.SpreadAngle = Vector2.new(75, 75)
    redLightning.LightEmission = 1
    redLightning.Brightness = 8
    redLightning.Parent = clonedAtt

    -- Relámpago Negro de Vacío
    local blackLightning = Instance.new("ParticleEmitter")
    blackLightning.Name = "OverloadBlackLightning"
    blackLightning.Texture = "rbxassetid://13002793471"
    blackLightning.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    blackLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.8),
        NumberSequenceKeypoint.new(0.3, 6.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackLightning.Lifetime = NumberRange.new(0.2, 0.42)
    blackLightning.Rate = 50
    blackLightning.Speed = NumberRange.new(10, 26)
    blackLightning.SpreadAngle = Vector2.new(75, 75)
    blackLightning.LightEmission = 0
    blackLightning.Brightness = 0
    blackLightning.ZOffset = -0.5
    blackLightning.Parent = clonedAtt

    -- Shocks de Electricidad Pura CDK (rbxassetid://2043130629)
    if CDKElectricShocks then
        local cdkShockInAura = CDKElectricShocks:Clone()
        cdkShockInAura.Name = "CDKPureElectricShocks"
        cdkShockInAura.Enabled = true
        cdkShockInAura.Rate = 35
        cdkShockInAura.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 5.0),
            NumberSequenceKeypoint.new(1, 0)
        })
        cdkShockInAura.Brightness = 7
        cdkShockInAura.Parent = clonedAtt
    end

    -- Ramificaciones Eléctricas
    local branchSparks = Instance.new("ParticleEmitter")
    branchSparks.Name = "OverloadBranchSparks"
    branchSparks.Texture = "rbxassetid://13001442706"
    branchSparks.Color = ColorSequence.new(Color3.fromRGB(255, 70, 80))
    branchSparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    branchSparks.Lifetime = NumberRange.new(0.18, 0.35)
    branchSparks.Rate = 40
    branchSparks.Speed = NumberRange.new(16, 34)
    branchSparks.SpreadAngle = Vector2.new(180, 180)
    branchSparks.LightEmission = 1
    branchSparks.Brightness = 7
    branchSparks.Parent = clonedAtt

    -- Arcos Eléctricos CDK
    local cdkShocks = Instance.new("ParticleEmitter")
    cdkShocks.Name = "OverloadElectricArcs"
    cdkShocks.Texture = "rbxassetid://280272015"
    cdkShocks.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 0, 0))
    })
    cdkShocks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.5, 5.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    cdkShocks.Lifetime = NumberRange.new(0.18, 0.32)
    cdkShocks.Rate = 30
    cdkShocks.Speed = NumberRange.new(8, 22)
    cdkShocks.SpreadAngle = Vector2.new(90, 90)
    cdkShocks.LightEmission = 1
    cdkShocks.Brightness = 7
    cdkShocks.Parent = clonedAtt

    table.insert(Engine.ActiveAttachments, clonedAtt)
end

function Engine:RefreshAura()
    for _, att in ipairs(self.ActiveAttachments) do
        if att and att.Parent then pcall(function() att:Destroy() end) end
    end
    self.ActiveAttachments = {}

    local char = LocalPlayer.Character
    if not char then return end

    local hasEquippedSword = false
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            for _, part in ipairs(item:GetDescendants()) do
                if part:IsA("BasePart") then
                    local n = part.Name:lower()
                    if n:find("blade") or n:find("sword") or n:find("handle") then
                        ApplyConquerorAura(part)
                        hasEquippedSword = true
                    end
                end
            end
            if not hasEquippedSword and item:FindFirstChild("Handle") then
                ApplyConquerorAura(item.Handle)
                hasEquippedSword = true
            end
        end
    end

    if not hasEquippedSword then
        local rArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        local lArm = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        if rArm then ApplyConquerorAura(rArm) end
        if lArm then ApplyConquerorAura(lArm) end
    end
end

-- ================================================================================
-- 7. SISTEMA DE CARGA DINÁMICA: RAYOS CERCANOS + RAYOS LEJANOS EN TODA LA ISLA
-- ================================================================================
function Engine:StartCharging(mode)
    if self.IsCharging then return end
    if os.clock() - self.LastBurstTime < self.Cooldown then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    self.ChargeMode = mode or "H"
    self.IsCharging = true
    self.ChargeStartTime = os.clock()

    -- Audio de carga
    pcall(function()
        local s = Instance.new("Sound")
        s.Name = "PolarChargeSound"
        s.SoundId = "rbxassetid://6026998623"
        s.Looped = true
        s.Volume = (self.ChargeMode == "G" and 2.8) or 0.9
        s.PlaybackSpeed = (self.ChargeMode == "G" and 1.35) or 0.75
        s.Parent = hrp
        s:Play()
        self.ChargeSound = s
    end)

    -- ILUMINACIÓN SOMBRÍA Y NÍTIDA (SIN PANTALLA CIEGA)
    pcall(function()
        if not self.ActiveColorCorr then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "PolarConquerorLighting"
            cc.Brightness = 0
            cc.Contrast = 0.05
            cc.Saturation = 0.08
            cc.TintColor = Color3.fromRGB(255, 245, 245)
            cc.Parent = Lighting
            self.ActiveColorCorr = cc
        end
    end)

    -- BUCLE DE TORMENTA ELÉCTRICA DUAL: CERCA (PAREDES) + LEJOS (ISLA COMPLETA)
    task.spawn(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        while self.IsCharging and self.Active do
            local elapsed = os.clock() - self.ChargeStartTime
            local mult, powerRatio, blastRadius, linearProgress
            if self.ChargeMode == "G" then
                -- Modo G: Comienza al 77% del máximo de la H y llega rápidamente al 100% en ~7s
                mult, powerRatio, blastRadius, linearProgress = GetGChargeStats(elapsed)
            else
                mult, powerRatio, blastRadius, linearProgress = GetChargeStats(elapsed)
            end

            -- 1. Oscurecimiento sombrío equilibrado (Brightness -0.35 máx a los 120s)
            if self.ActiveColorCorr then
                self.ActiveColorCorr.Brightness = -linearProgress * 0.35
                self.ActiveColorCorr.Contrast = 0.05 + (linearProgress * 0.18)
                self.ActiveColorCorr.Saturation = 0.08 + (linearProgress * 0.12)
                self.ActiveColorCorr.TintColor = Color3.fromRGB(255, math.floor(245 - linearProgress * 25), math.floor(245 - linearProgress * 25))
            end

            -- 2. Modulación de sonido de carga
            if self.ChargeSound and self.ChargeSound.Parent then
                self.ChargeSound.PlaybackSpeed = math.clamp(0.75 + linearProgress * 0.85, 0.75, 1.6)
                self.ChargeSound.Volume = math.clamp(0.9 + linearProgress * 2.6, 0.9, 3.5)
            end

            -- 3. Crecimiento gigante del aura en espadas y manos
            for _, att in ipairs(self.ActiveAttachments) do
                if att and att.Parent then
                    for _, pe in ipairs(att:GetChildren()) do
                        if pe:IsA("ParticleEmitter") then
                            if pe.Name:find("Lightning") or pe.Name:find("Red") or pe.Name:find("Black") or pe.Name:find("Shocks") then
                                pe.Rate = math.clamp(pe.Name:find("Lightning") and (50 + linearProgress * 180) or (140 + linearProgress * 280), 45, 450)
                            end
                            if pe.Name == "OverloadRedLightning" or pe.Name == "OverloadBlackLightning" then
                                local sz = 6.0 * (1 + linearProgress * 3.5) -- De 6 a 27 studs!
                                pe.Size = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1.4 * (1 + linearProgress * 2)),
                                    NumberSequenceKeypoint.new(0.3, sz),
                                    NumberSequenceKeypoint.new(1, 0)
                                })
                            end
                        end
                    end
                end
            end

            -- 4. Micro-vibración sísmica progresiva (CERO ROLL)
            ShakeScreenStabilized(0.25 + linearProgress * 1.3, 0.05)

            local origin = hrp.Position + Vector3.new(0, 2.5, 0)
            local widthMult = 1.0 + (powerRatio * 3.0)

            -- ====================================================================
            -- SUB-SISTEMA A: RAYOS CERCANOS CHOCANDO CON PAREDES Y SUPERFICIES (3D)
            -- ====================================================================
            local closeRayCount = math.random(3, math.clamp(math.floor(4 + linearProgress * 16), 4, 18))
            for _ = 1, closeRayCount do
                local randomDir = (CFrame.Angles(
                    (math.random() - 0.5) * math.pi * 1.6,
                    (math.random() - 0.5) * math.pi * 2.0,
                    0
                ).LookVector) * math.random(15, math.floor(35 + linearProgress * 65))

                local rayResult = Workspace:Raycast(origin, randomDir, rayParams)
                if rayResult then
                    -- ¡CHOCA CONTRA LA PARED! Detona chispas, shocks y arcos reptantes
                    SpawnWallImpactElectricity(origin, rayResult.Position, rayResult.Normal, widthMult)
                else
                    SpawnThickBeam(origin, origin + randomDir, widthMult * 0.7)
                end
            end

            -- ====================================================================
            -- SUB-SISTEMA B: RAYOS LEJANOS EN TODA LA ISLA (CADA SEGUNDO MÁS LEJOS Y MÁS CANTIDAD)
            -- ====================================================================
            -- Radio de cobertura lejano: de 120 studs hasta 2500+ studs (toda la isla!)
            local distantCoverageRadius = 120.0 + (linearProgress * 2380.0)

            -- Cantidad de rayos lejanos simultáneos por tick: se multiplica segundo a segundo
            local distantBoltCount = math.random(2, math.clamp(math.floor(3 + linearProgress * 28), 3, 30))

            for _ = 1, distantBoltCount do
                local angle = math.random() * math.pi * 2
                -- Distribuir en toda la extensión de la isla (desde 60 studs hasta el límite actual)
                local dist = math.random(60, math.floor(distantCoverageRadius))
                local skyPos = hrp.Position + Vector3.new(math.cos(angle) * dist, 280, math.sin(angle) * dist)

                -- Raycast hacia abajo buscando suelo, montaña, techo o mar
                local groundHit = Workspace:Raycast(skyPos, Vector3.new(0, -480, 0), rayParams)
                local targetGround = groundHit and groundHit.Position or (hrp.Position + Vector3.new(math.cos(angle) * dist, -2.5, math.sin(angle) * dist))

                -- Disparar columna de relámpago colosal en la distancia
                SpawnIslandDistantLightning(targetGround, math.random(240, 320), widthMult, dist)
            end

            -- ====================================================================
            -- SUB-SISTEMA C: RELÁMPAGOS RASGANDO LA PANTALLA
            -- ====================================================================
            SpawnScreenLightning(widthMult)

            -- Frecuencia muy rápida (cada 0.04 a 0.08s) para que la tormenta sea constante
            task.wait(math.max(0.04, 0.08 - linearProgress * 0.04))
        end
    end)
end

function Engine:ReleaseCharge()
    if not self.IsCharging then return end
    local currentMode = self.ChargeMode or "H"
    self.IsCharging = false

    local elapsed = os.clock() - self.ChargeStartTime
    local mult, powerRatio, blastRadius
    if currentMode == "G" then
        -- Detona proporcional a lo cargado en G (desde 77% al toque hasta 100% Colosal si se mantuvo ~7s)
        mult, powerRatio, blastRadius = GetGChargeStats(elapsed)
    else
        mult, powerRatio, blastRadius = GetChargeStats(elapsed)
    end

    -- Detener audio de carga
    if self.ChargeSound then
        pcall(function() self.ChargeSound:Destroy() end)
        self.ChargeSound = nil
    end

    -- Restaurar tasas base del aura
    self:RefreshAura()

    -- Detonar el Cataclismo a escala exacta
    self:TriggerBurst(mult, powerRatio, blastRadius)
end

-- ================================================================================
-- 8. ESTALLIDO PROPORCIONAL Y ABSURDAMENTE COLOSAL (57% A 1 MINUTO)
-- ================================================================================
function Engine:TriggerBurst(multiplier, powerRatio, customRadius)
    local mult = multiplier or 1.0
    local p = powerRatio or 0.0
    local radius = customRadius or (60.0 + (p * 2440.0))
    self.LastBurstTime = os.clock()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local rootCF = hrp.CFrame

    -- 1. Sonidos demoledores
    PlayConquerorBurstAudio(hrp, mult)

    -- 2. Sacudida de impacto pesada ultra-estabilizada (CERO ROLL)
    ShakeScreenStabilized(1.9 + p * 3.8, 0.70 + p * 0.85)

    -- 3. Destello de energía carmesí viva y clara con retorno suave
    task.spawn(function()
        local cc = self.ActiveColorCorr
        self.ActiveColorCorr = nil

        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "PolarConquerorFlash"
            cc.Parent = Lighting
        end

        cc.Brightness = 0.20 + (p * 0.30)
        cc.Contrast = 0.25 + (p * 0.30)
        cc.TintColor = Color3.fromRGB(255, 220, 220)

        local tweenTime = 0.85 + (p * 1.4)
        local tw = TweenService:Create(cc, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Brightness = 0,
            Contrast = 0,
            Saturation = 0,
            TintColor = Color3.fromRGB(255, 255, 255)
        })
        tw:Play()
        tw.Completed:Connect(function() pcall(function() cc:Destroy() end) end)
    end)

    -- 4. PILAR CENTRAL GIGANTESCO (TORNADO EXPLOSION ABSURDAMENTE COLOSAL)
    if TornadoExplosionTemplate then
        local burstClone = TornadoExplosionTemplate:Clone()
        burstClone.CFrame = rootCF * CFrame.new(0, -2.5, 0)
        burstClone.Anchored = true
        burstClone.CanCollide = false
        burstClone.Transparency = 1
        burstClone.Parent = Workspace
        Debris:AddItem(burstClone, 7.0)

        for _, desc in ipairs(burstClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "Lightning_Squash" then
                    -- Escala exacta con powerRatio: de 55 studs hasta 480 studs!
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 6.0 * (1 + p * 3.5)),
                        NumberSequenceKeypoint.new(1, 55.0 + (p * 425.0))
                    })
                    desc:Emit(math.floor(80 + p * 420))
                elseif desc.Name == "Burst" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 7.0 * (1 + p * 3.0)),
                        NumberSequenceKeypoint.new(1, 45.0 + (p * 235.0))
                    })
                    desc:Emit(math.floor(60 + p * 220))
                elseif desc.Name == "Shocks" then
                    desc:Emit(math.floor(150 + p * 650))
                elseif desc.Name == "InRays" then
                    desc:Emit(math.floor(50 + p * 200))
                elseif desc.Name == "AirWaves" then
                    -- Anillos de onda de choque colosales barriendo la isla (hasta 750 studs)
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 8.0 * (1 + p * 3.0)),
                        NumberSequenceKeypoint.new(1, 70.0 + (p * 680.0))
                    })
                    desc:Emit(math.floor(30 + p * 120))
                elseif desc.Name == "Sparks" then
                    desc:Emit(math.floor(100 + p * 400))
                else
                    desc:Emit(math.floor(30 + p * 100))
                end

                task.delay(0.60, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 5. CDK SLAYER HIT IMPACT (ESTRELLAS DE DESTELLO EN CRUZ)
    if SlayerHitTemplate then
        local slayerClone = SlayerHitTemplate:Clone()
        slayerClone.CFrame = rootCF
        slayerClone.Anchored = true
        slayerClone.CanCollide = false
        slayerClone.Transparency = 1
        slayerClone.Parent = Workspace
        Debris:AddItem(slayerClone, 5.5)

        for _, desc in ipairs(slayerClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "RedShine" then
                    desc:Emit(math.floor(30 + p * 120))
                elseif desc.Name == "BlackShine" then
                    desc:Emit(math.floor(30 + p * 120))
                elseif desc.Name == "FlashStar" then
                    desc:Emit(math.floor(10 + p * 40))
                elseif desc.Name == "FlashStarRays" then
                    desc:Emit(math.floor(40 + p * 160))
                elseif desc.Name == "NeonEmbers" then
                    desc:Emit(math.floor(100 + p * 400))
                end
                task.delay(0.55, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 6. STARTIMPACT DE SUELO ESCALADO
    if StartImpactTemplate then
        local startImpactClone = StartImpactTemplate:Clone()
        startImpactClone.CFrame = rootCF * CFrame.new(0, -2.8, 0)
        startImpactClone.Anchored = true
        startImpactClone.CanCollide = false
        startImpactClone.Transparency = 1
        startImpactClone.Parent = Workspace
        Debris:AddItem(startImpactClone, 4.5)

        for _, desc in ipairs(startImpactClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 0, 5))
                })
                desc:Emit(math.floor(25 + p * 105))
                task.delay(0.5, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 7. ONDAS SÍSMICAS DE RAYOS EN CASCADA (1 a 8 ANILLOS CONCÉNTRICOS)
    task.spawn(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        local maxRings = math.clamp(1 + math.floor(p * 7), 1, 8)
        local ringRadii = {30, 85, 200, 420, 850, 1400, 1950, 2500}
        local strikesPerRing = {8, 12, 16, 22, 28, 34, 40, 48}

        for ringIdx = 1, maxRings do
            local currentRadius = math.min(ringRadii[ringIdx], radius)
            local count = strikesPerRing[ringIdx]
            local ringWidthMult = 1.0 + (p * 2.5)

            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local rayOrigin = rootCF.Position + Vector3.new(math.cos(angle) * currentRadius, 180, math.sin(angle) * currentRadius)
                local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0), rayParams)
                local groundPos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 180, 0))

                SpawnThickBeam(groundPos + Vector3.new(0, 50, 0), groundPos, ringWidthMult)
            end

            task.wait(0.20)
        end
    end)

    -- 8. DETONACIÓN SIMULTÁNEA EN OBJETOS POR TODA LA ISLA
    task.spawn(function()
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {char}
        local parts = Workspace:GetPartBoundsInRadius(hrp.Position, math.min(radius, 800), op)
        local maxDet = math.min(#parts, math.clamp(math.floor(6 + p * 45), 6, 50))
        local detWidth = 1.2 + (p * 2.5)

        for i = 1, maxDet do
            local part = parts[i]
            if part and part:IsA("BasePart") and part.Transparency < 0.95 then
                SpawnThickBeam(part.Position + Vector3.new(0, 40, 0), part.Position, detWidth)
            end
        end
    end)
end

-- ================================================================================
-- 9. DESCARGAS AMBIENTALES PERIÓDICAS (PRESENCIA PASIVA)
-- ================================================================================
function Engine:StartAmbientPresence()
    task.spawn(function()
        local rayParams = RaycastParams.new()

        while self.Active do
            task.wait(math.random(7, 13) / 10)
            if not self.Active then break end

            if not self.IsCharging then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {char}

                    local angle = math.random() * math.pi * 2
                    local dist = math.random(6, 18)
                    local rayOrigin = hrp.Position + Vector3.new(math.cos(angle) * dist, 60, math.sin(angle) * dist)
                    local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -120, 0), rayParams)
                    local pos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 60, 0))

                    SpawnThickBeam(hrp.Position + Vector3.new(0, 4, 0), pos, 1.0)
                end
            end
        end
    end)
end

-- ================================================================================
-- 10. BINDINGS Y ESCUCHADORES EN VIVO
-- ================================================================================
function Engine:Init()
    -- InputBegan: Iniciar carga con [H] (progresiva 0-120s) o con [G] (etapa máxima fija al 100%)
    local pressConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            self:StartCharging("H")
        elseif input.KeyCode == Enum.KeyCode.G then
            -- Al mantener G: se activa directamente la ETAPA MÁXIMA de carga (tormenta colosal permanente)
            self:StartCharging("G")
        end
    end)
    table.insert(self.Connections, pressConn)

    -- InputEnded: Soltar carga al liberar [H] o [G] (detona el estallido correspondiente)
    local releaseConn = UserInputService.InputEnded:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.H and self.ChargeMode == "H" then
            self:ReleaseCharge()
        elseif input.KeyCode == Enum.KeyCode.G and self.ChargeMode == "G" then
            -- Al soltar G: detona el Estallido Máximo Absoluto (100%)
            self:ReleaseCharge()
        end
    end)
    table.insert(self.Connections, releaseConn)

    -- Auto-transferencia de aura al equipar / desequipar espadas
    local function bindCharacter(character)
        if not character then return end
        local toolConn = character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                self:RefreshAura()
            end
        end)
        table.insert(self.Connections, toolConn)

        local toolRemoveConn = character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                self:RefreshAura()
            end
        end)
        table.insert(self.Connections, toolRemoveConn)
    end

    bindCharacter(LocalPlayer.Character)
    local charConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        bindCharacter(newChar)
        self:RefreshAura()
    end)
    table.insert(self.Connections, charConn)

    self:RefreshAura()
    self:StartAmbientPresence()
end

-- ================================================================================
-- 11. LIMPIEZA SEGURA
-- ================================================================================
function Engine:Cleanup()
    self.Active = false
    self.IsCharging = false

    if self.ChargeSound then
        pcall(function() self.ChargeSound:Destroy() end)
        self.ChargeSound = nil
    end
    if self.ActiveColorCorr then
        pcall(function() self.ActiveColorCorr:Destroy() end)
        self.ActiveColorCorr = nil
    end

    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, att in ipairs(self.ActiveAttachments) do
        if att and att.Parent then pcall(function() att:Destroy() end) end
    end
    self.ActiveAttachments = {}

    print("[Polar Hub] ⚡ Haki del Conquistador V7 (Island-Wide Storm) desmontado limpiamente.")
end

-- Exportar a ambos entornos globales
G.ConquerorHakiCleanup = function() Engine:Cleanup() end
G.ConquerorBurst = function(mult, ratio) Engine:TriggerBurst(mult, ratio) end
G.ConquerorMaxBurst = function()
    local mult, powerRatio, blastRadius = GetChargeStats(120)
    Engine:TriggerBurst(mult, 1.0, blastRadius)
end
_G.ConquerorHakiCleanup = G.ConquerorHakiCleanup
_G.ConquerorBurst = G.ConquerorBurst
_G.ConquerorMaxBurst = G.ConquerorMaxBurst

Engine:Init()

print("================================================================================")
print("  👑 [POLAR HUB] HAKI DEL CONQUISTADOR V7 (ISLAND-WIDE STORM) ACTIVADO")
print("  ⚡ MANTÉN [G]: Comienza al 77% del máximo de la H y llega al 100% rápidamente en ~7s")
print("  💥 SUELTA [G]: ¡Detona el Estallido (desde 77% al toque hasta 100% Colosal)!")
print("  ⚡ MANTÉN [H]: Carga continua de 0 a 120s con rayos en paredes e isla completa")
print("  📐 ESCALADO EXACTO: A 1 minuto = 57% de potencia | A 120s = 100% Absurdamente Colosal")
print("  🌓 ILUMINACIÓN SOMBRÍA Y VIVA: 100% de visibilidad con contraste nítido")
print("  🎥 Cámara ultra-estabilizada sin volteo ni balanceo lateral")
print("================================================================================")

return Engine
