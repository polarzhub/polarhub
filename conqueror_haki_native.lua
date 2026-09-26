--[[
    ================================================================================
    POLAR HUB | NATIVE CONQUEROR'S HAKI (HAOSHOKU INFUSION) V2 - TITANIC EDITION
    ================================================================================
    Mejoras V2:
      1. RAYOS ULTRA-POTENCIADOS:
         - 4 capas de relámpagos oficiales (Rojo Carmesí, Vacío Negro, Ramificaciones
           y Arcos de Alto Voltaje de Yama y CDK).
         - Descargas ambientales continuas de rayos al suelo alrededor del jugador.
      2. ESTALLIDO COLOSAL Y POTENTE:
         - TornadoExplosion escalado y con emisión masiva (+120 Shocks, +75 Squash Lightning).
         - CDK SlayerHit (RedShine, BlackShine, FlashStarRays, NeonEmbers).
         - StartImpact de Blox Fruits (Anillos de choque en el suelo).
         - Efecto cinematográfico de Dimming/Tint en Lighting (el mundo se oscurece
           al estallar el Conquistador y vuelve suavemente).
         - Círculo de 8 impactos de rayos radiales alrededor del personaje.
      3. CÁMARA ESTABILIZADA:
         - Sacudida de impacto pesada pero 100% SIN rotar o voltear la pantalla
           (desplazamiento vertical/horizontal controlado con reseteo instantáneo).
    ================================================================================
    Controles:
      - Tecla [H]: Desata el Estallido Colosal del Conquistador.
      - Equipar/Desequipar espadas: El aura se adapta y transfiere automáticamente.
      - _G.ConquerorBurst() / getgenv().ConquerorBurst(): Ejecutar estallido vía código.
      - _G.ConquerorHakiCleanup() / getgenv().ConquerorHakiCleanup(): Desmontar todo.
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

-- Limpieza preventiva completa
if G.ConquerorHakiCleanup then
    pcall(G.ConquerorHakiCleanup)
end
if _G.ConquerorHakiCleanup and _G.ConquerorHakiCleanup ~= G.ConquerorHakiCleanup then
    pcall(_G.ConquerorHakiCleanup)
end

-- Limpieza física preventiva en el personaje
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
    LastBurstTime = 0,
    Cooldown = 2.0
}

-- ================================================================================
-- RECURSOS OFICIALES EXTRAÍDOS DIRECTAMENTE DE REPLICATEDSTORAGE
-- ================================================================================
local EffectContainer = ReplicatedStorage:WaitForChild("EffectContainer", 5)
local FX = ReplicatedStorage:WaitForChild("FX", 5)

-- CDK Assets
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

-- Yama Assets
local Yama_FX = FX and FX:FindFirstChild("Yama")
local YamaSkill1 = Yama_FX and Yama_FX:FindFirstChild("YamaSkill1")
local YamaGroundSparks = YamaSkill1 and YamaSkill1:FindFirstChild("GroundSparks")
local YamaSlash = YamaSkill1 and YamaSkill1:FindFirstChild("Slash")

-- ActivateAura Assets (Shockwave en piso)
local ActivateAuraFolder = EffectContainer and EffectContainer:FindFirstChild("ActivateAura")
local Phase1 = ActivateAuraFolder and ActivateAuraFolder:FindFirstChild("Assets") and ActivateAuraFolder.Assets:FindFirstChild("Phase1")
local StartImpactTemplate = Phase1 and Phase1:FindFirstChild("StartImpact")

-- Extraer Emisores de Rayos Nativos de Yama
local YamaJaggedLightningEmitter = nil
local YamaSparkEmitter = nil
pcall(function()
    if YamaSlash then
        local slash2 = YamaSlash:FindFirstChild("Slash2")
        if slash2 then
            for _, pe in ipairs(slash2:GetChildren()) do
                if pe:IsA("ParticleEmitter") then
                    if pe.Texture:find("13002793471") then
                        YamaJaggedLightningEmitter = pe
                    elseif pe.Texture:find("13001442706") then
                        YamaSparkEmitter = pe
                    end
                end
            end
        end
    end
end)

-- ================================================================================
-- 1. SONIDO Y SACUDIDA ESTABILIZADA DE CÁMARA (SIN ROTAR/VOLTEAR)
-- ================================================================================
local function PlayConquerorAudio(parent)
    -- Sonido 1: Retumbe y Explosión de Haki del Conquistador (Blox Fruits)
    local s1 = Instance.new("Sound")
    s1.SoundId = "rbxassetid://9069609200"
    s1.Volume = 3.5
    s1.PlaybackSpeed = 0.88 -- Bajo más profundo y demoledor
    s1.Parent = parent or Workspace
    s1:Play()
    Debris:AddItem(s1, 5)

    -- Sonido 2: Rugido de impacto eléctrico CDK
    local s2 = Instance.new("Sound")
    s2.SoundId = "rbxassetid://6026998623"
    s2.Volume = 2.4
    s2.PlaybackSpeed = 0.98
    s2.Parent = parent or Workspace
    s2:Play()
    Debris:AddItem(s2, 5)

    -- Sonido 3: Chisporroteo de alta tensión
    local s3 = Instance.new("Sound")
    s3.SoundId = "rbxassetid://5801257793"
    s3.Volume = 1.8
    s3.PlaybackSpeed = 1.1
    s3.Parent = parent or Workspace
    s3:Play()
    Debris:AddItem(s3, 4)
end

-- Sacudida de cámara con compensación instantánea:
-- Desplaza suavemente la posición (impacto) pero NUNCA inclina ni da vuelta la pantalla.
local function ShakeScreenStabilized(intensity, duration)
    task.spawn(function()
        local start = os.clock()
        local prevOffset = CFrame.new()

        while os.clock() - start < duration do
            local elapsed = os.clock() - start
            local progress = elapsed / duration
            local damp = (1 - progress) * (1 - progress) -- Caída cuadrática suave

            -- Revertir el offset del frame anterior para mantener orientación pura
            Camera.CFrame = Camera.CFrame * prevOffset:Inverse()

            -- Solo micro-desplazamiento de posición y CERO ROLL (sin inclinación lateral)
            local offsetX = (math.random() - 0.5) * intensity * damp * 0.4
            local offsetY = (math.random() - 0.5) * intensity * damp * 0.6
            local pitch = math.rad((math.random() - 0.5) * intensity * damp * 0.9) -- Mínimo cabeceo
            local yaw = math.rad((math.random() - 0.5) * intensity * damp * 0.7)

            prevOffset = CFrame.new(offsetX, offsetY, 0) * CFrame.Angles(pitch, yaw, 0)
            Camera.CFrame = Camera.CFrame * prevOffset

            RunService.RenderStepped:Wait()
        end

        -- Restauración absoluta al terminar
        Camera.CFrame = Camera.CFrame * prevOffset:Inverse()
    end)
end

-- ================================================================================
-- 2. AURA DE CONQUISTADOR CON SOBREDOSIS DE RAYOS (RED & BLACK LIGHTNING OVERLOAD)
-- ================================================================================
local function ApplyConquerorAura(targetPart)
    if not targetPart or targetPart:FindFirstChild("PolarNativeHaki") then return end

    if not CDKAuraParticles then
        warn("[Polar Haki] CDKCursedAura no disponible en ReplicatedStorage")
        return
    end

    local clonedAtt = CDKAuraParticles:Clone()
    clonedAtt.Name = "PolarNativeHaki"
    clonedAtt.Parent = targetPart

    -- Configurar y maximizar las capas base de fuego carmesí y vacío negro
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

    -- CAPA 1 DE RAYOS: Relámpagos Rojos Dentados Violentos (Yama)
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
    redLightning.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    redLightning.Lifetime = NumberRange.new(0.18, 0.38)
    redLightning.Rate = 35
    redLightning.Speed = NumberRange.new(8, 20)
    redLightning.SpreadAngle = Vector2.new(60, 60)
    redLightning.LightEmission = 1
    redLightning.Brightness = 8
    redLightning.Parent = clonedAtt

    -- CAPA 2 DE RAYOS: Relámpagos Negros de Vacío (Conqueror Void Lightning)
    local blackLightning = Instance.new("ParticleEmitter")
    blackLightning.Name = "OverloadBlackLightning"
    blackLightning.Texture = "rbxassetid://13002793471"
    blackLightning.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    blackLightning.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.3, 2.4),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackLightning.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.9, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    blackLightning.Lifetime = NumberRange.new(0.18, 0.38)
    blackLightning.Rate = 35
    blackLightning.Speed = NumberRange.new(8, 20)
    blackLightning.SpreadAngle = Vector2.new(60, 60)
    blackLightning.LightEmission = 0
    blackLightning.Brightness = 0
    blackLightning.ZOffset = -0.5 -- Corta la luz produciendo el efecto de antimateria
    blackLightning.Parent = clonedAtt

    -- CAPA 3 DE RAYOS: Ramificaciones y Chispas Eléctricas Rápidas
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

    -- CAPA 4 DE RAYOS: Arcos Eléctricos de CDK
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
    -- Limpiar auras previas
    for _, att in ipairs(self.ActiveAttachments) do
        if att and att.Parent then pcall(function() att:Destroy() end) end
    end
    self.ActiveAttachments = {}

    local char = LocalPlayer.Character
    if not char then return end

    local hasEquippedSword = false

    -- Buscar espadas equipadas
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

    -- Si no tiene espada, infundir en ambas manos y torso
    if not hasEquippedSword then
        local rArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        local lArm = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        if rArm then ApplyConquerorAura(rArm) end
        if lArm then ApplyConquerorAura(lArm) end
    end
