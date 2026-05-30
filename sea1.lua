-- ==================== POLAR HUB | SEA 1 ====================
print("Cargando datos del Sea 1...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)

local Window = getgenv().PolarWindow
local TabFarm = getgenv().PolarTabFarm
local TabStatus = getgenv().PolarTabStatus
local TabQuest = getgenv().PolarTabQuest
local BuyItem = getgenv().PolarBuyItem
local BypassTeleport = getgenv().PolarBypassTeleport
local IsEnemyAlive = getgenv().PolarIsEnemyAlive

-- Funciones y Variables requeridas globalmente (Cerebro AutoFarm)
getgenv().PolarAutoMobLeaderEnabled = false
getgenv().PolarAutoSaberExpertEnabled = false
getgenv().PolarFastAttackEnabled = getgenv().PolarFastAttackEnabled or false
getgenv().PolarCurrentBotState = getgenv().PolarCurrentBotState or "IDLE"

-- ==================== BASE DE DATOS DE MISIONES (SEA 1 INTELIGENTE) ====================
getgenv().PolarLevelQuests = {
    {lvl = 1, q = "BanditQuest1", ql = 1, name = "Bandit", giver = "Bandit Quest Giver", island = "Town"},
    {lvl = 10, q = "JungleQuest", ql = 1, name = "Monkey", giver = "Adventurer", island = "Jungle"},
    {lvl = 15, q = "JungleQuest", ql = 2, name = "Gorilla", giver = "Adventurer", island = "Jungle"},
    {lvl = 20, q = "JungleQuest", ql = 3, name = "Gorilla King", giver = "Adventurer", island = "Jungle", isBoss = true},
    {lvl = 30, q = "BuggyQuest1", ql = 1, name = "Pirate", giver = "Pirate Adventurer", island = "Pirate"},
    {lvl = 40, q = "BuggyQuest1", ql = 2, name = "Brute", giver = "Pirate Adventurer", island = "Pirate"},
    {lvl = 55, q = "BuggyQuest1", ql = 3, name = "Bobby", giver = "Pirate Adventurer", island = "Pirate", isBoss = true},
    {lvl = 60, q = "DesertQuest", ql = 1, name = "Desert Bandit", giver = "Desert Adventurer", island = "Desert"},
    {lvl = 75, q = "DesertQuest", ql = 2, name = "Desert Officer", giver = "Desert Adventurer", island = "Desert"},
    {lvl = 90, q = "SnowQuest", ql = 1, name = "Snow Bandit", giver = "Villager", island = "Snow"},
    {lvl = 100, q = "SnowQuest", ql = 2, name = "Snowman", giver = "Villager", island = "Snow"},
    {lvl = 105, q = "SnowQuest", ql = 3, name = "Yeti", giver = "Villager", island = "Snow", isBoss = true},
    {lvl = 120, q = "MarineQuest2", ql = 1, name = "Chief Petty Officer", giver = "Marine", island = "Marine"},
    {lvl = 130, q = "MarineQuest2", ql = 2, name = "Vice Admiral", giver = "Marine", island = "Marine", isBoss = true},
    {lvl = 150, q = "SkyQuest", ql = 1, name = "Sky Bandit", giver = "Sky Adventurer", island = "Sky"},
    {lvl = 175, q = "SkyQuest", ql = 2, name = "Dark Master", giver = "Sky Adventurer", island = "Sky"},
    {lvl = 190, q = "PrisonerQuest", ql = 1, name = "Prisoner", giver = "Jail Keeper", island = "Prison"},
    {lvl = 210, q = "PrisonerQuest", ql = 2, name = "Dangerous Prisoner", giver = "Jail Keeper", island = "Prison"},
    {lvl = 220, q = "ImpelQuest", ql = 1, name = "Warden", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 230, q = "ImpelQuest", ql = 2, name = "Chief Warden", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 240, q = "ImpelQuest", ql = 3, name = "Swan", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 250, q = "ColosseumQuest", ql = 1, name = "Toga Warrior", giver = "Colosseum Quest Giver", island = "Colosseum"},
    {lvl = 275, q = "ColosseumQuest", ql = 2, name = "Gladiator", giver = "Colosseum Quest Giver", island = "Colosseum"},
    {lvl = 300, q = "MagmaQuest", ql = 1, name = "Military Soldier", giver = "The Mayor", island = "Magma"},
    {lvl = 325, q = "MagmaQuest", ql = 2, name = "Military Spy", giver = "The Mayor", island = "Magma"},
    {lvl = 375, q = "FishmanQuest", ql = 1, name = "Fishman Warrior", giver = "Neptune", island = "Fishman"},
    {lvl = 400, q = "FishmanQuest", ql = 2, name = "Fishman Commando", giver = "Neptune", island = "Fishman"},
    {lvl = 425, q = "FishmanQuest", ql = 3, name = "Fishman Lord", giver = "Neptune", island = "Fishman", isBoss = true},
    {lvl = 450, q = "SkyExp1Quest", ql = 1, name = "God's Guard", giver = "Mole", island = "Sky"},
    {lvl = 475, q = "SkyExp1Quest", ql = 2, name = "Shanda", giver = "Mole", island = "Sky"},
    {lvl = 500, q = "SkyExp1Quest", ql = 3, name = "Wysper", giver = "Mole", island = "Sky", isBoss = true},
    {lvl = 525, q = "SkyExp2Quest", ql = 1, name = "Royal Squad", giver = "Sky Quest Giver 2", island = "Upper Sky"},
    {lvl = 550, q = "SkyExp2Quest", ql = 2, name = "Royal Soldier", giver = "Sky Quest Giver 2", island = "Upper Sky"},
    {lvl = 575, q = "SkyExp2Quest", ql = 3, name = "Thunder God", giver = "Sky Quest Giver 2", island = "Upper Sky", isBoss = true},
    {lvl = 625, q = "FountainQuest", ql = 1, name = "Galley Pirate", giver = "Freezeburg Quest Giver", island = "Fountain"},
    {lvl = 650, q = "FountainQuest", ql = 2, name = "Galley Captain", giver = "Freezeburg Quest Giver", island = "Fountain"},
    {lvl = 675, q = "FountainQuest", ql = 3, name = "Cyborg", giver = "Freezeburg Quest Giver", island = "Fountain", isBoss = true}
}



-- ==================== BASE DE DATOS DE JEFES (SEA 1) ====================
getgenv().PolarBosses = {
    {name = "Gorilla King", q = "JungleQuest", ql = 3, giver = "Adventurer", island = "Jungle", lvl = 20},
    {name = "Bobby", q = "BuggyQuest1", ql = 3, giver = "Pirate Adventurer", island = "Pirate", lvl = 55},
    {name = "Yeti", q = "SnowQuest", ql = 3, giver = "Villager", island = "Snow", lvl = 105},
    {name = "Mob Leader", q = nil, ql = nil, giver = nil, island = "Pirate", lvl = 120},
    {name = "Vice Admiral", q = "MarineQuest2", ql = 2, giver = "Marine", island = "Marine", lvl = 130},
    {name = "Warden", q = "ImpelQuest", ql = 1, giver = "Head Jailer", island = "Prison", lvl = 220},
    {name = "Chief Warden", q = "ImpelQuest", ql = 2, giver = "Head Jailer", island = "Prison", lvl = 230},
    {name = "Swan", q = "ImpelQuest", ql = 3, giver = "Head Jailer", island = "Prison", lvl = 240},
    {name = "Magma Admiral", q = "MagmaQuest", ql = 3, giver = "The Mayor", island = "Magma", lvl = 350},
    {name = "Fishman Lord", q = "FishmanQuest", ql = 3, giver = "Neptune", island = "Fishman", lvl = 425},
    {name = "Wysper", q = "SkyExp1Quest", ql = 3, giver = "Sky Adventurer", island = "Sky", lvl = 500},
    {name = "Thunder God", q = "SkyExp2Quest", ql = 3, giver = "Sky Adventurer", island = "Sky", lvl = 575},
    {name = "Cyborg", q = "FountainQuest", ql = 3, giver = "Fountain Quest Giver", island = "Fountain", lvl = 675},
    {name = "Saber Expert", q = nil, ql = nil, giver = nil, island = "Jungle", lvl = 200},
    {name = "The Saw", q = nil, ql = nil, giver = nil, island = "Town", lvl = 100},
    {name = "Greybeard", q = nil, ql = nil, giver = nil, island = "Marine", lvl = 750}
}



local AutoSecondSeaRunning = false
local function AutoSecondSea()
    if AutoSecondSeaRunning then return end
    
    local data = LocalPlayer:FindFirstChild("Data")
    local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
    if lvl < 700 then
        warn("❌ Error Polar Hub: Necesitas Nivel 700 para acceder al Second Sea.")
        return
    end

    local function GetNPCCFrame(name)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == name then
                if obj:IsA("Model") then
                    if obj.PrimaryPart then return obj.PrimaryPart.CFrame end
                    if obj:FindFirstChild("Head") then return obj.Head.CFrame end
                    if obj:FindFirstChild("HumanoidRootPart") then return obj.HumanoidRootPart.CFrame end
                    if obj:FindFirstChild("Torso") then return obj.Torso.CFrame end
                    pcall(function() return obj:GetBoundingBox() end)
                elseif obj:IsA("BasePart") then
                    return obj.CFrame
                end
            end
        end
        return nil
    end

    AutoSecondSeaRunning = true
    task.spawn(function()
        warn("Polar Hub [V19]: Paso 1 - Hack de Red (DressrosaQuestProgress)")
        local detectiveCFrame = GetNPCCFrame("Military Detective") or CFrame.new(4849, 5, 718)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCFrame.Position).Magnitude > 20 and AutoSecondSeaRunning do
            BypassTeleport(detectiveCFrame * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCFrame * CFrame.new(0, 0, 3)
        task.wait(1)
        
        warn("Polar Hub [V19]: Ejecutando CommF_ Secreto...")
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective") end)
        
        warn("Polar Hub: Verificando mochila por la Llave...")
        local key = nil
        for i=1, 30 do
            key = LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Character:FindFirstChild("Key")
            if key then
                warn("Polar Hub: ¡Llave obtenida exitosamente!")
                break
            end
            task.wait(0.5)
        end
        
        warn("Polar Hub: Paso 2 - Cueva Helada (Y=42.25)")
        local caveTop = CFrame.new(1344.55, 200, -1327.89)
        local doorStand = CFrame.new(1344.55, 42.25, -1327.89)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - caveTop.Position).Magnitude > 50 and AutoSecondSeaRunning do
            BypassTeleport(caveTop)
            task.wait(0.1)
        end
        
        LocalPlayer.Character.HumanoidRootPart.CFrame = doorStand
        task.wait(1)
        
        if key and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:EquipTool(key)
            task.wait(1)
            local realDoor = workspace.Map:FindFirstChild("Ice") and workspace.Map.Ice:FindFirstChild("Door")
            if realDoor and firetouchinterest and key:FindFirstChild("Handle") then
                pcall(function() firetouchinterest(key.Handle, realDoor, 0) end)
                task.wait(0.1)
                pcall(function()
                    if key and key:FindFirstChild("Handle") then
                        firetouchinterest(key.Handle, realDoor, 1)
                    end
                end)
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = doorStand * CFrame.new(0, 0, -5)
        end
        task.wait(1)
        
        warn("Polar Hub: Paso 3 - Asesinato del Ice Admiral (AutoFarm Nativo V19)")
        -- Robamos el control del AutoFarm del propio Polar Hub
        SelectedWeaponType = "Melee"
        getgenv().PolarSelectedBossToFarm = "Ice Admiral"
        AutoFarmBossEnabled = true
        getgenv().PolarFastAttackEnabled = true
        
        while AutoSecondSeaRunning do
            local enemy = workspace.Enemies:FindFirstChild("Ice Admiral") or workspace.Characters:FindFirstChild("Ice Admiral")
            if not enemy or (enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health <= 0) then
                -- Doble verificacion por si el boss aun no ha spawneado (tiempo de respawn)
                if not enemy then
                    task.wait(2)
                    enemy = workspace.Enemies:FindFirstChild("Ice Admiral") or workspace.Characters:FindFirstChild("Ice Admiral")
                    if not enemy then
                        break -- ¡Confirmado muerto o no existe!
                    end
                else
                    break
                end
            end
            task.wait(1)
        end
        
        -- Devolvemos el control apagando el AutoFarm
        AutoFarmBossEnabled = false
        getgenv().PolarFastAttackEnabled = false
        task.wait(2)

        warn("Polar Hub: Paso 4 - Validacion Servidor")
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCFrame.Position).Magnitude > 20 and AutoSecondSeaRunning do
            BypassTeleport(detectiveCFrame * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCFrame * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective") end)
        task.wait(2)
        
        warn("Polar Hub: Paso 5 - Viaje Final (TravelDressrosa)")
        local capCFrame = GetNPCCFrame("Experienced Captain") or CFrame.new(-789, 7, 1515)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - capCFrame.Position).Magnitude > 20 and AutoSecondSeaRunning do
            BypassTeleport(capCFrame * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = capCFrame * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa") end)
        
        AutoSecondSeaRunning = false
        warn("Polar Hub [V19]: Mision Auto Second Sea Finalizada.")
    end)
