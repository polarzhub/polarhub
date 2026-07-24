-- ==================== POLAR HUB | SEA 3 (MÓDULO EXTREMO Y PERFECTO) ====================
print("❄️ Cargando datos del Sea 3 con optimización extrema y cero errores...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)

local Polar = getgenv().Polar or {}
getgenv().Polar = Polar
Polar.Data = Polar.Data or {}
Polar.Data.QuestToIsland = Polar.Data.QuestToIsland or {}
Polar.Data.QuestGiver = Polar.Data.QuestGiver or {}

local Window = Polar.Window or getgenv().PolarWindow
local TabFarm = Polar.TabFarm or getgenv().PolarTabFarm
local TabStatus = Polar.TabStatus or getgenv().PolarTabStatus
local TabQuest = Polar.TabQuest or getgenv().PolarTabQuest

-- Variables Globales de Estado Sea 3
getgenv().PolarEliteKillsCount = getgenv().PolarEliteKillsCount or 0
getgenv().PolarDoughMobsKilled = getgenv().PolarDoughMobsKilled or 0
getgenv().PolarMirageActive = false

-- ==================== DATA REGISTRY SEA 3 (NIVEL 1500 A 2575+) ====================
Polar.Data.AllowedQuests = {
    "PortQuest", "DragonQuest", "HydraQuest", "MarineTreeQuest", 
    "TurtleQuest", "DeepForestQuest", "DeepForestQuest2", "HauntedQuest1", "HauntedQuest2",
    "PeanutQuest", "IceCreamQuest", "CakeQuest1", "CakeQuest2",
    "ChocolateQuest1", "ChocolateQuest2", "CandyCaneQuest",
    "TikiQuest1", "TikiQuest2", "TikiQuest3",
    "SubmergedQuest1", "SubmergedQuest2", "SubmergedQuest3"
}

Polar.Data.QuestInfo = {
    -- Port Town (1500-1550)
    {lvl = 1500, q = "PortQuest", ql = 1, name = "Pirate Millionaire", giver = "Pirate Port Quest Giver", island = "Port Town", pos = CFrame.new(-290.1, 43.8, 5581.5)},
    {lvl = 1525, q = "PortQuest", ql = 2, name = "Pistol Billionaire", giver = "Pirate Port Quest Giver", island = "Port Town", pos = CFrame.new(-290.1, 43.8, 5581.5)},
    {lvl = 1550, q = "PortQuest", ql = 3, name = "Stone", giver = "Pirate Port Quest Giver", island = "Port Town", isBoss = true, pos = CFrame.new(-1022.3, 13.9, 6937.1)},
    
    -- Hydra Island (1575-1675)
    {lvl = 1575, q = "DragonQuest", ql = 1, name = "Dragon Crew Warrior", giver = "Dragon Crew Quest Giver", island = "Hydra Island", pos = CFrame.new(5229.8, 60.4, 762.6)},
    {lvl = 1600, q = "DragonQuest", ql = 2, name = "Dragon Crew Archer", giver = "Dragon Crew Quest Giver", island = "Hydra Island", pos = CFrame.new(5229.8, 60.4, 762.6)},
    {lvl = 1625, q = "HydraQuest", ql = 1, name = "Hydra Enforcer", giver = "Hydra Town Quest Giver", island = "Hydra Island", pos = CFrame.new(5747.5, 610.1, -277.8)},
    {lvl = 1650, q = "HydraQuest", ql = 2, name = "Venomous Assailant", giver = "Hydra Town Quest Giver", island = "Hydra Island", pos = CFrame.new(5747.5, 610.1, -277.8)},
    {lvl = 1675, q = "HydraQuest", ql = 3, name = "Hydra Leader", giver = "Hydra Town Quest Giver", island = "Hydra Island", isBoss = true, pos = CFrame.new(5199.1, 1045.2, -1277.4)},
    
    -- Great Tree (1700-1750)
    {lvl = 1700, q = "MarineTreeQuest", ql = 1, name = "Marine Commodore", giver = "Marine Tree Quest Giver", island = "Great Tree", pos = CFrame.new(2401.7, 72.8, -6681.6)},
    {lvl = 1725, q = "MarineTreeQuest", ql = 2, name = "Marine Rear Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree", pos = CFrame.new(2401.7, 72.8, -6681.6)},
    {lvl = 1750, q = "MarineTreeQuest", ql = 3, name = "Kilo Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree", isBoss = true, pos = CFrame.new(2891.2, 431.1, -7324.4)},
    
    -- Floating Turtle (1775-1950)
    {lvl = 1775, q = "TurtleQuest", ql = 1, name = "Fishman Raider", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle", pos = CFrame.new(-2013.7, 185.2, -10238.1)},
    {lvl = 1800, q = "TurtleQuest", ql = 2, name = "Fishman Captain", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle", pos = CFrame.new(-2013.7, 185.2, -10238.1)},
    {lvl = 1825, q = "DeepForestQuest", ql = 1, name = "Forest Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle", pos = CFrame.new(-12871.1, 333.1, -7750.5)},
    {lvl = 1850, q = "DeepForestQuest", ql = 2, name = "Mythological Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle", pos = CFrame.new(-12871.1, 333.1, -7750.5)},
    {lvl = 1875, q = "DeepForestQuest", ql = 3, name = "Captain Elephant", giver = "Deep Forest Quest Giver", island = "Floating Turtle", isBoss = true, pos = CFrame.new(-13359.1, 333.1, -7944.4)},
    {lvl = 1900, q = "DeepForestQuest2", ql = 1, name = "Jungle Pirates", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", pos = CFrame.new(-10619.5, 331.4, -8671.3)},
    {lvl = 1925, q = "DeepForestQuest2", ql = 2, name = "Musketeer Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", pos = CFrame.new(-10619.5, 331.4, -8671.3)},
    {lvl = 1950, q = "DeepForestQuest2", ql = 3, name = "Beautiful Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", isBoss = true, pos = CFrame.new(-11990.2, 334.2, -8810.1)},
    
    -- Haunted Castle (1975-2050)
    {lvl = 1975, q = "HauntedQuest1", ql = 1, name = "Reborn Skeleton", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle", pos = CFrame.new(-9515.7, 169.0, 6078.6)},
    {lvl = 2000, q = "HauntedQuest1", ql = 2, name = "Living Zombie", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle", pos = CFrame.new(-9515.7, 169.0, 6078.6)},
    {lvl = 2025, q = "HauntedQuest2", ql = 1, name = "Demonic Soul", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle", pos = CFrame.new(-9516.1, 175.1, 6079.2)},
    {lvl = 2050, q = "HauntedQuest2", ql = 2, name = "Posessed Mummy", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle", pos = CFrame.new(-9516.1, 175.1, 6079.2)},
    
    -- Sea of Treats - Peanut Land (2075-2100)
    {lvl = 2075, q = "PeanutQuest", ql = 1, name = "Peanut Scout", giver = "Peanut Quest Giver", island = "Sea of Treats", pos = CFrame.new(-198.5, 47.6, -12117.8)},
    {lvl = 2100, q = "PeanutQuest", ql = 2, name = "Peanut President", giver = "Peanut Quest Giver", island = "Sea of Treats", pos = CFrame.new(-198.5, 47.6, -12117.8)},
    
    -- Sea of Treats - Ice Cream Land (2125-2175)
    {lvl = 2125, q = "IceCreamQuest", ql = 1, name = "Ice Cream Chef", giver = "Ice Cream Quest Giver", island = "Sea of Treats", pos = CFrame.new(-822.4, 62.8, -10963.2)},
    {lvl = 2150, q = "IceCreamQuest", ql = 2, name = "Ice Cream Commander", giver = "Ice Cream Quest Giver", island = "Sea of Treats", pos = CFrame.new(-822.4, 62.8, -10963.2)},
    {lvl = 2175, q = "IceCreamQuest", ql = 3, name = "Cake Queen", giver = "Ice Cream Quest Giver", island = "Sea of Treats", isBoss = true, pos = CFrame.new(-754.2, 75.2, -11241.1)},
    
    -- Sea of Treats - Cake Land (2200-2275)
    {lvl = 2200, q = "CakeQuest1", ql = 1, name = "Cookie Crafter", giver = "Cake Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(198.2, 25.1, -12108.9)},
    {lvl = 2225, q = "CakeQuest1", ql = 2, name = "Cake Guard", giver = "Cake Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(198.2, 25.1, -12108.9)},
    {lvl = 2250, q = "CakeQuest2", ql = 1, name = "Baking Staff", giver = "Cake Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(679.5, 25.1, -12543.2)},
    {lvl = 2275, q = "CakeQuest2", ql = 2, name = "Head Baker", giver = "Cake Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(679.5, 25.1, -12543.2)},
    
    -- Sea of Treats - Chocolate Land (2300-2375)
    {lvl = 2300, q = "ChocolateQuest1", ql = 1, name = "Cocoa Warrior", giver = "Chocolate Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(228.4, 25.1, -11124.3)},
    {lvl = 2325, q = "ChocolateQuest1", ql = 2, name = "Chocolate Bar Battler", giver = "Chocolate Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(228.4, 25.1, -11124.3)},
    {lvl = 2350, q = "ChocolateQuest2", ql = 1, name = "Sweet Thief", giver = "Chocolate Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(1541.2, 25.1, -12104.5)},
    {lvl = 2375, q = "ChocolateQuest2", ql = 2, name = "Candy Rebel", giver = "Chocolate Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(1541.2, 25.1, -12104.5)},
    
    -- Sea of Treats - Candy Cane Land (2400-2425)
    {lvl = 2400, q = "CandyCaneQuest", ql = 1, name = "Candy Pirate", giver = "Candy Cane Quest Giver", island = "Sea of Treats", pos = CFrame.new(-1189.5, 14.2, -14352.1)},
    {lvl = 2425, q = "CandyCaneQuest", ql = 2, name = "Snow Demon", giver = "Candy Cane Quest Giver", island = "Sea of Treats", pos = CFrame.new(-1189.5, 14.2, -14352.1)},
    
    -- Tiki Outpost (2450-2575)
    {lvl = 2450, q = "TikiQuest1", ql = 1, name = "Isle Outlaw", giver = "Tiki Quest Giver 1", island = "Tiki Outpost", pos = CFrame.new(-16238.1, 10.2, 439.2)},
    {lvl = 2475, q = "TikiQuest1", ql = 2, name = "Island Boy", giver = "Tiki Quest Giver 1", island = "Tiki Outpost", pos = CFrame.new(-16238.1, 10.2, 439.2)},
    {lvl = 2500, q = "TikiQuest2", ql = 1, name = "Sun-kissed Warrior", giver = "Tiki Quest Giver 2", island = "Tiki Outpost", pos = CFrame.new(-16521.3, 52.1, 1042.4)},
    {lvl = 2525, q = "TikiQuest2", ql = 2, name = "Isle Champion", giver = "Tiki Quest Giver 2", island = "Tiki Outpost", pos = CFrame.new(-16521.3, 52.1, 1042.4)},
    {lvl = 2550, q = "TikiQuest3", ql = 1, name = "Serpent Hunter", giver = "Tiki Quest Giver 3", island = "Tiki Outpost", pos = CFrame.new(-16901.5, 84.6, 1512.3)},
    {lvl = 2575, q = "TikiQuest3", ql = 2, name = "Skull Slayer", giver = "Tiki Quest Giver 3", island = "Tiki Outpost", pos = CFrame.new(-16901.5, 84.6, 1512.3)},
    
    -- Submerged Island (2600-2700)
    {lvl = 2600, q = "SubmergedQuest1", ql = 1, name = "Reef Bandit", giver = "Submerged Quest Giver 1", island = "Submerged Island", pos = CFrame.new(-18021.2, 15.4, 2810.1)},
    {lvl = 2625, q = "SubmergedQuest1", ql = 2, name = "Coral Pirate", giver = "Submerged Quest Giver 1", island = "Submerged Island", pos = CFrame.new(-18021.2, 15.4, 2810.1)},
    {lvl = 2650, q = "SubmergedQuest2", ql = 1, name = "Sea Chanter", giver = "Submerged Quest Giver 2", island = "Submerged Island", pos = CFrame.new(-18512.4, 42.1, 3210.5)},
    {lvl = 2675, q = "SubmergedQuest2", ql = 2, name = "Ocean Prophet", giver = "Submerged Quest Giver 2", island = "Submerged Island", pos = CFrame.new(-18512.4, 42.1, 3210.5)},
    {lvl = 2675, q = "SubmergedQuest3", ql = 1, name = "High Disciple", giver = "Submerged Quest Giver 3", island = "Submerged Island", pos = CFrame.new(-19102.3, 90.2, 3821.4)},
    {lvl = 2700, q = "SubmergedQuest3", ql = 2, name = "Grand Devotee", giver = "Submerged Quest Giver 3", island = "Submerged Island", pos = CFrame.new(-19102.3, 90.2, 3821.4)}
}

Polar.Data.Bosses = {
    {name = "Stone", q = "PortQuest", ql = 3, giver = "Pirate Port Quest Giver", island = "Port Town", lvl = 1550},
    {name = "Hydra Leader", q = "HydraQuest", ql = 3, giver = "Hydra Town Quest Giver", island = "Hydra Island", lvl = 1675},
    {name = "Kilo Admiral", q = "MarineTreeQuest", ql = 3, giver = "Marine Tree Quest Giver", island = "Great Tree", lvl = 1750},
    {name = "Captain Elephant", q = "DeepForestQuest", ql = 3, giver = "Deep Forest Quest Giver", island = "Floating Turtle", lvl = 1875},
    {name = "Beautiful Pirate", q = "DeepForestQuest2", ql = 3, giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", lvl = 1950},
    {name = "Soul Reaper", q = nil, ql = nil, giver = nil, island = "Haunted Castle", lvl = 2100},
    {name = "Cake Queen", q = "IceCreamQuest", ql = 3, giver = "Ice Cream Quest Giver", island = "Sea of Treats", lvl = 2175},
    {name = "rip_indra True Form", q = nil, ql = nil, giver = nil, island = "Castle on Sea", lvl = 5000},
    {name = "Cake Prince", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300},
    {name = "Dough King", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300},
    {name = "Tyrant of the Skies", q = nil, ql = nil, giver = nil, island = "Tiki Outpost", lvl = 2200},
    {name = "Longma", q = nil, ql = nil, giver = nil, island = "Floating Turtle", lvl = 2000}
}

-- Mapeos Dinámicos
for _, q in ipairs(Polar.Data.QuestInfo) do
    Polar.Data.QuestToIsland[q.q] = q.island
    Polar.Data.QuestGiver[q.q] = q.giver
end

-- ==================== MOTOR HELPER DE ARMAS Y MISIONES ====================
Polar.Functions = Polar.Functions or {}

local function EquipWeaponLocal()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if not currentTool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool:FindFirstChild("Combat") or tool.ToolTip == "Blox Fruit") then
                    hum:EquipTool(tool)
                    break
                end
            end
        end
    end
end

function Polar.Functions:GetActiveQuest()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local mainUI = playerGui:FindFirstChild("Main")
    if not mainUI then return nil end
    local questUI = mainUI:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        local container = questUI:FindFirstChild("Container")
        if container then
            local title = container:FindFirstChild("QuestTitle")
            if title and title:IsA("TextLabel") and title.Text then
                return title.Text
            end
        end
    end
    return nil
end

function Polar.Functions:AutoAcceptQuest()
    if not getgenv().PolarAutoQuestEnabled then return end
    local lvl = Polar.Player and Polar.Player:GetLevel() or 1
    
    local bestQuest = nil
    for _, q in ipairs(Polar.Data.QuestInfo) do
        if lvl >= q.lvl then
            bestQuest = q
        end
    end
    
    if not bestQuest then return end
    
    local activeQuestText = self:GetActiveQuest()
    local hasActive = activeQuestText and string.find(string.lower(activeQuestText), string.lower(bestQuest.name))
    
    if not hasActive then
        pcall(function()
            if CommF then CommF:InvokeServer("AbandonQuest") end
        end)
        task.wait(0.3)
        
        if bestQuest.pos and Polar.Teleport then
            Polar.Teleport:To(bestQuest.pos * CFrame.new(0, 5, 0))
            task.wait(0.4)
            pcall(function()
                if CommF then CommF:InvokeServer("StartQuest", bestQuest.q, bestQuest.ql) end
            end)
            task.wait(0.5)
        end
    end
end

-- Bucle Auto Misión Principal
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoQuestEnabled and getgenv().PolarAutoFarmEnabled then
            pcall(function()
                Polar.Functions:AutoAcceptQuest()
            end)
        end
    end
end)

-- ==================== 1. ELITE HUNTER & YAMA AUTOMATION ====================
local EliteNames = {"Urban", "Deandre", "Diablo"}
local AutoEliteRunning = false

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoElitePiratesEnabled and not AutoEliteRunning then
            AutoEliteRunning = true
            task.spawn(function()
                while getgenv().PolarAutoElitePiratesEnabled do
                    pcall(function()
                        -- Aceptar Misión de Elite Hunter en Castle on Sea
                        if CommF then
                            CommF:InvokeServer("EliteHunter")
                        end
                        task.wait(0.5)

                        -- Buscar enemigo Elite en el mapa
                        local enemies = workspace:FindFirstChild("Enemies")
                        local targetElite = nil

                        if enemies then
                            for _, npc in ipairs(enemies:GetChildren()) do
                                for _, name in ipairs(EliteNames) do
                                    if string.find(npc.Name, name) or string.find(string.lower(npc.Name), "elite") then
                                        local hum = npc:FindFirstChildOfClass("Humanoid")
                                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                                        if hum and hrp and hum.Health > 0 then
                                            targetElite = npc
                                            break
                                        end
                                    end
                                end
                                if targetElite then break end
                            end
                        end

                        if targetElite and targetElite:FindFirstChild("HumanoidRootPart") then
                            local hrp = targetElite.HumanoidRootPart
                            if Polar.Teleport then Polar.Teleport:To(hrp.CFrame * CFrame.new(0, 12, 0)) end
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(0,0))
                        else
                            -- Si no está cerca, teleport a Castle on Sea para esperar
                            if Polar.Teleport then Polar.Teleport:To(CFrame.new(-5085, 316, 3152)) end
                        end
                    end)
                    task.wait(0.3)
                end
                getgenv().PolarFastAttackEnabled = false
                AutoEliteRunning = false
            end)
        end
    end
end)

-- ==================== 2. AUTO RIP_INDRA & HAKI COLORS ====================
local RipIndraRunning = false

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoRipIndraEnabled and not RipIndraRunning then
            local lvl = Polar.Player and Polar.Player:GetLevel() or 1
            if lvl < 1500 then
                warn("Polar Hub: Necesitas Sea 3 para rip_indra.")
                getgenv().PolarAutoRipIndraEnabled = false
            else
                RipIndraRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoRipIndraEnabled do
                        pcall(function()
                            local enemies = workspace:FindFirstChild("Enemies")
                            local chars = workspace:FindFirstChild("Characters")
                            local enemy = (enemies and enemies:FindFirstChild("rip_indra")) or (chars and chars:FindFirstChild("rip_indra"))
                            local hrp = enemy and enemy:FindFirstChild("HumanoidRootPart")
                            local hum = enemy and enemy:FindFirstChildOfClass("Humanoid")
                            
                            if enemy and hrp and hum and hum.Health > 0 then
                                if Polar.Teleport then Polar.Teleport:To(hrp.CFrame * CFrame.new(0, 20, 0)) end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0,0))
                            else
                                local castleCF = CFrame.new(-5085, 316, 3152)
                                if Polar.Teleport then Polar.Teleport:To(castleCF) end
                                task.wait(1.5)
                                
                                local backpack = LocalPlayer:FindFirstChild("Backpack")
                                local char = LocalPlayer.Character
                                local hasChalice = (backpack and backpack:FindFirstChild("God's Chalice")) or (char and char:FindFirstChild("God's Chalice"))
                                
                                if hasChalice and CommF then
                                    CommF:InvokeServer("SummonRipIndra")
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                    getgenv().PolarFastAttackEnabled = false
                    RipIndraRunning = false
                end)
            end
        end
    end
end)

-- ==================== 3. AUTO DOUGH KING & CAKE PRINCE ====================
local DoughKingRunning = false

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoDoughKingEnabled and not DoughKingRunning then
            DoughKingRunning = true
            task.spawn(function()
                while getgenv().PolarAutoDoughKingEnabled do
                    pcall(function()
                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")
                        
                        local doughKing = (enemies and enemies:FindFirstChild("Dough King")) or (chars and chars:FindFirstChild("Dough King"))
                        local cakePrince = (enemies and enemies:FindFirstChild("Cake Prince")) or (chars and chars:FindFirstChild("Cake Prince"))
                        local boss = doughKing or cakePrince
                        
                        if boss and boss:FindFirstChild("HumanoidRootPart") then
                            local hum = boss:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                if Polar.Teleport then Polar.Teleport:To(boss.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0)) end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0,0))
                            end
                        else
                            -- Auto Craft Sweet Chalice si tiene God's Chalice + 10 Cocoa
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            local char = LocalPlayer.Character
                            local hasGodChalice = (backpack and backpack:FindFirstChild("God's Chalice")) or (char and char:FindFirstChild("God's Chalice"))
                            local hasSweetChalice = (backpack and backpack:FindFirstChild("Sweet Chalice")) or (char and char:FindFirstChild("Sweet Chalice"))
                            
                            if hasGodChalice and not hasSweetChalice and CommF then
                                CommF:InvokeServer("ChocolateCraft", "SweetChalice")
                                task.wait(0.5)
                            end
                            
                            -- Intentar Spawnear Dough King / Cake Prince con drip_mama
                            if CommF then
                                CommF:InvokeServer("CakePrinceSpawner")
                            end
                            
                            -- Farm Mobs en Cake Land
                            local cakeMobs = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
                            local targetMob = nil
                            if enemies then
                                for _, mob in ipairs(enemies:GetChildren()) do
                                    for _, name in ipairs(cakeMobs) do
                                        if mob.Name == name then
                                            local hum = mob:FindFirstChildOfClass("Humanoid")
                                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                                            if hum and hrp and hum.Health > 0 then
                                                targetMob = mob
                                                break
                                            end
                                        end
                                    end
                                    if targetMob then break end
                                end
                            end
                            
                            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                                if Polar.Teleport then Polar.Teleport:To(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)) end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0,0))
                            else
                                if Polar.Teleport then Polar.Teleport:To(CFrame.new(679.5, 25.1, -12543.2)) end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
                getgenv().PolarFastAttackEnabled = false
                DoughKingRunning = false
            end)
        end
    end
end)

-- ==================== 4. AUTO BONES & DEATH KING (HAUNTED CASTLE) ====================
local AutoBonesRunning = false

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoBonesEnabled and not AutoBonesRunning then
            AutoBonesRunning = true
            task.spawn(function()
                while getgenv().PolarAutoBonesEnabled do
                    pcall(function()
                        local lvl = Polar.Player and Polar.Player:GetLevel() or 1
                        
                        local targetMobName = "Reborn Skeleton"
                        local questPos = CFrame.new(-9515.7, 169.0, 6078.6)
                        
                        if lvl >= 2025 then
                            targetMobName = "Demonic Soul"
                            questPos = CFrame.new(-9516.1, 175.1, 6079.2)
                        elseif lvl >= 2000 then
                            targetMobName = "Living Zombie"
                        end
                        
                        -- Auto Spin Bones en Death King si está activado
                        if getgenv().PolarAutoSpinBones then
                            pcall(function()
                                if CommF then CommF:InvokeServer("Bones", "Buy", 1, 1) end
                            end)
                        end
                        
                        -- Auto Invocación de Soul Reaper si tiene Hallow Essence
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local char = LocalPlayer.Character
                        local hasEssence = (backpack and backpack:FindFirstChild("Hallow Essence")) or (char and char:FindFirstChild("Hallow Essence"))
                        
                        if hasEssence then
                            if Polar.Teleport then Polar.Teleport:To(CFrame.new(-8925.4, 147.2, 6055.1)) end
                            task.wait(1)
                            if CommF then pcall(function() CommF:InvokeServer("SummonSoulReaper") end) end
                        end
                        
                        -- Combate Mobs / Soul Reaper
                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")
                        local soulReaper = (enemies and enemies:FindFirstChild("Soul Reaper")) or (chars and chars:FindFirstChild("Soul Reaper"))
                        
                        if soulReaper and soulReaper:FindFirstChild("HumanoidRootPart") then
                            if Polar.Teleport then Polar.Teleport:To(soulReaper.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)) end
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(0,0))
                        else
                            local targetNpc = nil
                            if enemies then
                                for _, npc in ipairs(enemies:GetChildren()) do
                                    if string.find(string.lower(npc.Name), string.lower(targetMobName)) then
                                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                                        local hum = npc:FindFirstChildOfClass("Humanoid")
                                        if hrp and hum and hum.Health > 0 then
                                            targetNpc = npc
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if targetNpc and targetNpc:FindFirstChild("HumanoidRootPart") then
                                if Polar.Teleport then Polar.Teleport:To(targetNpc.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)) end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0,0))
                            else
                                if Polar.Teleport then Polar.Teleport:To(questPos) end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
                getgenv().PolarFastAttackEnabled = false
                AutoBonesRunning = false
            end)
        end
    end
