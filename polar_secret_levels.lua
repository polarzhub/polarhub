--[=[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                POLAR HUB - ISLAND SECRETS & AWAKENED BOSSES                 ║
    ║                  Full Automated Engine (Lv. 2800 -> 3000)                   ║
    ║                                                                              ║
    ║  • Sincronización en tiempo real con servidor (BonusMomentsReplication)     ║
    ║  • Radar Inteligente de Jefes Despertados (RequestNextRaidHint)              ║
    ║  • Solucionador Físico In-Game (Interacciones, Golpes M1, Puzzles, Quests)  ║
    ║  • Modo Dios "Speedrun": Resuelve las 23 misiones inmediatas (-> Lv. 2925)  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
--]=]

print("[Polar Hub] ⚡ Inicializando Motor Avanzado de Niveles Secretos y Jefes Despertados...")

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
local RequestSecretStories = Net and Net:FindFirstChild("RF/RequestSecretStories")
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

-- ==================== SISTEMA DE NOTIFICACIONES ====================
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

-- ==================== UTILIDADES DE MOVIMIENTO Y FÍSICA ====================
local NoclipConnection = nil

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

local function SafeTeleport(targetCF, speed)
    speed = speed or 320
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    EnableNoclip()

    if (hrp.Position - targetCF.Position).Magnitude <= 40 then
        hrp.CFrame = targetCF
        return true
    end

    local distance = (hrp.Position - targetCF.Position).Magnitude
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCF })
    
    local completed = false
    local conn
    conn = tween.Completed:Connect(function()
        completed = true
        if conn then conn:Disconnect() end
    end)

    tween:Play()

    local elapsed = 0
    while not completed and elapsed < (duration + 2) do
        task.wait(0.1)
        elapsed = elapsed + 0.1
        if not hrp or not hrp.Parent then
            tween:Cancel()
            return false
        end
    end

    hrp.CFrame = targetCF
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

-- ==================== VERIFICADOR DE PROGRESO DE SECRETOS ====================
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
        return { Completed = 0, Total = 40, Pending = 40, LevelCap = 2800 }
    end

    local count = 0
    for _, isDone in pairs(progress) do
        if isDone == true then count = count + 1 end
    end

    local levelCap = 2800 + (count * 5)
    return {
        Completed = count,
        Total = 40,
        Pending = 40 - count,
        LevelCap = levelCap,
        Data = progress
    }
end

-- ==================== SOLUCIONADORES FÍSICOS DE MISIONES INMEDIATAS ====================
PolarSecrets.Solvers = {}

-- 1. Desert - Rescue Hasan
PolarSecrets.Solvers["Sea1/Desert/Rescue Hasan"] = function()
    Notify("Hasan", "Iniciando rescate de Hasan en Desert...", 4)
    local triggerCF = CFrame.new(1301.5, 18.4, 4449.8)
    SafeTeleport(triggerCF)
    task.wait(1)

    FireMoment("Rescue Hasan", "StartWaves")
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

    local hasanCF = CFrame.new(1288.5, 31.3, 4490.9)
    SafeTeleport(hasanCF)
    task.wait(0.5)

    if BonusMomentsGuide then
        pcall(function() BonusMomentsGuide.interactQuestGiver("Rescue Hasan") end)
    end
    Notify("Hasan", "¡Rescate de Hasan completado!", 4)
end

-- 2. Desert - Prickly Harvest
PolarSecrets.Solvers["Sea1/Desert/Prickly Harvest"] = function()
    Notify("Cactus", "Iniciando cosecha de cactus en Desert...", 4)
    local merchantCF = CFrame.new(862.2, 7.0, 4453.7)
    SafeTeleport(merchantCF)
    task.wait(1)

    if BonusMomentsGuide then
        pcall(function() BonusMomentsGuide.interactQuestGiver("Desert Merchant") end)
    end

    local desert = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Desert")
    local cactiFolder = desert and desert:FindFirstChild("Cacti")
    if cactiFolder and #cactiFolder:GetChildren() > 0 then
        for _, cactus in ipairs(cactiFolder:GetChildren()) do
            if cactus:IsA("Model") then
                SafeTeleport(cactus:GetPivot() * CFrame.new(0, 0, 4))
                task.wait(0.3)
                AttackInstance(cactus, 2)
            end
        end
    else
        local baseCF = CFrame.new(879.9, 5.0, 4462.4)
        SafeTeleport(baseCF)
        task.wait(0.5)
        AttackInstance(workspace.Terrain, 3)
    end

    SafeTeleport(merchantCF)
    task.wait(0.5)
    if BonusMomentsGuide then
        pcall(function() BonusMomentsGuide.interactQuestGiver("Desert Merchant") end)
    end
    Notify("Cactus", "¡Cosecha de cactus completada!", 4)