end

local function FullAutoSaber()
    if AutoSaberRunning then return end
    AutoSaberRunning = true

    task.spawn(function()
        local playerData = LocalPlayer:FindFirstChild("Data")
        local playerLevel = playerData and playerData:FindFirstChild("Level")
        if not playerLevel or playerLevel.Value < 200 then
            warn("❌ Polar Hub [Error Inicial]: Necesitas Nivel 200+ para el Saber Puzzle o Datos no cargados.")
            AutoSaberRunning = false
            return
        end

        -- Desactivar interferencias globales
        AutoFarmEnabled = false
        AutoFarmBossEnabled = false
        AutoFarmAllBossesEnabled = false
        AutoFarmNearestEnabled = false
        print("✅ Polar Hub: Iniciando Auto Saber Puzzle (V7.2 Extreme)...")

        local function Notify(text)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "👑 Polar Hub", Text = text, Duration = 5})
            end)
            print("Polar Hub: " .. text)
        end

        -- ==================== V7.2 SAFE ACCESS UTILS ====================
        local function SafeGetMapFolder(folderName)
            local map = workspace:FindFirstChild("Map")
            if not map then return nil end
            return map:FindFirstChild(folderName)
        end

        local function GetHRP()
            local char = LocalPlayer.Character
            return char and char:FindFirstChild("HumanoidRootPart")
        end

        local function HasItem(toolName)
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp and bp:FindFirstChild(toolName) then return true end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(toolName) then return true end
            return false
        end

        local function EquipToolByName(toolName)
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            if not bp or not char then return false end
            local tool = bp:FindFirstChild(toolName) or char:FindFirstChild(toolName)
            if tool and tool.Parent == bp then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:EquipTool(tool) return true end
            end
            return (tool and tool.Parent == char)
        end

        local function ResolvePart(obj)
            if typeof(obj) == "CFrame" then return obj end
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj.CFrame end
            if obj:IsA("Model") then
                return (obj.PrimaryPart and obj.PrimaryPart.CFrame)
                    or (obj:FindFirstChild("Handle", true) and obj:FindFirstChild("Handle", true).CFrame)
                    or (obj:FindFirstChildWhichIsA("BasePart", true) and obj:FindFirstChildWhichIsA("BasePart", true).CFrame)
            end
            return nil
        end

        local function SafeFly(targetCF, forceTweenMode)
            if not targetCF then return end
            local hrp = GetHRP()
            if not hrp then return end
            local dist = (hrp.Position - targetCF.Position).Magnitude
            
            local function RawTween(cf)
                local tHrp = GetHRP()
                if not tHrp then return end
                local tDist = (tHrp.Position - cf.Position).Magnitude
                local tInfo = TweenInfo.new(tDist / 300, Enum.EasingStyle.Linear)
                local tween = game:GetService("TweenService"):Create(tHrp, tInfo, {CFrame = cf})
                
                local bp = Instance.new("BodyVelocity", tHrp)
                bp.Velocity = Vector3.new(0, 0, 0)
                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local nclConn = game:GetService("RunService").Stepped:Connect(function()
                    local lchar = LocalPlayer.Character
                    if lchar then
                        for _, v in ipairs(lchar:GetChildren()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end)
                
                tween:Play()
                tween.Completed:Wait()
                bp:Destroy()
                nclConn:Disconnect()
            end

            local pos = hrp.Position
            if pos.Y < 15 and pos.X > 1000 and pos.Z > 4000 then 
                RawTween(CFrame.new(1113, 5, 4350)) 
                RawTween(CFrame.new(1094, 20, 4344)) 
            elseif pos.Y < 50 and pos.X > 1300 and pos.Z < -1200 then 
                RawTween(CFrame.new(1370, 87, -1320)) 
                RawTween(CFrame.new(1384, 90, -1300)) 
            end

            hrp = GetHRP()
            if not hrp then return end
            dist = (hrp.Position - targetCF.Position).Magnitude

            if dist < 50 and not forceTweenMode then
                local char = LocalPlayer.Character
                if char then char:PivotTo(targetCF) end
            else
                if dist > 500 then
                    local upCF = CFrame.new(hrp.Position.X, 500, hrp.Position.Z)
                    RawTween(upCF)
                    local acrossCF = CFrame.new(targetCF.Position.X, 500, targetCF.Position.Z)
                    RawTween(acrossCF)
                end
                RawTween(targetCF)
            end
        end

        local function ForceTouchV7(obj, fallbackCF)
            local targetCF = ResolvePart(obj) or fallbackCF
            if not targetCF then return false end
            
            SafeFly(targetCF, false)
            
            local timeout = 0
            while AutoSaberRunning and GetHRP() and timeout < 50 do
                local hrp = GetHRP()
                local d = (hrp.Position - targetCF.Position).Magnitude
                if d < 15 then break end
                if timeout > 0 and timeout % 10 == 0 then
                    local char = LocalPlayer.Character
                    if char then char:PivotTo(targetCF) end
                end
                task.wait(0.2)
                timeout = timeout + 1
            end

            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = targetCF
                local isPart = (typeof(obj) ~= "CFrame" and obj and obj:IsA("BasePart"))
                if isPart and firetouchinterest then
                    task.wait(0.2)
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, obj, 1)
                end
                return true
            end
            return false
        end

        local function TalkToNPCV7(npcName, fallbackCF, remoteId)
            -- FIX #8: Buscar NPCs en workspace:GetDescendants() para encontrarlos incluso fuera de NPCs folder
            local function FindNPCByName(name)
                local npcs = workspace:FindFirstChild("NPCs")
                if npcs then
                    local found = npcs:FindFirstChild(name)
                    if found and found:FindFirstChild("HumanoidRootPart") then return found end
                end
                -- Fallback: buscar en todos los descendientes del workspace
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == name and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        return obj
                    end
                end
                return nil
            end
            
            local npc = FindNPCByName(npcName)
            if not npc then
                ForceTouchV7(nil, fallbackCF)
                task.wait(2) -- Esperar a que el NPC cargue
                npc = FindNPCByName(npcName)
                if not npc then
                    warn("Polar Hub [Error TalkToNPCV7]: NPC '" .. npcName .. "' no se encontró en workspace")
                    return false
                end
            end
            
            ForceTouchV7(npc.HumanoidRootPart, fallbackCF)
            task.wait(1)
            for i = 1, 3 do
                task.spawn(function() pcall(function() CommF:InvokeServer("ProQuestProgress", remoteId) end) end)
                if npc then
                    for _, v in ipairs(npc:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            task.spawn(function() pcall(function() fireproximityprompt(v) end) end)
                        end
                    end
                end
                task.wait(0.5)
            end
            return true
        end

        local function DetectPhase()
            -- PRIORIDAD ABSOLUTA: Si la memoria dice que superamos la fase 5+,
            -- confiar en ella. Después de entregar la copa al Sick Man, los ítems
            -- desaparecen del inventario y el desierto no renderiza a distancia.
            -- Sin esta barrera, el bot regresa infinitamente a la Fase 3.
            if HasItem("Saber") then MaxSaberPhaseReached = 9; return 9 end
            if MaxSaberPhaseReached >= 5 then return MaxSaberPhaseReached end
            
            local function calculateRawPhase()
                if HasItem("Saber") then return 9 end
                
                local s, progress = pcall(function() return CommF:InvokeServer("ProQuestProgress", "RichMan") end)
                if not s or (type(progress) == "string" and progress == "Unknown") then 
                    return -1 -- Remote failure/timeout
                end
                
                local hasRelic = HasItem("Relic") or progress == "Relic" or (type(progress) == "table" and progress.Relic)
                if hasRelic then return 7 end
                
                -- El remoto de RichMan indica si ya matamos al Mob Leader
                if type(progress) == "table" and progress.RichMan then return 6 end
                -- NOTA: progress.SickMan NO existe en Blox Fruits.
                -- La transición Fase 4→5 se fuerza manualmente al hablar con Sick Man.
                
                if HasItem("Cup") or HasItem("FilledCup") then return 4 end
                if HasItem("Torch") then return 3 end
                
                -- Chequeo de la puerta del desierto:
                -- SOLO verificar si estamos en fases bajas (< 5).
                -- Si la puerta Burn ya NO existe y no tenemos copa,
                -- significa que la quemamos y perdimos la copa.
                local desert = SafeGetMapFolder("Desert")
                local desertDoor = desert and desert:FindFirstChild("Burn")
                if desert and not desertDoor then return 3 end
                
                local jungle = SafeGetMapFolder("Jungle")
                local jungleDoor = jungle and jungle:FindFirstChild("QuestDoor")
                if jungleDoor and jungleDoor.Transparency > 0.5 then return 2 end
                
                if GlobalPhase1Solved then return 2 end
                
                return 1
            end
            
            local rawPhase = calculateRawPhase()
            
            -- Si el remoto falló, usar ítems físicos como override, luego memoria
            if rawPhase == -1 then
                if HasItem("Relic") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 7); return MaxSaberPhaseReached end
                if HasItem("Cup") or HasItem("FilledCup") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 4); return MaxSaberPhaseReached end
                if HasItem("Torch") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 3); return MaxSaberPhaseReached end
                warn("Polar Hub [DetectPhase]: Remoto sin respuesta. Forzando memoria Anti-Regresión: Fase " .. MaxSaberPhaseReached)
                return MaxSaberPhaseReached
            end
            
            -- Cuando la detección es exitosa, actualizar si avanzamos naturalmente.
            if rawPhase > MaxSaberPhaseReached then
                MaxSaberPhaseReached = rawPhase
            end
            
            -- ✅ DEBE DEVOLVER LA MEMORIA, NUNCA EL RAWPHASE
            return MaxSaberPhaseReached
        end

        local function WaitForItem(itemName, timeoutSecs)
            local t = 0
            while t < timeoutSecs and AutoSaberRunning do
                if HasItem(itemName) then return true end
                task.wait(1)
                t = t + 1
            end
            return false
        end

        local function ExclusiveTargetLock(targetCF, enemyName, timeoutSecs)
            -- Equipar arma al entrar en combate
            EquipWeapon()
            
            -- Guardar estado previo de todas las banderas
            local prevFastAttack = getgenv().PolarFastAttackEnabled
            local prevSaberFlag = getgenv().PolarAutoSaberExpertEnabled
            local prevMobFlag = getgenv().PolarAutoMobLeaderEnabled
            
            -- Activar FastAttack Y la bandera correcta para que el bucle global de ataque
            -- también dispare (su condición requiere al menos un Auto*Enabled = true)
            getgenv().PolarFastAttackEnabled = true
            if string.find(string.lower(enemyName), "saber") then getgenv().PolarAutoSaberExpertEnabled = true end
            if string.find(string.lower(enemyName), "mob") then getgenv().PolarAutoMobLeaderEnabled = true end
            
            local timeout = 0
            local aliveCheckFails = 0
            local lastHP = math.huge
            local hpStuckCount = 0
            while AutoSaberRunning and timeout < timeoutSecs do
                if not IsEnemyAlive(enemyName) then
                    aliveCheckFails = aliveCheckFails + 1
                    if aliveCheckFails > 5 then break end
                else
                    aliveCheckFails = 0
                end
                
                task.wait(0.5)
                local hrp = GetHRP()
                local enemies = workspace:FindFirstChild("Enemies")
                
                -- Usar MatchEnemyName en lugar de FindFirstChild
                local target = nil
                if enemies then
                    for _, npc in ipairs(enemies:GetChildren()) do
                        if MatchEnemyName(npc.Name, enemyName) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            target = npc
                            break
                        end
                    end
                end
                
                if target and target:FindFirstChild("HumanoidRootPart") and hrp then
                    -- Incrementar contador si el HP del boss no baja
                    local currentHP = target:FindFirstChild("Humanoid") and target.Humanoid.Health or 0
                    if currentHP >= lastHP then
                        hpStuckCount = hpStuckCount + 1
                        if hpStuckCount > 20 then
                            warn("Polar Hub [ExclusiveTargetLock]: HP de '" .. enemyName .. "' no baja. Re-equipando arma...")
                            EquipWeapon()
                            hpStuckCount = 0
                        end
                    else
                        hpStuckCount = 0
                    end
                    lastHP = currentHP
                    
                    if (hrp.Position - target.HumanoidRootPart.Position).Magnitude > 300 then
                        SafeFly(target.HumanoidRootPart.CFrame, true)
                    else
                        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    end
                    
                    -- Atacar con remotes directamente
                    if RegisterHit and RegisterAttack then
                        local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                        if targetPart then
                            pcall(function()
                                RegisterAttack:FireServer(0)
                                RegisterHit:FireServer(targetPart, {{target, targetPart}})
                            end)
                        end
                    end
                elseif hrp and (hrp.Position - targetCF.Position).Magnitude > 300 then
                    SafeFly(targetCF, true)
                end
                timeout = timeout + 1
            end
            
            -- Restaurar TODAS las banderas a su estado previo
            getgenv().PolarFastAttackEnabled = prevFastAttack
            getgenv().PolarAutoSaberExpertEnabled = prevSaberFlag
            getgenv().PolarAutoMobLeaderEnabled = prevMobFlag
        end

        -- ==================== BUCLE MAESTRO V7.2 ====================
        local phaseAttempts = { [1]=0, [2]=0, [3]=0, [4]=0, [5]=0, [6]=0, [7]=0, [8]=0 }

        local function HandleCriticalFailure(phaseNum)
            warn("Polar Hub [Error Crítico]: Atascado en Fase " .. phaseNum .. " tras múltiples intentos.")
            Notify("⚠️ Atascado en Fase " .. phaseNum .. ". Retrocediendo para re-validar...")
            
            -- LÓGICA DE ESCAPE (Rollback): Si fallamos repetidamente,
            -- retrocedemos la memoria 1 fase para obligar al bot a re-verificar.
            if MaxSaberPhaseReached > 1 then
                MaxSaberPhaseReached = MaxSaberPhaseReached - 1
            else
                MaxSaberPhaseReached = 1
                GlobalPhase1Solved = false
            end
            
            -- Reiniciar contadores para el nuevo intento
            for i=1, 8 do phaseAttempts[i] = 0 end
            task.wait(3) -- Pausa táctica antes de reintentar
        end

        while AutoSaberRunning do
            task.wait(1)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then continue end

            local currentPhase = DetectPhase()
            
            -- Fase 1: Placas (MODO EXTREMO: 5 INTENTOS Y FUERZA AVANCE)
            if currentPhase == 1 then
                local s, err = pcall(function()
                    if not GlobalPhase1Solved then
                        phaseAttempts[1] = phaseAttempts[1] + 1
                        
                        -- LÍMITE EXTREMO: Si ya lo intentó 5 veces, ¡PASA A LA FASE 2 A LA FUERZA!
                        if phaseAttempts[1] > 5 then 
                            Notify("⚠️ 5 intentos alcanzados. ¡Forzando avance a Fase 2 (Antorcha)!")
                            GlobalPhase1Solved = true
                            MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 2)
                            phaseAttempts[1] = 0
                            return 
                        end
                        
                        Notify("Fase 1: Activando Placas (Intento " .. phaseAttempts[1] .. "/5)")
                        
                        local hrp = GetHRP()
                        local jungleCenterCF = CFrame.new(-1610, 22, 162)
                        if hrp and (hrp.Position - jungleCenterCF.Position).Magnitude > 300 then
                            Notify("✈️ Volando a la Jungla para cargar el mapa...")
                            SafeFly(jungleCenterCF, false)
                            task.wait(2)
                        end
                        
                        local jungle = SafeGetMapFolder("Jungle")
                        local questPlates = jungle and jungle:FindFirstChild("QuestPlates")
                        if questPlates then
                            for _, v in ipairs(questPlates:GetDescendants()) do
                                if not AutoSaberRunning then break end
                                if v:IsA("BasePart") and (string.find(string.lower(v.Name), "button") or string.find(string.lower(v.Name), "plate")) then
                                    ForceTouchV7(v, v.CFrame)
                                    task.wait(0.5)
                                end
                            end
                        else
                            warn("Polar Hub [Error Fase 1]: Carpeta 'QuestPlates' no renderizada aún.")
                        end
                        
                        task.wait(2)
                        local door = jungle and jungle:FindFirstChild("QuestDoor")
                        if door and door.Transparency > 0.5 then
                            Notify("✅ ¡Placas activadas! Puerta abierta de forma natural.")
                            GlobalPhase1Solved = true
                            MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 2)
                            phaseAttempts[1] = 0
                        else
                            if phaseAttempts[1] >= 3 then
                                Notify("⚠️ Las placas resisten. Cooldown táctico (3s)...")
                                task.wait(3)
                            end
                        end
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 1]: " .. tostring(err)) end
                continue
            end

            -- Fase 2: Recoger Antorcha (MODO EXTREMO)
            if currentPhase == 2 then
                local s, err = pcall(function()
                    phaseAttempts[2] = phaseAttempts[2] + 1
                    
                    if phaseAttempts[2] > 5 then
                        Notify("⚠️ 5 intentos en Antorcha. ¡Forzando avance a Fase 3 (Desierto)!")
                        MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 3)
                        phaseAttempts[2] = 0
                        return
                    end
                    
                    Notify("Fase 2: Recogiendo Antorcha (Intento " .. phaseAttempts[2] .. "/5)...")
                    local torchCF = CFrame.new(-1610.15, 12.18, 162.72)
                    local jungle = SafeGetMapFolder("Jungle")
                    local torch = jungle and jungle:FindFirstChild("Torch")
                    
                    if not torch then warn("Polar Hub [Error Fase 2]: Objeto 'Torch' no renderizado en Map/Jungle.") end
                    ForceTouchV7(torch, torchCF)
                    
                    if WaitForItem("Torch", 5) then -- Reducido a 5s de espera por agilidad
                        Notify("✅ ¡Antorcha obtenida!")
                        phaseAttempts[2] = 0
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 2]: " .. tostring(err)) end
                continue
            end

            -- Fase 3: Desierto (Quemar Puerta y Recoger Copa) (MODO EXTREMO)
            if currentPhase == 3 then
                local s, err = pcall(function()
                    phaseAttempts[3] = phaseAttempts[3] + 1
                    
                    if phaseAttempts[3] > 5 then
                        Notify("⚠️ 5 intentos en Desierto. ¡Forzando avance a Fase 4 (Nieve)!")
                        MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 4)
                        phaseAttempts[3] = 0
                        return
                    end
                    
                    Notify("Fase 3: Desierto (Puerta y Copa) - Intento " .. phaseAttempts[3] .. "/5")
                    local desert = SafeGetMapFolder("Desert")
                    local doorBurn = desert and desert:FindFirstChild("Burn")
                    
                    if doorBurn then
                        if HasItem("Torch") then
                            EquipToolByName("Torch")
                            ForceTouchV7(doorBurn, doorBurn.CFrame)
                            task.wait(3)
                        else
                            -- Ya no retrocede. Gasta el intento advirtiendo.
                            warn("Polar Hub [Fase 3]: Intentando avanzar sin Antorcha física...")
                        end
                    else
                        Notify("Fase 3: Puerta ya quemada o no existe.")
                    end

                    local cupCF = CFrame.new(1114.26, 4.17, 4366.15)
                    local cup = desert and desert:FindFirstChild("Cup")
                    ForceTouchV7(cup, cupCF)

                    if WaitForItem("Cup", 5) then
                        Notify("✅ ¡Copa obtenida exitosamente!")
                        phaseAttempts[3] = 0
                    else
                        warn("Polar Hub [Fase 3]: Fallo al obtener Copa. Se forzará en próximos intentos.")
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 3]: " .. tostring(err)) end
                continue
            end

            -- Fase 4: Llenar Copa y dársela al Sick Man
            if currentPhase == 4 then
                local s, err = pcall(function()
                    phaseAttempts[4] = phaseAttempts[4] + 1
                    if phaseAttempts[4] > 5 then
                        Notify("⚠️ 5 intentos en Sick Man. ¡Forzando avance a Fase 5!")
                        MaxSaberPhaseReached = 5
                        phaseAttempts[4] = 0
                        return
                    end
                    
                    Notify("Fase 4: Llenando Copa en la Nieve (Intento " .. phaseAttempts[4] .. "/5)")
                    local fillCF = CFrame.new(1394.12, 37.38, -1320.83)
                    
                    if HasItem("FilledCup") then
                        EquipToolByName("FilledCup")
                    elseif HasItem("Cup") then
                        EquipToolByName("Cup")
                    end
                    
                    ForceTouchV7(nil, fillCF)
                    task.wait(4)
                    
                    if HasItem("FilledCup") then
                        Notify("Fase 4: Copa llena. Entregando a Sick Man...")
                        TalkToNPCV7("Sick Man", CFrame.new(1395.4, 37.3, -1322.5), nil)
                        task.wait(2)
                        
                        -- VERIFICACIÓN FÍSICA: Si ya no tenemos la copa, el NPC la aceptó.
                        if not HasItem("FilledCup") and not HasItem("Cup") then
                            Notify("✅ ¡Sick Man ayudado! Avanzando a Fase 5...")
                            MaxSaberPhaseReached = 5
                            phaseAttempts[4] = 0
                        else
                            warn("Polar Hub [Error Fase 4]: Sick Man no tomó la copa. Reintentando...")
                        end
                    else
                        warn("Polar Hub [Error Fase 4]: La copa no se llenó con agua.")
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 4]: " .. tostring(err)) end
                continue
            end

            -- Fase 5: Ir a Rich Man (Primer Encuentro)
            if currentPhase == 5 then
                local s, err = pcall(function()
                    phaseAttempts[5] = phaseAttempts[5] + 1
                    if phaseAttempts[5] > 5 then
                        Notify("⚠️ 5 intentos en Rich Man. ¡Forzando avance a Fase 6!")
                        MaxSaberPhaseReached = 6
                        phaseAttempts[5] = 0
                        return
                    end
                    
                    Notify("Fase 5: Volando hacia Rich Man (Intento " .. phaseAttempts[5] .. "/5)...")
                    TalkToNPCV7("Rich Man", CFrame.new(-1145, 4.7, 3828.6), "RichMan")
                    task.wait(3)
                    
                    Notify("✅ ¡Hablamos con Rich Man! Avanzando a cazar al Mob Leader...")
                    MaxSaberPhaseReached = 6
                    phaseAttempts[5] = 0
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 5]: " .. tostring(err)) end
                continue
            end

            -- Fase 6: Matar Mob Leader y Reclamar Reliquia
            if currentPhase == 6 then
                local s, err = pcall(function()
                    phaseAttempts[6] = phaseAttempts[6] + 1
                    if phaseAttempts[6] > 40 then
                        HandleCriticalFailure(6)
                        return
                    end
                    
                    local mobLeaderCF = CFrame.new(-2880.71, 15, 5430.85)
                    local richManCF = CFrame.new(-1145, 4.7, 3828.6)
                    
                    -- 1. Intentar cobrar recompensa ANTES de cazar (Por si ya lo matamos antes)
                    if phaseAttempts[6] == 1 or phaseAttempts[6] % 4 == 0 then
                        Notify("Fase 6: Verificando estado con Rich Man...")
                        TalkToNPCV7("Rich Man", richManCF, "RichMan")
                        task.wait(3)
                        if HasItem("Relic") then
                            Notify("✅ ¡Reliquia obtenida! Avanzando a Fase 7...")
                            MaxSaberPhaseReached = 7
                            phaseAttempts[6] = 0
                            return
                        end
                    end
                    
                    -- 2. Si no tenemos la reliquia, buscamos al Mob Leader
                    if IsEnemyAlive("Mob Leader") then
                        Notify("🎯 ¡Mob Leader encontrado! Entrando en combate...")
                        ExclusiveTargetLock(mobLeaderCF, "Mob Leader", 600)
                        Notify("✅ ¡Mob Leader derrotado! Yendo a reclamar recompensa...")
                        task.wait(3)
                        
                        -- Reclamar insistentemente
                        for i = 1, 3 do
                            TalkToNPCV7("Rich Man", richManCF, "RichMan")
                            task.wait(3)
                            if HasItem("Relic") then
                                Notify("✅ ¡Reliquia obtenida! Avanzando a Fase 7...")
                                MaxSaberPhaseReached = 7
                                phaseAttempts[6] = 0
                                return
                            end
                        end
                        Notify("⚠️ No se recibió la reliquia. Se reintentará en el próximo ciclo...")
                    else
                        Notify("⏳ Mob Leader no spawneado. Esperando en isla (Intento " .. phaseAttempts[6] .. "/40)...")
                        local hrp = GetHRP()
                        if hrp and (hrp.Position - mobLeaderCF.Position).Magnitude > 100 then
                            SafeFly(mobLeaderCF, false)
                        end
                        task.wait(5)
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 6]: " .. tostring(err)) end
                continue
            end

            -- Fase 7: Usar Relic
            if currentPhase == 7 then
                local s, err = pcall(function()
                    phaseAttempts[7] = phaseAttempts[7] + 1
                    
                    if phaseAttempts[7] > 5 then
                        Notify("⚠️ 5 intentos con Relic. ¡Forzando avance a Fase 8 (Saber Expert)!")
                        MaxSaberPhaseReached = 8
                        phaseAttempts[7] = 0
                        return
                    end
                    
                    Notify("Fase 7: Abriendo bóveda con Relic (Intento " .. phaseAttempts[7] .. "/5)...")
                    EquipToolByName("Relic")
                    local relicCF = CFrame.new(-1406.8, 29.8, 3.8)
                    local jungle = SafeGetMapFolder("Jungle")
                    local relicDoor = jungle and jungle:FindFirstChild("Relic", true)
                    
                    if not relicDoor then warn("Polar Hub [Error Fase 7]: Puerta 'Relic' no encontrada en Map/Jungle.") end
                    ForceTouchV7(relicDoor, relicCF)
                    task.wait(3)
                    
                    Notify("✅ ¡Reliquia colocada! Avanzando a Fase 8...")
                    MaxSaberPhaseReached = 8
                    phaseAttempts[7] = 0
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 7]: " .. tostring(err)) end
                continue
            end

            -- Fase 8: Saber Expert
            if currentPhase == 8 or currentPhase == 9 then
                local s, err = pcall(function()
                    if HasItem("Saber") or currentPhase == 9 then
                        Notify("🎉 ¡ÉXITO TOTAL! Ya tienes la espada Saber.")
                        AutoSaberRunning = false
                        getgenv().PolarCurrentBotState = "IDLE"
                        return
                    end
                    
                    Notify("Fase 8: Validando Saber Expert...")
                    local shanksCF = CFrame.new(-1461, 30, -51)
                    ForceTouchV7(nil, shanksCF)
                    task.wait(1)
                    
                    if not IsEnemyAlive("Saber Expert") then
                        phaseAttempts[8] = phaseAttempts[8] + 1
                        -- Los bosses tardan hasta 30 min en reaparecer.
                        -- 120 intentos x 10s = 20 minutos de espera paciente.
                        if phaseAttempts[8] > 120 then
                            Notify("⚠️ Saber Expert no ha spawneado en 20 min. Reiniciando contador...")
                            phaseAttempts[8] = 0
                            return
                        end
                        -- Mostrar progreso sin alarmar al usuario
                        if phaseAttempts[8] % 6 == 1 then -- Solo notificar cada ~60s
                            local minutesWaited = math.floor(phaseAttempts[8] * 10 / 60)
                            Notify("⏳ Esperando spawn de Saber Expert... (" .. minutesWaited .. " min)")
                        end
                        -- Mantenerse en la zona de spawn
                        local hrp = GetHRP()
                        if hrp and (hrp.Position - shanksCF.Position).Magnitude > 100 then
                            SafeFly(shanksCF, false)
                        end
                        task.wait(10)
                        return
                    end

                    -- Boss está vivo, entrar en combate
                    EquipWeapon()
                    phaseAttempts[8] = 0
                    Notify("⚔️ ¡Matando a Shanks (Saber Expert)!")
                    ExclusiveTargetLock(shanksCF, "Saber Expert", 600)
                    WaitForItem("Saber", 10)
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 8]: " .. tostring(err)) end
                if not AutoSaberRunning then break end
                continue
            end
            
            -- FIX #9: Else con warn al final del loop si ninguna fase coincidió
            warn("Polar Hub [Loop Principal]: Fase " .. tostring(currentPhase) .. " no tiene handler definido. MaxPhase=" .. tostring(MaxSaberPhaseReached))
        end
        
        -- Limpieza Final
        AutoSaberRunning = false
        -- FIX #15: Restaurar getgenv().PolarCurrentBotState al terminar FullAutoSaber
        getgenv().PolarCurrentBotState = "IDLE"
    end)