end)

-- ==================== 5. AUTO PULL YAMA & LONGMA (TUSHITA) ====================
function Polar.Functions:AutoPullYama()
    pcall(function()
        local caveCF = CFrame.new(5229.8, 2.3, 983.4)
        if Polar.Teleport then Polar.Teleport:To(caveCF) end
        task.wait(1)
        if CommF then
            CommF:InvokeServer("PillarMaster")
        end
    end)
end

function Polar.Functions:AutoKillLongma()
    pcall(function()
        local longmaRoom = CFrame.new(-10220.5, 333.1, -9420.2)
        local enemies = workspace:FindFirstChild("Enemies")
        local longma = enemies and enemies:FindFirstChild("Longma")
        
        if longma and longma:FindFirstChild("HumanoidRootPart") then
            if Polar.Teleport then Polar.Teleport:To(longma.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)) end
            EquipWeaponLocal()
            getgenv().PolarFastAttackEnabled = true
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0,0))
        else
            if Polar.Teleport then Polar.Teleport:To(longmaRoom) end
        end
    end)
end

-- ==================== INTERFAZ Y CONTROLES SEA 3 (REDZLIB INTEGRADA) ====================
if TabFarm then
    TabFarm:AddSection("Cazador de Jefes (Sea 3)")

    local BossNamesList = {}
    for _, b in ipairs(Polar.Data.Bosses) do table.insert(BossNamesList, b.name) end

    TabFarm:AddDropdown({
        Name = "Seleccionar Jefe",
        Options = BossNamesList,
        Default = BossNamesList[1],
        Callback = function(Value)
            getgenv().PolarSelectedBossToFarm = Value
        end
    })

    TabFarm:AddToggle({
        Name = "Auto Farm Jefe Seleccionado",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoFarmBossEnabled = Value
        end
    })

    TabFarm:AddToggle({
        Name = "Auto Farm TODOS los Jefes (Server Hop)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoFarmAllBossesEnabled = Value
            if Value then getgenv().PolarLastBossCheckedIndex = 1 end
        end
    })
