-- ==================== POLAR HUB | SEA 1 (POWERHOUSE EDITION) ====================
print("[Polar Hub] 🌊 Cargando datos del Sea 1...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)
local NetFolder = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit = NetFolder and NetFolder:FindFirstChild("RE/RegisterHit")
local RegisterAttack = NetFolder and NetFolder:FindFirstChild("RE/RegisterAttack")
local RequestBonusMoment = NetFolder and NetFolder:FindFirstChild("RF/RequestBonusMomentReplication")
local RequestSecretStories = NetFolder and NetFolder:FindFirstChild("RF/RequestSecretStories")
local RequestNextRaidHint = NetFolder and NetFolder:FindFirstChild("RF/RequestNextRaidHint")

local Polar = getgenv().Polar or {}
local Window = Polar.Window or getgenv().PolarWindow
local TabFarm = Polar.TabFarm or getgenv().PolarTabFarm
local TabStatus = Polar.TabStatus or getgenv().PolarTabStatus
local TabQuest = Polar.TabQuest or getgenv().PolarTabQuest
local TabShop = Polar.TabShop or getgenv().PolarTabShop

-- Helper para compra segura con bypass o remoto
local function SafeBuy(action, arg1, arg2, npcName)
    if getgenv().PolarBuyItem then
        getgenv().PolarBuyItem(action, arg1, arg2, npcName)
    elseif CommF then
        pcall(function()
            if arg2 then CommF:InvokeServer(action, arg1, arg2)
            elseif arg1 then CommF:InvokeServer(action, arg1)
            else CommF:InvokeServer(action) end
        end)
    end
end

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "👑 Polar Hub",
            Text = text or "",
            Duration = duration or 4
        })
    end)
    print("[Polar Hub] " .. tostring(text))
end

local function UpdatePara(para, newDesc)
    if not para then return end
    pcall(function()
        if para.SetDesc then para:SetDesc(newDesc)
        elseif para.Set then para:Set({Desc = newDesc}) end
    end)
end

-- ==================== DATA REGISTRY SEA 1 ====================
Polar.Data = Polar.Data or {}
Polar.Data.QuestToIsland = Polar.Data.QuestToIsland or {}
Polar.Data.QuestGiver = Polar.Data.QuestGiver or {}

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
    {lvl = 450, q = "SkyExp1Quest", ql = 1, name = "God\'s Guard", giver = "Mole", island = "Sky"},
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

for _, q in ipairs(Polar.Data.QuestInfo) do
    Polar.Data.QuestToIsland[q.q] = q.island
    Polar.Data.QuestGiver[q.q] = q.giver
end

-- ==================== INVENTARIO & EQUIPADO ====================
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