end
local AutoHakiEnabled = true
task.spawn(function()
    while true do
        if not AutoHakiEnabled then
            task.wait(1)
            continue
        end
        task.wait(0.5)
        -- FIX: Activar Haki automáticamente si está encendido
        if AutoHakiEnabled and CommF then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild("HasBuso") then 
                pcall(function() CommF:InvokeServer("Buso") end) 
            end
        end
    end
end)




TabStatus:Section({ Title = "Radar de Jefes Especiales (Sea 1)" })

local LabelTheSaw = TabStatus:Paragraph({
    Title = "The Saw (Nvl 100) - Middle Town",
    Desc = "Estado: Calculando..."
})

local LabelGreybeard = TabStatus:Paragraph({
    Title = "Greybeard (Nvl 750) - Marine Fortress",
    Desc = "Estado: Calculando..."
})

local scriptStartTime = os.time()

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function UpdatePara(para, newDesc)
    if not para then return end
    pcall(function()
        if para.SetDesc then para:SetDesc(newDesc)
        elseif para.Set then para:Set({Desc = newDesc}) end
    end)
end

local function GetExactBossTimer(bossName)
    local foundTimer = nil
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            local isTargetBoss = false
            local timerText = nil
            
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text then
                    local textLower = string.lower(child.Text)
                    if string.find(textLower, string.lower(bossName)) then
                        isTargetBoss = true
                    end
                    local matchTimer = string.match(child.Text, "%[(%d+:%d+:%d+)%]") or string.match(child.Text, "%[(%d+:%d+)%]")
                    if matchTimer then
                        timerText = matchTimer
                    end
                end
            end
            
            if isTargetBoss and timerText then
                foundTimer = timerText
            end
        end
    end
    return foundTimer
