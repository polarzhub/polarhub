--[[
    ================================================================================
    POLAR HUB | NATIVE CONQUEROR'S HAKI (HAOSHOKU INFUSION) V5 - TITANIC OVERLOAD
    ================================================================================
    Novedades V5:
      1. RAYOS CONSTANTES, GIGANTESCOS Y MULTIPLICÁNDOSE EN PARTES:
         - Los rayos NO son pocos ni pequeños: son masivos (grosor de 5 a 25 studs).
         - Red eléctrica constante que conecta el personaje con partes cercanas,
           y salta entre objeto y objeto por todo el entorno.
         - Entre más tiempo se mantiene [H], más rayos se multiplican simultáneamente
           (de 4 rayos iniciales hasta más de 70 rayos gigantescos activos a la vez).
         - Rayos de doble capa canónica: Núcleo Rojo Carmesí + Silueta de Vacío Negro.
      2. OSCURECIMIENTO EQUILIBRADO Y PERFECTO:
         - Se ajustó el tono oscuro: ahora es un eclipse sombrío cinematográfico
           (Brightness -0.35 máx, Contraste +0.22, Tinte rojizo suave).
         - Permite ver el entorno y hace que los rayos rojos y negros resalten
           con un contraste y nitidez absoluta (CERO pantalla ciega).
      3. AURA GIGANTE QUE CRECE HASTA CONVERTIRSE EN UN SOL DE RAYOS:
         - El aura de la espada/manos escala de 2.5 studs hasta más de 25 studs.
         - Tasa de emisión multiplicada de 130 hasta más de 400 partículas/s.
      4. CARGA DE HASTA 120 SEGUNDOS Y ESTALLIDO ABSURDAMENTE COLOSAL:
         - Si se carga al máximo (o cerca de él), la detonación es cataclísmica:
           * Rayos Lightning_Squash de hasta 450 studs de grosor y altura.
           * Anillos de ondas expansivas AirWaves de hasta 1200 studs.
           * 8 anillos concéntricos en cascada con más de 220 columnas de rayos
             propagándose por toda la isla hasta más de 2000 studs.
           * Detonación simultánea en decenas de objetos del mapa.
           * Sacudida de impacto sísmica estabilizada (CERO ROLL / Sin mareos).
    ================================================================================
    Controles:
      - Mantén presionada [H]: Concentra el Haki hasta por 120 segundos.
      - Suelta [H]: Desata el Estallido Proporcional al tiempo cargado.
      - Equipar/Desequipar espadas: El aura se transfiere automáticamente.
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

-- Yama
local Yama_FX = FX and FX:FindFirstChild("Yama")
local YamaSkill1 = Yama_FX and Yama_FX:FindFirstChild("YamaSkill1")
local YamaGroundSparks = YamaSkill1 and YamaSkill1:FindFirstChild("GroundSparks")

-- ActivateAura
local ActivateAuraFolder = EffectContainer and EffectContainer:FindFirstChild("ActivateAura")
local Phase1 = ActivateAuraFolder and ActivateAuraFolder:FindFirstChild("Assets") and ActivateAuraFolder.Assets:FindFirstChild("Phase1")
local StartImpactTemplate = Phase1 and Phase1:FindFirstChild("StartImpact")

-- ================================================================================
-- 1. FÓRMULA DE ESCALADO DINÁMICO (0 a 120 Segundos)
-- ================================================================================
local function GetChargeStats(elapsed)
    local t = math.clamp(elapsed, 0, 120)
    local progress = t / 120.0

    -- Multiplicador de potencia: de 1.0x hasta 35.0x
    local mult = 1.0 + 34.0 * (progress ^ 0.58)

    -- Radio del estallido: desde 50 studs hasta 2200+ studs (isla completa)
    local blastRadius = 50.0 + 2150.0 * (progress ^ 0.65)

    return mult, progress, blastRadius
end

-- ================================================================================
-- 2. AUDIO SÍSMICO Y RETUMBE DE ISLA
-- ================================================================================
local function PlayConquerorBurstAudio(parent, multiplier)
    local mult = multiplier or 1.0

    -- Sonido 1: Bajo de Haki del Conquistador (Blox Fruits)
    local s1 = Instance.new("Sound")
    s1.SoundId = "rbxassetid://9069609200"
    s1.Volume = math.clamp(3.8 + (mult * 0.18), 3.8, 8.5)
    s1.PlaybackSpeed = math.clamp(0.90 - (mult * 0.006), 0.68, 0.95)
    s1.Parent = parent or Workspace
    s1:Play()
    Debris:AddItem(s1, 6)

    -- Sonido 2: Impacto CDK
    local s2 = Instance.new("Sound")
    s2.SoundId = "rbxassetid://6026998623"
    s2.Volume = math.clamp(2.8 + (mult * 0.15), 2.8, 7.5)
    s2.PlaybackSpeed = 0.94
    s2.Parent = parent or Workspace
    s2:Play()
    Debris:AddItem(s2, 6)

    -- Sonido 3: Trueno expansivo de alta tensión
    local s3 = Instance.new("Sound")
    s3.SoundId = "rbxassetid://5801257793"
    s3.Volume = math.clamp(2.2 + (mult * 0.12), 2.2, 6.5)
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
-- 4. RAYOS MASIVOS Y GRUESOS (THICK CONQUEROR BOLTS)
-- ================================================================================
-- Crea un rayo potente, grueso y caótico entre dos puntos
local function SpawnThickLightning(posA, posB, widthMult)
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

    -- Curvatura caótica de relámpago
    local curveA = math.random(-6, 6) * math.clamp(wMult * 0.8, 1, 3.5)
    local curveB = math.random(-6, 6) * math.clamp(wMult * 0.8, 1, 3.5)

    -- Capa 1: Núcleo Rojo Carmesí Brillante
    local beamRed = Instance.new("Beam")
    beamRed.Texture = "rbxassetid://13002793471"
    beamRed.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 10))
    })
    beamRed.Width0 = math.clamp(4.5 * wMult, 4.5, 24.0)
    beamRed.Width1 = math.clamp(2.8 * wMult, 2.8, 16.0)
    beamRed.FaceCamera = true
    beamRed.Segments = 10
    beamRed.CurveSize0 = curveA
    beamRed.CurveSize1 = curveB
    beamRed.LightEmission = 1
    beamRed.Attachment0 = attA
    beamRed.Attachment1 = attB
    beamRed.Parent = pA

    -- Capa 2: Silueta de Vacío Negro de Conquistador
    local beamBlack = Instance.new("Beam")
    beamBlack.Texture = "rbxassetid://13002793471"
    beamBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beamBlack.Width0 = math.clamp(6.8 * wMult, 6.8, 34.0)
    beamBlack.Width1 = math.clamp(4.2 * wMult, 4.2, 22.0)
    beamBlack.FaceCamera = true
    beamBlack.Segments = 10
    beamBlack.CurveSize0 = curveA
    beamBlack.CurveSize1 = curveB
    beamBlack.LightEmission = 0
    beamBlack.ZOffset = -0.3
    beamBlack.Attachment0 = attA
    beamBlack.Attachment1 = attB
    beamBlack.Parent = pA

    -- Chispas en el punto de impacto B
    if YamaGroundSparks then
        local sparks = YamaGroundSparks:Clone()
        sparks.CFrame = CFrame.new(posB)
        sparks.Anchored = true
        sparks.CanCollide = false
        sparks.Transparency = 1
        sparks.Parent = Workspace
        Debris:AddItem(sparks, 0.8)

        for _, pe in ipairs(sparks:GetDescendants()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(15)
                task.delay(0.2, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    Debris:AddItem(pA, 0.22)
    Debris:AddItem(pB, 0.22)
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
    bRed.Width0 = math.clamp(1.8 * w, 1.8, 6.0)
    bRed.Width1 = math.clamp(1.0 * w, 1.0, 3.5)
    bRed.FaceCamera = true
    bRed.Attachment0 = a1
    bRed.Attachment1 = a2
    bRed.LightEmission = 1
    bRed.Parent = p1

    local bBlack = Instance.new("Beam")
    bBlack.Texture = "rbxassetid://13002793471"
    bBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    bBlack.Width0 = math.clamp(2.6 * w, 2.6, 8.5)
    bBlack.Width1 = math.clamp(1.5 * w, 1.5, 5.0)
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
-- 5. AURA NATIVA ULTRA-POTENCIADA (ESPADA Y MANOS)
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

    -- Relámpago Rojo Dentado de Yama (Mucho más grande)
    local redLightning = Instance.new("ParticleEmitter")
    redLightning.Name = "OverloadRedLightning"
    redLightning.Texture = "rbxassetid://13002793471"
    redLightning.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 15, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 0, 15))
    })
    redLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.3, 5.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    redLightning.Lifetime = NumberRange.new(0.2, 0.42)
    redLightning.Rate = 45
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
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(0.3, 6.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackLightning.Lifetime = NumberRange.new(0.2, 0.42)
    blackLightning.Rate = 45
    blackLightning.Speed = NumberRange.new(10, 26)
    blackLightning.SpreadAngle = Vector2.new(75, 75)
    blackLightning.LightEmission = 0
    blackLightning.Brightness = 0
    blackLightning.ZOffset = -0.5
    blackLightning.Parent = clonedAtt

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
        NumberSequenceKeypoint.new(0, 1.0),
        NumberSequenceKeypoint.new(0.5, 5.0),
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
-- 6. SISTEMA DE CARGA DINÁMICA CON RAYOS MULTIPLICÁNDOSE EN PARTES
-- ================================================================================
function Engine:StartCharging()
    if self.IsCharging then return end
    if os.clock() - self.LastBurstTime < self.Cooldown then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    self.IsCharging = true
    self.ChargeStartTime = os.clock()

    -- Audio de carga
    pcall(function()
        local s = Instance.new("Sound")
        s.Name = "PolarChargeSound"
        s.SoundId = "rbxassetid://6026998623"
        s.Looped = true
        s.Volume = 0.9
        s.PlaybackSpeed = 0.75
        s.Parent = hrp
        s:Play()
        self.ChargeSound = s
    end)

    -- ILUMINACIÓN EQUILIBRADA (SOMBRÍA PERO NÍTIDA, SIN PANTALLA CIEGA)
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

    -- BUCLE DE TORMENTA ELÉCTRICA EN TIEMPO REAL
    task.spawn(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {char}

        while self.IsCharging and self.Active do
            local elapsed = os.clock() - self.ChargeStartTime
            local mult, progress, blastRadius = GetChargeStats(elapsed)

            -- 1. Oscurecimiento sombrío y nítido (de 0 a -0.35 máx)
            if self.ActiveColorCorr then
                self.ActiveColorCorr.Brightness = -progress * 0.35
                self.ActiveColorCorr.Contrast = 0.05 + (progress * 0.18)
                self.ActiveColorCorr.Saturation = 0.08 + (progress * 0.12)
                self.ActiveColorCorr.TintColor = Color3.fromRGB(255, math.floor(245 - progress * 25), math.floor(245 - progress * 25))
            end

            -- 2. Modulación de sonido
            if self.ChargeSound and self.ChargeSound.Parent then
                self.ChargeSound.PlaybackSpeed = math.clamp(0.75 + progress * 0.85, 0.75, 1.6)
                self.ChargeSound.Volume = math.clamp(0.9 + progress * 2.6, 0.9, 3.5)
            end

            -- 3. Crecimiento gigante del aura en armas y manos
            for _, att in ipairs(self.ActiveAttachments) do
                if att and att.Parent then
                    for _, pe in ipairs(att:GetChildren()) do
                        if pe:IsA("ParticleEmitter") then
                            if pe.Name:find("Lightning") or pe.Name:find("Red") or pe.Name:find("Black") then
                                pe.Rate = math.clamp(pe.Name:find("Lightning") and (45 + progress * 160) or (140 + progress * 260), 45, 420)
                            end
                            -- Agrandar tamaño de los rayos del aura
                            if pe.Name == "OverloadRedLightning" or pe.Name == "OverloadBlackLightning" then
                                local sz = 5.5 * (1 + progress * 3.5) -- De 5.5 hasta 25 studs!
                                pe.Size = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1.2 * (1 + progress * 2)),
                                    NumberSequenceKeypoint.new(0.3, sz),
                                    NumberSequenceKeypoint.new(1, 0)
                                })
                            end
                        end
                    end
                end
            end

            -- 4. Micro-vibración sísmica progresiva (CERO balanceo de cámara)
            ShakeScreenStabilized(0.25 + progress * 1.3, 0.05)

            -- 5. MULTIPLICACIÓN CONSTANTE DE RAYOS EN PARTES DEL ENTORNO
            -- Escanear partes cercanas dentro del radio expansivo
            local searchRadius = 25.0 + (progress * 300.0)
            local nearbyParts = Workspace:GetPartBoundsInRadius(hrp.Position, searchRadius, op)

            -- Filtrar partes visibles
            local validParts = {}
            for _, p in ipairs(nearbyParts) do
                if p:IsA("BasePart") and p.Transparency < 0.95 and not p:IsDescendantOf(char) then
                    table.insert(validParts, p)
                end
            end

            -- Número de rayos simultáneos que se disparan en este frame
            -- Crece de 2-4 al inicio hasta 12-25 por frame en carga alta!
            local boltsThisTick = math.random(2, math.clamp(math.floor(4 + progress * 22), 4, 25))
            local widthMult = 1.0 + (progress * 3.0) -- Grosor escala de 1.0x a 4.0x

            for _ = 1, boltsThisTick do
                local mode = math.random(1, 3)

                if mode == 1 and #validParts > 0 then
                    -- Modo 1: Del jugador hacia una parte del entorno
                    local targetPart = validParts[math.random(1, #validParts)]
                    local pPos = targetPart.Position + Vector3.new(
                        (math.random() - 0.5) * math.min(targetPart.Size.X, 8),
                        targetPart.Size.Y * 0.5,
                        (math.random() - 0.5) * math.min(targetPart.Size.Z, 8)
                    )
                    SpawnThickLightning(hrp.Position + Vector3.new(0, 2.5, 0), pPos, widthMult)

                elseif mode == 2 and #validParts >= 2 then
                    -- Modo 2: Rayos saltando ENTRE PARTES del entorno (Red eléctrica viva)
                    local p1 = validParts[math.random(1, #validParts)]
                    local p2 = validParts[math.random(1, #validParts)]
                    if p1 ~= p2 and (p1.Position - p2.Position).Magnitude < 180 then
                        SpawnThickLightning(p1.Position, p2.Position, widthMult * 0.85)
                    else
                        SpawnThickLightning(hrp.Position + Vector3.new(0, 2.5, 0), p1.Position, widthMult)
                    end

                else
                    -- Modo 3: Rayo colosal desde el cielo al suelo o montaña distante
                    local angle = math.random() * math.pi * 2
                    local dist = math.random(15, math.floor(blastRadius))
                    local rayOrigin = hrp.Position + Vector3.new(math.cos(angle) * dist, 180, math.sin(angle) * dist)
                    local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0), rayParams)
                    local groundPos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 180, 0))

                    SpawnThickLightning(rayOrigin, groundPos, widthMult * 1.2)
                end
            end

            -- 6. Relámpagos rasgando la pantalla
            SpawnScreenLightning(widthMult)

            -- Frecuencia muy rápida (cada 0.05 a 0.08s) para que sea CONSTANTE
            task.wait(math.max(0.04, 0.09 - progress * 0.05))
        end
    end)
end

function Engine:ReleaseCharge()
    if not self.IsCharging then return end
    self.IsCharging = false

    local elapsed = os.clock() - self.ChargeStartTime
    local mult, progress, blastRadius = GetChargeStats(elapsed)

    -- Detener audio de carga
    if self.ChargeSound then
        pcall(function() self.ChargeSound:Destroy() end)
        self.ChargeSound = nil
    end

    -- Restaurar tasas base del aura
    self:RefreshAura()

    -- Detonar el Cataclismo a escala calculada
    self:TriggerBurst(mult, progress, blastRadius)
end

-- ================================================================================
-- 7. ESTALLIDO ABSURDAMENTE COLOSAL (ESCALA ISLA)
-- ================================================================================
function Engine:TriggerBurst(multiplier, progressRatio, customRadius)
    local mult = multiplier or 1.0
    local p = progressRatio or 0.0
    local radius = customRadius or (50 + 2150 * (p ^ 0.65))
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
                    -- Rayos colosales alcanzando hasta 450 studs de grosor y altura
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 6.0 * (1 + p * 3.5)),
                        NumberSequenceKeypoint.new(1, 65.0 * (1 + p * 6.0)) -- Hasta 450 studs!
                    })
                    desc:Emit(math.clamp(math.floor(90 * mult), 90, 500))
                elseif desc.Name == "Burst" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 7.0 * (1 + p * 3.0)),
                        NumberSequenceKeypoint.new(1, 55.0 * (1 + p * 4.5))
                    })
                    desc:Emit(math.clamp(math.floor(65 * mult), 65, 280))
                elseif desc.Name == "Shocks" then
                    desc:Emit(math.clamp(math.floor(160 * mult), 160, 650))
                elseif desc.Name == "InRays" then
                    desc:Emit(math.clamp(math.floor(60 * mult), 60, 220))
                elseif desc.Name == "AirWaves" then
                    -- Anillos de onda de choque colosales barriendo la isla (hasta 650 studs)
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 8.0 * (1 + p * 3.0)),
                        NumberSequenceKeypoint.new(1, 85.0 * (1 + p * 6.5))
                    })
                    desc:Emit(math.clamp(math.floor(35 * mult), 35, 150))
                elseif desc.Name == "Sparks" then
                    desc:Emit(math.clamp(math.floor(120 * mult), 120, 450))
                else
                    desc:Emit(math.clamp(math.floor(35 * mult), 35, 120))
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
                    desc:Emit(math.clamp(math.floor(35 * mult), 35, 150))
                elseif desc.Name == "BlackShine" then
                    desc:Emit(math.clamp(math.floor(35 * mult), 35, 150))
                elseif desc.Name == "FlashStar" then
                    desc:Emit(math.clamp(math.floor(12 * mult), 12, 50))
                elseif desc.Name == "FlashStarRays" then
                    desc:Emit(math.clamp(math.floor(45 * mult), 45, 200))
                elseif desc.Name == "NeonEmbers" then
                    desc:Emit(math.clamp(math.floor(120 * mult), 120, 500))
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
                desc:Emit(math.clamp(math.floor(30 * mult), 30, 130))
                task.delay(0.5, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 7. ONDAS SÍSMICAS DE RAYOS EN CASCADA (HASTA 8 ANILLOS CONCÉNTRICOS)
    task.spawn(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        local maxRings = math.clamp(1 + math.floor(p * 7), 1, 8)
        local ringRadii = {30, 85, 200, 420, 800, 1300, 1850, 2400}
        local strikesPerRing = {8, 12, 16, 20, 26, 32, 38, 44}

        for ringIdx = 1, maxRings do
            local currentRadius = math.min(ringRadii[ringIdx], radius)
            local count = strikesPerRing[ringIdx]
            local ringWidthMult = 1.0 + (p * 2.5)

            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local rayOrigin = rootCF.Position + Vector3.new(math.cos(angle) * currentRadius, 180, math.sin(angle) * currentRadius)
                local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0), rayParams)
                local groundPos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 180, 0))

                -- Rayo grueso vertical
                SpawnThickLightning(groundPos + Vector3.new(0, 50, 0), groundPos, ringWidthMult)
            end

            -- Retardo para crear la onda de choque en expansión
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
                SpawnThickLightning(part.Position + Vector3.new(0, 40, 0), part.Position, detWidth)
            end
        end
    end)