-- ==================== COMBATE EXCLUSIVO DE BOSSES ====================
local function ExclusiveTargetLock(targetCF, enemyName, timeoutSecs)
    timeoutSecs = timeoutSecs or 90
    getgenv().PolarFastAttackEnabled = true
    
    local timeout = 0
    while timeout < timeoutSecs do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local target = nil
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Characters")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                if string.find(string.lower(npc.Name), string.lower(enemyName)) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    target = npc
                    break
                end
            end
        end
        
        if target and target:FindFirstChild("HumanoidRootPart") then
            if Polar.Teleport and Polar.Teleport.To then
                Polar.Teleport:To(target.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            else
                hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
            end
            
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
            if Polar.Teleport and Polar.Teleport.To then
                Polar.Teleport:To(targetCF)
            else
                hrp.CFrame = targetCF
            end
            task.wait(1)
            if not Polar.World or not Polar.World:IsEnemyAlive(enemyName) then
                break
            end
        end
        task.wait(0.4)
        timeout = timeout + 1
    end
    
    getgenv().PolarFastAttackEnabled = false
end

-- ==================== AUTO SABER PUZZLE (SERVER-STATE SYNCHRONIZED) ====================
local AutoSaberRunning = false

local function GetProQuestProgress()
    if not CommF then return nil end
    local s, data = pcall(function() return CommF:InvokeServer("ProQuestProgress") end)
    if s and type(data) == "table" then
        return data
    end
    return nil
end

local function FullAutoSaber()
    if AutoSaberRunning then return end
    
    local lvl = Polar.Player and Polar.Player:GetLevel() or 1
    if lvl < 200 then
        Notify("❌ Nivel Insuficiente", "Necesitas Nivel 200+ para el Saber Puzzle.", 5)
        return
    end

    AutoSaberRunning = true
    task.spawn(function()
        getgenv().PolarAutoFarmEnabled = false
        getgenv().PolarAutoFarmBossEnabled = false
        getgenv().PolarAutoFarmAllBossesEnabled = false
        
        Notify("👑 Saber Puzzle", "Iniciando resolución 100% automática sincronizada...", 5)

        -- Coordenadas de las 5 placas de la Jungla
        local PlateCFs = {
            CFrame.new(-1206.94, 25.52, 219.00),
            CFrame.new(-1474.89, 57.05, 58.47),
            CFrame.new(-1703.99, 27.05, 473.30),
            CFrame.new(-1525.18, 24.13, -612.97),
            CFrame.new(-1298.48, 2.24, -802.26)
        }

        while AutoSaberRunning do
            local prog = GetProQuestProgress()
            if not prog then
                task.wait(2)
                prog = GetProQuestProgress()
            end
            
            -- Si ya tiene la espada o derrotó a Shanks
            if HasItem("Saber") or (prog and prog.KilledShanks) then
                Notify("🎉 ¡Completado!", "¡Saber obtenida con éxito! Puzzle 100% Finalizado.", 6)
                AutoSaberRunning = false
                break
            end

            -- FASE 1: Presionar las 5 Placas de la Jungla
            local platesDone = true
            if prog and prog.Plates then
                for i = 1, 5 do
                    if not prog.Plates[i] then
                        platesDone = false
                        Notify("Paso 1: Botones", "Presionando botón #" .. i .. " de la Jungla...", 3)
                        local targetCF = PlateCFs[i]
                        Polar.Teleport:To(targetCF)
                        task.wait(0.5)
                        
                        -- Intentar touchinterest y remoto
                        local btn = workspace.Map:FindFirstChild("Jungle") and workspace.Map.Jungle:FindFirstChild("QuestPlates") and workspace.Map.Jungle.QuestPlates:FindFirstChild("Plate" .. i)
                        local buttonPart = btn and btn:FindFirstChild("Button")
                        if buttonPart and firetouchinterest and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, buttonPart, 0)
                            task.wait(0.1)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, buttonPart, 1)
                        end
                        pcall(function() CommF:InvokeServer("ProQuestProgress", "Plate", i) end)
                        task.wait(1)
                    end
                end
            else
                -- Fallback si el server no respondió la tabla de placas
                for i, cf in ipairs(PlateCFs) do
                    Polar.Teleport:To(cf)
                    task.wait(0.5)
                    pcall(function() CommF:InvokeServer("ProQuestProgress", "Plate", i) end)
                end
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 2: Obtener la Antorcha en el sótano de la Jungla
            if prog and not prog.UsedTorch then
                Notify("Paso 2: Antorcha", "Obteniendo antorcha en el sótano del Quest Giver...", 4)
                local torchBasementCF = CFrame.new(-1679.26, 20.49, 170.77)
                Polar.Teleport:To(torchBasementCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "GetTorch") end)
                task.wait(1)

                -- FASE 3: Ir a Desierto, quemar la puerta con la antorcha y tomar la Copa
                Notify("Paso 3: Desierto", "Quemando la puerta de la casa del Desierto...", 4)
                local desertDoorCF = CFrame.new(1120.86, 0.60, 4388.67)
                Polar.Teleport:To(desertDoorCF)
                task.wait(1)
                EquipToolByName("Torch")
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "DestroyTorch") end)
                task.wait(2)

                Notify("Paso 3: Copa", "Tomando la Copa en el sótano del Desierto...", 4)
                local cupCF = CFrame.new(1109.47, 2.21, 4402.89)
                Polar.Teleport:To(cupCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "GetCup") end)
                task.wait(1)
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 4: Llenar la copa en la Cueva Helada y dársela al Sick Man
            if prog and not prog.UsedCup then
                Notify("Paso 4: Agua Helada", "Llenando copa en la Cueva de Nieve...", 4)
                local waterDripCF = CFrame.new(1330.06, 45.46, -1290.63)
                Polar.Teleport:To(waterDripCF)
                task.wait(1)
                EquipToolByName("Cup")
                task.wait(1)
                
                local cupTool = LocalPlayer.Character:FindFirstChild("Cup") or LocalPlayer.Backpack:FindFirstChild("Cup")
                pcall(function() CommF:InvokeServer("ProQuestProgress", "FillCup", cupTool) end)
                task.wait(2)

                Notify("Paso 4: Sick Man", "Entregando agua al Sick Man en Frozen Village...", 4)
                local sickManCF = CFrame.new(1503.40, 77.35, -1297.55)
                Polar.Teleport:To(sickManCF)
                if not EquipToolByName("FilledCup") then
                    EquipToolByName("Cup")
                end
                pcall(function() CommF:InvokeServer("ProQuestProgress", "SickMan") end)
                task.wait(2)
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 5: Hablar con Rich Man en Pirate Village
            if prog and not prog.TalkedSon then
                Notify("Paso 5: Rich Man", "Hablando con Rich Man en Pirate Village...", 4)
                local richManCF = CFrame.new(-939.34, 26.03, 4114.77)
                Polar.Teleport:To(richManCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "RichSon") end)
                task.wait(2)
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 6: Derrotar al Mob Leader en la Isla Secreta
            if prog and not prog.KilledMob then
                Notify("Paso 6: Mob Leader", "Cazando al Mob Leader en la Isla Secreta...", 4)
                local mobIslandCF = CFrame.new(-2880.72, 15, 5430.85)
                Polar.Teleport:To(mobIslandCF)
                task.wait(1)
                ExclusiveTargetLock(mobIslandCF, "Mob Leader", 90)
                task.wait(1)

                -- Volver con Rich Man a reclamar la Reliquia
                Notify("Paso 6: Reliquia", "Reclamando la Reliquia con Rich Man...", 4)
                local richManCF = CFrame.new(-939.34, 26.03, 4114.77)
                Polar.Teleport:To(richManCF)
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "RichSon") end)
                task.wait(2)
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 7: Colocar la Reliquia en el Altar de Shanks
            if prog and not prog.UsedRelic then
                Notify("Paso 7: Altar Shanks", "Colocando Reliquia en la puerta de Shanks (Jungla)...", 4)
                local relicAltarCF = CFrame.new(-1466.66, 44.64, 47.18)
                Polar.Teleport:To(relicAltarCF)
                task.wait(1)
                EquipToolByName("Relic")
                task.wait(1)
                pcall(function() CommF:InvokeServer("ProQuestProgress", "PlaceRelic") end)
                task.wait(2)
            end

            prog = GetProQuestProgress()
            task.wait(1)

            -- FASE 8: Eliminar a Saber Expert (Shanks)
            if prog and not prog.KilledShanks and not HasItem("Saber") then
                Notify("Paso 8: Shanks", "Derrotando a Saber Expert [Lv. 200]...", 5)
                local shanksVaultCF = CFrame.new(-1527.20, 34.09, -33.16)
                Polar.Teleport:To(shanksVaultCF)
                task.wait(1)
                
                ExclusiveTargetLock(shanksVaultCF, "Saber Expert", 120)
                task.wait(2)
            end

            task.wait(2)
        end
    end)