end

task.spawn(function()
    while true do
        task.wait(5) -- OPTIMIZADO: Espera aumentada para evitar lag extremo de búsqueda en workspace
        pcall(function()
            local serverUptime = workspace.DistributedGameTime
            UpdatePara(LabelServerUptime, FormatTime(serverUptime))
            
            local sessionTime = os.time() - scriptStartTime
            UpdatePara(LabelPlayerTime, FormatTime(sessionTime))
            
            local enemies = workspace:FindFirstChild("Enemies")
            
            -- THE SAW
            local sawAlive = false
            if enemies and enemies:FindFirstChild("The Saw") then sawAlive = true end
            
            if sawAlive then
                UpdatePara(LabelTheSaw, "🟢 SPAWNEADO! (¡Ve a matarlo!)")
            else
                local exactTimer = GetExactBossTimer("The Saw")
                if exactTimer then
                    UpdatePara(LabelTheSaw, "🔴 MUERTO\nPróximo Spawn (Holograma Oficial): " .. exactTimer)
                else
                    UpdatePara(LabelTheSaw, "🔴 MUERTO\nPróximo Spawn: Esperando sincronización...")
                end
            end
            
            -- GREYBEARD
            local greyAlive = false
            if enemies and enemies:FindFirstChild("Greybeard") then greyAlive = true end
            
            if greyAlive then
                UpdatePara(LabelGreybeard, "🟢 SPAWNEADO! (¡Ve a matarlo!)")
            else
                local exactTimer = GetExactBossTimer("Greybeard")
                if exactTimer then
                    UpdatePara(LabelGreybeard, "🔴 MUERTO\nPróximo Spawn (Holograma Oficial): " .. exactTimer)
                else
                    UpdatePara(LabelGreybeard, "🔴 MUERTO\nPróximo Spawn: Esperando sincronización...")
                end
            end
        end)
    end
end)




