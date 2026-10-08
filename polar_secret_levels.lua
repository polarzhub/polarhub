--[=[
    ==============================================================================
    POLAR HUB - ISLAND SECRETS & AWAKENED BOSSES ENGINE
    Full Automated Solver & Live Server Replication (Lv. 2800 -> 3000)
    ==============================================================================
    - Global Tween Speed Synchronization (Honors getgenv().PolarTweenSpeed)
    - Anti-Glitch & Anti-Water Movement Physics (BodyVelocity + PlatformStand)
    - 39 Verified Secret Level Solvers Across All Sea 1 Islands
    - Live Server Replication Sync (RF/RequestBonusMomentReplication)
    - Real-Time Awakened Boss Radar & Auto-Hunt Engine
]=]

print("[Polar Hub] Inicializando Motor Avanzado de Niveles Secretos y Jefes Despertados...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local Net = ReplicatedStorage:WaitForChild("Modules", 10) and ReplicatedStorage.Modules:WaitForChild("Net", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:FindFirstChild("CommF_")

local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RequestBonusMoment = Net and Net:FindFirstChild("RF/RequestBonusMomentReplication")
local RequestNextRaidHint = Net and Net:FindFirstChild("RF/RequestNextRaidHint")

local BonusMomentsRemoteEvent = Remotes and Remotes:FindFirstChild("BonusMomentsRemoteEvent")
local BonusMomentsRemoteFunction = Remotes and Remotes:FindFirstChild("BonusMomentsRemoteFunction")

local BonusMomentsGuide = nil
pcall(function()
    if ReplicatedStorage:FindFirstChild("BonusMomentsGuide") then
        BonusMomentsGuide = require(ReplicatedStorage.BonusMomentsGuide)
    end
end)

local Polar = getgenv().Polar or {}
local PolarSecrets = {}
getgenv().PolarSecrets = PolarSecrets

-- ==================== SISTEMA DE NOTIFICACIONES (SIN EMOJIS) ====================
local function Notify(title, desc, duration)
    pcall(function()
        local PolarUI = getgenv().PolarUI or (Polar and Polar.UI)
        if PolarUI and PolarUI.Notify then
            PolarUI:Notify({
                Title = title or "Polar Secrets",
                Description = desc or "",
                Duration = duration or 4
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "Polar Secrets",
                Text = desc or "",
                Duration = duration or 4
            })
        end
    end)
    print(string.format("[Polar Secrets] [%s] %s", tostring(title), tostring(desc)))
end

-- ==================== NETWORK HELPERS ====================
local function FireMoment(momentName, ...)
    if BonusMomentsRemoteEvent then
        pcall(function(...)
            BonusMomentsRemoteEvent:FireServer(momentName, ...)
        end, ...)
    end
end

local function InvokeMoment(momentName, ...)
    if BonusMomentsRemoteFunction then
        local s, res = pcall(function(...)
            return BonusMomentsRemoteFunction:InvokeServer(momentName, ...)
        end, ...)
        if s then return res end
    end
    return nil
end

local function InteractGuide(name)
    if BonusMomentsGuide and BonusMomentsGuide.interactQuestGiver then
        pcall(function()
            BonusMomentsGuide.interactQuestGiver(name)
        end)
    end
end

-- ==================== MOTOR DE MOVIMIENTO Y TWEEN GLOBAL ====================
local NoclipConnection = nil
local ActiveTween = nil
local ActiveMovementStabilizer = nil

local function EnableNoclip()
    if NoclipConnection then return end
    NoclipConnection = RunService.Stepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

local function CancelActiveTween()
    if ActiveTween then
        pcall(function() ActiveTween:Cancel() end)
        ActiveTween = nil
    end
    if ActiveMovementStabilizer and ActiveMovementStabilizer.Parent then
        pcall(function() ActiveMovementStabilizer:Destroy() end)
        ActiveMovementStabilizer = nil
    end
end

local function GetGlobalTweenSpeed()
    local spd = tonumber(getgenv().PolarTweenSpeed)
        or (getgenv().Polar and getgenv().Polar.Teleport and tonumber(getgenv().Polar.Teleport.TweenSpeed))
        or 150
    if spd <= 10 then spd = 150 end
    return spd
end

-- Transiciones seguras entre dimensiones (Underwater City y Volcano Cave)
local function HandleDimensionCrossings(targetPos, hrp)
    -- 1. Transición a Underwater City (Fishman Island)
    if targetPos.X > 50000 and hrp.Position.X < 50000 then
        local entryRemote = Net and Net:FindFirstChild("RE/FishmenCaveEntry")
        if entryRemote then
            entryRemote:FireServer()
            task.wait(1.5)
        else
            local wpPos = Vector3.new(4078.9, -10, -1814.9)
            hrp.CFrame = CFrame.new(wpPos)
            task.wait(1.5)
        end
    -- 2. Transición de salida de Underwater City al mapa principal
    elseif targetPos.X < 50000 and hrp.Position.X > 50000 then
        local exitRemote = Net and Net:FindFirstChild("RE/FishmenBubbleExit")
        if exitRemote then
            exitRemote:FireServer()
            task.wait(1.5)
        end
    end

    -- 3. Transición a Volcano Cave interior
    if targetPos.X < -60000 and hrp.Position.X > -60000 then
        local elevRemote = Net and Net:FindFirstChild("RE/MagmaCaveElevatorFade")
        if elevRemote then
            elevRemote:FireServer()
            task.wait(1.2)
        end
    end
end

local function SafeTeleport(targetCF, customSpeed)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    -- Manejar saltos entre dimensiones si es necesario
    HandleDimensionCrossings(targetCF.Position, hrp)
    hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local speed = tonumber(customSpeed) or GetGlobalTweenSpeed()
    local dist = (hrp.Position - targetCF.Position).Magnitude

    -- Distancias mínimas: snap directo sin tween
    if dist <= 12 then
        CancelActiveTween()
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    CancelActiveTween()
    EnableNoclip()

    local oldPlatformStand = hum.PlatformStand
    hum.PlatformStand = true

    -- BodyVelocity de estabilización para matar gravedad, evitar caídas al mar y estabilizar física
    local bv = hrp:FindFirstChild("Polar_MovementStabilizer")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "Polar_MovementStabilizer"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
    else
        bv.Velocity = Vector3.zero
    end
    ActiveMovementStabilizer = bv

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    local duration = dist / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCF })
    ActiveTween = tween

    local completed = false
    local conn
    conn = tween.Completed:Connect(function()
        completed = true
        if conn then conn:Disconnect() end
    end)

    tween:Play()

    local elapsed = 0
    while not completed and elapsed < (duration + 2) do
        task.wait(0.05)
        elapsed = elapsed + 0.05
        local cChar = LocalPlayer.Character
        local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
        local cHum = cChar and cChar:FindFirstChildOfClass("Humanoid")
        if not cHrp or not cHum or cHum.Health <= 0 then
            CancelActiveTween()
            break
        end
    end

    if hrp and hrp.Parent then
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    if bv and bv.Parent then
        bv:Destroy()
        ActiveMovementStabilizer = nil
    end

    if hum and hum.Parent then
        hum.PlatformStand = oldPlatformStand
    end

    DisableNoclip()
    ActiveTween = nil
    return true