end

-- ==================== SECRETS MASTER & COMBAT ENGINE ====================
local function GetMomentProgressTable()
    if not RequestBonusMoment then return nil end
    local s, res = pcall(function() return RequestBonusMoment:InvokeServer({Type = "GetMomentProgress"}) end)
    if s and type(res) == "table" and res.Data then
        return res.Data
    end
    return nil
end

local function GetSecretStoriesPhase()
    if not RequestSecretStories then return "Locked" end
    local s, res = pcall(function() return RequestSecretStories:InvokeServer({Type = "GetPhase"}) end)
    if s and type(res) == "table" and res.Phase then
        return res.Phase
    end
    return "Locked"
end

local function CalculateCompletedIslandsCount()
    local data = GetMomentProgressTable()
    if not data then return 0, 13 end
    
    local islandMoments = {
        ["Colosseum"] = {"Sea1/Colosseum/Crowd Favorite", "Sea1/Colosseum/King\'s Apprentice", "Sea1/Colosseum/Legendary Creator Statues"},
        ["Desert"] = {"Sea1/Desert/Archaeologist\'s Tablet", "Sea1/Desert/Prickly Harvest", "Sea1/Desert/Rescue Hasan"},
        ["Fountain"] = {"Sea1/Fountain/Fountain Pipe Repair", "Sea1/Fountain/Fountain Wire Repair", "Sea1/Fountain/Sewer Gangs"},
        ["Frozen Village"] = {"Sea1/Frozen Village/Breaking the Ice", "Sea1/Frozen Village/Frozen Defense", "Sea1/Frozen Village/Snowman"},
        ["Jungle"] = {"Sea1/Jungle/Banana Tree", "Sea1/Jungle/The Thieving Monkey", "Sea1/Jungle/Zipline Repair"},
        ["Magma Village"] = {"Sea1/Magma Village/Evil Slimes", "Sea1/Magma Village/Magma Ore Extraction", "Sea1/Magma Village/One Last Eruption"},
        ["Marine Fortress"] = {"Sea1/Marine Fortress/Battle Plans", "Sea1/Marine Fortress/Fortress Flagpole", "Sea1/Marine Fortress/Fortress Under Fire"},
        ["Middle Town"] = {"Sea1/Middle Town/Early Access", "Sea1/Middle Town/Lookout", "Sea1/Middle Town/X Marks The Spot"},
        ["Pirate Village"] = {"Sea1/Pirate Village/Chef\'s Kiss", "Sea1/Pirate Village/Tavern Brawl", "Sea1/Pirate Village/Windmill Maintenance"},
        ["Prison"] = {"Sea1/Prison/Don Megalo", "Sea1/Prison/Escape from Alcatraz", "Sea1/Prison/Lever Jailbreak"},
        ["Sky"] = {"Sea1/Sky/Electric Fighting Teacher", "Sea1/Sky/The Clown\'s Jewels", "Sea1/Sky/Unexpected Guest"},
        ["SkyArea2"] = {"Sea1/SkyArea2/Echoes Through the Clouds", "Sea1/SkyArea2/Temple Intel", "Sea1/SkyArea2/The Tyrant Awakens"},
        ["Underwater City"] = {"Sea1/Underwater City/Beyond the Bubble", "Sea1/Underwater City/Fishman Karate", "Sea1/Underwater City/Pearl of the Deep"}
    }
    
    local completedIslands = 0
    local totalIslands = 0
    for isl, moments in pairs(islandMoments) do
        totalIslands = totalIslands + 1
        local allDone = true
        for _, m in ipairs(moments) do
            if not data[m] then allDone = false break end
        end
        if allDone then completedIslands = completedIslands + 1 end
    end
    return completedIslands, totalIslands
