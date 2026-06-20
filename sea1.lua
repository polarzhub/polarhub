-- ==================== POLAR HUB | SEA 1 ====================
print("Cargando datos del Sea 1...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)
local RegisterHit = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5) and ReplicatedStorage.Modules.Net:FindFirstChild("RE/RegisterHit")
local RegisterAttack = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5) and ReplicatedStorage.Modules.Net:FindFirstChild("RE/RegisterAttack")

local Polar = getgenv().Polar
local Window = Polar.Window or getgenv().PolarWindow
local TabFarm = Polar.TabFarm or getgenv().PolarTabFarm
local TabStatus = Polar.TabStatus or getgenv().PolarTabStatus
local TabQuest = Polar.TabQuest or getgenv().PolarTabQuest

-- ==================== DATA REGISTRY SEA 1 ====================
Polar.Data.AllowedQuests = {
    "BanditQuest1", "JungleQuest", "BuggyQuest1", "DesertQuest", 
    "SnowQuest", "MarineQuest2", "SkyQuest", "PrisonerQuest", 
    "ImpelQuest", "ColosseumQuest", "MagmaQuest", "FishmanQuest", 
    "SkyExp1Quest", "SkyExp2Quest", "FountainQuest"
}

Polar.Data.QuestInfo = {
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

Polar.Data.Bosses = {
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

-- Mapeos Dinámicos
for _, q in ipairs(Polar.Data.QuestInfo) do
    Polar.Data.QuestToIsland[q.q] = q.island
    Polar.Data.QuestGiver[q.q] = q.giver
end

-- ==================== AUTO SECOND SEA PUZZLE ====================
local AutoSecondSeaRunning = false
local function AutoSecondSea()
    if AutoSecondSeaRunning then return end
    
    local lvl = Polar.Player:GetLevel()
    if lvl < 700 then
        warn("❌ Error Polar Hub: Necesitas Nivel 700 para acceder al Second Sea.")
        return
    end

    AutoSecondSeaRunning = true
    task.spawn(function()
        warn("Polar Hub: Paso 1 - Hablando con Military Detective...")
        local detectiveCF = Polar.World:FindNPC("Military Detective") or CFrame.new(4849, 5, 718)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(detectiveCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective") end)
        
        warn("Polar Hub: Obteniendo llave...")
        local key = nil
        for i=1, 30 do
            key = LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Character:FindFirstChild("Key")
            if key then break end
            task.wait(0.5)
        end
        
        warn("Polar Hub: Paso 2 - Yendo a la Cueva Helada...")
        local caveTop = CFrame.new(1344.55, 200, -1327.89)
        local doorStand = CFrame.new(1344.55, 42.25, -1327.89)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - caveTop.Position).Magnitude > 50 and AutoSecondSeaRunning do
            Polar.Teleport:To(caveTop)
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
                pcall(function() firetouchinterest(key.Handle, realDoor, 1) end)
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = doorStand * CFrame.new(0, 0, -5)
        end
        task.wait(1)
        
        warn("Polar Hub: Paso 3 - Eliminando al Ice Admiral...")
        getgenv().PolarSelectedBossToFarm = "Ice Admiral"
        getgenv().PolarAutoFarmBossEnabled = true
        
        while AutoSecondSeaRunning do
            local enemy = workspace.Enemies:FindFirstChild("Ice Admiral") or workspace.Characters:FindFirstChild("Ice Admiral")
            if not enemy or (enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health <= 0) then
                task.wait(2)
                enemy = workspace.Enemies:FindFirstChild("Ice Admiral") or workspace.Characters:FindFirstChild("Ice Admiral")
                if not enemy then break end
            end
            task.wait(1)
        end
        
        getgenv().PolarAutoFarmBossEnabled = false
        task.wait(2)

        warn("Polar Hub: Paso 4 - Validando progreso...")
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(detectiveCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective") end)
        task.wait(2)
        
        warn("Polar Hub: Paso 5 - Viajando a Dressrosa...")
        local capCF = Polar.World:FindNPC("Experienced Captain") or CFrame.new(-789, 7, 1515)
        while (LocalPlayer.Character.HumanoidRootPart.Position - capCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(capCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = capCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa") end)
        AutoSecondSeaRunning = false
    end)
end

-- ==================== AUTO SABER PUZZLE ====================
local AutoSaberRunning = false
local MaxSaberPhaseReached = 1
local GlobalPhase1Solved = false

local function FullAutoSaber()
    if AutoSaberRunning then return end
    
    local lvl = Polar.Player:GetLevel()
    if lvl < 200 then
        warn("❌ Polar Hub: Necesitas Nivel 200+ para el Saber Puzzle.")
        return
    end

    AutoSaberRunning = true
    task.spawn(function()
        -- Detener farms normales
        getgenv().PolarAutoFarmEnabled = false
        getgenv().PolarAutoFarmBossEnabled = false
        getgenv().PolarAutoFarmAllBossesEnabled = false
        
        local function Notify(text)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "👑 Polar Hub", Text = text, Duration = 5})
            end)
            print("Polar Hub Saber: " .. text)
        end

        local function HasItem(itemName)
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp and bp:FindFirstChild(itemName) then return true end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(itemName) then return true end
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

        local function DetectPhase()
            if HasItem("Saber") then MaxSaberPhaseReached = 9; return 9 end
            if MaxSaberPhaseReached >= 5 then return MaxSaberPhaseReached end
            
            local function calculateRawPhase()
                local s, progress = pcall(function() return CommF:InvokeServer("ProQuestProgress", "RichMan") end)
                if not s or (type(progress) == "string" and progress == "Unknown") then return -1 end
                
                local hasRelic = HasItem("Relic") or progress == "Relic" or (type(progress) == "table" and progress.Relic)
                if hasRelic then return 7 end
                if type(progress) == "table" and progress.RichMan then return 6 end
                if HasItem("Cup") or HasItem("FilledCup") then return 4 end
                if HasItem("Torch") then return 3 end
                
                local map = workspace:FindFirstChild("Map")
                local desert = map and map:FindFirstChild("Desert")
                local door = desert and desert:FindFirstChild("Burn")
                if desert and not door then return 3 end
                
                local jungle = map and map:FindFirstChild("Jungle")
                local jDoor = jungle and jungle:FindFirstChild("QuestDoor")
                if jDoor and jDoor.Transparency > 0.5 then return 2 end
                
                if GlobalPhase1Solved then return 2 end
                return 1
            end
            
            local raw = calculateRawPhase()
            if raw == -1 then
                if HasItem("Relic") then raw = 7
                elif HasItem("Cup") or HasItem("FilledCup") then raw = 4
                elif HasItem("Torch") then raw = 3
                else raw = MaxSaberPhaseReached end
            end
            
            if raw > MaxSaberPhaseReached then MaxSaberPhaseReached = raw end
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

        local function ExclusiveTargetLock(targetCF, enemyName)
            getgenv().PolarFastAttackEnabled = true
            if string.find(string.lower(enemyName), "saber") then getgenv().PolarAutoSaberExpertEnabled = true end
            if string.find(string.lower(enemyName), "mob") then getgenv().PolarAutoMobLeaderEnabled = true end
            
            local timeout = 0
            while AutoSaberRunning and timeout < 120 do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                
                if not Polar.World:IsEnemyAlive(enemyName) then
                    task.wait(0.5)
                    if not Polar.World:IsEnemyAlive(enemyName) then break end
                end
                
                local target = nil
                if workspace:FindFirstChild("Enemies") then
                    for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                        if string.find(string.lower(npc.Name), string.lower(enemyName)) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            target = npc
                            break
                        end
                    end
                end
                
                if target and target:FindFirstChild("HumanoidRootPart") then
                    Polar.Teleport:To(target.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
                    -- Atacar
                    if RegisterHit and RegisterAttack then
                        local p = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                        if p then
                            pcall(function()
                                RegisterAttack:FireServer(0)
                                RegisterHit:FireServer(p, {{target, p}})
                            end)
                        end
                    end
                else
                    Polar.Teleport:To(targetCF)
                end
                task.wait(0.5)
                timeout = timeout + 1
            end
            
            getgenv().PolarFastAttackEnabled = false
            getgenv().PolarAutoSaberExpertEnabled = false
            getgenv().PolarAutoMobLeaderEnabled = false
        end

        while AutoSaberRunning do
            task.wait(1)
            local currentPhase = DetectPhase()
            
            if currentPhase == 1 then
                Notify("Fase 1: Activando botones de la Jungla...")
                Polar.Teleport:ToIsland("Jungle")
                local map = workspace:FindFirstChild("Map")
                local jungle = map and map:FindFirstChild("Jungle")
                local plates = jungle and jungle:FindFirstChild("QuestPlates")
                
                if plates then
                    for _, btn in ipairs(plates:GetDescendants()) do
                        if btn:IsA("BasePart") and (string.find(string.lower(btn.Name), "button") or string.find(string.lower(btn.Name), "plate")) then
                            Polar.Teleport:To(btn.CFrame)
                            task.wait(0.5)
                            if firetouchinterest then
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, btn, 0)
                                task.wait(0.05)
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, btn, 1)
                            end
                        end
                    end
                end
                task.wait(2)
                GlobalPhase1Solved = true
                MaxSaberPhaseReached = 2
            
            elseif currentPhase == 2 then
                Notify("Fase 2: Buscando la Antorcha...")
                local torchCF = CFrame.new(-1610.15, 12.18, 162.72)
                Polar.Teleport:To(torchCF)
                task.wait(1)
                if WaitForItem("Torch", 5) then
                    Notify("✅ ¡Antorcha obtenida!")
                end
            
            elseif currentPhase == 3 then
                Notify("Fase 3: Desierto (Quemar puerta y tomar Copa)...")
                local desertCenter = CFrame.new(1114.26, 4.17, 4366.15)
                Polar.Teleport:To(desertCenter)
                task.wait(1)
                
                local burnDoor = workspace.Map:FindFirstChild("Burn", true)
                if burnDoor then
                    EquipToolByName("Torch")
                    Polar.Teleport:To(burnDoor.CFrame)
                    task.wait(2)
                end
                
                local cup = workspace.Map:FindFirstChild("Cup", true)
                if cup then
                    Polar.Teleport:To(cup.CFrame)
                    task.wait(1)
                end
                
                if WaitForItem("Cup", 5) then
                    Notify("✅ ¡Copa obtenida!")
                end
            
            elseif currentPhase == 4 then
                Notify("Fase 4: Llenando copa en la Cueva de Nieve...")
                local fillCF = CFrame.new(1394.12, 37.38, -1320.83)
                Polar.Teleport:To(fillCF)
                task.wait(2)
                
                EquipToolByName("Cup")
                task.wait(2)
                
                if HasItem("FilledCup") then
                    Notify("Entregando agua al Sick Man...")
                    local sickManCF = CFrame.new(1395.4, 37.3, -1322.5)
                    Polar.Teleport:To(sickManCF)
                    task.wait(1)
                    EquipToolByName("FilledCup")
                    task.wait(1)
                    pcall(function() CommF:InvokeServer("ProQuestProgress", "SickMan") end)
                    task.wait(2)
                    MaxSaberPhaseReached = 5
                end
            
            elseif currentPhase == 5 then
                Notify("Fase 5: Hablando con Rich Man...")
                local richManCF = CFrame.new(-1145, 4.7, 3828.6)
                Polar.Teleport:To(richManCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "RichMan") end)
                task.wait(1)
                MaxSaberPhaseReached = 6
            
            elseif currentPhase == 6 then
                Notify("Fase 6: Derrotando al Mob Leader...")
                local mobCF = CFrame.new(-2880.71, 15, 5430.85)
                Polar.Teleport:To(mobCF)
                task.wait(1)
                
                if Polar.World:IsEnemyAlive("Mob Leader") then
                    ExclusiveTargetLock(mobCF, "Mob Leader")
                end
                
                -- Volver a Rich Man por Reliquia
                local richManCF = CFrame.new(-1145, 4.7, 3828.6)
                Polar.Teleport:To(richManCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "RichMan") end)
                task.wait(1)
                
                if WaitForItem("Relic", 10) then
                    Notify("✅ ¡Reliquia obtenida!")
                    MaxSaberPhaseReached = 7
                end
            
            elseif currentPhase == 7 then
                Notify("Fase 7: Abriendo la Bóveda de Shanks...")
                local relicCF = CFrame.new(-1406.8, 29.8, 3.8)
                Polar.Teleport:To(relicCF)
                task.wait(1)
                EquipToolByName("Relic")
                task.wait(2)
                MaxSaberPhaseReached = 8
            
            elseif currentPhase == 8 or currentPhase == 9 then
                if HasItem("Saber") then
                    Notify("🎉 ¡Puzzle Completado! Saber obtenida.")
                    AutoSaberRunning = false
                    break
                end
                
                Notify("Fase 8: Esperando a Saber Expert / Shanks...")
                local shanksCF = CFrame.new(-1461, 30, -51)
                Polar.Teleport:To(shanksCF)
                
                if Polar.World:IsEnemyAlive("Saber Expert") then
                    ExclusiveTargetLock(shanksCF, "Saber Expert")
                else
                    task.wait(5)
                end
            end
        end
    end)