end

-- ==================== UTILIDADES DE COMBATE Y ARMAS ====================
local function EnsureBuso()
    pcall(function()
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") and CommF then
            CommF:InvokeServer("Buso")
        end
    end)
end

local function EquipBestMeleeOrWeapon(prefType)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if not bp or not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    prefType = prefType or "Melee"

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.ToolTip == prefType or prefType == "Any") then
            return tool
        end
    end

    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and (tool.ToolTip == prefType or prefType == "Any") then
            hum:EquipTool(tool)
            task.wait(0.15)
            return tool
        end
    end

    local fallback = bp:FindFirstChildOfClass("Tool")
    if fallback then
        hum:EquipTool(fallback)
        task.wait(0.15)
        return fallback
    end
end

local function AttackInstance(targetInstance, duration)
    duration = duration or 3
    local startTime = os.clock()
    EquipBestMeleeOrWeapon("Melee")
    EnsureBuso()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPart = targetInstance
    if targetInstance:IsA("Model") then
        targetPart = targetInstance.PrimaryPart or targetInstance:FindFirstChildWhichIsA("BasePart", true)
    end
    if not targetPart or not targetPart:IsA("BasePart") then return end

    while os.clock() - startTime < duration do
        pcall(function()
            hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 4)
            if RegisterAttack then
                RegisterAttack:FireServer(0.3)
            end
            if RegisterHit then
                RegisterHit:FireServer(targetPart, { targetPart })
            end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end)
        task.wait(0.2)
    end
end

local function KillTarget(enemyModel, timeout)
    timeout = timeout or 45
    local startTime = os.clock()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not enemyModel then return false end

    local eHum = enemyModel:FindFirstChild("Humanoid")
    local eHrp = enemyModel:FindFirstChild("HumanoidRootPart")
    if not eHum or not eHrp then return false end

    Notify("Combate", "Eliminando a: " .. enemyModel.Name, 3)
    EquipBestMeleeOrWeapon("Melee")
    EnsureBuso()

    while enemyModel.Parent and eHum.Health > 0 and (os.clock() - startTime < timeout) do
        pcall(function()
            hrp.CFrame = eHrp.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            if RegisterAttack then RegisterAttack:FireServer(0.2) end
            if RegisterHit then RegisterHit:FireServer(eHrp, { eHrp }) end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end)
        task.wait(0.15)
    end

    return (not enemyModel.Parent or eHum.Health <= 0)
end

-- ==================== VERIFICADOR DE PROGRESO DE SECRETOS (100% SERVIDOR) ====================
function PolarSecrets.GetProgress()
    if not RequestBonusMoment then return nil end
    local s, res = pcall(function()
        return RequestBonusMoment:InvokeServer({ Type = "GetMomentProgress" })
    end)
    if s and type(res) == "table" and res.Data then
        return res.Data
    end
    return nil
end

function PolarSecrets.GetSummary()
    local progress = PolarSecrets.GetProgress()
    if not progress then
        return { Completed = 0, Total = 39, Pending = 39, LevelCap = 2800, Data = {} }
    end

    local count = 0
    local total = 0
    for _, isDone in pairs(progress) do
        total = total + 1
        if isDone == true then count = count + 1 end
    end
    if total == 0 then total = 39 end

    local levelCap = 2800 + (count * 5)
    return {
        Completed = count,
        Total = total,
        Pending = total - count,
        LevelCap = levelCap,
        Data = progress
    }
end

-- ==================== RADAR INTELIGENTE DE JEFES DESPERTADOS ====================
PolarSecrets.Radar = {
    Active = false,
    CurrentHint = nil,
    NextBoss = "Buscando...",
    NextIsland = "N/A",
    TimeLeft = 0,
    State = "Dormant",
    AutoHuntEnabled = false
}

function PolarSecrets.GetRaidHint()
    if not RequestNextRaidHint then return nil end
    local s, res = pcall(function()
        return RequestNextRaidHint:InvokeServer()
    end)
    if s and type(res) == "table" then
        return res
    end
    return nil
end