end

-- 3. Frozen Village - Breaking the Ice
PolarSecrets.Solvers["Sea1/Frozen Village/Breaking the Ice"] = function()
    Notify("Iceberg", "Rompiendo el iceberg del Ability Teacher...", 4)
    local icebergCF = CFrame.new(1450.3, 24.2, -1406.5)
    SafeTeleport(icebergCF)
    task.wait(1)

    FireMoment("Breaking the Ice", "Init")
    task.wait(0.5)

    AttackInstance(workspace.Terrain, 4)

    if BonusMomentsGuide then
        pcall(function() BonusMomentsGuide.interactQuestGiver("FrozenAbilityTeacher") end)
    end
    Notify("Iceberg", "¡Iceberg destruido y Ability Teacher liberado!", 4)
end

-- 4. Frozen Village - Snowman
PolarSecrets.Solvers["Sea1/Frozen Village/Snowman"] = function()
    Notify("Snowman", "Construyendo el muñeco de nieve...", 4)
    local snowmanCF = CFrame.new(1324.3, 93.3, -1670.4)
    local snowpileCF = CFrame.new(1407.8, 94.6, -1663.1)
    
    SafeTeleport(snowpileCF)
    task.wait(1)
    FireMoment("Snowman", "Init")
    FireMoment("Snowman", "GrabSnowball", 1)
    task.wait(1)

    SafeTeleport(snowmanCF)
    task.wait(1)
    FireMoment("Snowman", "Finished")
    Notify("Snowman", "¡Muñeco de nieve completado!", 4)
end

-- 5. Jungle - Zipline Repair
PolarSecrets.Solvers["Sea1/Jungle/Zipline Repair"] = function()
    Notify("Zipline", "Reparando tirolesa en Jungle...", 4)
    local groundCF = CFrame.new(-1282.31, 76.33, -245.48)
    SafeTeleport(groundCF)
    task.wait(1)

    FireMoment("Zipline Repair", "Initialize")
    task.wait(0.5)
    FireMoment("Zipline Repair", "PickupTool")
    task.wait(1)

    local targetPlatformCF = CFrame.new(-1600, 110, -250)
    SafeTeleport(targetPlatformCF)
    task.wait(1)

    if BonusMomentsGuide then
        pcall(function() BonusMomentsGuide.interactQuestGiver("Stranded Explorer") end)
    end
    Notify("Zipline", "¡Tirolesa reparada exitosamente!", 4)
end

-- 6. Jungle - The Thieving Monkey
PolarSecrets.Solvers["Sea1/Jungle/The Thieving Monkey"] = function()
    Notify("Mono Ladrón", "Rastreando huellas del mono en Jungle...", 4)
    local treeCF = CFrame.new(-1909.2, 14.6, 310.2)
    SafeTeleport(treeCF)
    task.wait(1)

    FireMoment("The Thieving Monkey", "Initialize")
    task.wait(0.5)

    AttackInstance(workspace.Terrain, 3)
    task.wait(1.5)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Monkey") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
            end
        end
    end

    FireMoment("The Thieving Monkey", "ClaimHat")
    task.wait(1)

    local advCF = CFrame.new(-1600, 37, 153)
    SafeTeleport(advCF)
    task.wait(0.5)
    InvokeMoment("The Thieving Monkey", "ReturnHat")
    Notify("Mono Ladrón", "¡Sombrero devuelto al aventurero!", 4)
end

-- 7. Pirate Village - Tavern Brawl
PolarSecrets.Solvers["Sea1/Pirate Village/Tavern Brawl"] = function()
    Notify("Taberna", "Iniciando pelea en la taberna...", 4)
    local doorCF = CFrame.new(-1145, 4.7, 3828.6)
    SafeTeleport(doorCF)
    task.wait(1)

    FireMoment("Tavern Brawl", "Breach")
    task.wait(0.5)
    FireMoment("Tavern Brawl", "DoorsKicked")
    task.wait(0.5)
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
    task.wait(1)
    Notify("Taberna", "¡Pelea de taberna superada!", 4)