TabFarm:Section({ Title = "Cazador de Jefes (Bosses)" })

local BossNamesList = {}
for _, b in ipairs(getgenv().PolarBosses) do table.insert(BossNamesList, b.name) end

TabFarm:Dropdown({
    Title = "Seleccionar Jefe",
    Values = BossNamesList,
    Value = "Gorilla King",
    Callback = function(Value)
        getgenv().PolarSelectedBossToFarm = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm Boss Seleccionado",
    Desc = "Caza exclusivamente al jefe seleccionado arriba.",
    Callback = function(Value)
        getgenv().PolarAutoFarmBossEnabled = Value
        getgenv().PolarFastAttackEnabled = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm ALL Bosses",
    Desc = "Modo Exterminio: Escanea el servidor y caza a TODOS los jefes vivos.",
    Callback = function(Value)
        getgenv().PolarAutoFarmAllBossesEnabled = Value
        getgenv().PolarFastAttackEnabled = Value
        getgenv().PolarLastBossCheckedIndex = 1
    end
})

TabFarm:Toggle({
    Title = "Tomar Misión del Jefe",
    Desc = "Si está desactivado, los cazará a sangre fría ignorando requisitos de nivel.",
    Callback = function(Value)
        getgenv().PolarBossWithQuest = Value
    end
})



