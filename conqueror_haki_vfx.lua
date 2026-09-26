--[[
    ================================================================================
    POLAR HUB | ADVANCED CONQUEROR'S HAKI (HAOSHOKU INFUSION) VFX ENGINE
    ================================================================================
    Inspirado en la ingeniería interna de Blox Fruits (Yama, Tushita, Cursed Dual Katana):
      1. Generador de Rayos Procedurales (Shafi-Style Lightning):
         - Núcleo negro abismal (#050005) + Corona de plasma carmesí puro (#FF1428).
         - Desplazamiento irregular en zigzag y bifurcaciones a tierra (Ground Arcs).
      2. Aura Pasiva de Espadas / Manos:
         - Relámpagos negros y rojos orbitando continuamente las armas equipadas o brazos.
      3. Estallido Supremo del Rey (Conqueror's Burst):
         - Carga de energía con distorsión esférica implosiva.
         - Explosión de onda expansiva masiva (40+ studs) con anillos de choque.
         - Detonación de rocas del terreno (Crater Debris) levitadas por la presión de Haki.
         - Sacudida sísmica de pantalla (Camera Impulse Spring) y estruendos de trueno.
      4. Totalmente Client-Sided, Zero-Lag, Anti-Leak y con soporte Live-Reload.
    ================================================================================
    Controles:
      - Tecla [H] en teclado o comando: Dispara el Estallido del Conquistador.
      - _G.ToggleConquerorAura(true/false): Activa/Desactiva el aura continua.
      - _G.ConquerorBurst(): Ejecuta la descarga en cualquier momento.
    ================================================================================
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Limpieza preventiva de sesiones previas
if _G.ConquerorHakiCleanup then
    pcall(_G.ConquerorHakiCleanup)
end

local Engine = {
    Active = true,
    AuraEnabled = true,
    Connections = {},
    Instances = {},
    Sounds = {},
    LastBurstTime = 0,
    Cooldown = 3.5
}

-- Paleta de colores oficial de Haki de Conquistador CDK / Yama
local COLOR_CRIMSON_GLOW = Color3.fromRGB(255, 20, 35)      -- Rojo carmesí ardiente
local COLOR_DARK_RED     = Color3.fromRGB(150, 0, 15)       -- Rojo sangre profundo
local COLOR_VOID_BLACK   = Color3.fromRGB(8, 2, 8)          -- Negro abisal de Haki
local COLOR_CORE_BLACK   = Color3.fromRGB(0, 0, 0)          -- Cero luz (antimateria)

-- ================================================================================
-- 1. MOTOR DE SONIDO INMERSIVO
-- ================================================================================
local function PlaySound(id, volume, playbackSpeed, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = volume or 1
    sound.PlaybackSpeed = playbackSpeed or 1
    sound.Parent = parent or SoundService
    sound:Play()
    Debris:AddItem(sound, 5)
    return sound
end

-- ================================================================================
-- 2. SACUDIDA DE CÁMARA CINEMÁTICA (CAMERA SHAKE)
-- ================================================================================
local function ShakeCamera(intensity, duration)
    task.spawn(function()
        local startTime = os.clock()
        while os.clock() - startTime < duration do
            local elapsed = os.clock() - startTime
            local damp = 1 - (elapsed / duration)
            local offsetX = (math.random() - 0.5) * intensity * damp
            local offsetY = (math.random() - 0.5) * intensity * damp
            local offsetZ = (math.random() - 0.5) * intensity * damp * 0.5
            
            Camera.CFrame = Camera.CFrame * CFrame.Angles(
                math.rad(offsetX * 15),
                math.rad(offsetY * 15),
                math.rad(offsetZ * 15)
            )
            RunService.RenderStepped:Wait()
        end
    end)
end

-- ================================================================================
-- 3. GENERADOR PROCEDURAL DE RAYOS ROJOS Y NEGROS (SHAFI LIGHTNING)
-- ================================================================================
local function CreateLightningBolt(startPos, endPos, segmentsCount, roughness, isBlackVoid)
    local container = Instance.new("Folder")
    container.Name = "HakiBolt"
    container.Parent = Workspace
    Debris:AddItem(container, 0.45)

    local points = {startPos}
    local delta = (endPos - startPos)
    local segLength = delta.Magnitude / segmentsCount
    local unitDir = delta.Unit

    for i = 1, segmentsCount - 1 do
        local base = startPos + unitDir * (i * segLength)
        local spread = roughness or 2.2
        local offset = Vector3.new(
            (math.random() - 0.5) * spread,
            (math.random() - 0.5) * spread,
            (math.random() - 0.5) * spread
        )
        table.insert(points, base + offset)
    end
    table.insert(points, endPos)

    for i = 1, #points - 1 do
        local pA = points[i]
        local pB = points[i + 1]
        local mag = (pB - pA).Magnitude
        if mag > 0.01 then
            local beamPart = Instance.new("Part")
            beamPart.Anchored = true
            beamPart.CanCollide = false
            beamPart.CanQuery = false
            beamPart.CanTouch = false
            beamPart.CastShadow = false
            beamPart.Material = isBlackVoid and Enum.Material.Glass or Enum.Material.Neon
            beamPart.Color = isBlackVoid and COLOR_VOID_BLACK or COLOR_CRIMSON_GLOW
            beamPart.Transparency = isBlackVoid and 0.05 or 0.1
            beamPart.Size = Vector3.new(isBlackVoid and 0.45 or 0.28, isBlackVoid and 0.45 or 0.28, mag)
            beamPart.CFrame = CFrame.new((pA + pB) / 2, pB)
            beamPart.Parent = container

            -- Añadir desvanecimiento rápido
            TweenService:Create(beamPart, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0, 0, mag),
                Transparency = 1
            }):Play()
        end
    end
end

-- Rayos dobles simultáneos (Núcleo negro envuelto en plasma rojo - Estilo CDK)
local function SpawnDualHakiBolt(origin, target, spread)
    CreateLightningBolt(origin, target, 7, spread or 2.8, true)   -- Relámpago negro grueso
    CreateLightningBolt(origin, target, 9, (spread or 2.8) * 0.7, false) -- Filamento rojo incandescente
end

-- ================================================================================
-- 4. CRÁTER Y ROCAS DE TERRENO LEVITANTES (TERRAIN DEBRIS)
-- ================================================================================
local function SpawnCraterRocks(centerPos, radius, count)
    local debrisFolder = Instance.new("Folder")
    debrisFolder.Name = "HakiDebris"
    debrisFolder.Parent = Workspace
    Debris:AddItem(debrisFolder, 3.5)

    for i = 1, count or 14 do
        local angle = (i / count) * math.pi * 2 + math.random(-0.3, 0.3)
        local dist = math.random(radius * 0.3, radius * 1.0)
        local spawnPos = centerPos + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)

        -- Detectar altura del suelo real
        local raycast = Workspace:Raycast(spawnPos + Vector3.new(0, 10, 0), Vector3.new(0, -25, 0))
        if raycast then
            local rock = Instance.new("Part")
            rock.Size = Vector3.new(math.random(12, 28) / 10, math.random(10, 25) / 10, math.random(12, 28) / 10)
            rock.CFrame = CFrame.new(raycast.Position) * CFrame.Angles(math.random(), math.random(), math.random())
            rock.Material = Enum.Material.Slate
            rock.Color = Color3.fromRGB(45, 45, 50)
            rock.Anchored = true
            rock.CanCollide = false
            rock.CastShadow = false
            rock.Parent = debrisFolder

            -- Levitar por la gravedad del Haki
            local liftHeight = math.random(4, 11)
            local targetCF = rock.CFrame + Vector3.new(0, liftHeight, 0) + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
            
            TweenService:Create(rock, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                CFrame = targetCF
            }):Play()

            -- Salpicar pequeños relámpagos a las rocas
            task.delay(0.15, function()
                if rock and rock.Parent then
                    SpawnDualHakiBolt(centerPos + Vector3.new(0, 2, 0), rock.Position, 1.2)
                end
            end)

            -- Caer y disolverse
            task.delay(1.4, function()
                if rock and rock.Parent then
                    local dropTween = TweenService:Create(rock, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        CFrame = rock.CFrame - Vector3.new(0, liftHeight + 2, 0),
                        Size = Vector3.new(0.1, 0.1, 0.1),
                        Transparency = 1
                    })
                    dropTween:Play()
                    dropTween.Completed:Connect(function() pcall(function() rock:Destroy() end) end)
                end
            end)
        end
    end