end

-- Bucle Auto Haki
local AutoHakiEnabled = true
task.spawn(function()
    while true do
        task.wait(1)
        if AutoHakiEnabled and CommF then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild("HasBuso") then
                pcall(function() CommF:InvokeServer("Buso") end)
            end
        end
    end
end)

-- ==================== UI BINDINGS AND RADARS ====================
TabStatus:Section({ Title = "Radar de Jefes Especiales (Sea 1)" })
local LabelTheSaw = TabStatus:Paragraph({ Title = "The Saw (Nvl 100) - Middle Town", Desc = "Calculando..." })
local LabelGreybeard = TabStatus:Paragraph({ Title = "Greybeard (Nvl 750) - Marine Fortress", Desc = "Calculando..." })
local LabelServerUptime = TabStatus:Paragraph({ Title = "Tiempo de Vida del Servidor", Desc = "Calculando..." })
local LabelPlayerTime = TabStatus:Paragraph({ Title = "Tiempo en Sesión (Jugador)", Desc = "Calculando..." })

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

task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            local serverUptime = workspace.DistributedGameTime
            UpdatePara(LabelServerUptime, FormatTime(serverUptime))
            
            local sessionTime = os.time() - scriptStartTime
            UpdatePara(LabelPlayerTime, FormatTime(sessionTime))
            
            local enemies = workspace:FindFirstChild("Enemies")
            
            local sawAlive = enemies and enemies:FindFirstChild("The Saw")
            UpdatePara(LabelTheSaw, sawAlive and "🟢 SPAWNEADO! (¡Ve a matarlo!)" or "🔴 MUERTO")
            
            local greyAlive = enemies and enemies:FindFirstChild("Greybeard")
            UpdatePara(LabelGreybeard, greyAlive and "🟢 SPAWNEADO! (¡Ve a matarlo!)" or "🔴 MUERTO")
        end)
    end