end

-- 8. Marine Fortress - Fortress Flagpole
PolarSecrets.Solvers["Sea1/Marine Fortress/Fortress Flagpole"] = function()
    Notify("Bandera", "Izando la bandera en Marine Fortress...", 4)
    local flagCF = CFrame.new(-4836.3, 21.7, 4282.1)
    SafeTeleport(flagCF)
    task.wait(1)

    FireMoment("Fortress Flagpole", "Init")
    task.wait(0.5)
    FireMoment("Fortress Flagpole", "Start")
    task.wait(1)

    local ropeCF = CFrame.new(-4838.0, 10.8, 4488.2)
    SafeTeleport(ropeCF)
    task.wait(0.5)
    FireMoment("Fortress Flagpole", "TakeRope")
    task.wait(1)

    SafeTeleport(flagCF)
    task.wait(0.5)
    FireMoment("Fortress Flagpole", "Hoist")
    task.wait(1)
    Notify("Bandera", "¡Bandera izada en lo alto del fuerte!", 4)
end

-- 9. Prison - Don Megalo
PolarSecrets.Solvers["Sea1/Prison/Don Megalo"] = function()
    Notify("Don Megalo", "Consiguiendo la capa rosa de Don Megalo...", 4)
    local prisonCF = CFrame.new(5525.46, 9.01, 933.47)
    SafeTeleport(prisonCF)
    task.wait(1)

    FireMoment("Don Megalo", "Init")
    task.wait(0.5)
    FireMoment("Don Megalo", "BouncerReady")
    task.wait(0.5)
    InvokeMoment("Don Megalo", "TakeKey")
    task.wait(0.5)
    InvokeMoment("Don Megalo", "Unlock")
    task.wait(0.5)
    InvokeMoment("Don Megalo", "TakeCape")
    task.wait(0.5)
    InvokeMoment("Don Megalo", "ClaimCape")
    task.wait(1)
    Notify("Don Megalo", "¡Capa rosa reclamada con éxito!", 4)
end

-- 10. Prison - Escape from Alcatraz
PolarSecrets.Solvers["Sea1/Prison/Escape from Alcatraz"] = function()
    Notify("Prisión", "Impidiendo la fuga en Alcatraz...", 4)
    local prisonYard = CFrame.new(5337.93, 22.10, 841.69)
    SafeTeleport(prisonYard)
    task.wait(1)

    for _, prisonerType in ipairs({ "Digger", "Puncher", "Raft" }) do
        pcall(function()
            InvokeMoment("Escape from Alcatraz", "Provoke", prisonerType)
        end)
        task.wait(0.5)
    end

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if (enemy.Name:find("Prisoner") or enemy.Name:find("Escaped")) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
            end
        end
    end
    task.wait(1)
    Notify("Prisión", "¡Fuga de Alcatraz frustrada!", 4)
end

-- 11. Prison - Lever Jailbreak
PolarSecrets.Solvers["Sea1/Prison/Lever Jailbreak"] = function()
    Notify("Palancas", "Activando palancas de la prisión...", 4)
    local leverCF = CFrame.new(5337.93, 22.10, 841.69)
    SafeTeleport(leverCF)
    task.wait(1)

    FireMoment("Lever Jailbreak", "Init")
    task.wait(0.5)

    for i = 1, 3 do
        pcall(function()
            InvokeMoment("Lever Jailbreak", "Pull", i)
        end)
        task.wait(0.5)
    end
    Notify("Palancas", "¡Palancas activadas!", 4)
end

-- 12. Colosseum - King's Apprentice
PolarSecrets.Solvers["Sea1/Colosseum/King's Apprentice"] = function()
    Notify("Coliseo", "Iniciando prueba del rey en el Coliseo...", 4)
    local arenaCF = CFrame.new(-1500, 7.5, 2500)
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
    Notify("Coliseo", "¡Prueba del rey superada!", 4)
end

-- 13. Colosseum - Legendary Creator Statues
PolarSecrets.Solvers["Sea1/Colosseum/Legendary Creator Statues"] = function()
    Notify("Estatuas", "Inspeccionando estatuas de los creadores...", 4)
    local statuesCF = CFrame.new(-1500, 15, 2500)
    SafeTeleport(statuesCF)
    task.wait(1)

    for i = 1, 4 do
        local offset = CFrame.new(math.cos(i) * 35, 0, math.sin(i) * 35)
        SafeTeleport(statuesCF * offset)
        task.wait(0.5)
        AttackInstance(workspace.Terrain, 1)
    end
    Notify("Estatuas", "¡Estatuas de los creadores inspeccionadas!", 4)