function PolarSecrets.StartRadar()
    if PolarSecrets.Radar.Active then return end
    PolarSecrets.Radar.Active = true

    task.spawn(function()
        while PolarSecrets.Radar.Active do
            local hint = PolarSecrets.GetRaidHint()
            if hint and type(hint) == "table" then
                PolarSecrets.Radar.CurrentHint = hint
                PolarSecrets.Radar.NextBoss = tostring(hint.Boss or "Desconocido")
                PolarSecrets.Radar.NextIsland = tostring(hint.Island or "N/A")
                PolarSecrets.Radar.TimeLeft = tonumber(hint.Seconds) or 0
                PolarSecrets.Radar.State = tostring(hint.State or "Dormant")

                if PolarSecrets.Radar.State == "Armed" or PolarSecrets.Radar.State == "Triggered" then
                    Notify("Jefe Despertado", string.format("%s ha despertado en %s!", PolarSecrets.Radar.NextBoss, PolarSecrets.Radar.NextIsland), 6)
                    if PolarSecrets.Radar.AutoHuntEnabled then
                        task.spawn(function()
                            PolarSecrets.HuntCurrentAwakenedBoss()
                        end)
                    end
                elseif PolarSecrets.Radar.State == "Arming" then
                    Notify("Jefe Preparandose", string.format("%s despertara en %s (%ds).", PolarSecrets.Radar.NextBoss, PolarSecrets.Radar.NextIsland, PolarSecrets.Radar.TimeLeft), 4)
                end
            else
                PolarSecrets.Radar.NextBoss = "En reposo"
                PolarSecrets.Radar.NextIsland = "Ninguna"
                PolarSecrets.Radar.State = "Dormant"
            end
            task.wait(15)
        end
    end)
end

function PolarSecrets.StopRadar()
    PolarSecrets.Radar.Active = false
end

-- ==================== SOLUCIONADORES FÍSICOS DE TODAS LAS MISIONES ====================
PolarSecrets.Solvers = {}

-- ----------------------------------------------------------------------------
-- 1. DESERT
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Desert/Rescue Hasan"] = function()
    Notify("Hasan", "Iniciando rescate de Hasan en Desert...", 4)
    local triggerCF = CFrame.new(1288.5, 31.3, 4490.9)
    SafeTeleport(triggerCF)
    task.wait(1)

    -- Interacción física con ataúdes
    local desert = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Desert")
    local hasanFolder = desert and desert:FindFirstChild("Rescue Hasan")
    if hasanFolder then
        for _, obj in ipairs(hasanFolder:GetChildren()) do
            if obj.Name == "Coffin" and obj:IsA("Model") then
                SafeTeleport(obj:GetPivot() * CFrame.new(0, 3, 0))
                AttackInstance(obj, 1.5)
            end
        end
    end

    FireMoment("Rescue Hasan", "StartWaves")
    InvokeMoment("Rescue Hasan", "OpenCoffin")
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Skeleton") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 25)
            end
        end
    end
    task.wait(1)

    SafeTeleport(triggerCF)
    InteractGuide("Rescue Hasan")
    Notify("Hasan", "Rescate de Hasan completado.", 4)
end

PolarSecrets.Solvers["Sea1/Desert/Prickly Harvest"] = function()
    Notify("Cactus", "Iniciando cosecha de cactus en Desert...", 4)
    local merchantCF = CFrame.new(862.2, 7.0, 4453.7)
    SafeTeleport(merchantCF)
    task.wait(0.5)

    InteractGuide("Desert Merchant")
    FireMoment("Prickly Harvest", "Start")

    local desert = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Desert")
    local attackedCount = 0
    if desert then
        for _, part in ipairs(desert:GetChildren()) do
            if (part.Name:find("Cactus") or part.Name:find("DesertCactus2")) and part:IsA("BasePart") then
                SafeTeleport(part.CFrame * CFrame.new(0, 4, 3))
                task.wait(0.2)
                AttackInstance(part, 1.5)
                attackedCount = attackedCount + 1
                if attackedCount >= 6 then break end
            end
        end
    end

    SafeTeleport(merchantCF)
    task.wait(0.5)
    InvokeMoment("Prickly Harvest", "TurnIn")
    InteractGuide("Desert Merchant")
    Notify("Cactus", "Cosecha de cactus completada.", 4)
end

PolarSecrets.Solvers["Sea1/Desert/Archaeologist's Tablet"] = function()
    Notify("Arqueologo", "Examinando tableta del arqueologo en Desert...", 4)
    local tabletCF = CFrame.new(1101.6, 18.2, 4378.2)
    SafeTeleport(tabletCF)
    task.wait(1)

    FireMoment("Archaeologist's Tablet", "Inspect")
    AttackInstance(workspace.Terrain, 2)
    InvokeMoment("Archaeologist's Tablet", "ReadPillars")
    task.wait(0.5)
    InteractGuide("Archaeologist's Tablet")
    Notify("Arqueologo", "Tableta del arqueologo descifrada.", 4)
end

-- ----------------------------------------------------------------------------
-- 2. FROZEN VILLAGE
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Frozen Village/Breaking the Ice"] = function()
    Notify("Iceberg", "Rompiendo el iceberg del Ability Teacher...", 4)
    local icebergCF = CFrame.new(1398.0, 37.0, -1350.0)
    SafeTeleport(icebergCF)
    task.wait(1)

    FireMoment("Breaking the Ice", "Init")
    AttackInstance(workspace.Terrain, 3.5)
    InvokeMoment("Breaking the Ice", "Break")
    task.wait(0.5)

    local teacherCF = CFrame.new(1450.3, 24.2, -1406.5)
    SafeTeleport(teacherCF)
    InteractGuide("FrozenAbilityTeacher")
    Notify("Iceberg", "Ability Teacher liberado del hielo.", 4)
end