end)

-- UI Farm Bosses
TabFarm:Section({ Title = "Cazador de Jefes (Bosses)" })
local BossNamesList = {}
for _, b in ipairs(Polar.Data.Bosses) do table.insert(BossNamesList, b.name) end

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
    end
})

TabFarm:Toggle({
    Title = "Auto Farm ALL Bosses",
    Desc = "Modo Exterminio: Escanea el servidor y caza a TODOS los jefes vivos.",
    Callback = function(Value)
        getgenv().PolarAutoFarmAllBossesEnabled = Value
        getgenv().PolarLastBossCheckedIndex = 1
    end
})

TabFarm:Toggle({
    Title = "Tomar Misión del Jefe",
    Callback = function(Value)
        getgenv().PolarBossWithQuest = Value
    end
})

-- UI Special Quests
TabQuest:Section({ Title = "Habilidades Especiales" })
TabQuest:Button({ 
    Title = "Auto Desbloquear Ken Haki (Visión) - $750k", 
    Callback = function() 
        local lvl = Polar.Player:GetLevel()
        if lvl >= 300 then
            BuyItem("KenTalk", "Buy")
        else
            warn("❌ Necesitas Nivel 300 para el Ken Haki.")
        end
    end 
})

TabQuest:Section({ Title = "Saber Puzzle (100% Automático)" })
TabQuest:Button({
    Title = "▶ Iniciar Auto Saber Puzzle",
    Callback = function()
        FullAutoSaber()
    end
})

TabQuest:Button({
    Title = "⏹ Detener Auto Saber",
    Callback = function()
        AutoSaberRunning = false
    end
})

TabQuest:Section({ Title = "Puzzle Second Sea (Lv. 700+)" })
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
