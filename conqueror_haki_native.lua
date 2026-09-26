--[[
    ================================================================================
    POLAR HUB | NATIVE CONQUEROR'S HAKI (HAOSHOKU INFUSION) V3 - CHARGE & OVERLOAD
    ================================================================================
    Novedades V3 (Charge & Release System):
      1. MECÁNICA DE CARGA AL MANTENER [H]:
         - Al mantener presionada la tecla [H], el Haki del Conquistador se concentra
           y se acumula progresivamente (hasta 3.5 segundos de carga máxima).
         - Entre más tiempo se mantiene presionado:
           * El aura en armas y manos crece colosalmente en tamaño y densidad.
           * El zumbido eléctrico y la vibración se vuelven más intensos y agudos.
           * El mundo y el cielo se oscurecen cada vez más (Atmospheric Void Eclipse).
           * Rayos rojos y negros violentos azotan objetos, paredes y suelos cercanos.
           * Relámpagos de Conquistador rasgan las esquinas de la pantalla/cámara.
      2. ESTALLIDO TITÁNICO AL SOLTAR [H]:
         - Al soltar la tecla [H], la energía acumulada detona con un multiplicador
           de potencia proporcional al tiempo de carga (hasta 5.0x de poder).
         - Carga Máxima:
           * Onda expansiva sísmica de hasta 120 studs.
           * Hasta 180 rayos gigantescos Lightning_Squash y 280 Shocks de CDK.
           * 3 anillos concéntricos de rayos en el suelo (36 columnas de relámpagos).
           * Eclipse total de luz con destello cegador y retorno suave.
           * Detonación simultánea de rayos en todos los objetos cercanos.
      3. CÁMARA ULTRA-ESTABILIZADA:
         - Sacudida de impacto pesada con cero balanceo lateral (roll = 0) para
           no voltear la cámara ni causar mareos.
    ================================================================================
    Controles:
      - Mantén presionada [H]: Concentra el Haki del Conquistador.
      - Suelta [H]: Desata el Estallido Supremo según el tiempo cargado.
      - Equipar/Desequipar espadas: El aura se transfiere automáticamente.
      - _G.ConquerorBurst(mult, ratio): Ejecutar directamente vía script.
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
    BaseEmitters = {},
    
    -- Sistema de Carga
    IsCharging = false,
    ChargeStartTime = 0,
    MaxChargeDuration = 3.5, -- Segundos para llegar a carga 100%
    ChargeSound = nil,
    ActiveTint = nil,
    ActiveBloom = nil,
    
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
local CDKSlayerTintTemplate = CDK_X and CDK_X:FindFirstChild("CDKSlayerTint")
local CDKSlayerBloomTemplate = CDK_X and CDK_X:FindFirstChild("CDKSlayerBloom")

-- Yama
local Yama_FX = FX and FX:FindFirstChild("Yama")
local YamaSkill1 = Yama_FX and Yama_FX:FindFirstChild("YamaSkill1")
local YamaGroundSparks = YamaSkill1 and YamaSkill1:FindFirstChild("GroundSparks")
local YamaSlash = YamaSkill1 and YamaSkill1:FindFirstChild("Slash")

-- ActivateAura
local ActivateAuraFolder = EffectContainer and EffectContainer:FindFirstChild("ActivateAura")
local Phase1 = ActivateAuraFolder and ActivateAuraFolder:FindFirstChild("Assets") and ActivateAuraFolder.Assets:FindFirstChild("Phase1")
local StartImpactTemplate = Phase1 and Phase1:FindFirstChild("StartImpact")

-- ================================================================================
-- 1. SISTEMA DE AUDIO POTENCIADO
-- ================================================================================
local function PlayConquerorBurstAudio(parent, multiplier)
    local mult = multiplier or 1.0

    -- 1. Bajo de Haki del Conquistador (Blox Fruits)
    local s1 = Instance.new("Sound")
    s1.SoundId = "rbxassetid://9069609200"
    s1.Volume = math.clamp(3.0 * mult, 3.0, 6.0)
    s1.PlaybackSpeed = math.clamp(0.92 - (mult - 1) * 0.04, 0.75, 1.0)
    s1.Parent = parent or Workspace
    s1:Play()
    Debris:AddItem(s1, 5)

    -- 2. Rugido de impacto CDK
    local s2 = Instance.new("Sound")
    s2.SoundId = "rbxassetid://6026998623"
    s2.Volume = math.clamp(2.2 * mult, 2.2, 5.0)
    s2.PlaybackSpeed = 0.96
    s2.Parent = parent or Workspace
    s2:Play()
    Debris:AddItem(s2, 5)

    -- 3. Detonación eléctrica cortante
    local s3 = Instance.new("Sound")
    s3.SoundId = "rbxassetid://5801257793"
    s3.Volume = math.clamp(1.8 * mult, 1.8, 4.0)
    s3.PlaybackSpeed = 1.05
    s3.Parent = parent or Workspace
    s3:Play()
    Debris:AddItem(s3, 4)
end

-- ================================================================================
-- 2. SACUDIDA ESTABILIZADA DE CÁMARA (CERO VOLTEO / SIN ROLL)
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
-- 3. RAYOS NATIVOS EN OBJETOS DEL ENTORNO Y EN PANTALLA
-- ================================================================================
local function SpawnObjectLightning(targetPos, originPos)
    local startPos = originPos or (targetPos + Vector3.new(math.random(-6, 6), math.random(18, 30), math.random(-6, 6)))
    
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

    -- Viga de Rayo Rojo
    local beamRed = Instance.new("Beam")
    beamRed.Texture = "rbxassetid://13002793471"
    beamRed.Color = ColorSequence.new(Color3.fromRGB(255, 30, 45))
    beamRed.Width0 = 1.6
    beamRed.Width1 = 0.9
    beamRed.FaceCamera = true
    beamRed.Attachment0 = attOrigin
    beamRed.Attachment1 = attTarget
    beamRed.LightEmission = 1
    beamRed.Parent = pTarget

    -- Viga de Vacío Negro (Efecto Conqueror)
    local beamBlack = Instance.new("Beam")
    beamBlack.Texture = "rbxassetid://13002793471"
    beamBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beamBlack.Width0 = 2.2
    beamBlack.Width1 = 1.3
    beamBlack.FaceCamera = true
    beamBlack.Attachment0 = attOrigin
    beamBlack.Attachment1 = attTarget
    beamBlack.LightEmission = 0
    beamBlack.ZOffset = -0.3
    beamBlack.Parent = pTarget

    -- Chispas de impacto de Yama en el objeto
    if YamaGroundSparks then
        local sparks = YamaGroundSparks:Clone()
        sparks.CFrame = CFrame.new(targetPos)
        sparks.Anchored = true
        sparks.CanCollide = false
        sparks.Transparency = 1
        sparks.Parent = Workspace
        Debris:AddItem(sparks, 0.8)

        for _, pe in ipairs(sparks:GetDescendants()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(14)
                task.delay(0.18, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    Debris:AddItem(pTarget, 0.22)
    Debris:AddItem(pOrigin, 0.22)
end

local function SpawnScreenLightning()
    local cf = Camera.CFrame
    -- Generar dos puntos en el campo visual de la cámara
    local angle = math.random() * math.pi * 2
    local dist = math.random(3, 6)
    local p1Pos = (cf * CFrame.new(math.cos(angle) * dist, math.sin(angle) * dist, -4.5)).Position
    local p2Pos = (cf * CFrame.new((math.cos(angle) * dist) * 0.3 + (math.random() - 0.5) * 2, (math.sin(angle) * dist) * 0.3 + (math.random() - 0.5) * 2, -4.0)).Position

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
    bRed.Color = ColorSequence.new(Color3.fromRGB(255, 40, 50))
    bRed.Width0 = 0.9
    bRed.Width1 = 0.5
    bRed.FaceCamera = true
    bRed.Attachment0 = a1
    bRed.Attachment1 = a2
    bRed.LightEmission = 1
    bRed.Parent = p1

    local bBlack = Instance.new("Beam")
    bBlack.Texture = "rbxassetid://13002793471"
    bBlack.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    bBlack.Width0 = 1.3
    bBlack.Width1 = 0.8
    bBlack.FaceCamera = true
    bBlack.Attachment0 = a1
    bBlack.Attachment1 = a2
    bBlack.LightEmission = 0
    bBlack.ZOffset = -0.2
    bBlack.Parent = p1

    Debris:AddItem(p1, 0.16)
    Debris:AddItem(p2, 0.16)
end

-- ================================================================================
-- 4. CONFIGURACIÓN DEL AURA NATIVA ULTRA-POTENCIADA
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
                em.Rate = 120
                em.LightEmission = 0.85
                em.Brightness = 3
            elseif em.Name == "Black" then
                em.Rate = 120
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 10))
    })
    redLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.3, 2.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    redLightning.Lifetime = NumberRange.new(0.18, 0.38)
    redLightning.Rate = 35
    redLightning.Speed = NumberRange.new(8, 20)
    redLightning.SpreadAngle = Vector2.new(60, 60)
    redLightning.LightEmission = 1
    redLightning.Brightness = 8
    redLightning.Parent = clonedAtt

    -- Relámpago Negro de Vacío
    local blackLightning = Instance.new("ParticleEmitter")
    blackLightning.Name = "OverloadBlackLightning"
    blackLightning.Texture = "rbxassetid://13002793471"
    blackLightning.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    blackLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.3, 2.4),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackLightning.Lifetime = NumberRange.new(0.18, 0.38)
    blackLightning.Rate = 35
    blackLightning.Speed = NumberRange.new(8, 20)
    blackLightning.SpreadAngle = Vector2.new(60, 60)
    blackLightning.LightEmission = 0
    blackLightning.Brightness = 0
    blackLightning.ZOffset = -0.5
    blackLightning.Parent = clonedAtt

    -- Ramificaciones Eléctricas
    local branchSparks = Instance.new("ParticleEmitter")
    branchSparks.Name = "OverloadBranchSparks"
    branchSparks.Texture = "rbxassetid://13001442706"
    branchSparks.Color = ColorSequence.new(Color3.fromRGB(255, 60, 70))
    branchSparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    branchSparks.Lifetime = NumberRange.new(0.15, 0.3)
    branchSparks.Rate = 30
    branchSparks.Speed = NumberRange.new(14, 28)
    branchSparks.SpreadAngle = Vector2.new(180, 180)
    branchSparks.LightEmission = 1
    branchSparks.Brightness = 6
    branchSparks.Parent = clonedAtt

    -- Arcos Eléctricos CDK
    local cdkShocks = Instance.new("ParticleEmitter")
    cdkShocks.Name = "OverloadElectricArcs"
    cdkShocks.Texture = "rbxassetid://280272015"
    cdkShocks.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
    })
    cdkShocks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.5, 3.0),
        NumberSequenceKeypoint.new(1, 0)
    })
    cdkShocks.Lifetime = NumberRange.new(0.15, 0.28)
    cdkShocks.Rate = 22
    cdkShocks.Speed = NumberRange.new(6, 16)
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
-- 5. MECÁNICA DE CARGA DINÁMICA AL MANTENER [H]
-- ================================================================================
function Engine:StartCharging()
    if self.IsCharging then return end
    if os.clock() - self.LastBurstTime < self.Cooldown then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    self.IsCharging = true
    self.ChargeStartTime = os.clock()

    -- Audio de carga ascendente
    pcall(function()
        local s = Instance.new("Sound")
        s.Name = "PolarChargeSound"
        s.SoundId = "rbxassetid://6026998623"
        s.Looped = true
        s.Volume = 0.8
        s.PlaybackSpeed = 0.75
        s.Parent = hrp
        s:Play()
        self.ChargeSound = s
    end)

    -- Instanciar efectos de iluminación para oscurecimiento gradual
    pcall(function()
        if CDKSlayerTintTemplate and not self.ActiveTint then
            self.ActiveTint = CDKSlayerTintTemplate:Clone()
            self.ActiveTint.Brightness = 0
            self.ActiveTint.Contrast = 0
            self.ActiveTint.Enabled = true
            self.ActiveTint.Parent = Lighting
        end
        if CDKSlayerBloomTemplate and not self.ActiveBloom then
            self.ActiveBloom = CDKSlayerBloomTemplate:Clone()
            self.ActiveBloom.Intensity = 0
            self.ActiveBloom.Size = 56
            self.ActiveBloom.Enabled = true
            self.ActiveBloom.Parent = Lighting
        end
    end)

    -- Bucle de concentración y escalada de Haki
    task.spawn(function()
        local lastStrikeTime = 0
        local lastScreenStrikeTime = 0

        while self.IsCharging and self.Active do
            local elapsed = os.clock() - self.ChargeStartTime
            local ratio = math.clamp(elapsed / self.MaxChargeDuration, 0, 1)

            -- 1. Modulación de sonido
            if self.ChargeSound and self.ChargeSound.Parent then
                self.ChargeSound.PlaybackSpeed = 0.75 + ratio * 0.75 -- De 0.75 a 1.50 pitch
                self.ChargeSound.Volume = 0.8 + ratio * 2.4        -- De 0.8 a 3.2 volume
            end

            -- 2. Oscurecimiento gradual del mundo (Eclipse del Conquistador)
            if self.ActiveTint then
                self.ActiveTint.Brightness = -ratio * 1.5
                self.ActiveTint.Contrast = ratio * 0.4
            end
            if self.ActiveBloom then
                self.ActiveBloom.Intensity = ratio * 2.2
            end

            -- 3. Aumentar densidad y tamaño del aura en vivo
            for _, att in ipairs(self.ActiveAttachments) do
                if att and att.Parent then
                    for _, pe in ipairs(att:GetChildren()) do
                        if pe:IsA("ParticleEmitter") then
                            if pe.Name:find("Lightning") or pe.Name:find("Red") or pe.Name:find("Black") then
                                pe.Rate = (pe.Name:find("Lightning") and (35 + ratio * 65)) or (120 + ratio * 160)
                            end
                        end
                    end
                end
            end

            -- 4. Micro-vibración sísmica de carga (sin voltear la vista)
            ShakeScreenStabilized(0.25 + ratio * 0.95, 0.05)

            -- 5. Rayos azotando objetos del entorno
            local strikeInterval = math.max(0.08, 0.38 - ratio * 0.28)
            if os.clock() - lastStrikeTime > strikeInterval then
                lastStrikeTime = os.clock()
                local radius = 15 + ratio * 45
                local op = OverlapParams.new()
                op.FilterType = Enum.RaycastFilterType.Exclude
                op.FilterDescendantsInstances = {char}
                local nearbyParts = Workspace:GetPartBoundsInRadius(hrp.Position, radius, op)

                if #nearbyParts > 0 then
                    local count = math.random(1, 1 + math.floor(ratio * 3))
                    for _ = 1, count do
                        local randomPart = nearbyParts[math.random(1, #nearbyParts)]
                        if randomPart and randomPart:IsA("BasePart") and randomPart.Transparency < 0.95 then
                            local surfacePoint = randomPart.Position + Vector3.new(
                                (math.random() - 0.5) * math.min(randomPart.Size.X, 6),
                                randomPart.Size.Y * 0.5,
                                (math.random() - 0.5) * math.min(randomPart.Size.Z, 6)
                            )
                            SpawnObjectLightning(surfacePoint, hrp.Position + Vector3.new(0, 3, 0))
                        end
                    end
                else
                    -- Si no hay partes cerca, azotar el suelo alrededor del jugador
                    local angle = math.random() * math.pi * 2
                    local d = math.random(5, math.floor(radius))
                    local groundPos = hrp.Position + Vector3.new(math.cos(angle) * d, -2.5, math.sin(angle) * d)
                    SpawnObjectLightning(groundPos, hrp.Position + Vector3.new(0, 3, 0))
                end
            end

            -- 6. Rayos cortando en la pantalla
            if os.clock() - lastScreenStrikeTime > (0.28 - ratio * 0.18) then
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
    local ratio = math.clamp(elapsed / self.MaxChargeDuration, 0, 1)
    local multiplier = 1.0 + (ratio * 4.0) -- De 1.0x hasta 5.0x

    -- Detener audio de carga
    if self.ChargeSound then
        pcall(function() self.ChargeSound:Destroy() end)
        self.ChargeSound = nil
    end

    -- Restaurar tasas base del aura
    self:RefreshAura()

    -- Detonar el Estallido Supremo de acuerdo a la potencia acumulada
    self:TriggerBurst(multiplier, ratio)
end

-- ================================================================================
-- 6. ESTALLIDO SUPREMO ESCALADO POR POTENCIA (BURST EXPLOSION)
-- ================================================================================
function Engine:TriggerBurst(multiplier, ratio)
    local mult = multiplier or 1.0
    local r = ratio or 0.0
    self.LastBurstTime = os.clock()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local rootCF = hrp.CFrame

    -- 1. Sonidos de estallido con bajo sísmico
    PlayConquerorBurstAudio(hrp, mult)

    -- 2. Sacudida de impacto pesada ultra-estabilizada
    ShakeScreenStabilized(1.8 + r * 2.6, 0.65 + r * 0.45)

    -- 3. Transición de iluminación: Eclipse súbito y restauración suave
    task.spawn(function()
        local tint = self.ActiveTint
        local bloom = self.ActiveBloom
        self.ActiveTint = nil
        self.ActiveBloom = nil

        if not tint and CDKSlayerTintTemplate then
            tint = CDKSlayerTintTemplate:Clone()
            tint.Parent = Lighting
        end
        if not bloom and CDKSlayerBloomTemplate then
            bloom = CDKSlayerBloomTemplate:Clone()
            bloom.Parent = Lighting
        end

        if tint then
            tint.Brightness = -1.5 - (r * 1.0) -- Eclipse profundo a carga máxima
            tint.Contrast = 0.35 + (r * 0.25)
            tint.Enabled = true
            local tw = TweenService:Create(tint, TweenInfo.new(0.7 + r * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0, Contrast = 0})
            tw:Play()
            tw.Completed:Connect(function() pcall(function() tint:Destroy() end) end)
        end

        if bloom then
            bloom.Intensity = 2.0 + (r * 2.5)
            bloom.Size = 56
            bloom.Enabled = true
            local twB = TweenService:Create(bloom, TweenInfo.new(0.6 + r * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Intensity = 0})
            twB:Play()
            twB.Completed:Connect(function() pcall(function() bloom:Destroy() end) end)
        end
    end)

    -- 4. CDK TORNADO EXPLOSION ESCALADO
    if TornadoExplosionTemplate then
        local burstClone = TornadoExplosionTemplate:Clone()
        burstClone.CFrame = rootCF * CFrame.new(0, -2.5, 0)
        burstClone.Anchored = true
        burstClone.CanCollide = false
        burstClone.Transparency = 1
        burstClone.Parent = Workspace
        Debris:AddItem(burstClone, 5.0)

        for _, desc in ipairs(burstClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "Lightning_Squash" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 4.0 * (1 + r * 1.5)),
                        NumberSequenceKeypoint.new(1, 48.0 * (1 + r * 1.5))
                    })
                    desc:Emit(math.floor(75 * mult))
                elseif desc.Name == "Burst" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 5.0 * (1 + r * 1.2)),
                        NumberSequenceKeypoint.new(1, 38.0 * (1 + r * 1.4))
                    })
                    desc:Emit(math.floor(50 * mult))
                elseif desc.Name == "Shocks" then
                    desc:Emit(math.floor(130 * mult))
                elseif desc.Name == "InRays" then
                    desc:Emit(math.floor(45 * mult))
                elseif desc.Name == "HalfRing" then
                    desc:Emit(math.floor(25 * mult))
                elseif desc.Name == "Sparks" then
                    desc:Emit(math.floor(90 * mult))
                elseif desc.Name == "AirWaves" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 4.0 * (1 + r * 1.5)),
                        NumberSequenceKeypoint.new(1, 55.0 * (1 + r * 1.8))
                    })
                    desc:Emit(math.floor(25 * mult))
                else
                    desc:Emit(math.floor(25 * mult))
                end

                task.delay(0.45, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 5. CDK SLAYER HIT IMPACT (ESTRELLAS DE DESTELLO Y RAYOS EN CRUZ)
    if SlayerHitTemplate then
        local slayerClone = SlayerHitTemplate:Clone()
        slayerClone.CFrame = rootCF
        slayerClone.Anchored = true
        slayerClone.CanCollide = false
        slayerClone.Transparency = 1
        slayerClone.Parent = Workspace
        Debris:AddItem(slayerClone, 4.5)

        for _, desc in ipairs(slayerClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "RedShine" then
                    desc:Emit(math.floor(25 * mult))
                elseif desc.Name == "BlackShine" then
                    desc:Emit(math.floor(25 * mult))
                elseif desc.Name == "FlashStar" then
                    desc:Emit(math.floor(8 * mult))
                elseif desc.Name == "FlashStarRays" then
                    desc:Emit(math.floor(35 * mult))
                elseif desc.Name == "NeonEmbers" then
                    desc:Emit(math.floor(90 * mult))
                elseif desc.Name == "Fog" then
                    desc:Emit(math.floor(15 * mult))
                else
                    desc:Emit(math.floor(20 * mult))
                end

                task.delay(0.4, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 6. ONDA EXPANSIVA DE SUELO (STARTIMPACT)
    if StartImpactTemplate then
        local startImpactClone = StartImpactTemplate:Clone()
        startImpactClone.CFrame = rootCF * CFrame.new(0, -2.8, 0)
        startImpactClone.Anchored = true
        startImpactClone.CanCollide = false
        startImpactClone.Transparency = 1
        startImpactClone.Parent = Workspace
        Debris:AddItem(startImpactClone, 3.5)

        for _, desc in ipairs(startImpactClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 40)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 0, 5))
                })
                desc:Emit(math.floor(20 * mult))
                task.delay(0.4, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 7. ANILLOS CONCÉNTRICOS DE RAYOS EN EL SUELO (1 a 3 anillos según carga)
    if YamaGroundSparks then
        local rings = 1
        if r > 0.35 then rings = 2 end
        if r > 0.70 then rings = 3 end

        local ringRadii = {16, 36, 62}
        local strikesPerRing = {8, 12, 16}

        for ringIdx = 1, rings do
            local radius = ringRadii[ringIdx]
            local count = strikesPerRing[ringIdx]

            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local offsetPos = rootCF.Position + Vector3.new(math.cos(angle) * radius, -2.5, math.sin(angle) * radius)
                local groundClone = YamaGroundSparks:Clone()
                groundClone.CFrame = CFrame.new(offsetPos)
                groundClone.Anchored = true
                groundClone.CanCollide = false
                groundClone.Transparency = 1
                groundClone.Parent = Workspace
                Debris:AddItem(groundClone, 3)

                for _, desc in ipairs(groundClone:GetDescendants()) do
                    if desc:IsA("ParticleEmitter") then
                        desc.Enabled = true
                        desc:Emit(math.floor(25 * (1 + r * 0.8)))
                        task.delay(0.35, function() pcall(function() desc.Enabled = false end) end)
                    end
                end

                -- Viga de relámpago vertical en cada punto del anillo
                SpawnObjectLightning(offsetPos, offsetPos + Vector3.new(0, 24, 0))
            end
        end
    end

    -- 8. DETONACIÓN SIMULTÁNEA EN OBJETOS CERCANOS
    pcall(function()
        local detRadius = 25 + r * 50
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {char}
        local parts = Workspace:GetPartBoundsInRadius(hrp.Position, detRadius, op)
        local maxDet = math.min(#parts, math.floor(4 + r * 14))

        for i = 1, maxDet do
            local p = parts[i]
            if p and p:IsA("BasePart") and p.Transparency < 0.95 then
                SpawnObjectLightning(p.Position)
            end
        end
    end)
end

-- ================================================================================
-- 7. DESCARGAS AMBIENTALES PERIÓDICAS (PRESENCIA PASIVA)
-- ================================================================================
function Engine:StartAmbientPresence()
    task.spawn(function()
        while self.Active do
            task.wait(math.random(7, 13) / 10)
            if not self.Active then break end

            if not self.IsCharging then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and YamaGroundSparks then
                    local angle = math.random() * math.pi * 2
                    local dist = math.random(4, 10)
                    local pos = hrp.Position + Vector3.new(math.cos(angle) * dist, -2.5, math.sin(angle) * dist)
                    SpawnObjectLightning(pos, hrp.Position + Vector3.new(0, 4, 0))
                end
            end
        end
    end)
end

-- ================================================================================
-- 8. BINDINGS Y ESCUCHADORES EN VIVO (MANTENER [H] PARA CARGAR)
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
-- 9. LIMPIEZA SEGURA
-- ================================================================================
function Engine:Cleanup()
    self.Active = false
    self.IsCharging = false

    if self.ChargeSound then
        pcall(function() self.ChargeSound:Destroy() end)
        self.ChargeSound = nil
    end
    if self.ActiveTint then
        pcall(function() self.ActiveTint:Destroy() end)
        self.ActiveTint = nil
    end
    if self.ActiveBloom then
        pcall(function() self.ActiveBloom:Destroy() end)
        self.ActiveBloom = nil
    end

    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, att in ipairs(self.ActiveAttachments) do
        if att and att.Parent then pcall(function() att:Destroy() end) end
    end
    self.ActiveAttachments = {}

    print("[Polar Hub] ⚡ Haki del Conquistador V3 (Charge & Release) desmontado limpiamente.")
end

-- Exportar a ambos entornos globales
G.ConquerorHakiCleanup = function() Engine:Cleanup() end
G.ConquerorBurst = function(mult, ratio) Engine:TriggerBurst(mult, ratio) end
_G.ConquerorHakiCleanup = G.ConquerorHakiCleanup
_G.ConquerorBurst = G.ConquerorBurst

Engine:Init()

print("================================================================================")
print("  👑 [POLAR HUB] HAKI DEL CONQUISTADOR V3 (CHARGE & RELEASE SYSTEM) ACTIVADO")
print("  ⚡ MANTÉN PRESIONADA LA TECLA [H]: Concentra y magnifica el Haki del Conquistador")
print("  💥 SUELTA [H]: Desata el Estallido Supremo (Escala colosalmente con la carga)")
print("  ⚡ Relámpagos azotan objetos y la pantalla dinámicamente mientras cargas")
print("  🎥 Cámara ultra-estabilizada sin volteo ni balanceo")
print("================================================================================")

return Engine