end

-- ================================================================================
-- 5. ONDA DE CHOQUE MASIVA (CONQUEROR'S SHOCKWAVE EXPANSION)
-- ================================================================================
local function SpawnShockwaveBurst(centerCFrame)
    local fxModel = Instance.new("Folder")
    fxModel.Name = "HakiShockwave"
    fxModel.Parent = Workspace
    Debris:AddItem(fxModel, 3)

    -- Anillo exterior de vacío negro
    local ringMesh = Instance.new("Part")
    ringMesh.Anchored = true
    ringMesh.CanCollide = false
    ringMesh.CastShadow = false
    ringMesh.Material = Enum.Material.Neon
    ringMesh.Color = COLOR_CRIMSON_GLOW
    ringMesh.CFrame = centerCFrame * CFrame.Angles(0, 0, 0)
    ringMesh.Size = Vector3.new(2, 0.5, 2)
    ringMesh.Parent = fxModel

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://3270017" -- Mesh clásica de anillo expansivo de Blox Fruits
    mesh.Scale = Vector3.new(1, 0.2, 1)
    mesh.Parent = ringMesh

    -- Esfera de pulso oscuro
    local dome = Instance.new("Part")
    dome.Shape = Enum.PartType.Ball
    dome.Anchored = true
    dome.CanCollide = false
    dome.CastShadow = false
    dome.Material = Enum.Material.Neon
    dome.Color = COLOR_VOID_BLACK
    dome.CFrame = centerCFrame
    dome.Size = Vector3.new(4, 4, 4)
    dome.Transparency = 0.2
    dome.Parent = fxModel

    -- Animación de expansión explosiva
    TweenService:Create(mesh, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Scale = Vector3.new(65, 8, 65)
    }):Play()
    
    TweenService:Create(ringMesh, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    }):Play()

    TweenService:Create(dome, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = Vector3.new(48, 48, 48),
        Transparency = 1
    }):Play()

    -- Disparar 12 relámpagos radiales a tierra
    for i = 1, 12 do
        local angle = (i / 12) * math.pi * 2
        local dist = math.random(22, 38)
        local groundTarget = centerCFrame.Position + Vector3.new(math.cos(angle) * dist, -2, math.sin(angle) * dist)
        SpawnDualHakiBolt(centerCFrame.Position + Vector3.new(0, 4, 0), groundTarget, 3.5)
    end