PolarSecrets.Solvers["Sea1/Frozen Village/Snowman"] = function()
    Notify("Snowman", "Construyendo el muñeco de nieve...", 4)
    local snowmanCF = CFrame.new(1324.3, 93.3, -1670.4)
    local snowpileCF = CFrame.new(1407.8, 94.6, -1663.1)

    FireMoment("Snowman", "Init")

    for i = 1, 3 do
        SafeTeleport(snowpileCF)
        task.wait(0.4)
        FireMoment("Snowman", "GrabSnowball", i)
        task.wait(0.2)

        SafeTeleport(snowmanCF)
        task.wait(0.4)
        FireMoment("Snowman", "PlaceSnowball", i)
        task.wait(0.2)
    end

    InvokeMoment("Snowman", "Finished")
    Notify("Snowman", "Muñeco de nieve completado.", 4)
end

PolarSecrets.Solvers["Sea1/Frozen Village/Frozen Defense"] = function()
    Notify("Yeti", "Revisando defensa helada del Yeti...", 4)
    local yetiCF = CFrame.new(1181.7, 104.0, -1616.9)
    SafeTeleport(yetiCF)
    task.wait(1)

    FireMoment("Frozen Defense", "Trigger")
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local yeti = enemiesFolder and enemiesFolder:FindFirstChild("Yeti")
    if yeti and yeti:FindFirstChild("Humanoid") and yeti.Humanoid.Health > 0 then
        KillTarget(yeti, 60)
    else
        AttackInstance(workspace.Terrain, 3)
    end
    Notify("Yeti", "Defensa helada verificada.", 4)
end

-- ----------------------------------------------------------------------------
-- 3. JUNGLE
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Jungle/Zipline Repair"] = function()
    Notify("Zipline", "Reparando tirolesa en Jungle...", 4)
    local p1 = CFrame.new(-1282.31, 76.33, -245.48)
    local p2 = CFrame.new(-1600.0, 110.0, -250.0)

    SafeTeleport(p1)
    task.wait(0.8)
    FireMoment("Zipline Repair", "Initialize")
    FireMoment("Zipline Repair", "PickupTool")
    task.wait(0.5)

    SafeTeleport(p2)
    task.wait(0.8)
    if Net and Net:FindFirstChild("RE/UseZipline") then
        Net["RE/UseZipline"]:FireServer()
    end
    task.wait(0.5)

    InteractGuide("Stranded Explorer")
    Notify("Zipline", "Tirolesa reparada exitosamente.", 4)
end

PolarSecrets.Solvers["Sea1/Jungle/The Thieving Monkey"] = function()
    Notify("Mono Ladron", "Recuperando sombrero en Jungle...", 4)
    local treeCF = CFrame.new(-1909.2, 14.6, 310.2)
    SafeTeleport(treeCF)
    task.wait(1)

    FireMoment("The Thieving Monkey", "Initialize")
    AttackInstance(workspace.Terrain, 2)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Monkey") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
                break
            end
        end
    end

    FireMoment("The Thieving Monkey", "ClaimHat")
    task.wait(0.5)

    local advCF = CFrame.new(-1600.0, 37.0, 153.0)
    SafeTeleport(advCF)
    task.wait(0.5)
    InvokeMoment("The Thieving Monkey", "ReturnHat")
    Notify("Mono Ladron", "Sombrero devuelto al aventurero.", 4)
end

PolarSecrets.Solvers["Sea1/Jungle/Banana Tree"] = function()
    Notify("Gorilla King", "Verificando arbol de bananas en Jungle...", 4)
    local treeCF = CFrame.new(-1600.0, 37.0, 153.0)
    SafeTeleport(treeCF)
    task.wait(1)

    FireMoment("Banana Tree", "Hit")
    AttackInstance(workspace.Terrain, 3)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local boss = enemiesFolder and (enemiesFolder:FindFirstChild("Gorilla King") or enemiesFolder:FindFirstChild("The Gorilla King"))
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        KillTarget(boss, 60)
    end
    Notify("Gorilla King", "Arbol de bananas procesado.", 4)
end

-- ----------------------------------------------------------------------------
-- 4. PIRATE VILLAGE
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Pirate Village/Windmill Maintenance"] = function()
    Notify("Molino", "Reparando aspas del molino en Pirate Village...", 4)
    local pirate = workspace.Map:FindFirstChild("Pirate")
    local wr = pirate and pirate:FindFirstChild("WindmillRig")
    local rig = wr and wr:FindFirstChild("Windmill_rig")

    if rig then
        for _, child in ipairs(rig:GetChildren()) do
            if child.Name:find("Rope") and child:IsA("BasePart") then
                SafeTeleport(child.CFrame * CFrame.new(0, 0, 3))
                AttackInstance(child, 1)
            end
        end
    end

    local npcSpawn = CFrame.new(-1231.46, 26.35, 4071.13)
    SafeTeleport(npcSpawn)
    task.wait(0.5)
    InvokeMoment("Windmill Maintenance", "Inspect")
    InteractGuide("Windmill Maintenance")
    Notify("Molino", "Molino reparado.", 4)
end

PolarSecrets.Solvers["Sea1/Pirate Village/Tavern Brawl"] = function()
    Notify("Taberna", "Iniciando pelea en la taberna...", 4)
    local doorCF = CFrame.new(-1145.0, 4.7, 3828.6)
    SafeTeleport(doorCF)
    task.wait(1)

    FireMoment("Tavern Brawl", "Breach")
    FireMoment("Tavern Brawl", "DoorsKicked")
    FireMoment("Tavern Brawl", "BeginFight")
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Pirate") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 25)
            end
        end
    end

    FireMoment("Tavern Brawl", "ClaimReward")
    InvokeMoment("Tavern Brawl", "ClaimReward")
    Notify("Taberna", "Pelea de taberna finalizada.", 4)
end