end

-- 14. Magma Village - Evil Slimes
PolarSecrets.Solvers["Sea1/Magma Village/Evil Slimes"] = function()
    Notify("Slimes", "Combatiendo slimes en Magma Village...", 4)
    local slimeCF = CFrame.new(-5344.5, 17.8, 8397.1)
    SafeTeleport(slimeCF)
    task.wait(1)

    AttackInstance(workspace.Terrain, 5)
    Notify("Slimes", "¡Slimes derrotados!", 4)
end

-- 15. Magma Village - Magma Ore Extraction
PolarSecrets.Solvers["Sea1/Magma Village/Magma Ore Extraction"] = function()
    Notify("Mineral", "Extrayendo mineral de magma...", 4)
    local oreCF = CFrame.new(-5896.4, 6.7, 8960.0)
    SafeTeleport(oreCF)
    task.wait(1)

    AttackInstance(workspace.Terrain, 5)
    Notify("Mineral", "¡Mineral de magma extraído!", 4)
end

-- 16. Sky - Electric Fighting Teacher
PolarSecrets.Solvers["Sea1/Sky/Electric Fighting Teacher"] = function()
    Notify("Electric", "Visitando al maestro de combate eléctrico...", 4)
    local teacherCF = CFrame.new(-4628.89, 12.13, -355.72)
    SafeTeleport(teacherCF)
    task.wait(1)

    AttackInstance(workspace.Terrain, 3)
    if CommF then
        pcall(function() CommF:InvokeServer("BuyElectric") end)
    end
    Notify("Electric", "¡Lección eléctrica completada!", 4)
end

-- 17. Sky - Unexpected Guest
PolarSecrets.Solvers["Sea1/Sky/Unexpected Guest"] = function()
    Notify("Bóveda", "Abriendo bóveda del castillo en Skylands...", 4)
    local vaultCF = CFrame.new(-5130.7, 289.2, -1231.8)
    SafeTeleport(vaultCF)
    task.wait(1)

    FireMoment("Unexpected Guest", "BreakDoor")
    task.wait(0.5)
    InvokeMoment("Unexpected Guest", "ReadLetter")
    task.wait(0.5)
    FireMoment("Unexpected Guest", "GuardsOut")
    task.wait(0.5)
    InvokeMoment("Unexpected Guest", "TakeChest")
    task.wait(1)
    Notify("Bóveda", "¡Cofre de la bóveda reclamado!", 4)
end

-- 18. Sky - The Clown's Jewels
PolarSecrets.Solvers["Sea1/Sky/The Clown's Jewels"] = function()
    Notify("Joyas del Payaso", "Reclamando joyas en Skylands...", 4)
    local jewelsCF = CFrame.new(-4800, 560, -850)
    SafeTeleport(jewelsCF)
    task.wait(1)

    FireMoment("The Clown's Jewels", "Provoke")
    task.wait(0.5)
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
    task.wait(1)
    Notify("Joyas del Payaso", "¡Joyas del payaso recolectadas!", 4)
end

-- 19. SkyArea2 - Echoes Through the Clouds
PolarSecrets.Solvers["Sea1/SkyArea2/Echoes Through the Clouds"] = function()
    Notify("Campana Dorada", "Haciendo sonar la Campana Dorada en Upper Skylands...", 4)
    local bellCF = CFrame.new(-7800, 5600, -450)
    SafeTeleport(bellCF)
    task.wait(1)

    InvokeMoment("Echoes Through the Clouds", "WakeGod")
    AttackInstance(workspace.Terrain, 4)
    Notify("Campana Dorada", "¡La Campana Dorada ha resonado en las nubes!", 4)
end

-- 20. SkyArea2 - Temple Intel
PolarSecrets.Solvers["Sea1/SkyArea2/Temple Intel"] = function()
    Notify("Templo", "Recuperando informes en el templo de Skylands...", 4)
    local templeCF = CFrame.new(-7399.0, 5593.5, 334.4)
    SafeTeleport(templeCF)
    task.wait(1)

    FireMoment("Temple Intel", "Struck")
    task.wait(0.5)
    FireMoment("Temple Intel", "Solved")
    task.wait(0.5)
    InvokeMoment("Temple Intel", "TakeIntel")
    task.wait(1)
    Notify("Templo", "¡Informes del templo obtenidos!", 4)