end

local function AutoRollAllStories()
    if not RequestSecretStories then
        Notify("❌ Error", "Remoto RequestSecretStories no encontrado.", 4)
        return
    end
    
    task.spawn(function()
        Notify("📖 Historias", "Iniciando lectura de historias con Secrets Master...", 4)
        for i = 1, 10 do
            local s, res = pcall(function() return RequestSecretStories:InvokeServer({Type = "RollStories"}) end)
            task.wait(1)
            local currentPhase = GetSecretStoriesPhase()
            if currentPhase == "Complete" then
                Notify("🎉 ¡Completado!", "¡Secrets Master completado! Ahora puedes equipar Combat y Advanced Combat.", 6)
                return
            end
        end
        Notify("Fase Actual", "Fase: " .. tostring(GetSecretStoriesPhase()), 4)
    end)
end

-- ==================== AUTO SECOND SEA PUZZLE ====================
local AutoSecondSeaRunning = false
local function AutoSecondSea()
    if AutoSecondSeaRunning then return end
    
    local lvl = Polar.Player and Polar.Player:GetLevel() or 1
    if lvl < 700 then
        Notify("❌ Error", "Necesitas Nivel 700 para acceder al Second Sea.", 5)
        return
    end

    AutoSecondSeaRunning = true
    task.spawn(function()
        Notify("Paso 1: Detective", "Hablando con Military Detective...", 4)
        local detectiveCF = Polar.World and Polar.World:FindNPC("Military Detective") or CFrame.new(4849, 5, 718)
        
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(detectiveCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() CommF:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() CommF:InvokeServer("DressrosaQuestProgress", "Detective") end)
        
        Notify("Paso 2: Llave", "Esperando llave...", 4)
        local key = nil
        for i = 1, 30 do
            key = LocalPlayer.Backpack:FindFirstChild("Key") or LocalPlayer.Character:FindFirstChild("Key")
            if key then break end
            task.wait(0.5)
        end
        
        Notify("Paso 2: Cueva Helada", "Abriendo puerta en Cueva Helada...", 4)
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
        
        Notify("Paso 3: Ice Admiral", "Eliminando al Ice Admiral...", 4)
        ExclusiveTargetLock(doorStand, "Ice Admiral", 120)
        task.wait(2)

        Notify("Paso 4: Validar Progreso", "Volviendo con Military Detective...", 4)
        while (LocalPlayer.Character.HumanoidRootPart.Position - detectiveCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(detectiveCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = detectiveCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() CommF:InvokeServer("DressrosaQuestProgress") end)
        task.wait(1)
        pcall(function() CommF:InvokeServer("DressrosaQuestProgress", "Detective") end)
        task.wait(2)
        
        Notify("Paso 5: Viajar", "Viajando a Dressrosa con Experienced Captain...", 4)
        local capCF = Polar.World and Polar.World:FindNPC("Experienced Captain") or CFrame.new(-789, 7, 1515)
        while (LocalPlayer.Character.HumanoidRootPart.Position - capCF.Position).Magnitude > 20 and AutoSecondSeaRunning do
            Polar.Teleport:To(capCF * CFrame.new(0, 50, 0))
            task.wait(0.1)
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = capCF * CFrame.new(0, 0, 3)
        task.wait(1)
        
        pcall(function() CommF:InvokeServer("TravelDressrosa") end)
        AutoSecondSeaRunning = false
    end)
end

-- ==================== BUCLE AUTO BUSO HAKI ====================
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

-- ==================== UI RADARS & TELEMETRY ====================
TabStatus:AddSection("Radar de Jefes Especiales (Sea 1)")
local LabelTheSaw = TabStatus:AddParagraph({ Title = "The Saw (Nvl 100) - Middle Town", Text = "Calculando..." })
local LabelGreybeard = TabStatus:AddParagraph({ Title = "Greybeard (Nvl 750) - Marine Fortress", Text = "Calculando..." })
local LabelSaberRadar = TabStatus:AddParagraph({ Title = "Saber Expert (Shanks) - Jungle", Text = "Calculando..." })
local LabelNextRaid = TabStatus:AddParagraph({ Title = "Próximo Jefe Especial (Raid Hint)", Text = "Calculando..." })
local LabelServerUptime = TabStatus:AddParagraph({ Title = "Tiempo de Vida del Servidor", Text = "Calculando..." })
local LabelPlayerTime = TabStatus:AddParagraph({ Title = "Tiempo en Sesión (Jugador)", Text = "Calculando..." })

local scriptStartTime = os.time()
local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            local serverUptime = workspace.DistributedGameTime
            UpdatePara(LabelServerUptime, FormatTime(serverUptime))
            
            local sessionTime = os.time() - scriptStartTime
            UpdatePara(LabelPlayerTime, FormatTime(sessionTime))
            
            local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Characters")
            
            local sawAlive = enemies and enemies:FindFirstChild("The Saw")
            UpdatePara(LabelTheSaw, sawAlive and "🟢 SPAWNEADO! (¡Ve a matarlo!)" or "🔴 MUERTO / NO SPAWNEADO")
            
            local greyAlive = enemies and enemies:FindFirstChild("Greybeard")
            UpdatePara(LabelGreybeard, greyAlive and "🟢 SPAWNEADO! (¡Ve a matarlo!)" or "🔴 MUERTO / NO SPAWNEADO")
            
            local shanksAlive = enemies and enemies:FindFirstChild("Saber Expert")
            UpdatePara(LabelSaberRadar, shanksAlive and "🟢 SPAWNEADO EN BÓVEDA!" or "🔴 NO DISPONIBLE / NO SPAWNEADO")

            if RequestNextRaidHint then
                local s, hint = pcall(function() return RequestNextRaidHint:InvokeServer() end)
                if s and type(hint) == "table" and hint.Boss and hint.Island then
                    local mins = hint.Seconds and math.ceil(hint.Seconds / 60) or 0
                    UpdatePara(LabelNextRaid, string.format("🔮 %s en %s (Estado: %s, ~%d min)", tostring(hint.Boss), tostring(hint.Island), tostring(hint.State or "Desconocido"), mins))
                else
                    UpdatePara(LabelNextRaid, "Sin actividad inminente.")
                end
            end
        end)
    end