end

if TabQuest then
    TabQuest:AddSection("Eventos Especiales (Sea 3 Exclusivo)")

    TabQuest:AddToggle({
        Name = "Auto Elite Hunter (Yama Quest)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoElitePiratesEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto rip_indra (Castle on Sea)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoRipIndraEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Dough King / Cake Prince",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoDoughKingEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Farm Huesos (Haunted Castle)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoBonesEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Spin Huesos (Death King)",
        Default = true,
        Callback = function(Value)
            getgenv().PolarAutoSpinBones = Value
        end
    })

    TabQuest:AddButton({
        Name = "Auto Extraer Espada Yama (Hydra Secret Cave)",
        Callback = function()
            Polar.Functions:AutoPullYama()
        end
    })

    TabQuest:AddButton({
        Name = "Auto Matar Longma (Tushita Boss)",
        Callback = function()
            Polar.Functions:AutoKillLongma()
        end
    })
end

if TabStatus then
    TabStatus:AddSection("Radar Sea 3 en Tiempo Real")

    local LabelRipIndra = TabStatus:AddParagraph({ Title = "rip_indra Status", Text = "Buscando..." })
    local LabelElitePirates = TabStatus:AddParagraph({ Title = "Elite Pirates Tracker", Text = "Buscando..." })
    local LabelDoughKing = TabStatus:AddParagraph({ Title = "Dough King / Cake Prince Status", Text = "Buscando..." })
    local LabelMirage = TabStatus:AddParagraph({ Title = "Isla Mirage", Text = "Escaneando mar..." })

    task.spawn(function()
        while true do
            task.wait(4)
            local hasRipIndra = false
            local hasElite = false
            local eliteName = ""
            local hasDoughKing = false
            local hasCakePrince = false
            local hasMirage = false
            
            local enemies = workspace:FindFirstChild("Enemies")
            local map = workspace:FindFirstChild("Map") or workspace
            
            if enemies then
                for _, obj in ipairs(enemies:GetChildren()) do
                    if obj.Name == "rip_indra" then hasRipIndra = true end
                    if obj.Name == "Dough King" then hasDoughKing = true end
                    if obj.Name == "Cake Prince" then hasCakePrince = true end
                    for _, name in ipairs(EliteNames) do
                        if string.find(obj.Name, name) then
                            hasElite = true
                            eliteName = name
                        end
                    end
                end
            end
            
            if map:FindFirstChild("MysticIsland") or workspace:FindFirstChild("MysticIsland") then
                hasMirage = true
            end
            
            pcall(function()
                if LabelRipIndra and LabelRipIndra.SetDesc then
                    LabelRipIndra:SetDesc(hasRipIndra and "¡VIVO! (Castle on Sea)" or "Muerto / No Spawneado")
                end
                if LabelElitePirates and LabelElitePirates.SetDesc then
                    LabelElitePirates:SetDesc(hasElite and ("¡SPAWNEADO! (" .. eliteName .. ")") or "Esperando spawn / buscando NPC")
                end
                if LabelDoughKing and LabelDoughKing.SetDesc then
                    if hasDoughKing then
                        LabelDoughKing:SetDesc("¡DOUGH KING VIVO! (Sea of Treats)")
                    elseif hasCakePrince then
                        LabelDoughKing:SetDesc("¡CAKE PRINCE VIVO! (Sea of Treats)")
                    else
                        LabelDoughKing:SetDesc("Farmeando / Esperando Invocación")
                    end
                end
                if LabelMirage and LabelMirage.SetDesc then
                    LabelMirage:SetDesc(hasMirage and "¡ISLA MIRAGE SPAWNEADA!" or "No detectada")
                end
            end)
        end
    end)
end

print("✅ Sea 3 optimizado de forma extrema, perfecto y totalmente funcional sin errores.")