end

-- ================================================================================
-- 6. AURA CONTINUA EN ESPADAS Y EXTREMIDADES (PASSIVE HAOSHOKU INFUSION)
-- ================================================================================
local function AttachHakiAuraToPart(part)
    if not part or part:FindFirstChild("HakiAttachment") then return end

    local att = Instance.new("Attachment")
    att.Name = "HakiAttachment"
    att.Parent = part

    -- Emisor de chispas rojas
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "HakiSparks"
    sparks.Texture = "rbxassetid://7045169477" -- Chispas afiladas de alta resolución
    sparks.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLOR_CRIMSON_GLOW),
        ColorSequenceKeypoint.new(0.6, COLOR_DARK_RED),
        ColorSequenceKeypoint.new(1, COLOR_VOID_BLACK)
    })
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.7, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    sparks.Lifetime = NumberRange.new(0.3, 0.6)
    sparks.Rate = 28
    sparks.Speed = NumberRange.new(3, 8)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.LightEmission = 0.75
    sparks.Parent = att

    -- Emisor de filamentos de vacío negro
    local voidSmoke = Instance.new("ParticleEmitter")
    voidSmoke.Name = "HakiVoidSmoke"
    voidSmoke.Texture = "rbxassetid://258128463"
    voidSmoke.Color = ColorSequence.new(COLOR_VOID_BLACK)
    voidSmoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 1.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    voidSmoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.6, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    voidSmoke.Lifetime = NumberRange.new(0.4, 0.7)
    voidSmoke.Rate = 22
    voidSmoke.Speed = NumberRange.new(1, 4)
    voidSmoke.SpreadAngle = Vector2.new(180, 180)
    voidSmoke.LightEmission = 0 -- Negro puro sin brillo
    voidSmoke.Parent = att

    table.insert(Engine.Instances, att)
end