end)

-- ==================== TAB FARM BOSSES ====================
TabFarm:AddSection("Cazador de Jefes (Sea 1)")
local BossNamesList = {}
for _, b in ipairs(Polar.Data.Bosses) do table.insert(BossNamesList, b.name) end

TabFarm:AddDropdown({
    Name = "Seleccionar Jefe",
    Options = BossNamesList,
    Default = "Gorilla King",
    Callback = function(Value)
        getgenv().PolarSelectedBossToFarm = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Farm Boss Seleccionado",
    Desc = "Caza exclusivamente al jefe seleccionado arriba.",
    Callback = function(Value)
        getgenv().PolarAutoFarmBossEnabled = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Farm ALL Bosses",
    Desc = "Modo Exterminio: Escanea el servidor y caza a TODOS los jefes vivos.",
    Callback = function(Value)
        getgenv().PolarAutoFarmAllBossesEnabled = Value
        getgenv().PolarLastBossCheckedIndex = 1
    end
})

TabFarm:AddToggle({
    Name = "Tomar Misión del Jefe",
    Callback = function(Value)
        getgenv().PolarBossWithQuest = Value
    end
})

-- ==================== TAB QUEST: SABER PUZZLE ====================
TabQuest:AddSection("Saber Puzzle (100% Automático Sincronizado)")
local SaberStatusPara = TabQuest:AddParagraph({
    Title = "Progreso del Puzzle Saber (Servidor)",
    Text = "Consultando estado en el servidor..."
})