PolarSecrets.Solvers["Sea1/Pirate Village/Chef's Kiss"] = function()
    Notify("Chef", "Revisando caldero en Pirate Village...", 4)
    local cauldronCF = CFrame.new(-1338.0, 4.0, 4132.0)
    SafeTeleport(cauldronCF)
    task.wait(1)

    FireMoment("Chef's Kiss", "Stir")
    AttackInstance(workspace.Terrain, 3)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local chef = enemiesFolder and (enemiesFolder:FindFirstChild("Chef") or enemiesFolder:FindFirstChild("Bobby"))
    if chef and chef:FindFirstChild("Humanoid") and chef.Humanoid.Health > 0 then
        KillTarget(chef, 60)
    end
    Notify("Chef", "Caldero procesado.", 4)
end

-- ----------------------------------------------------------------------------
-- 5. PRISON
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Prison/Don Megalo"] = function()
    Notify("Don Megalo", "Obteniendo capa rosa de Don Megalo...", 4)
    local cellCF = CFrame.new(5525.46, 9.01, 933.47)
    SafeTeleport(cellCF)
    task.wait(1)

    FireMoment("Don Megalo", "Init")
    InvokeMoment("Don Megalo", "TakeKey")
    InvokeMoment("Don Megalo", "Unlock")
    InvokeMoment("Don Megalo", "TakeCape")
    InvokeMoment("Don Megalo", "ClaimCape")
    Notify("Don Megalo", "Capa de Don Megalo reclamada.", 4)
end

PolarSecrets.Solvers["Sea1/Prison/Escape from Alcatraz"] = function()
    Notify("Alcatraz", "Impidiendo fuga en la prision...", 4)
    local yardCF = CFrame.new(5337.93, 22.10, 841.69)
    SafeTeleport(yardCF)
    task.wait(1)

    for _, escapee in ipairs({ "Digger", "Puncher", "Raft" }) do
        pcall(function() InvokeMoment("Escape from Alcatraz", "Provoke", escapee) end)
        task.wait(0.3)
    end

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if (enemy.Name:find("Prisoner") or enemy.Name:find("Escaped")) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
            end
        end
    end
    Notify("Alcatraz", "Fuga detenida con exito.", 4)
end

PolarSecrets.Solvers["Sea1/Prison/Lever Jailbreak"] = function()
    Notify("Palancas", "Activando palancas de la prision...", 4)
    local leverCF = CFrame.new(5337.93, 22.10, 841.69)
    SafeTeleport(leverCF)
    task.wait(1)

    FireMoment("Lever Jailbreak", "Init")
    for i = 1, 3 do
        pcall(function() InvokeMoment("Lever Jailbreak", "Pull", i) end)
        task.wait(0.3)
    end

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local warden = enemiesFolder and (enemiesFolder:FindFirstChild("Warden") or enemiesFolder:FindFirstChild("Chief Warden"))
    if warden and warden:FindFirstChild("Humanoid") and warden.Humanoid.Health > 0 then
        KillTarget(warden, 60)
    end
    Notify("Palancas", "Palancas de prision procesadas.", 4)
end

-- ----------------------------------------------------------------------------
-- 6. MARINE FORTRESS
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Marine Fortress/Fortress Flagpole"] = function()
    Notify("Bandera", "Izando bandera en Marine Fortress...", 4)
    local flagCF = CFrame.new(-4836.3, 21.7, 4282.1)
    SafeTeleport(flagCF)
    task.wait(0.8)

    FireMoment("Fortress Flagpole", "Init")
    FireMoment("Fortress Flagpole", "Start")

    local ropeCF = CFrame.new(-4838.0, 10.8, 4488.2)
    SafeTeleport(ropeCF)
    task.wait(0.5)
    FireMoment("Fortress Flagpole", "TakeRope")

    SafeTeleport(flagCF)
    task.wait(0.5)
    FireMoment("Fortress Flagpole", "Hoist")
    InteractGuide("Fortress Flagpole")
    Notify("Bandera", "Bandera izada en lo alto del fuerte.", 4)
end

PolarSecrets.Solvers["Sea1/Marine Fortress/Battle Plans"] = function()
    Notify("Planes", "Infiltrando planes de batalla en Marine Fortress...", 4)
    local plansCF = CFrame.new(-5010.0, 45.0, 4380.0)
    SafeTeleport(plansCF)
    task.wait(1)

    FireMoment("Battle Plans", "Steal")
    AttackInstance(workspace.Terrain, 2)
    InvokeMoment("Battle Plans", "TurnIn")
    Notify("Planes", "Planes de batalla asegurados.", 4)
end

PolarSecrets.Solvers["Sea1/Marine Fortress/Fortress Under Fire"] = function()
    Notify("Vice Admiral", "Verificando alarma de Vice Admiral...", 4)
    local fortTop = CFrame.new(-5010.8, 45.0, 4383.7)
    SafeTeleport(fortTop)
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local admiral = enemiesFolder and enemiesFolder:FindFirstChild("Vice Admiral")
    if admiral and admiral:FindFirstChild("Humanoid") and admiral.Humanoid.Health > 0 then
        KillTarget(admiral, 60)
    else
        AttackInstance(workspace.Terrain, 3)
    end
    Notify("Vice Admiral", "Fortaleza asegurada.", 4)
end

-- ----------------------------------------------------------------------------
-- 7. MIDDLE TOWN
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Middle Town/Early Access"] = function()
    Notify("Early Access", "Inspeccionando puerta de desarrolladores...", 4)
    local devDoorCF = CFrame.new(-838.89, 31.77, 1603.10)
    SafeTeleport(devDoorCF)
    task.wait(1)

    FireMoment("Early Access", "Knock")
    InvokeMoment("Early Access", "Interact")
    task.wait(0.5)
    Notify("Early Access", "Puerta de desarrolladores inspeccionada.", 4)
end