function Engine:RefreshCharacterAura()
    local char = LocalPlayer.Character
    if not char then return end

    -- Aplicar a brazos o manos
    local rArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local lArm = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    if rArm then AttachHakiAuraToPart(rArm) end
    if lArm then AttachHakiAuraToPart(lArm) end

    -- Aplicar a todas las espadas o herramientas equipadas
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _, descendant in ipairs(tool:GetDescendants()) do
                if descendant:IsA("BasePart") and (descendant.Name:lower():find("blade") or descendant.Name:lower():find("handle") or descendant.Name:lower():find("sword")) then
                    AttachHakiAuraToPart(descendant)
                end
            end
        end
    end
end

-- ================================================================================
-- 7. EJECUCIÓN DEL ESTALLIDO SUPREMO (CONQUEROR'S BURST)
-- ================================================================================
function Engine:CastConquerorBurst()
    if os.clock() - self.LastBurstTime < self.Cooldown then return end
    self.LastBurstTime = os.clock()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local rootCF = hrp.CFrame

    -- Sonidos cinemáticos
    PlaySound(9069609200, 2.2, 0.95, hrp) -- Trueno masivo de Haki
    PlaySound(6026998623, 1.8, 1.10, hrp) -- Explosión eléctrica

    -- Fase 1: Implosión de carga súbita
    ShakeCamera(0.65, 0.25)
    
    -- Fase 2: Detonación del impacto
    task.delay(0.12, function()
        ShakeCamera(1.85, 0.95)
        SpawnShockwaveBurst(rootCF * CFrame.new(0, -2.5, 0))
        SpawnCraterRocks(rootCF.Position - Vector3.new(0, 2.5, 0), 22, 16)
        
        -- Relámpagos verticales del cielo al personaje (Fuerza del Conquistador)
        local skyOrigin = rootCF.Position + Vector3.new(0, 85, 0)
        SpawnDualHakiBolt(skyOrigin, rootCF.Position, 4.0)
    end)
end

-- ================================================================================
-- 8. BUCLE PRINCIPAL DE RELÁMPAGOS AMBIENTALES
-- ================================================================================
function Engine:StartPassiveLoop()
    local conn = RunService.Heartbeat:Connect(function()
        if not self.Active or not self.AuraEnabled then return end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Cada ~0.25 segundos disparar un pequeño arco salvaje entre extremidades o hacia el aire
        if math.random() < 0.28 then
            local rArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            if rArm then
                local offset = Vector3.new(math.random(-4, 4), math.random(-3, 5), math.random(-4, 4))
                SpawnDualHakiBolt(rArm.Position, rArm.Position + offset, 1.8)
            end
        end
    end)
    table.insert(self.Connections, conn)

    -- Escuchar cuando cambie la herramienta equipada para infundirla de inmediato
    if LocalPlayer.Character then
        local childConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                self:RefreshCharacterAura()
            end
        end)
        table.insert(self.Connections, childConn)
    end

    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        self:RefreshCharacterAura()
        local childConn = newChar.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                self:RefreshCharacterAura()
            end
        end)
        table.insert(self.Connections, childConn)
    end)
    table.insert(self.Connections, charAddedConn)
end

-- ================================================================================
-- 9. GESTIÓN DE ENTRADA (HOTKEY)
-- ================================================================================
function Engine:BindInput()
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.H then
            self:CastConquerorBurst()
        end
    end)
    table.insert(self.Connections, inputConn)
end

-- ================================================================================
-- 10. LIMPIEZA TOTAL (CLEANUP API)
-- ================================================================================
function Engine:Cleanup()
    self.Active = false
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, inst in ipairs(self.Instances) do
        pcall(function() inst:Destroy() end)
    end
    print("[Polar Hub] ⚡ VFX de Haki del Conquistador desmontado limpiamente.")
end

_G.ConquerorHakiCleanup = function() Engine:Cleanup() end
_G.ConquerorBurst = function() Engine:CastConquerorBurst() end
_G.ToggleConquerorAura = function(state) Engine.AuraEnabled = state end

-- Inicializar sistema
Engine:RefreshCharacterAura()
Engine:StartPassiveLoop()
Engine:BindInput()

print("================================================================================")
print("  👑 POLAR HUB | HAKI DEL CONQUISTADOR (HAOSHOKU INFUSION) ACTIVADO")
print("  ⚡ Presiona la tecla [H] para desatar el Estallido Supremo del Rey")
print("  ⚡ Rayos Rojos y Negros activos en armas y brazos (Estilo CDK / Yama)")
print("================================================================================")

return Engine
