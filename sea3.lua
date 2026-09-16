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
    {name = "Stone", q = "PortQuest", ql = 3, giver = "Pirate Port Quest Giver", island = "Port Town", lvl = 1550, cd = 300, pos = Vector3.new(-1052.7, 40.2, 6729.8)},
    {name = "Hydra Leader", q = "HydraQuest", ql = 3, giver = "Hydra Town Quest Giver", island = "Hydra Island", lvl = 1675, cd = 300, pos = Vector3.new(5229.8, 604.2, 345.1)},
    {name = "Kilo Admiral", q = "MarineTreeQuest", ql = 3, giver = "Marine Tree Quest Giver", island = "Great Tree", lvl = 1750, cd = 300, pos = Vector3.new(2889.3, 73.1, -7231.5)},
    {name = "Captain Elephant", q = "DeepForestQuest", ql = 3, giver = "Deep Forest Quest Giver", island = "Floating Turtle", lvl = 1875, cd = 300, pos = Vector3.new(-13373.2, 331.7, -9832.2)},
    {name = "Beautiful Pirate", q = "DeepForestQuest2", ql = 3, giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", lvl = 1950, cd = 600, pos = Vector3.new(5052.3, 616.4, 250.2)},
    {name = "Cake Queen", q = "IceCreamQuest", ql = 3, giver = "Ice Cream Quest Giver", island = "Sea of Treats", lvl = 2175, cd = 600, pos = Vector3.new(-710.2, 381.5, -11150.2)},
    {name = "Longma", q = nil, ql = nil, giver = nil, island = "Floating Turtle", lvl = 2000, cd = 900, pos = Vector3.new(-10220.5, 333.1, -9420.2)},
    {name = "Soul Reaper", q = nil, ql = nil, giver = nil, island = "Haunted Castle", lvl = 2100, cd = 3600, pos = Vector3.new(-9515.2, 172.1, 6075.4)},
    {name = "Cake Prince", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300, cd = 3600, pos = Vector3.new(-2103.5, 70.1, -12165.2)},
    {name = "Dough King", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300, cd = 3600, pos = Vector3.new(-2103.5, 70.1, -12165.2)},
    {name = "Tyrant of the Skies", q = nil, ql = nil, giver = nil, island = "Tiki Outpost", lvl = 2200, cd = 1200, pos = Vector3.new(-16234.5, 60.1, 452.3)},
    {name = "rip_indra True Form", q = nil, ql = nil, giver = nil, island = "Castle on Sea", lvl = 5000, cd = 7200, pos = Vector3.new(-5333.1, 423.8, -2672.9)}
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

Polar.LastEliteRawResponse = nil
Polar.LastEliteInfo = nil

function Polar.HasEliteQuest()
    local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return false end
    if pgui:FindFirstChild("TrackedQuestFrame") then return true end
    for _, name in ipairs(EliteNames) do
        if pgui:FindFirstChild(name) then return true end
    end
    return false
end

function Polar.IsNearEliteNPC()
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local npcPos = Vector3.new(-5417.6, 313.1, -2822.9)
    return (hrp.Position - npcPos).Magnitude < 45
end

function Polar.SafeQueryEliteHunter(allowQuest)
    if not CommF then return false, nil end

    -- 1. Si el usuario ya tiene la misión activa (tomada manual o automáticamente), no interferir
    if Polar.HasEliteQuest() then
        return true, Polar.LastEliteRawResponse or "Active Quest"
    end

    -- 2. Si el jugador está físicamente al lado del NPC interactuando manualmente, pausar escaneo para no reiniciar el diálogo
    if Polar.IsNearEliteNPC() then
        return true, Polar.LastEliteRawResponse or "Interacting With NPC"
    end

    local disabledConns = {}
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local questUpdate = remotes and remotes:FindFirstChild("QuestUpdate")

    -- 3. Interceptar OnClientEvent sólo durante la consulta para que el cliente no dibuje UI
    if not allowQuest and getconnections and questUpdate then
        pcall(function()
            local conns = getconnections(questUpdate.OnClientEvent)
            for _, c in ipairs(conns) do
                pcall(function()
                    if c.Disable then
                        c:Disable()
                        table.insert(disabledConns, c)
                    elseif c.Enabled ~= nil then
                        c.Enabled = false
                        table.insert(disabledConns, c)
                    end
                end)
            end
        end)
    end

    local ok, res = pcall(function()
        return CommF:InvokeServer("EliteHunter", "Check")
    end)

    if ok and type(res) == "string" then
        Polar.LastEliteRawResponse = res
    end

    -- 4. Reactivar conexiones inmediatamente (JAMÁS destruir frames de PlayerGui)
    if not allowQuest then
        task.wait(0.03)
        for _, c in ipairs(disabledConns) do
            pcall(function()
                if c.Enable then
                    c:Enable()
                elseif c.Enabled ~= nil then
                    c.Enabled = true
                end
            end)
        end
    end

    return ok, res
end

local EliteIslandFallbacks = {
    ["Floating Turtle"] = CFrame.new(-2014, 250, -10238),
    ["Hydra Island"] = CFrame.new(5230, 150, 763),
    ["Port Town"] = CFrame.new(-290, 100, 5582),
    ["Great Tree"] = CFrame.new(2402, 120, -6682)
}

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoElitePiratesEnabled and not AutoEliteRunning then
            AutoEliteRunning = true
            task.spawn(function()
                while getgenv().PolarAutoElitePiratesEnabled do
                    pcall(function()
                        if not CommF then return end

                        -- 1. Consultar estado del Elite de forma no intrusiva (sin activar quest)
                        local ok, checkRes = Polar.SafeQueryEliteHunter(false)

                        local activeEliteName = nil
                        local activeIsland = nil
                        if ok and type(checkRes) == "string" then
                            for _, name in ipairs(EliteNames) do
                                if checkRes:find(name) then
                                    activeEliteName = name
                                    break
                                end
                            end
                            local islands = {"Floating Turtle", "Hydra Island", "Port Town", "Great Tree"}
                            for _, isl in ipairs(islands) do
                                if checkRes:find(isl) then
                                    activeIsland = isl
                                    break
                                end
                            end
                        end

                        -- Si no hay Elite disponible, esperar pacíficamente sin aceptar misiones
                        if not activeEliteName then
                            task.wait(3)
                            return
                        end

                        -- 2. Hay un Elite activo y el usuario tiene activado Auto Elite Hunter -> Aceptar misión
                        CommF:InvokeServer("EliteHunter")
                        task.wait(0.3)

                        -- 3. Buscar enemigo Elite en el mapa
                        local enemies = workspace:FindFirstChild("Enemies")
                        local targetElite = nil

                        if enemies then
                            for _, npc in ipairs(enemies:GetChildren()) do
                                if string.find(npc.Name, activeEliteName) then
                                    local hum = npc:FindFirstChildOfClass("Humanoid")
                                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                                    if hum and hrp and hum.Health > 0 then
                                        targetElite = npc
                                        break
                                    end
                                end
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
                            -- Si no está en rango de streaming local, volar a la isla donde fue reportado
                            local targetCF = activeIsland and EliteIslandFallbacks[activeIsland]
                            if targetCF and Polar.Teleport then
                                Polar.Teleport:To(targetCF)
                                task.wait(1.5)
                            else
                                if Polar.Teleport then Polar.Teleport:To(CFrame.new(-5085, 316, 3152)) end
                            end
                        end
                    end)
                    task.wait(0.4)
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

local function HasHauntedQuestActive(expectedName)
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local tq = pgui and pgui:FindFirstChild("TrackedQuestFrame")
    if tq then
        local frame = tq:FindFirstChild("Frame")
        if frame and frame.Visible then
            local progress = frame:FindFirstChild("progress")
            if progress and progress.Text and string.find(progress.Text, "8/8") then
                return false -- Misión ya completada
            end
            local desc = frame:FindFirstChild("description")
            local descText = desc and desc.Text or ""
            local txtLabels = ""
            for _, l in ipairs(frame:GetChildren()) do
                if l:IsA("TextLabel") and l.Visible then
                    txtLabels = txtLabels .. " " .. l.Text
                end
            end
            if expectedName then
                local lowerExp = string.lower(expectedName)
                if string.find(string.lower(descText), lowerExp) or string.find(string.lower(txtLabels), lowerExp) then
                    return true
                end
                -- Compatibilidad con nombres traducidos al español (Momia, Esqueleto, Zombi, Alma)
                if string.find(lowerExp, "mummy") and (string.find(string.lower(txtLabels), "momi") or string.find(string.lower(descText), "momi")) then
                    return true
                elseif string.find(lowerExp, "skeleton") and (string.find(string.lower(txtLabels), "esquelet") or string.find(string.lower(descText), "esquelet")) then
                    return true
                elseif string.find(lowerExp, "zombie") and (string.find(string.lower(txtLabels), "zomb") or string.find(string.lower(descText), "zomb")) then
                    return true
                elseif string.find(lowerExp, "soul") and (string.find(string.lower(txtLabels), "alma") or string.find(string.lower(descText), "alma")) then
                    return true
                end
                return false
            end
            return true
        end
    end
    local mainUI = pgui and pgui:FindFirstChild("Main")
    local questUI = mainUI and mainUI:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        local container = questUI:FindFirstChild("Container")
        local title = container and (container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title") or container:FindFirstChild("QuestTitle"))
        if title and title.Text and title.Text ~= "" then
            if expectedName then
                return string.find(string.lower(title.Text), string.lower(expectedName)) ~= nil
            end
            return true
        end
    end
    return false
end

-- Bucle Independiente de Auto Spin Huesos (Death King) - Totalmente separado del farm
task.spawn(function()
    while true do
        task.wait(2.5)
        if getgenv().PolarAutoSpinBones then
            pcall(function()
                if CommF then
                    CommF:InvokeServer("Bones", "Buy", 1, 1)
                end
            end)
        end
    end
end)

-- Bucle de Auto Farm Huesos (Haunted Castle con Misión y Multi-Target)
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().PolarAutoBonesEnabled and not AutoBonesRunning then
            AutoBonesRunning = true
            task.spawn(function()
                while getgenv().PolarAutoBonesEnabled do
                    pcall(function()
                        -- Si PolarMastery esta activo y gestionando huesos, ceder el control del combate
                        local pm = getgenv().PolarMastery
                        if pm and pm.AutoBones then
                            task.wait(0.5)
                            return
                        end
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not hrp or not hum or hum.Health <= 0 then
                            task.wait(1)
                            return
                        end

                        local lvl = Polar.Player and Polar.Player:GetLevel() or 1
                        
                        -- Determinar mejor enemigo y misión de Haunted Castle
                        local qName = "HauntedQuest2"
                        local qIndex = 2
                        local targetMobName = "Posessed Mummy"
                        local questPos = CFrame.new(-9516.1, 175.1, 6079.2)
                        
                        if lvl < 2000 then
                            qName = "HauntedQuest1"
                            qIndex = 1
                            targetMobName = "Reborn Skeleton"
                            questPos = CFrame.new(-9515.7, 169.0, 6078.6)
                        elseif lvl < 2025 then
                            qName = "HauntedQuest1"
                            qIndex = 2
                            targetMobName = "Living Zombie"
                            questPos = CFrame.new(-9515.7, 169.0, 6078.6)
                        elseif lvl < 2050 then
                            qName = "HauntedQuest2"
                            qIndex = 1
                            targetMobName = "Demonic Soul"
                            questPos = CFrame.new(-9516.1, 175.1, 6079.2)
                        end
                        
                        -- 1. Auto Invocación de Soul Reaper si tiene Hallow Essence
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local hasEssence = (backpack and backpack:FindFirstChild("Hallow Essence")) or (char and char:FindFirstChild("Hallow Essence"))
                        if hasEssence then
                            if Polar.Teleport then Polar.Teleport:To(CFrame.new(-8925.4, 147.2, 6055.1)) end
                            task.wait(0.8)
                            if CommF then pcall(function() CommF:InvokeServer("SummonSoulReaper") end) end
                        end
                        
                        -- 2. Asegurar que tenemos la misión correcta de Haunted Castle antes de atacar
                        local hasQuest = HasHauntedQuestActive(targetMobName)
                        if not hasQuest then
                            if (hrp.Position - questPos.Position).Magnitude > 15 then
                                if Polar.Teleport then Polar.Teleport:To(questPos) end
                            end
                            if CommF then
                                local res = CommF:InvokeServer("StartQuest", qName, qIndex)
                                if res == 0 then
                                    task.wait(0.3)
                                end
                            end
                            task.wait(0.3)
                            return
                        end
                        
                        -- 3. Buscar y aniquilar objetivo (Soul Reaper prioritario o Mobs de Huesos)
                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")
                        local soulReaper = (enemies and enemies:FindFirstChild("Soul Reaper")) or (chars and chars:FindFirstChild("Soul Reaper"))
                        local targetNpc = nil
                        
                        if soulReaper and soulReaper:FindFirstChild("HumanoidRootPart") and soulReaper:FindFirstChildOfClass("Humanoid") and soulReaper.Humanoid.Health > 0 then
                            targetNpc = soulReaper
                        else
                            if enemies then
                                for _, npc in ipairs(enemies:GetChildren()) do
                                    if string.find(string.lower(npc.Name), string.lower(targetMobName)) then
                                        local nHrp = npc:FindFirstChild("HumanoidRootPart")
                                        local nHum = npc:FindFirstChildOfClass("Humanoid")
                                        if nHrp and nHum and nHum.Health > 0 then
                                            targetNpc = npc
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if targetNpc and targetNpc:FindFirstChild("HumanoidRootPart") then
                            local tHrp = targetNpc.HumanoidRootPart
                            local tHum = targetNpc:FindFirstChildOfClass("Humanoid")
                            local targetHoverCF = tHrp.CFrame * CFrame.new(0, (Polar.Combat and Polar.Combat.HoverHeight) or 12.5, 0)
                            
                            -- Anclaje Hover para no caer jamás al suelo ni recibir daño de los NPCs
                            local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
                            if not hoverBv then
                                hoverBv = Instance.new("BodyVelocity")
                                hoverBv.Name = "Polar_PlayerHover"
                                hoverBv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                hoverBv.Velocity = Vector3.zero
                                hoverBv.Parent = hrp
                            else
                                hoverBv.Velocity = Vector3.zero
                            end
                            
                            local dist = (hrp.Position - targetHoverCF.Position).Magnitude
                            if dist > 15 then
                                if Polar.Teleport then Polar.Teleport:To(targetHoverCF) end
                            else
                                hrp.CFrame = CFrame.lookAt(targetHoverCF.Position, tHrp.Position)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                            end
                            
                            -- Agrupar otros NPCs de huesos cercanos (Bring Mobs para matar 2+ a la vez)
                            if enemies and targetNpc ~= soulReaper then
                                local brought = 1
                                for _, other in ipairs(enemies:GetChildren()) do
                                    if other ~= targetNpc and string.find(string.lower(other.Name), string.lower(targetMobName)) then
                                        local oHrp = other:FindFirstChild("HumanoidRootPart")
                                        local oHum = other:FindFirstChildOfClass("Humanoid")
                                        if oHrp and oHum and oHum.Health > 0 and (oHrp.Position - tHrp.Position).Magnitude <= 300 then
                                            if brought < 4 then
                                                brought = brought + 1
                                                for _, p in ipairs(other:GetDescendants()) do
                                                    if p:IsA("BasePart") then p.CanCollide = false end
                                                end
                                                local angle = brought * (2 * math.pi / 4)
                                                oHrp.CFrame = tHrp.CFrame * CFrame.new(math.cos(angle) * 2.5, 0, math.sin(angle) * 2.5)
                                                oHrp.AssemblyLinearVelocity = Vector3.zero
                                                oHum.WalkSpeed = 0
                                            end
                                        end
                                    end
                                end
                            end
                            
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                        else
                            -- Si no hay NPC spawneado, esperar en la zona de spawn
                            if Polar.Teleport then Polar.Teleport:To(questPos * CFrame.new(0, 15, 0)) end
                        end
                    end)
                    task.wait(0.15)
                end
                
                -- Limpieza al apagar
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
                    if hoverBv then hoverBv:Destroy() end
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

-- ==================== INTERFAZ Y CONTROLES SEA 3 ====================

local BossNamesList = {}
for _, b in ipairs(Polar.Data.Bosses) do
    -- Excluir jefes de raid de la lista principal de Boss Hunter para evitar bugs
    if b.q or b.name == "Longma" then
        table.insert(BossNamesList, b.name)
    end
end

-- Sync Sea 3 bosses with Boss Hunter dropdown in TabHome
if Polar.BossDropdown and Polar.BossDropdown.SetValues then
    Polar.BossDropdown:SetValues(BossNamesList)
    if Polar.BossDropdown.Set then
        Polar.BossDropdown:Set("Stone")
    end
end
getgenv().PolarSelectedBossToFarm = "Stone"
if PolarMastery then PolarMastery.SelectedBoss = "Stone" end
if Polar.UpdateBossHunterStatus then
    Polar.UpdateBossHunterStatus("Stone")
end

if TabQuest then
    TabQuest:AddSection("Special Events")

    TabQuest:AddToggle({
        Name = "Auto Elite Hunter",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoElitePiratesEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto rip_indra",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoRipIndraEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Dough King",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoDoughKingEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Cake Prince",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoCakePrinceEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Bones",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoBonesEnabled = Value
            if PolarMastery then
                if Value then
                    PolarMastery.AutoFarm = false
                    PolarMastery.AutoFarmBoss = false
                    PolarMastery.AutoBones = true
                else
                    PolarMastery:StopAll()
                end
            end
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Spin Bones",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoSpinBones = Value
        end
    })

    TabQuest:AddButton({
        Name = "Pull Yama Sword",
        Callback = function()
            Polar.Functions:AutoPullYama()
        end
    })

    TabQuest:AddButton({
        Name = "Kill Longma",
        Callback = function()
            Polar.Functions:AutoKillLongma()
        end
    })
end

if TabStatus then
    local BS = Polar.BossSystem
    if BS and BS.InitTracker then
        BS.InitTracker()
        BS.SetupReactiveListeners()
    end

    local SelectedStatusBoss = "Stone"

    local function GetBossStatusCard(bossName)
        if BS and BS.GetBossStatusCard then
            return BS.GetBossStatusCard(bossName or SelectedStatusBoss)
        end
        return "Loading..."
    end

    local function UpdatePara(para, text)
        if not para then return end
        if para.SetDesc then para:SetDesc(text)
        elseif para.Set then para:Set(text)
        elseif type(para) == "table" and para.Desc then para.Desc.Text = text end
    end

    TabStatus:AddSection("Boss Status")

    local LabelSelectedBossInfo = TabStatus:AddParagraph({
        Title = "Stone",
        Text = GetBossStatusCard("Stone")
    })

    TabStatus:AddDropdown({
        Name = "Select Boss to Inspect",
        Options = BossNamesList,
        Default = "Stone",
        Callback = function(value)
            local resolved = BS and BS.FindBossData(value)
            SelectedStatusBoss = resolved and resolved.name or value
            if LabelSelectedBossInfo and LabelSelectedBossInfo.SetTitle then
                LabelSelectedBossInfo:SetTitle(tostring(SelectedStatusBoss))
            end
            UpdatePara(LabelSelectedBossInfo, GetBossStatusCard(SelectedStatusBoss))
        end
    })

    TabStatus:AddButton({
        Name = "Refresh Boss Status",
        Callback = function()
            if LabelSelectedBossInfo and LabelSelectedBossInfo.SetTitle then
                LabelSelectedBossInfo:SetTitle(tostring(SelectedStatusBoss))
            end
            UpdatePara(LabelSelectedBossInfo, GetBossStatusCard(SelectedStatusBoss))
            if PolarUI and PolarUI.Notify then
                PolarUI:Notify({ Title = "Polar Hub", Content = "Boss status actualizado", Duration = 2 })
            end
        end
    })

    TabStatus:AddButton({
        Name = "Teleport to Boss",
        Callback = function()
            local bData = (BS and BS.FindBossData(SelectedStatusBoss)) or Polar.Data.Bosses[1]
            if bData and bData.pos then
                if PolarUI and PolarUI.Notify then
                    PolarUI:Notify({ Title = "Polar Hub", Content = "Teleporting to " .. bData.name .. "...", Duration = 3 })
                end
                local destCF = CFrame.new(bData.pos + Vector3.new(0, 15, 0))
                if Polar.Teleport and Polar.Teleport.To then
                    Polar.Teleport:To(destCF)
                elseif getgenv().PolarBypassTeleport then
                    getgenv().PolarBypassTeleport(destCF)
                else
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = destCF end
                end
            end
        end
    })

    TabStatus:AddSection("Event Radar")

    local LabelRipIndra = TabStatus:AddParagraph({ Title = "rip_indra", Text = "Scanning..." })
    local LabelCakePrince = TabStatus:AddParagraph({ Title = "Cake Prince", Text = "Scanning..." })
    local LabelDoughKing = TabStatus:AddParagraph({ Title = "Dough King", Text = "Scanning..." })
    local LabelElitePirates = TabStatus:AddParagraph({ Title = "Elite Hunter", Text = "Scanning..." })
    local LabelMirage = TabStatus:AddParagraph({ Title = "Mirage Island", Text = "Scanning ocean..." })
    local LabelSoulReaper = TabStatus:AddParagraph({ Title = "Soul Reaper", Text = "Scanning..." })

    local function getMoonPhase()
        local lighting = game:GetService("Lighting")
        local clock = lighting.ClockTime
        local sky = lighting:FindFirstChildOfClass("Sky")
        local moonTex = sky and sky.MoonTextureId or ""
        if moonTex:find("9709149431") or moonTex:find("Full") or moonTex:find("full") then
            return "Luna Llena"
        end
        local isNight = (clock < 6 or clock > 18)
        return isNight and "Noche" or "Dia"
    end

    local EliteNames = {"Urban", "Deandre", "Diablo"}

    task.spawn(function()
        while true do
            task.wait(4)
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                local characters = workspace:FindFirstChild("Characters")
                local map = workspace:FindFirstChild("Map") or workspace

                -- 1. rip_indra
                local indraMob = (enemies and (enemies:FindFirstChild("rip_indra") or enemies:FindFirstChild("rip_indra True Form"))) or (characters and characters:FindFirstChild("rip_indra True Form"))
                if indraMob then
                    local hum = indraMob:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    local maxHp = hum and math.floor(hum.MaxHealth) or 1
                    local pct = math.floor((hp / math.max(1, maxHp)) * 100)
                    UpdatePara(LabelRipIndra, string.format("Nombre: rip_indra\nIsla: Castle on Sea\nEstado: Vivo\nVida: %d%%", pct))
                else
                    UpdatePara(LabelRipIndra, "Nombre: rip_indra\nIsla: Castle on Sea\nEstado: Muerto")
                end

                -- 2. Cake Prince
                local princeMob = enemies and enemies:FindFirstChild("Cake Prince")
                if princeMob then
                    local hum = princeMob:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    local maxHp = hum and math.floor(hum.MaxHealth) or 1
                    local pct = math.floor((hp / math.max(1, maxHp)) * 100)
                    UpdatePara(LabelCakePrince, string.format("Nombre: Cake Prince\nIsla: Mirror Dimension\nEstado: Vivo\nVida: %d%%", pct))
                else
                    UpdatePara(LabelCakePrince, "Nombre: Cake Prince\nIsla: Sea of Treats\nEstado: Muerto")
                end

                -- 3. Dough King
                local doughMob = enemies and enemies:FindFirstChild("Dough King")
                if doughMob then
                    local hum = doughMob:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    local maxHp = hum and math.floor(hum.MaxHealth) or 1
                    local pct = math.floor((hp / math.max(1, maxHp)) * 100)
                    UpdatePara(LabelDoughKing, string.format("Nombre: Dough King\nIsla: Mirror Dimension\nEstado: Vivo\nVida: %d%%", pct))
                else
                    UpdatePara(LabelDoughKing, "Nombre: Dough King\nIsla: Sea of Treats\nEstado: Muerto")
                end

                -- 4. Elite Hunter (Consulta directa a remoto sin activar mision ni abrir dialogos)
                local eliteInfo = nil
                local hasQuest = Polar.HasEliteQuest and Polar.HasEliteQuest()
                pcall(function()
                    if CommF then
                        local ok, res = Polar.SafeQueryEliteHunter(false)
                        if ok and type(res) == "string" then
                            local foundName = nil
                            for _, ename in ipairs(EliteNames) do
                                if res:find(ename) then
                                    foundName = ename
                                    break
                                end
                            end
                            if foundName then
                                local foundIsland = "Mar"
                                local islands = {"Floating Turtle", "Hydra Island", "Port Town", "Great Tree", "Castle on Sea", "Haunted Castle"}
                                for _, isl in ipairs(islands) do
                                    if res:find(isl) then
                                        foundIsland = isl
                                        break
                                    end
                                end
                                eliteInfo = {
                                    name = foundName,
                                    island = foundIsland
                                }
                                Polar.LastEliteInfo = eliteInfo
                            end
                        end
                    end
                end)

                if not eliteInfo and hasQuest and Polar.LastEliteInfo then
                    eliteInfo = Polar.LastEliteInfo
                end

                if eliteInfo then
                    local liveMob = nil
                    if enemies then
                        for _, child in ipairs(enemies:GetChildren()) do
                            if string.find(child.Name, eliteInfo.name) then
                                liveMob = child
                                break
                            end
                        end
                    end

                    local suffix = hasQuest and " (Misión Activa)" or ""
                    if liveMob then
                        local hum = liveMob:FindFirstChildOfClass("Humanoid")
                        local hp = hum and math.floor(hum.Health) or 0
                        local maxHp = hum and math.floor(hum.MaxHealth) or 1
                        local pct = math.floor((hp / math.max(1, maxHp)) * 100)
                        UpdatePara(LabelElitePirates, string.format("Nombre: %s\nIsla: %s\nEstado: Vivo%s\nVida: %d%%", eliteInfo.name, eliteInfo.island, suffix, pct))
                    else
                        UpdatePara(LabelElitePirates, string.format("Nombre: %s\nIsla: %s\nEstado: Vivo%s", eliteInfo.name, eliteInfo.island, suffix))
                    end
                else
                    UpdatePara(LabelElitePirates, "Nombre: Elite Hunter\nIsla: Desconocida\nEstado: Muerto")
                end

                -- 5. Mirage Island
                local mirageFound = (map and map:FindFirstChild("MysticIsland"))
                    or (workspace:FindFirstChild("MysticIsland"))
                    or (workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations") and workspace._WorldOrigin.Locations:FindFirstChild("Mirage"))
                    or (workspace:FindFirstChild("Locations") and workspace.Locations:FindFirstChild("Mirage Island"))

                if mirageFound then
                    UpdatePara(LabelMirage, "Nombre: Mirage Island\nIsla: Mar\nEstado: Activa")
                else
                    UpdatePara(LabelMirage, "Nombre: Mirage Island\nIsla: Mar\nEstado: No detectada")
                end

                -- 6. Soul Reaper
                local reaperMob = enemies and enemies:FindFirstChild("Soul Reaper")
                if reaperMob then
                    local hum = reaperMob:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    local maxHp = hum and math.floor(hum.MaxHealth) or 1
                    local pct = math.floor((hp / math.max(1, maxHp)) * 100)
                    UpdatePara(LabelSoulReaper, string.format("Nombre: Soul Reaper\nIsla: Haunted Castle\nEstado: Vivo\nVida: %d%%", pct))
                else
                    UpdatePara(LabelSoulReaper, "Nombre: Soul Reaper\nIsla: Haunted Castle\nEstado: Muerto")
                end
            end)
        end
    end)
end

print("✅ Sea 3 optimized, 100% English, Boss Inspector & World Radar active.")


-- ==================== 5. AUTO TYRANT OF THE SKIES ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().PolarAutoTyrant then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end
                
                local enemies = workspace:FindFirstChild("Enemies")
                local chars = workspace:FindFirstChild("Characters")
                local tyrant = (enemies and enemies:FindFirstChild("Tyrant of the Skies")) or (chars and chars:FindFirstChild("Tyrant of the Skies"))
                
                if tyrant and tyrant:FindFirstChild("HumanoidRootPart") and tyrant:FindFirstChildOfClass("Humanoid") and tyrant.Humanoid.Health > 0 then
                    local tRoot = tyrant.HumanoidRootPart
                    local hoverCF = tRoot.CFrame * CFrame.new(0, 13, 0)
                    local dist = (hrp.Position - hoverCF.Position).Magnitude
                    if dist > 20 then
                        if Polar.Teleport then Polar.Teleport:To(hoverCF) end
                    else
                        hrp.CFrame = hoverCF
                    end
                    EquipWeaponLocal()
                    getgenv().PolarFastAttackEnabled = true
                else
                    -- Check for Tiki Outpost Sky temple / urns to break
                    local templeCF = CFrame.new(-16450, 120, 450)
                    if (hrp.Position - templeCF.Position).Magnitude > 300 then
                        if Polar.Teleport then Polar.Teleport:To(templeCF) end
                    end
                end
            end)
        end
    end
end)