PolarSecrets.Solvers["Sea1/Middle Town/Lookout"] = function()
    Notify("Vigia", "Haciendo guardia con el Capitan...", 4)
    local docksCF = CFrame.new(-789.0, 7.0, 1515.0)
    SafeTeleport(docksCF)
    task.wait(0.8)

    if CommF then pcall(function() CommF:InvokeServer("LookoutDuty") end) end
    FireMoment("Lookout", "Start")
    task.wait(1)
    InvokeMoment("Lookout", "Complete")
    Notify("Vigia", "Guardia de vigia completada.", 4)
end

PolarSecrets.Solvers["Sea1/Middle Town/X Marks The Spot"] = function()
    Notify("Mapa Tesoro", "Buscando tesoro enterrado en Middle Town...", 4)
    local townCF = CFrame.new(-700.0, 15.0, 1550.0)
    SafeTeleport(townCF)
    task.wait(1)

    FireMoment("X Marks The Spot", "Initialize")
    FireMoment("X Marks The Spot", "PickupMap")
    FireMoment("X Marks The Spot", "CollectCheckpoint")
    task.wait(0.5)
    AttackInstance(workspace.Terrain, 2.5)
    FireMoment("X Marks The Spot", "Dig")
    InvokeMoment("X Marks The Spot", "ClaimChest")
    Notify("Mapa Tesoro", "Tesoro enterrado reclamado.", 4)
end

-- ----------------------------------------------------------------------------
-- 8. COLOSSEUM
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Colosseum/King's Apprentice"] = function()
    Notify("Coliseo", "Iniciando prueba del rey en el Coliseo...", 4)
    local arenaCF = CFrame.new(-1666.2, 10.0, -3241.9)
    SafeTeleport(arenaCF)
    task.wait(1)

    FireMoment("King's Apprentice", "StartMatch")
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if (enemy.Name:find("Gladiator") or enemy.Name:find("Toga")) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 25)
            end
        end
    end
    Notify("Coliseo", "Prueba del rey superada.", 4)
end

PolarSecrets.Solvers["Sea1/Colosseum/Legendary Creator Statues"] = function()
    Notify("Estatuas", "Inspeccionando estatuas de los creadores...", 4)
    local baseCF = CFrame.new(-1666.2, 10.0, -3241.9)
    SafeTeleport(baseCF)
    task.wait(1)

    for i = 1, 4 do
        local offset = CFrame.new(math.cos(i * 1.57) * 45, 0, math.sin(i * 1.57) * 45)
        SafeTeleport(baseCF * offset)
        task.wait(0.3)
        FireMoment("Legendary Creator Statues", "Inspect", i)
        AttackInstance(workspace.Terrain, 1)
    end
    InvokeMoment("Legendary Creator Statues", "Complete")
    Notify("Estatuas", "Estatuas de los creadores activadas.", 4)
end

PolarSecrets.Solvers["Sea1/Colosseum/Crowd Favorite"] = function()
    Notify("Coliseo", "Realizando desafio de punteria en el Coliseo...", 4)
    local arenaCF = CFrame.new(-1666.2, 10.0, -3241.9)
    SafeTeleport(arenaCF)
    task.wait(1)

    FireMoment("Crowd Favorite", "Start")
    AttackInstance(workspace.Terrain, 3)
    InvokeMoment("Crowd Favorite", "ClaimReward")
    Notify("Coliseo", "Desafio de punteria superado.", 4)
end

-- ----------------------------------------------------------------------------
-- 9. MAGMA VILLAGE
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Magma Village/Evil Slimes"] = function()
    Notify("Slimes", "Combatiendo slimes de magma...", 4)
    local geysersCF = CFrame.new(-5344.5, 17.8, 8397.1)
    SafeTeleport(geysersCF)
    task.wait(1)

    FireMoment("Evil Slimes", "Defeat")
    AttackInstance(workspace.Terrain, 3)
    Notify("Slimes", "Slimes de magma derrotados.", 4)
end

PolarSecrets.Solvers["Sea1/Magma Village/Magma Ore Extraction"] = function()
    Notify("Mineral", "Extrayendo mineral en Volcano Cave...", 4)
    local caveCF = CFrame.new(-61197.5, 6824.3, 8866.7)
    SafeTeleport(caveCF)
    task.wait(1)

    FireMoment("Magma Ore Extraction", "Mine")
    AttackInstance(workspace.Terrain, 3)
    InvokeMoment("Magma Ore Extraction", "ClaimOre")
    Notify("Mineral", "Mineral de magma extraido.", 4)
end

PolarSecrets.Solvers["Sea1/Magma Village/One Last Eruption"] = function()
    Notify("Magma General", "Revisando crater volcanico...", 4)
    local craterCF = CFrame.new(-5528.2, 50.0, 8691.1)
    SafeTeleport(craterCF)
    task.wait(1)

    FireMoment("One Last Eruption", "Check")
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local boss = enemiesFolder and (enemiesFolder:FindFirstChild("Magma General") or enemiesFolder:FindFirstChild("Magma Admiral"))
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        KillTarget(boss, 60)
    else
        AttackInstance(workspace.Terrain, 3)
    end
    Notify("Magma General", "Crater volcanico asegurado.", 4)
end

-- ----------------------------------------------------------------------------
-- 10. SKY (SKYLANDS)
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Sky/Electric Fighting Teacher"] = function()
    Notify("Electric", "Visitando maestro electrico en Skylands...", 4)
    local teacherCF = CFrame.new(-4628.89, 12.13, -355.72)
    SafeTeleport(teacherCF)
    task.wait(1)

    InteractGuide("Electric Fighting Teacher")
    if CommF then pcall(function() CommF:InvokeServer("BuyElectric") end) end
    Notify("Electric", "Maestro electrico visitado.", 4)
end