task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            local prog = GetProQuestProgress()
            if prog then
                local pCount = 0
                if prog.Plates then
                    for i = 1, 5 do if prog.Plates[i] then pCount = pCount + 1 end end
                end
                local text = string.format(
                    "Placas: %d/5 | Antorcha: %s | Copa: %s\nSick Man: %s | Rich Son: %s | Mob Leader: %s\nRelic: %s | Shanks: %s",
                    pCount,
                    prog.UsedTorch and "✅" or "❌",
                    prog.UsedCup and "✅" or "❌",
                    prog.TalkedSon and "✅" or "❌",
                    prog.TalkedSon and "✅" or "❌",
                    prog.KilledMob and "✅" or "❌",
                    prog.UsedRelic and "✅" or "❌",
                    prog.KilledShanks and "✅" or "❌"
                )
                UpdatePara(SaberStatusPara, text)
            end
        end)
    end
end)

TabQuest:AddButton({
    Name = "▶ Iniciar Auto Saber Puzzle Completo",
    Callback = function()
        FullAutoSaber()
    end
})

TabQuest:AddButton({
    Name = "⏹ Detener Auto Saber Puzzle",
    Callback = function()
        AutoSaberRunning = false
        Notify("⏹ Auto Saber", "Auto Saber detenido por el usuario.", 3)
    end
})

-- ==================== TAB QUEST: SECRETS MASTER & COMBAT ====================
TabQuest:AddSection("Secrets Master & Estilos Secretos (Sea 1)")
local SecretsStatusPara = TabQuest:AddParagraph({
    Title = "Progreso de Islas & Fase de Secretos",
    Text = "Consultando progreso de las 13 islas..."
})