end

-- ================================================================================
-- 8. DESCARGAS AMBIENTALES PERIÓDICAS (PRESENCIA PASIVA)
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

                    SpawnThickLightning(hrp.Position + Vector3.new(0, 4, 0), pos, 1.0)
                end
            end
        end
    end)
end

-- ================================================================================
-- 9. BINDINGS Y ESCUCHADORES EN VIVO
-- ================================================================================
function Engine:Init()
    -- InputBegan: Iniciar carga al presionar [H]
    local pressConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            self:StartCharging()
        end
    end)
    table.insert(self.Connections, pressConn)

    -- InputEnded: Soltar carga al liberar [H]
    local releaseConn = UserInputService.InputEnded:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.H then
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
-- 10. LIMPIEZA SEGURA
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

    print("[Polar Hub] ⚡ Haki del Conquistador V5 (Titanic Overload) desmontado limpiamente.")
end

-- Exportar a ambos entornos globales
G.ConquerorHakiCleanup = function() Engine:Cleanup() end
G.ConquerorBurst = function(mult, ratio) Engine:TriggerBurst(mult, ratio) end
_G.ConquerorHakiCleanup = G.ConquerorHakiCleanup
_G.ConquerorBurst = G.ConquerorBurst

Engine:Init()

print("================================================================================")
print("  👑 [POLAR HUB] HAKI DEL CONQUISTADOR V5 (TITANIC OVERLOAD) ACTIVADO")
print("  ⚡ RAYOS CONSTANTES Y GIGANTESCOS: Se multiplican en todas las partes del entorno")
print("  🌓 OSCURECIMIENTO SOMBRÍO EQUILIBRADO: Atmósfera ominosa con 100% visibilidad")
print("  💥 MANTÉN [H] (hasta 120s) y SUELTA: Estallido Absurdamente Colosal")
print("  🎥 Cámara ultra-estabilizada sin volteo ni balanceo lateral")
print("================================================================================")

return Engine