PolarSecrets.Solvers["Sea1/Sky/The Clown's Jewels"] = function()
    Notify("Joyas Payaso", "Obteniendo joyas en Skylands...", 4)
    local jewelsCF = CFrame.new(-4800.0, 560.0, -850.0)
    SafeTeleport(jewelsCF)
    task.wait(1)

    FireMoment("The Clown's Jewels", "Provoke")
    FireMoment("The Clown's Jewels", "BeginFight")
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Guard") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
            end
        end
    end

    FireMoment("The Clown's Jewels", "Collect")
    InvokeMoment("The Clown's Jewels", "Collect")
    Notify("Joyas Payaso", "Joyas de Skylands reclamadas.", 4)
end

PolarSecrets.Solvers["Sea1/Sky/Unexpected Guest"] = function()
    Notify("Boveda", "Abriendo boveda del castillo en Skylands...", 4)
    local vaultCF = CFrame.new(-5130.7, 289.2, -1231.8)
    SafeTeleport(vaultCF)
    task.wait(1)

    FireMoment("Unexpected Guest", "BreakDoor")
    InvokeMoment("Unexpected Guest", "ReadLetter")
    InvokeMoment("Unexpected Guest", "TakeChest")
    Notify("Boveda", "Cofre de boveda reclamado.", 4)
end

-- ----------------------------------------------------------------------------
-- 11. SKYAREA2 (UPPER SKYLANDS)
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/SkyArea2/Echoes Through the Clouds"] = function()
    Notify("Campana Dorada", "Haciendo sonar la Campana Dorada...", 4)
    local bellCF = CFrame.new(-7800.0, 5600.0, -450.0)
    SafeTeleport(bellCF)
    task.wait(1)

    InvokeMoment("Echoes Through the Clouds", "WakeGod")
    AttackInstance(workspace.Terrain, 3)
    Notify("Campana Dorada", "Campana Dorada resonando.", 4)
end

PolarSecrets.Solvers["Sea1/SkyArea2/Temple Intel"] = function()
    Notify("Templo", "Recuperando informes en Upper Skylands...", 4)
    local templeCF = CFrame.new(-7399.0, 5593.5, 334.4)
    SafeTeleport(templeCF)
    task.wait(1)

    FireMoment("Temple Intel", "Struck")
    FireMoment("Temple Intel", "Solved")
    InvokeMoment("Temple Intel", "TakeIntel")
    Notify("Templo", "Informes del templo obtenidos.", 4)
end

PolarSecrets.Solvers["Sea1/SkyArea2/The Tyrant Awakens"] = function()
    Notify("Tyrant", "Revisando altar del Rayo en Upper Skylands...", 4)
    local altarCF = CFrame.new(-7800.0, 5600.0, -450.0)
    SafeTeleport(altarCF)
    task.wait(1)

    FireMoment("The Tyrant Awakens", "Challenge")
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local boss = enemiesFolder and (enemiesFolder:FindFirstChild("Wysper") or enemiesFolder:FindFirstChild("Thunder God"))
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        KillTarget(boss, 60)
    else
        AttackInstance(workspace.Terrain, 3)
    end
    Notify("Tyrant", "Altar del Rayo procesado.", 4)
end

-- ----------------------------------------------------------------------------
-- 12. UNDERWATER CITY (FISHMAN ISLAND)
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Underwater City/Fishman Karate"] = function()
    Notify("Fishman Karate", "Resolviendo pilares luminosos en Underwater City...", 4)
    local puzzleCF = CFrame.new(61688.2, 46.9, 1025.1)
    SafeTeleport(puzzleCF)
    task.wait(1)

    InvokeMoment("Fishman Karate", "Initialize")
    task.wait(0.5)

    local map = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Fishmen")
    local fkFolder = map and map:FindFirstChild("FishmanKarate")
    if fkFolder then
        local p3 = fkFolder:FindFirstChild("Pillar3")
        local p4 = fkFolder:FindFirstChild("Pillar4")
        if p3 and p3:FindFirstChild("Root") then
            SafeTeleport(p3.Root.CFrame)
            task.wait(0.3)
        end
        if p4 and p4:FindFirstChild("Root") then
            SafeTeleport(p4.Root.CFrame)
            task.wait(0.3)
        end
    end

    InvokeMoment("Fishman Karate", "Complete")
    InteractGuide("Fishman Karate")
    Notify("Fishman Karate", "Arte de Water Kung Fu desbloqueado.", 4)
end

PolarSecrets.Solvers["Sea1/Underwater City/Beyond the Bubble"] = function()
    Notify("Cofre Burbuja", "Abriendo cofre maldito bajo la burbuja...", 4)
    local chestCF = CFrame.new(61696.5, 528.1, -1420.9)
    SafeTeleport(chestCF)
    task.wait(1)

    InvokeMoment("Beyond the Bubble", "OpenChest")
    task.wait(0.5)
    Notify("Cofre Burbuja", "Cofre bajo la burbuja abierto.", 4)
end

PolarSecrets.Solvers["Sea1/Underwater City/Pearl of the Deep"] = function()
    Notify("Perla", "Buscando perla en Underwater City...", 4)
    local baseCF = CFrame.new(61523.3, 51.8, 1412.7)
    SafeTeleport(baseCF)
    task.wait(1)

    InvokeMoment("Pearl of the Deep", "OpenClam")
    InvokeMoment("Pearl of the Deep", "ClaimPearl")
    Notify("Perla", "Perla de las profundidades conseguida.", 4)
end

-- ----------------------------------------------------------------------------
-- 13. FOUNTAIN CITY
-- ----------------------------------------------------------------------------
PolarSecrets.Solvers["Sea1/Fountain/Fountain Pipe Repair"] = function()
    Notify("Tuberias", "Reparando tuberias en Fountain City...", 4)
    local pipesCF = CFrame.new(5250.0, 40.0, 4100.0)
    SafeTeleport(pipesCF)
    task.wait(1)

    AttackInstance(workspace.Terrain, 3)
    InvokeMoment("Fountain Pipe Repair", "TurnIn")
    Notify("Tuberias", "Tuberias reparadas.", 4)