task.spawn(function()
    while true do
        task.wait(6)
        pcall(function()
            local comp, tot = CalculateCompletedIslandsCount()
            local phase = GetSecretStoriesPhase()
            local text = string.format("Islas Completas: %d / %d (%.1f%%)\nFase de Secretos: %s", comp, tot, (comp / tot) * 100, tostring(phase))
            UpdatePara(SecretsStatusPara, text)
        end)
    end
end)

TabQuest:AddButton({
    Name = "🌀 Teleport a Secrets Master (Middle Town)",
    Callback = function()
        Polar.Teleport:To(CFrame.new(-838.89, 31.77, 1603.10))
    end
})

TabQuest:AddButton({
    Name = "📖 Auto Leer Historias (RollStories)",
    Callback = function()
        AutoRollAllStories()
    end
})

TabQuest:AddButton({
    Name = "🥊 Desbloquear / Equipar Style: Combat",
    Callback = function()
        if CommF then
            local r = CommF:InvokeServer("SetSecretStyle", "Combat")
            if r == 1 then
                Notify("✅ Éxito", "Estilo Combat activado: Back to basics.", 4)
            elseif r == 2 then
                Notify("ℹ️ Info", "Ya tienes equipado el estilo Combat.", 4)
            else
                Notify("❌ Bloqueado", "Aún no has completado todos los secretos del Sea 1.", 4)
            end
        end
    end
})

TabQuest:AddButton({
    Name = "⚡ Desbloquear / Equipar Style: Advanced Combat",
    Callback = function()
        if CommF then
            local r = CommF:InvokeServer("SetSecretStyle", "Advanced Combat")
            if r == 1 then
                Notify("✅ Éxito", "¡Estilo Advanced Combat desbloqueado y equipado!", 5)
            elseif r == 2 then
                Notify("ℹ️ Info", "Ya tienes equipado el estilo Advanced Combat.", 4)
            else
                Notify("❌ Bloqueado", "Aún no has completado todos los secretos del Sea 1.", 4)
            end
        end
    end
})

-- ==================== TAB QUEST: BONUS MOMENTS EXPLORER ====================
TabQuest:AddSection("Explorador de Secretos de Islas (39 Bonus Moments)")

local IslandSecretsLocations = {
    ["Jungle - Zipline Repair"] = CFrame.new(-1282.31, 76.33, -245.48),
    ["Jungle - Banana Tree (Gorilla King)"] = CFrame.new(-1600, 37, 153),
    ["Pirate - Windmill Maintenance"] = CFrame.new(-1231.46, 26.35, 4071.13),
    ["Pirate - Tavern Brawl (Taverna)"] = CFrame.new(-1145, 4.7, 3828.6),
    ["Desert - Rescue Hasan (Cueva Hasan)"] = CFrame.new(1288.51, 31.28, 4490.87),
    ["Desert - Archaeologist\'s Tablet"] = CFrame.new(1094, 20, 4344),
    ["Frozen Village - Snowman Location"] = CFrame.new(1485.22, 76.52, -1283.63),
    ["Frozen Village - Ability Teacher Cave"] = CFrame.new(1344.55, 42.25, -1327.89),
    ["Prison - Escape from Alcatraz"] = CFrame.new(5525.46, 9.01, 933.47),
    ["Prison - Lever Jailbreak (Palancas)"] = CFrame.new(5337.93, 22.10, 841.69),
    ["Middle Town - Early Access (Mansion)"] = CFrame.new(-838.89, 31.77, 1603.10),
    ["Middle Town - Lookout Captain"] = CFrame.new(-789, 7, 1515),
    ["Colosseum - Statues & Arena"] = CFrame.new(-1500, 7, 2500),
    ["Magma Village - Magma Ore / Volcano"] = CFrame.new(-5259, 37, 4050),
    ["Underwater City - Water Kung-fu Teacher"] = CFrame.new(61715.23, 53.00, 871.93),
    ["Sky - Electric Teacher (Mad Scientist)"] = CFrame.new(-4628.89, 12.13, -355.72),
    ["Upper Sky - Instinct Teacher (Ken Haki)"] = CFrame.new(-7374.40, 5791.68, 383.17)
}

local LocationOptions = {}
for locName, _ in pairs(IslandSecretsLocations) do table.insert(LocationOptions, locName) end
table.sort(LocationOptions)