TabQuest:Section({ Title = "Habilidades Especiales" })
TabQuest:Button({ 
    Title = "Auto Desbloquear Ken Haki (Visión) - $750k", 
    Callback = function() 
        local data = LocalPlayer:FindFirstChild("Data")
        local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
        if lvl >= 300 then
            BuyItem("KenTalk", "Buy")
        else
            warn("❌ Error Polar Hub: Necesitas Nivel 300 para el Ken Haki.")
        end
    end 
})

TabQuest:Section({ Title = "Saber Puzzle (100% Automático)" })
TabQuest:Paragraph({
    Title = "Auto Saber Definitivo",
    Desc = "Presiona INICIAR y el bot viajará por 4 islas, presionará los botones secretos, tomará la antorcha, quemará paredes, y masacrará a los jefes de la mafia y a Shanks de forma autónoma."
})

TabQuest:Button({
    Title = "▶ Iniciar Auto Saber Puzzle",
    Callback = function()
        if not AutoSaberRunning then
            FullAutoSaber()
        end
    end
})

TabQuest:Button({
    Title = "⏹ Detener Auto Saber",
    Callback = function()
        AutoSaberRunning = false
        getgenv().PolarAutoMobLeaderEnabled = false
        getgenv().PolarAutoSaberExpertEnabled = false
    end
})


TabQuest:Section({ Title = "Puzzle Second Sea (Lv. 700+)" })
TabQuest:Paragraph({
    Title = "Acceso Automático",
    Desc = "Cumple la misión del Detective, mata al Ice Admiral y viaja a Dressrosa de forma 100% autónoma."
})

TabQuest:Button({
    Title = "▶ Iniciar Viaje al Second Sea",
    Callback = function()
        AutoSecondSea()
    end
})

TabQuest:Button({
    Title = "⏹ Detener Viaje",
    Callback = function()
        AutoSecondSeaRunning = false
    end
})

TabQuest:Section({ Title = "Caza de Jefes (Modo Manual)" })


TabQuest:Toggle({
    Title = "Auto Matar Mob Leader (Nvl 120)",
    Default = false,
    Callback = function(v)
        getgenv().PolarAutoMobLeaderEnabled = v
        getgenv().PolarFastAttackEnabled = v
    end
})

TabQuest:Toggle({
    Title = "Auto Matar Saber Expert / Shanks (Nvl 200)",
    Default = false,
    Callback = function(v)
        getgenv().PolarAutoSaberExpertEnabled = v
        getgenv().PolarFastAttackEnabled = v
    end
})