end

-- ================================================================================
-- 3. ESTALLIDO COLOSAL Y POTENTE (TITANIC CONQUEROR BURST)
-- ================================================================================
function Engine:TriggerBurst()
    if os.clock() - self.LastBurstTime < self.Cooldown then return end
    self.LastBurstTime = os.clock()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local rootCF = hrp.CFrame

    -- 1. Sonidos oficiales con bajo masivo
    PlayConquerorAudio(hrp)

    -- 2. Sacudida de impacto estabilizada (SIN voltear la cámara)
    ShakeScreenStabilized(1.9, 0.65)

    -- 3. EFECTO CINEMATOGRÁFICO DE VACÍO (LIGHTING DIMMING)
    task.spawn(function()
        local tint = nil
        local bloom = nil

        if CDKSlayerTintTemplate then
            tint = CDKSlayerTintTemplate:Clone()
            tint.Brightness = -1.4
            tint.Contrast = 0.35
            tint.Enabled = true
            tint.Parent = Lighting
        end

        if CDKSlayerBloomTemplate then
            bloom = CDKSlayerBloomTemplate:Clone()
            bloom.Intensity = 2.0
            bloom.Size = 56
            bloom.Enabled = true
            bloom.Parent = Lighting
        end

        -- Transición suave de regreso a la normalidad en 0.7 segundos
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if tint then
            local tw = TweenService:Create(tint, tweenInfo, {Brightness = 0, Contrast = 0})
            tw:Play()
            tw.Completed:Connect(function() pcall(function() tint:Destroy() end) end)
        end
        if bloom then
            local twB = TweenService:Create(bloom, tweenInfo, {Intensity = 0})
            twB:Play()
            twB.Completed:Connect(function() pcall(function() bloom:Destroy() end) end)
        end
    end)

    -- 4. EXPLOSIÓN TORNADO CDK ESCALADA AL MÁXIMO
    if TornadoExplosionTemplate then
        local burstClone = TornadoExplosionTemplate:Clone()
        burstClone.CFrame = rootCF * CFrame.new(0, -2.5, 0)
        burstClone.Anchored = true
        burstClone.CanCollide = false
        burstClone.Transparency = 1
        burstClone.Parent = Workspace
        Debris:AddItem(burstClone, 4.5)

        for _, desc in ipairs(burstClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "Lightning_Squash" then
                    -- Rayos colosales en cruz y vertical
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 4.0),
                        NumberSequenceKeypoint.new(1, 48.0)
                    })
                    desc:Emit(75)
                elseif desc.Name == "Burst" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 5.0),
                        NumberSequenceKeypoint.new(1, 38.0)
                    })
                    desc:Emit(50)
                elseif desc.Name == "Shocks" then
                    -- Campo de relámpagos densos
                    desc:Emit(130)
                elseif desc.Name == "InRays" then
                    desc:Emit(45)
                elseif desc.Name == "HalfRing" then
                    desc:Emit(25)
                elseif desc.Name == "Sparks" then
                    desc:Emit(90)
                elseif desc.Name == "AirWaves" then
                    desc.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 4.0),
                        NumberSequenceKeypoint.new(1, 55.0)
                    })
                    desc:Emit(25)
                else
                    desc:Emit(25)
                end

                task.delay(0.4, function()
                    pcall(function() desc.Enabled = false end)
                end)
            end
        end
    end

    -- 5. CDK SLAYER HIT IMPACT (ESTRELLAS DE DESTELLO, RED & BLACK SHINE)
    if SlayerHitTemplate then
        local slayerClone = SlayerHitTemplate:Clone()
        slayerClone.CFrame = rootCF * CFrame.new(0, 0, 0)
        slayerClone.Anchored = true
        slayerClone.CanCollide = false
        slayerClone.Transparency = 1
        slayerClone.Parent = Workspace
        Debris:AddItem(slayerClone, 4)

        for _, desc in ipairs(slayerClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                if desc.Name == "RedShine" then
                    desc:Emit(25)
                elseif desc.Name == "BlackShine" then
                    desc:Emit(25)
                elseif desc.Name == "FlashStar" then
                    desc:Emit(8)
                elseif desc.Name == "FlashStarRays" then
                    desc:Emit(35)
                elseif desc.Name == "NeonEmbers" then
                    desc:Emit(90)
                elseif desc.Name == "Fog" then
                    desc:Emit(15)
                else
                    desc:Emit(20)
                end

                task.delay(0.35, function()
                    pcall(function() desc.Enabled = false end)
                end)
            end
        end
    end

    -- 6. STARTIMPACT DE ACTIVACIÓN DE AURA (ONDA EXPANSIVA TERRESTRE)
    if StartImpactTemplate then
        local startImpactClone = StartImpactTemplate:Clone()
        startImpactClone.CFrame = rootCF * CFrame.new(0, -2.8, 0)
        startImpactClone.Anchored = true
        startImpactClone.CanCollide = false
        startImpactClone.Transparency = 1
        startImpactClone.Parent = Workspace
        Debris:AddItem(startImpactClone, 3)

        for _, desc in ipairs(startImpactClone:GetDescendants()) do
            if desc:IsA("ParticleEmitter") then
                desc.Enabled = true
                -- Tinte rojizo/oscuro de conquistador
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 40)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 0, 5))
                })
                desc:Emit(20)
                task.delay(0.35, function() pcall(function() desc.Enabled = false end) end)
            end
        end
    end

    -- 7. STATIC IMPACT & GROUND SPARKS DE YAMA
    if StaticImpactTemplate then
        local staticClone = StaticImpactTemplate:Clone()
        staticClone.CFrame = rootCF * CFrame.new(0, -2, 0)
        staticClone.Anchored = true
        staticClone.CanCollide = false
        staticClone.Transparency = 1
        staticClone.Parent = Workspace
        Debris:AddItem(staticClone, 3)

        for _, pe in ipairs(staticClone:GetChildren()) do
            if pe:IsA("ParticleEmitter") then
                pe.Enabled = true
                pe:Emit(45)
                task.delay(0.3, function() pcall(function() pe.Enabled = false end) end)
            end
        end
    end

    -- 8. CÍRCULO DE 8 IMPACTOS DE RAYOS RADIALES EN EL SUELO (CONQUEROR LIGHTNING RING)
    if YamaGroundSparks then
        local radius = 18
        for i = 1, 8 do
            local angle = (i / 8) * math.pi * 2
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
                    desc:Emit(25)
                    task.delay(0.35, function() pcall(function() desc.Enabled = false end) end)
                end
            end
        end
    end
