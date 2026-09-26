--[[
    ================================================================================
    POLAR HUB | NATIVE CONQUEROR'S HAKI (HAOSHOKU INFUSION) V4 - ISLAND APOCALYPSE
    ================================================================================
    Novedades V4 (Island-Scale & Crystal Clear Visibility):
      1. CARGA COLOSAL DE HASTA 120 SEGUNDOS:
         - Mantén pulsada [H] hasta 120 segundos (2 minutos completos de acumulación).
         - Curva progresiva balanceada:
           * 1s - 3s:   Potente y rápido (1.5x - 3.5x, radio de 60 a 160 studs).
           * 10s - 30s: Nivel cataclismo (6x - 13x, radio de 350 a 700 studs).
           * 60s - 90s: Nivel colosal continental (18x - 25x, radio de 1100 a 1500 studs).
           * 120s:      NIVEL ISLA ABSOLUTO (30x, radio de 1800+ studs, toda la isla).
      2. VISIBILIDAD 100% NÍTIDA (SIN OSCURECIMIENTO CIEGO):
         - Se eliminó por completo el tinte negro/oscuro que ocultaba los rayos.
         - La iluminación se mantiene completamente clara, viva y con contraste
           realzado (+0.08 contrast, +0.12 saturation) para que tanto los relámpagos
           rojos carmesí como los rayos negros de vacío resalten con máxima nitidez.
      3. TORMENTA DE RAYOS EN TODA LA ISLA DURANTE LA CARGA:
         - Rayos con raycasting vertical descienden desde el cielo impactando
           árboles, montañas, edificios, el mar y objetos en un radio que crece
           hasta abarcar toda la isla en 360 grados.
         - Relámpagos rasgan la pantalla sin obstruir la vista central.
      4. DETONACIÓN APOCALÍPTICA AL SOLTAR [H]:
         - Pilar central gigante de relámpagos (Squash Lightning de hasta 280 studs).
         - Ondas expansivas concéntricas que se propagan hacia afuera por la isla
           en 7 anillos sucesivos (más de 140 columnas de rayos brotando en cadena).
         - Decenas de impactos simultáneos en objetos lejanos de la isla.
         - Retumbe de bajo sísmico y temblor estabilizado (CERO VOLTEO / ROLL = 0).
    ================================================================================
    Controles:
      - Mantén presionada [H]: Concentra el Haki hasta por 120 segundos.
      - Suelta [H]: Desata el Estallido Supremo a escala proporcional.
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
    MaxChargeDuration = 120.0, -- Máximo de 120 segundos (2 minutos)
    ChargeSound = nil,
    ChargeThunderSound = nil,
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
-- Proporciona respuesta inmediata desde los primeros segundos pero escala
-- hasta un cataclismo del tamaño de una isla completa a los 120 segundos.
local function GetChargeStats(elapsed)
    local t = math.clamp(elapsed, 0, 120)
    local progress = t / 120.0 -- De 0.0 a 1.0

    -- Multiplicador de potencia: de 1.0x hasta 30.0x
    local mult = 1.0 + 29.0 * (progress ^ 0.62)

    -- Radio del estallido: desde 45 studs hasta 1800+ studs (isla entera)
    local blastRadius = 45.0 + 1755.0 * (progress ^ 0.68)

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
    s1.Volume = math.clamp(3.5 + (mult * 0.15), 3.5, 8.0)
    s1.PlaybackSpeed = math.clamp(0.90 - (mult * 0.005), 0.70, 0.95)
    s1.Parent = parent or Workspace
    s1:Play()
    Debris:AddItem(s1, 6)

    -- Sonido 2: Impacto CDK
    local s2 = Instance.new("Sound")
    s2.SoundId = "rbxassetid://6026998623"
    s2.Volume = math.clamp(2.5 + (mult * 0.12), 2.5, 7.0)
    s2.PlaybackSpeed = 0.95
    s2.Parent = parent or Workspace
    s2:Play()
    Debris:AddItem(s2, 6)

    -- Sonido 3: Trueno expansivo de alta tensión
    local s3 = Instance.new("Sound")
    s3.SoundId = "rbxassetid://5801257793"
    s3.Volume = math.clamp(2.0 + (mult * 0.1), 2.0, 6.0)
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
            local pitch = math.rad((math.random() - 0.5) * intensity * damp * 0.8)
            local yaw = math.rad((math.random() - 0.5) * intensity * damp * 0.6)

            prevOffset = CFrame.new(offsetX, offsetY, 0) * CFrame.Angles(pitch, yaw, 0)
            Camera.CFrame = Camera.CFrame * prevOffset

            RunService.RenderStepped:Wait()
        end

        Camera.CFrame = Camera.CFrame * prevOffset:Inverse()
    end)
end

-- ================================================================================
-- 4. RAYOS EN OBJETOS, TERRENO Y PANTALLA (100% VISIBILIDAD)
-- ================================================================================
-- Genera un rayo canónico de dos capas (rojo vivo + contorno de vacío negro)
local function SpawnIslandLightning(targetPos, originPos)
    local startPos = originPos or (targetPos + Vector3.new(math.random(-8, 8), math.random(35, 75), math.random(-8, 8)))

    local pTarget = Instance.new("Part")
    pTarget.Anchored = true
    pTarget.CanCollide = false
    pTarget.Transparency = 1
    pTarget.Size = Vector3.new(1, 1, 1)
    pTarget.Position = targetPos
    pTarget.Parent = Workspace

    local pOrigin = Instance.new("Part")
    pOrigin.Anchored = true
    pOrigin.CanCollide = false
    pOrigin.Transparency = 1
    pOrigin.Size = Vector3.new(1, 1, 1)
    pOrigin.Position = startPos
    pOrigin.Parent = Workspace

    local attTarget = Instance.new("Attachment", pTarget)
    local attOrigin = Instance.new("Attachment", pOrigin)

    -- Viga de Rayo Rojo Vivo (Brillante y claro)
    local beamRed = Instance.new("Beam")
    beamRed.Texture = "rbxassetid://13002793471"
    beamRed.Color = ColorSequence.new(Color3.fromRGB(255, 35, 45))
    beamRed.Width0 = 2.4
    beamRed.Width1 = 1.2
    beamRed.FaceCamera = true
    beamRed.Attachment0 = attOrigin
    beamRed.Attachment1 = attTarget
    beamRed.LightEmission = 1
    beamRed.Parent = pTarget

    -- Viga de Vacío Negro de Conquistador
    local beamBlack = Instance.new("Beam")
    beamBlack.Texture = "rbxassetid://13002793471"
    beamBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beamBlack.Width0 = 3.2
    beamBlack.Width1 = 1.8
    beamBlack.FaceCamera = true
    beamBlack.Attachment0 = attOrigin
    beamBlack.Attachment1 = attTarget
    beamBlack.LightEmission = 0
    beamBlack.ZOffset = -0.3
    beamBlack.Parent = pTarget

    -- Chispas de Yama en el punto de impacto
    if YamaGroundSparks then
        local sparks = YamaGroundSparks:Clone()
        sparks.CFrame = CFrame.new(targetPos)
        sparks.Anchored = true
        sparks.CanCollide = false
        sparks.Transparency = 1
        sparks.Parent = Workspace
        Debris:AddItem(sparks, 1.0)

        for _, pe in ipairs(sparks:GetDescendants()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(18)
                task.delay(0.25, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    Debris:AddItem(pTarget, 0.28)
    Debris:AddItem(pOrigin, 0.28)
end

-- Relámpagos que rasgan las esquinas de la pantalla
local function SpawnScreenLightning()
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
    bRed.Width0 = 1.2
    bRed.Width1 = 0.6
    bRed.FaceCamera = true
    bRed.Attachment0 = a1
    bRed.Attachment1 = a2
    bRed.LightEmission = 1
    bRed.Parent = p1

    local bBlack = Instance.new("Beam")
    bBlack.Texture = "rbxassetid://13002793471"
    bBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    bBlack.Width0 = 1.6
    bBlack.Width1 = 0.9
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
-- 5. AURA NATIVA POTENCIADA (ESPADA Y MANOS)
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
                em.Rate = 130
                em.LightEmission = 0.9
                em.Brightness = 3
            elseif em.Name == "Black" then
                em.Rate = 130
                em.ZOffset = -0.45
                em.LightEmission = 0
                em.Brightness = 0
            elseif em.Name == "Orbs" then
                em.Rate = 45
                em.Brightness = 6
                em.LightEmission = 1
            elseif em.Name == "Air" then
                em.Rate = 16
            end
        end
    end

    -- Relámpago Rojo Dentado de Yama
    local redLightning = Instance.new("ParticleEmitter")
    redLightning.Name = "OverloadRedLightning"
    redLightning.Texture = "rbxassetid://13002793471"
    redLightning.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 15, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 0, 15))
    })
    redLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.3, 2.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    redLightning.Lifetime = NumberRange.new(0.18, 0.38)
    redLightning.Rate = 40
    redLightning.Speed = NumberRange.new(8, 22)
    redLightning.SpreadAngle = Vector2.new(65, 65)
    redLightning.LightEmission = 1
    redLightning.Brightness = 8
    redLightning.Parent = clonedAtt

    -- Relámpago Negro de Vacío
    local blackLightning = Instance.new("ParticleEmitter")
    blackLightning.Name = "OverloadBlackLightning"
    blackLightning.Texture = "rbxassetid://13002793471"
    blackLightning.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    blackLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.3, 2.7),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackLightning.Lifetime = NumberRange.new(0.18, 0.38)
    blackLightning.Rate = 40
    blackLightning.Speed = NumberRange.new(8, 22)
    blackLightning.SpreadAngle = Vector2.new(65, 65)
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
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0)
    })
    branchSparks.Lifetime = NumberRange.new(0.15, 0.3)
    branchSparks.Rate = 35
    branchSparks.Speed = NumberRange.new(15, 30)
    branchSparks.SpreadAngle = Vector2.new(180, 180)
    branchSparks.LightEmission = 1
    branchSparks.Brightness = 6
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
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 3.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    cdkShocks.Lifetime = NumberRange.new(0.15, 0.28)
    cdkShocks.Rate = 25
    cdkShocks.Speed = NumberRange.new(6, 18)
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
-- 6. SISTEMA DE CARGA DE HASTA 120 SEGUNDOS (ESCALA ISLA Y 100% VISIBILIDAD)
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

    -- ILUMINACIÓN CLARA Y VIBRANTE (SIN OSCURECIMIENTO CIEGO)
    -- Se realza el contraste y la saturación para que los rayos rojos y negros POPPEN al máximo
    pcall(function()
        if not self.ActiveColorCorr then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "PolarConquerorLighting"
            cc.Brightness = 0.02 -- Ligeramente brillante para contraste perfecto
            cc.Contrast = 0.08   -- Nitidez máxima para siluetas de rayos
            cc.Saturation = 0.12 -- Colores intensos
            cc.TintColor = Color3.fromRGB(255, 248, 248) -- Tono cristalino
            cc.Parent = Lighting
            self.ActiveColorCorr = cc
        end
    end)

    -- Bucle de concentración y expansión por la isla (hasta 120s)
    task.spawn(function()
        local lastStrikeTime = 0
        local lastScreenStrikeTime = 0
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        while self.IsCharging and self.Active do
            local elapsed = os.clock() - self.ChargeStartTime
            local mult, progress, blastRadius = GetChargeStats(elapsed)

            -- 1. Modulación de sonido
            if self.ChargeSound and self.ChargeSound.Parent then
                self.ChargeSound.PlaybackSpeed = math.clamp(0.75 + progress * 0.85, 0.75, 1.6)
                self.ChargeSound.Volume = math.clamp(0.9 + progress * 2.5, 0.9, 3.5)
            end

            -- 2. Crecimiento dinámico del aura en manos/espadas
            for _, att in ipairs(self.ActiveAttachments) do
                if att and att.Parent then
                    for _, pe in ipairs(att:GetChildren()) do
                        if pe:IsA("ParticleEmitter") then
                            if pe.Name:find("Lightning") or pe.Name:find("Red") or pe.Name:find("Black") then
                                pe.Rate = math.clamp(pe.Name:find("Lightning") and (40 + progress * 120) or (130 + progress * 220), 40, 360)
                            end
                        end
                    end
                end
            end

            -- 3. Micro-vibración sísmica progresiva (sin balanceo de cámara)
            ShakeScreenStabilized(0.25 + progress * 1.2, 0.05)

            -- 4. Rayos azotando toda la isla progresivamente
            local strikeInterval = math.max(0.09, 0.35 - progress * 0.26)
            if os.clock() - lastStrikeTime > strikeInterval then
                lastStrikeTime = os.clock()

                -- Disparar de 1 a 6 rayos simultáneos en la isla según la carga
                local numStrikes = math.random(1, math.min(6, 1 + math.floor(progress * 7)))
                for _ = 1, numStrikes do
                    local angle = math.random() * math.pi * 2
                    local dist = math.random(15, math.floor(blastRadius))
                    local rayOrigin = hrp.Position + Vector3.new(math.cos(angle) * dist, 180, math.sin(angle) * dist)
                    local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0), rayParams)

                    local strikeTarget = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 180, 0))
                    SpawnIslandLightning(strikeTarget, rayOrigin)
                end
            end

            -- 5. Relámpagos rasgando la pantalla
            if os.clock() - lastScreenStrikeTime > math.max(0.12, 0.28 - progress * 0.16) then
                lastScreenStrikeTime = os.clock()
                SpawnScreenLightning()
            end

            RunService.Heartbeat:Wait()
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
-- 7. CATACLISMO DEL CONQUISTADOR (ESCALA ISLA Y 100% VISIBILIDAD)
-- ================================================================================
function Engine:TriggerBurst(multiplier, progressRatio, customRadius)
    local mult = multiplier or 1.0
    local p = progressRatio or 0.0
    local radius = customRadius or (45 + 1755 * (p ^ 0.68))
    self.LastBurstTime = os.clock()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local rootCF = hrp.CFrame

    -- 1. Sonidos demoledores
    PlayConquerorBurstAudio(hrp, mult)

    -- 2. Sacudida de impacto pesada ultra-estabilizada (CERO ROLL)
    ShakeScreenStabilized(1.8 + p * 3.5, 0.65 + p * 0.75)

    -- 3. Destello de destello claro y retorno suave (SIN PANTALLA NEGRA)
    task.spawn(function()
        local cc = self.ActiveColorCorr
        self.ActiveColorCorr = nil

        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "PolarConquerorFlash"
            cc.Parent = Lighting
        end

        -- Destello de energía carmesí viva y clara
        cc.Brightness = 0.15 + (p * 0.25)
        cc.Contrast = 0.20 + (p * 0.25)
        cc.TintColor = Color3.fromRGB(255, 215, 215)

        local tweenTime = 0.8 + (p * 1.2)
        local tw = TweenService:Create(cc, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Brightness = 0,
            Contrast = 0,
            Saturation = 0,
            TintColor = Color3.fromRGB(255, 255, 255)
        })
        tw:Play()
        tw.Completed:Connect(function() pcall(function() cc:Destroy() end) end)
    end)

    -- 4. PILAR CENTRAL GIGANTESCO (TORNADO EXPLOSION ESCALADO A NIVEL ISLA)
    if TornadoExplosionTemplate then
        local burstClone = TornadoExplosionTemplate:Clone()
        burstClone.CFrame = rootCF * CFrame.new(0, -2.5, 0)
        burstClone.Anchored = true
        burstClone.CanCollide = false
        burstClone.Transparency = 1
        burstClone.Parent = Workspace
        Debris:AddItem(burstClone, 6.0)

        for _, desc in ipairs(burstClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "Lightning_Squash" then
                    -- Rayos colosales elevándose a la estratosfera
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 5.0 * (1 + p * 3.0)),
                        NumberSequenceKeypoint.new(1, 55.0 * (1 + p * 4.5)) -- Hasta 280 studs!
                    })
                    desc:Emit(math.clamp(math.floor(80 * mult), 80, 400))
                elseif desc.Name == "Burst" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 6.0 * (1 + p * 2.5)),
                        NumberSequenceKeypoint.new(1, 45.0 * (1 + p * 3.5))
                    })
                    desc:Emit(math.clamp(math.floor(55 * mult), 55, 220))
                elseif desc.Name == "Shocks" then
                    desc:Emit(math.clamp(math.floor(140 * mult), 140, 500))
                elseif desc.Name == "InRays" then
                    desc:Emit(math.clamp(math.floor(50 * mult), 50, 180))
                elseif desc.Name == "AirWaves" then
                    -- Anillos de onda de choque barriendo la isla
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 6.0 * (1 + p * 2.5)),
                        NumberSequenceKeypoint.new(1, 70.0 * (1 + p * 5.0)) -- Hasta 420 studs!
                    })
                    desc:Emit(math.clamp(math.floor(30 * mult), 30, 120))
                elseif desc.Name == "Sparks" then
                    desc:Emit(math.clamp(math.floor(100 * mult), 100, 350))
                else
                    desc:Emit(math.clamp(math.floor(30 * mult), 30, 100))
                end

                task.delay(0.55, function() pcall(function() desc.Enabled = false end) end)
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
        Debris:AddItem(slayerClone, 5.0)

        for _, desc in ipairs(slayerClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "RedShine" then
                    desc:Emit(math.clamp(math.floor(30 * mult), 30, 120))
                elseif desc.Name == "BlackShine" then
                    desc:Emit(math.clamp(math.floor(30 * mult), 30, 120))
                elseif desc.Name == "FlashStar" then
                    desc:Emit(math.clamp(math.floor(10 * mult), 10, 40))
                elseif desc.Name == "FlashStarRays" then
                    desc:Emit(math.clamp(math.floor(40 * mult), 40, 160))
                elseif desc.Name == "NeonEmbers" then
                    desc:Emit(math.clamp(math.floor(100 * mult), 100, 400))
                end
                task.delay(0.5, function() pcall(function() desc.Enabled = false end) end)
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
        Debris:AddItem(startImpactClone, 4.0)

        for _, desc in ipairs(startImpactClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 0, 5))
                })
                desc:Emit(math.clamp(math.floor(25 * mult), 25, 100))
                task.delay(0.45, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 7. ANILLOS CONCÉNTRICOS PROPAGÁNDOSE POR TODA LA ISLA
    -- Los anillos de rayos viajan en ondas hacia afuera sobre el terreno
    task.spawn(function()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}

        local maxRings = math.clamp(1 + math.floor(p * 6), 1, 7) -- Hasta 7 anillos concéntricos
        local ringRadii = {25, 75, 180, 380, 750, 1250, 1800}
        local strikesPerRing = {8, 12, 16, 20, 24, 28, 32}

        for ringIdx = 1, maxRings do
            local currentRadius = math.min(ringRadii[ringIdx], radius)
            local count = strikesPerRing[ringIdx]

            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local rayOrigin = rootCF.Position + Vector3.new(math.cos(angle) * currentRadius, 180, math.sin(angle) * currentRadius)
                local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0), rayParams)
                local groundPos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 180, 0))

                -- Clonar chispas de Yama en el suelo
                if YamaGroundSparks then
                    local gClone = YamaGroundSparks:Clone()
                    gClone.CFrame = CFrame.new(groundPos)
                    gClone.Anchored = true
                    gClone.CanCollide = false
                    gClone.Transparency = 1
                    gClone.Parent = Workspace
                    Debris:AddItem(gClone, 3.5)

                    for _, d in ipairs(gClone:GetDescendants()) do
                        if d:IsA("ParticleEmitter") then
                            d.Enabled = true
                            d:Emit(30)
                            task.delay(0.35, function() pcall(function() d.Enabled = false end) end)
                        end
                    end
                end

                -- Columna de relámpago vertical
                SpawnIslandLightning(groundPos, groundPos + Vector3.new(0, 45, 0))
            end

            -- Retardo entre anillos para crear la onda de choque en expansión
            task.wait(0.20)
        end
    end)

    -- 8. DETONACIÓN SIMULTÁNEA EN OBJETOS POR TODA LA ISLA
    task.spawn(function()
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {char}
        local parts = Workspace:GetPartBoundsInRadius(hrp.Position, math.min(radius, 600), op)
        local maxDet = math.min(#parts, math.clamp(math.floor(5 + p * 35), 5, 40))

        for i = 1, maxDet do
            local part = parts[i]
            if part and part:IsA("BasePart") and part.Transparency < 0.95 then
                SpawnIslandLightning(part.Position)
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
                    local dist = math.random(5, 16)
                    local rayOrigin = hrp.Position + Vector3.new(math.cos(angle) * dist, 50, math.sin(angle) * dist)
                    local rayHit = Workspace:Raycast(rayOrigin, Vector3.new(0, -100, 0), rayParams)
                    local pos = rayHit and rayHit.Position or (rayOrigin - Vector3.new(0, 50, 0))

                    SpawnIslandLightning(pos, hrp.Position + Vector3.new(0, 5, 0))
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

    print("[Polar Hub] ⚡ Haki del Conquistador V4 (Island Apocalypse) desmontado limpiamente.")
end

-- Exportar a ambos entornos globales
G.ConquerorHakiCleanup = function() Engine:Cleanup() end
G.ConquerorBurst = function(mult, ratio) Engine:TriggerBurst(mult, ratio) end
_G.ConquerorHakiCleanup = G.ConquerorHakiCleanup
_G.ConquerorBurst = G.ConquerorBurst

Engine:Init()

print("================================================================================")
print("  👑 [POLAR HUB] HAKI DEL CONQUISTADOR V4 (ISLAND APOCALYPSE) ACTIVADO")
print("  ⚡ MANTÉN PRESIONADA LA TECLA [H]: Carga hasta 120 segundos (Escala Isla)")
print("  💥 SUELTA [H]: Desata el Estallido Cataclísmico (Hasta 1800+ studs de radio)")
print("  🌟 Iluminación 100% clara y nítida: Los rayos rojos y negros resaltan al máximo")
print("  🎥 Cámara ultra-estabilizada sin volteo ni balanceo lateral")
print("================================================================================")

return Engine