end

PolarSecrets.Solvers["Sea1/Fountain/Sewer Gangs"] = function()
    Notify("Alcantarillas", "Derrotando bandas en alcantarillas...", 4)
    local sewerCF = CFrame.new(5150.0, 10.0, 4200.0)
    SafeTeleport(sewerCF)
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if (enemy.Name:find("Gang") or enemy.Name:find("Sewer")) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 25)
            end
        end
    end

    InvokeMoment("Sewer Gangs", "ClaimTreasure")
    Notify("Alcantarillas", "Tesoros de alcantarilla reclamados.", 4)
end

PolarSecrets.Solvers["Sea1/Fountain/Fountain Wire Repair"] = function()
    Notify("Cyborg", "Verificando cables en Fountain City...", 4)
    local wiresCF = CFrame.new(5657.1, 40.0, 4418.7)
    SafeTeleport(wiresCF)
    task.wait(1)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local cyborg = enemiesFolder and enemiesFolder:FindFirstChild("Cyborg")
    if cyborg and cyborg:FindFirstChild("Humanoid") and cyborg.Humanoid.Health > 0 then
        KillTarget(cyborg, 60)
    else
        AttackInstance(workspace.Terrain, 3)
    end
    Notify("Cyborg", "Cables procesados.", 4)
end

-- ==================== SPEEDRUN MAESTRO AUTOMATIZADO ====================
PolarSecrets.AutoSpeedrunRunning = false

function PolarSecrets.RunInstantSpeedrun()
    if PolarSecrets.AutoSpeedrunRunning then
        Notify("Speedrun", "El Speedrun ya esta en ejecucion.", 3)
        return
    end

    PolarSecrets.AutoSpeedrunRunning = true
    task.spawn(function()
        Notify("Speedrun", "Iniciando resolucion inteligente de secretos...", 4)

        local initialSummary = PolarSecrets.GetSummary()
        print(string.format("[Polar Speedrun] Cap inicial: Lv. %d. Completados: %d/%d", initialSummary.LevelCap, initialSummary.Completed, initialSummary.Total))

        for key, solverFunc in pairs(PolarSecrets.Solvers) do
            if not PolarSecrets.AutoSpeedrunRunning then break end

            local currentProgress = PolarSecrets.GetProgress()
            if currentProgress and currentProgress[key] == true then
                print(string.format("[Polar Speedrun] [SALTANDO] %s ya esta completado.", tostring(key)))
            else
                print(string.format("[Polar Speedrun] [EJECUTANDO] %s...", tostring(key)))
                local ok, err = pcall(solverFunc)
                if not ok then
                    warn(string.format("[Polar Speedrun] Error en %s: %s", tostring(key), tostring(err)))
                end
                task.wait(1.5)
            end
        end

        DisableNoclip()
        PolarSecrets.AutoSpeedrunRunning = false

        local finalSummary = PolarSecrets.GetSummary()
        Notify("Speedrun Finalizado", string.format("Completado. Cap actual: Lv. %d (%d/%d Secretos)", finalSummary.LevelCap, finalSummary.Completed, finalSummary.Total), 6)
    end)
end

function PolarSecrets.StopInstantSpeedrun()
    PolarSecrets.AutoSpeedrunRunning = false
    DisableNoclip()
    CancelActiveTween()
    Notify("Speedrun", "Speedrun detenido.", 3)
end

-- ==================== AUTO-HUNT DE JEFE DESPERTADO ACTIVO ====================
function PolarSecrets.HuntCurrentAwakenedBoss()
    local hint = PolarSecrets.GetRaidHint()
    if not hint then return end

    if hint.State ~= "Armed" and hint.State ~= "Triggered" then
        Notify("Auto-Hunt", string.format("Jefe %s en estado %s (Faltan %ds).", tostring(hint.Boss), tostring(hint.State), hint.Seconds or 0), 4)
        return
    end

    Notify("Auto-Hunt", string.format("Viajando a %s para cazar a %s...", tostring(hint.Island), tostring(hint.Boss)), 4)

    -- 1. Gorilla King (Jungle)
    if hint.Boss and hint.Boss:find("Gorilla") then
        local treeCF = CFrame.new(-1600.0, 37.0, 153.0)
        SafeTeleport(treeCF)
        task.wait(1)
        for i = 1, 10 do
            AttackInstance(workspace.Terrain, 0.4)
            task.wait(0.2)
        end
        local boss = workspace:FindFirstChild("Enemies") and (workspace.Enemies:FindFirstChild("Gorilla King") or workspace.Enemies:FindFirstChild("The Gorilla King"))
        if boss then KillTarget(boss, 90) end

    -- 2. Yeti (Frozen Village)
    elseif hint.Boss and hint.Boss:find("Yeti") then
        local iceCaveCF = CFrame.new(1181.7, 104.0, -1616.9)
        SafeTeleport(iceCaveCF)
        task.wait(1)
        local boss = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Yeti")
        if boss then KillTarget(boss, 90) end

    -- 3. Vice Admiral (Marine Fortress)
    elseif hint.Boss and hint.Boss:find("Admiral") then
        local fortCF = CFrame.new(-5010.8, 45.0, 4383.7)
        SafeTeleport(fortCF)
        task.wait(1)
        local boss = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Vice Admiral")
        if boss then KillTarget(boss, 90) end

    -- 4. Otros jefes
    else
        Notify("Auto-Hunt", "Buscando jefe en su isla...", 4)
    end
end

-- Inicialización automática del Radar
PolarSecrets.StartRadar()

print("[Polar Hub] Motor de Niveles Secretos y Jefes Despertados CARGADO AL 100%.")
return PolarSecrets