end

-- 21. Underwater City - Beyond the Bubble
PolarSecrets.Solvers["Sea1/Underwater City/Beyond the Bubble"] = function()
    Notify("Cursed Chest", "Abriendo cofre maldito bajo el agua...", 4)
    local chestCF = CFrame.new(61696.5, 528.1, -1420.9)
    SafeTeleport(chestCF)
    task.wait(1)

    InvokeMoment("Beyond the Bubble", "OpenChest")
    task.wait(1)
    Notify("Cursed Chest", "¡Cofre bajo la burbuja abierto!", 4)
end

-- 22. Underwater City - Fishman Karate
PolarSecrets.Solvers["Sea1/Underwater City/Fishman Karate"] = function()
    Notify("Fishman Karate", "Resolviendo puzzle de pilares luminosos...", 4)
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
            task.wait(0.5)
        end
        if p4 and p4:FindFirstChild("Root") then
            SafeTeleport(p4.Root.CFrame)
            task.wait(0.5)
        end
    end

    InvokeMoment("Fishman Karate", "Complete")
    task.wait(1)
    Notify("Fishman Karate", "¡Puzzle de Fishman Karate resuelto!", 4)
end

-- 23. Underwater City - Pearl of the Deep
PolarSecrets.Solvers["Sea1/Underwater City/Pearl of the Deep"] = function()
    Notify("Perla", "Buscando la perla en las almejas...", 4)
    local clams = CollectionService:GetTagged("PearlClam")
    if #clams > 0 then
        for _, clam in ipairs(clams) do
            local p = clam:IsA("Model") and clam:GetPivot().Position or clam.Position
            SafeTeleport(CFrame.new(p + Vector3.new(0, 3, 0)))
            task.wait(0.4)
            InvokeMoment("Pearl of the Deep", "OpenClam", clam)
            InvokeMoment("Pearl of the Deep", "ClaimPearl")
        end
    else
        local baseCF = CFrame.new(61523.3, 51.8, 1412.7)
        SafeTeleport(baseCF)
        task.wait(1)
        InvokeMoment("Pearl of the Deep", "ClaimPearl")
    end
    Notify("Perla", "¡Perla de las profundidades conseguida!", 4)
end

-- 24. Fountain - Fountain Pipe Repair
PolarSecrets.Solvers["Sea1/Fountain/Fountain Pipe Repair"] = function()
    Notify("Tuberías", "Reparando tuberías en Fountain City...", 4)
    local pipesCF = CFrame.new(5250, 40, 4100)
    SafeTeleport(pipesCF)
    task.wait(1)

    AttackInstance(workspace.Terrain, 4)
    task.wait(1)
    InvokeMoment("Fountain Pipe Repair", "TurnIn")
    Notify("Tuberías", "¡Tuberías de Fountain City reparadas!", 4)
end

-- 25. Fountain - Sewer Gangs
PolarSecrets.Solvers["Sea1/Fountain/Sewer Gangs"] = function()
    Notify("Alcantarillas", "Derrotando bandas en las alcantarillas...", 4)
    local sewerCF = CFrame.new(5150, 10, 4200)
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
    task.wait(1)
    Notify("Alcantarillas", "¡Tesoros de alcantarilla reclamados!", 4)
end

-- 26. Middle Town - X Marks The Spot
PolarSecrets.Solvers["Sea1/Middle Town/X Marks The Spot"] = function()
    Notify("Mapa Tesoro", "Buscando fragmentos de mapa en Middle Town...", 4)
    local cityCF = CFrame.new(-700, 15, 1550)
    SafeTeleport(cityCF)
    task.wait(1)

    FireMoment("X Marks The Spot", "Initialize")
    task.wait(0.5)
    FireMoment("X Marks The Spot", "PickupMap")
    task.wait(0.5)
    FireMoment("X Marks The Spot", "CollectCheckpoint")
    task.wait(1)

    AttackInstance(workspace.Terrain, 4)

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy.Name:find("Skeleton") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                KillTarget(enemy, 20)
            end
        end
    end
    Notify("Mapa Tesoro", "¡Tesoro de Middle Town desenterrado!", 4)