local SelectedSecretLoc = LocationOptions[1]
TabQuest:AddDropdown({
    Name = "Seleccionar Misión Secreta / Zona",
    Options = LocationOptions,
    Default = SelectedSecretLoc,
    Callback = function(val)
        SelectedSecretLoc = val
    end
})

TabQuest:AddButton({
    Name = "🚀 Teleport a Misión Secreta Seleccionada",
    Callback = function()
        local cf = IslandSecretsLocations[SelectedSecretLoc]
        if cf then
            Polar.Teleport:To(cf)
            Notify("🚀 Teleport", "Llegada a: " .. tostring(SelectedSecretLoc), 3)
        end
    end
})

-- ==================== TAB QUEST: SECOND SEA PUZZLE ====================
TabQuest:AddSection("Puzzle Second Sea (Nivel 700+)")
TabQuest:AddButton({
    Name = "▶ Iniciar Viaje al Second Sea",
    Callback = function()
        AutoSecondSea()
    end
})

TabQuest:AddButton({
    Name = "⏹ Detener Viaje",
    Callback = function()
        AutoSecondSeaRunning = false
    end
})

-- ==================== TAB SHOP: HAKI & FIGHTING STYLES SEA 1 ====================
if TabShop then
    TabShop:AddSection("Entrenadores de Haki (Sea 1)")
    
    TabShop:AddButton({ 
        Name = "Comprar Geppo (Skyjump) - $10,000", 
        Callback = function() 
            SafeBuy("BuyHaki", "Geppo", nil, "Ability Teacher") 
        end 
    })
    
    TabShop:AddButton({ 
        Name = "Comprar Buso Haki (Aura) - $25,000", 
        Callback = function() 
            SafeBuy("BuyHaki", "Buso", nil, "Ability Teacher") 
        end 
    })
    
    TabShop:AddButton({ 
        Name = "Comprar Soru (Flash Step) - $100,000", 
        Callback = function() 
            SafeBuy("BuyHaki", "Soru", nil, "Ability Teacher") 
        end 
    })
    
    TabShop:AddButton({ 
        Name = "Auto Desbloquear Ken Haki (Visión) - $750,000", 
        Callback = function() 
            local lvl = Polar.Player and Polar.Player:GetLevel() or 1
            if lvl >= 200 then
                SafeBuy("KenTalk", "Buy", nil, "Instinct Teacher")
            else
                Notify("❌ Nivel Insuficiente", "Necesitas Nivel 200+ y haber vencido a Shanks.", 5)
            end
        end 
    })

    TabShop:AddButton({
        Name = "📊 Consultar Esquivas / Exp Ken Haki",
        Callback = function()
            if CommF then
                local r = CommF:InvokeServer("KenTalk", "Status")
                Notify("👁️ Ken Haki Status", tostring(r or "Sin datos"), 5)
            end
        end
    })

    TabShop:AddSection("Estilos de Pelea (Sea 1)")
    
    TabShop:AddButton({ 
        Name = "Dark Step (Black Leg) - $150,000", 
        Callback = function() 
            SafeBuy("BuyBlackLeg", nil, nil, "Dark Step Teacher") 
        end 
    })
    
    TabShop:AddButton({ 
        Name = "Electro (Skylands) - $500,000", 
        Callback = function() 
            SafeBuy("BuyElectro", nil, nil, "Mad Scientist") 
        end 
    })
    
    TabShop:AddButton({ 
        Name = "Water Kung-fu (Underwater) - $750,000", 
        Callback = function() 
            SafeBuy("BuyFishmanKarate", nil, nil, "Water Kung-fu Teacher") 
        end 
    })
end

-- Asegurar que todos los contenedores inicien en la parte superior (0, 0)
pcall(function()
    local rz = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("redz Library V5")
    if rz then
        for _, c in ipairs(rz:GetDescendants()) do
            if c:IsA("ScrollingFrame") and string.find(c.Name, "Container") then
                c.CanvasPosition = Vector2.new(0, 0)
            end
        end
    end
end)

print("[Polar Hub] ✅ Sea 1 cargado e inicializado al 100% con éxito.")