end

-- ================================================================================
-- 4. DESCARGAS AMBIENTALES DE RAYOS (CONQUEROR PRESENCE LOOP)
-- ================================================================================
function Engine:StartAmbientPresence()
    task.spawn(function()
        while self.Active do
            task.wait(math.random(6, 11) / 10) -- Cada 0.6 a 1.1s
            if not self.Active then break end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and YamaGroundSparks then
                -- Descarga súbita cerca de los pies del jugador
                local angle = math.random() * math.pi * 2
                local dist = math.random(3, 9)
                local pos = hrp.Position + Vector3.new(math.cos(angle) * dist, -2.5, math.sin(angle) * dist)

                local p = YamaGroundSparks:Clone()
                p.CFrame = CFrame.new(pos)
                p.Anchored = true
                p.CanCollide = false
                p.Transparency = 1
                p.Parent = Workspace
                Debris:AddItem(p, 1.2)

                for _, pe in ipairs(p:GetDescendants()) do
                    if pe:IsA("ParticleEmitter") then
                        pe.Enabled = true
                        pe:Emit(12)
                        task.delay(0.2, function() pcall(function() pe.Enabled = false end) end)
                    end
                end
            end
        end
    end)
end

-- ================================================================================
-- 5. BINDINGS Y ESCUCHADORES EN VIVO
-- ================================================================================
function Engine:Init()
    -- Tecla [H] para detonar
    local keyConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            self:TriggerBurst()
        end
    end)
    table.insert(self.Connections, keyConn)

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
-- 6. LIMPIEZA SEGURA
-- ================================================================================
function Engine:Cleanup()
    self.Active = false
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, att in ipairs(self.ActiveAttachments) do
        if att and att.Parent then pcall(function() att:Destroy() end) end
    end
    self.ActiveAttachments = {}
    print("[Polar Hub] ⚡ Haki Nativo de Conquistador V2 desmontado limpiamente.")
end

-- Exportar a ambos entornos globales
G.ConquerorHakiCleanup = function() Engine:Cleanup() end
G.ConquerorBurst = function() Engine:TriggerBurst() end
_G.ConquerorHakiCleanup = G.ConquerorHakiCleanup
_G.ConquerorBurst = G.ConquerorBurst

Engine:Init()

print("================================================================================")
print("  👑 [POLAR HUB] HAKI DEL CONQUISTADOR NATIVO V2 ACTIVADO")
print("  ⚡ Rayos Rojos y Negros Ultra-Potenciados (4 capas simultáneas + Presencia viva)")
print("  💥 Estallido Colosal Escala Titán (Tornado + SlayerHit + Anillo de Rayos)")
print("  🎥 Cámara Estabilizada de Alto Impacto (Cero Volteo / Sin Mareos)")
print("  ⚡ Presiona la tecla [H] para desatar el Estallido Supremo")
print("================================================================================")

return Engine