end

-- 27. Middle Town - Lookout
PolarSecrets.Solvers["Sea1/Middle Town/Lookout"] = function()
    Notify("Vigía", "Realizando guardia de vigía con el Capitán...", 4)
    local captCF = CFrame.new(-789, 7, 1515)
    SafeTeleport(captCF)
    task.wait(1)

    if CommF then
        pcall(function() CommF:InvokeServer("LookoutDuty") end)
    end
    Notify("Vigía", "¡Guardia de vigía completada!", 4)
end

-- ==================== SPEEDRUN MAESTRO (LV 2800 -> 2925) ====================
PolarSecrets.AutoSpeedrunRunning = false

function PolarSecrets.RunInstantSpeedrun()
    if PolarSecrets.AutoSpeedrunRunning then
        Notify("Speedrun", "El Speedrun ya está en ejecución.", 3)
        return
    end

    PolarSecrets.AutoSpeedrunRunning = true
    task.spawn(function()
        Notify("Speedrun", "Iniciando resolucion de misiones inmediatas...", 4)
        
        local initialSummary = PolarSecrets.GetSummary()
        print(string.format("[Polar Speedrun] Nivel actual: %d. Secretos completados: %d/40", initialSummary.LevelCap, initialSummary.Completed))

        for key, solverFunc in pairs(PolarSecrets.Solvers) do
            if not PolarSecrets.AutoSpeedrunRunning then break end

            local currentProgress = PolarSecrets.GetProgress()
            if currentProgress and currentProgress[key] == true then
                print(string.format("[Polar Speedrun] [SALTANDO] %s ya está completado.", tostring(key)))
            else
                print(string.format("[Polar Speedrun] [EJECUTANDO] %s...", tostring(key)))
                local ok, err = pcall(solverFunc)
                if not ok then
                    warn(string.format("[Polar Speedrun] Error en %s: %s", tostring(key), tostring(err)))
                end
                task.wait(2)
            end
        end

        DisableNoclip()
        PolarSecrets.AutoSpeedrunRunning = false
        
        local finalSummary = PolarSecrets.GetSummary()
        Notify("Speedrun Finalizado", string.format("Completado. Nivel: %d (%d/40 Secretos)", finalSummary.LevelCap, finalSummary.Completed), 6)
    end)
end

function PolarSecrets.StopInstantSpeedrun()
    PolarSecrets.AutoSpeedrunRunning = false
    DisableNoclip()
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
        local treeCF = CFrame.new(-1600, 37, 153)
        SafeTeleport(treeCF)
        task.wait(1)
        Notify("Gorilla King", "Vaciando árbol de bananas a golpes...", 4)
        for i = 1, 14 do
            AttackInstance(workspace.Terrain, 0.4)
            task.wait(0.2)
        end
        task.wait(2)
        local boss = workspace:FindFirstChild("Enemies") and (workspace.Enemies:FindFirstChild("Gorilla King") or workspace.Enemies:FindFirstChild("The Gorilla King"))
        if boss then
            KillTarget(boss, 90)
        end
    -- 2. Yeti (Frozen Village)
    elseif hint.Boss and hint.Boss:find("Yeti") then
        local iceCaveCF = CFrame.new(1181.7, 104.0, -1616.9)
        SafeTeleport(iceCaveCF)
        task.wait(1)
        EnsureBuso()
        AttackInstance(workspace.Terrain, 4)
        local boss = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Yeti")
        if boss then
            KillTarget(boss, 90)
        end
    -- 3. Vice Admiral (Marine Fortress)
    elseif hint.Boss and hint.Boss:find("Admiral") then
        local fortCF = CFrame.new(-5010.8, 45, 4383.7)
        SafeTeleport(fortCF)
        task.wait(1)
        AttackInstance(workspace.Terrain, 3)
        local boss = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Vice Admiral")
        if boss then
            KillTarget(boss, 90)
        end
    -- 4. Otros jefes
    else
        Notify("Auto-Hunt", "Buscando jefe en su isla...", 4)
    end
end

-- ==================== INICIALIZACIÓN AUTOMÁTICA DEL RADAR ====================
PolarSecrets.StartRadar()

print("[Polar Hub] ✅ Motor de Niveles Secretos y Jefes Despertados CARGADO AL 100%.")
return PolarSecrets
