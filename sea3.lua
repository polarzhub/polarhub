-- ==================== POLAR HUB | SEA 3 ====================
print("Cargando datos del Sea 3...")

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

-- ==================== DATA REGISTRY SEA 3 (NIVEL 1500 A 2700+) ====================
-- Verified against ReplicatedStorage.Quests, ReplicatedStorage.NPCs, and _WorldOrigin.Locations
Polar.Data.AllowedQuests = {
    "PiratePortQuest", "DragonCrewQuest", "VenomCrewQuest", "MarineTreeIsland",
    "DeepForestIsland3", "DeepForestIsland", "DeepForestIsland2",
    "HauntedQuest1", "HauntedQuest2",
    "NutsIslandQuest", "IceCreamIslandQuest", "CakeQuest1", "CakeQuest2",
    "ChocQuest1", "ChocQuest2", "CandyQuest1",
    "TikiQuest1", "TikiQuest2", "TikiQuest3",
    "SubmergedQuest1", "SubmergedQuest2", "SubmergedQuest3"
}

Polar.Data.QuestInfo = {
    -- Port Town (1500-1550)
    {lvl = 1500, q = "PiratePortQuest", ql = 1, name = "Pirate Millionaire", giver = "Pirate Port Quest Giver", island = "Port Town", pos = CFrame.new(-450.2, 107.6, 5950.7)},
    {lvl = 1525, q = "PiratePortQuest", ql = 2, name = "Pistol Billionaire", giver = "Pirate Port Quest Giver", island = "Port Town", pos = CFrame.new(-450.2, 107.6, 5950.7)},
    {lvl = 1550, q = "PiratePortQuest", ql = 3, name = "Stone", giver = "Pirate Port Quest Giver", island = "Port Town", isBoss = true, pos = CFrame.new(-1109.9, 53.4, 6811.7)},

    -- Hydra Island (1575-1675)
    {lvl = 1575, q = "DragonCrewQuest", ql = 1, name = "Dragon Crew Warrior", giver = "Dragon Crew Quest Giver", island = "Hydra Island", pos = CFrame.new(6735.1, 126.9, -711.1)},
    {lvl = 1600, q = "DragonCrewQuest", ql = 2, name = "Dragon Crew Archer", giver = "Dragon Crew Quest Giver", island = "Hydra Island", pos = CFrame.new(6735.1, 126.9, -711.1)},
    {lvl = 1625, q = "VenomCrewQuest", ql = 1, name = "Hydra Enforcer", giver = "Hydra Town Quest Giver", island = "Hydra Island", pos = CFrame.new(5214.3, 1003.5, 759.5)},
    {lvl = 1650, q = "VenomCrewQuest", ql = 2, name = "Venomous Assailant", giver = "Hydra Town Quest Giver", island = "Hydra Island", pos = CFrame.new(5214.3, 1003.5, 759.5)},
    {lvl = 1675, q = "VenomCrewQuest", ql = 3, name = "Hydra Leader", giver = "Hydra Town Quest Giver", island = "Hydra Island", isBoss = true, pos = CFrame.new(5888.8, 1020.1, -117.8)},

    -- Great Tree (1700-1750)
    {lvl = 1700, q = "MarineTreeIsland", ql = 1, name = "Marine Commodore", giver = "Marine Tree Quest Giver", island = "Great Tree", pos = CFrame.new(2485.7, 73.3, -6788.7)},
    {lvl = 1725, q = "MarineTreeIsland", ql = 2, name = "Marine Rear Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree", pos = CFrame.new(2485.7, 73.3, -6788.7)},
    {lvl = 1750, q = "MarineTreeIsland", ql = 3, name = "Kilo Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree", isBoss = true, pos = CFrame.new(2998.3, 508.8, -7344.3)},

    -- Floating Turtle (1775-1950)
    {lvl = 1775, q = "DeepForestIsland3", ql = 1, name = "Fishman Raider", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle", pos = CFrame.new(-10581.7, 330.8, -8761.2)},
    {lvl = 1800, q = "DeepForestIsland3", ql = 2, name = "Fishman Captain", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle", pos = CFrame.new(-10581.7, 330.8, -8761.2)},
    {lvl = 1825, q = "DeepForestIsland", ql = 1, name = "Forest Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle", pos = CFrame.new(-13234.1, 331.4, -7625.5)},
    {lvl = 1850, q = "DeepForestIsland", ql = 2, name = "Mythological Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle", pos = CFrame.new(-13234.1, 331.4, -7625.5)},
    {lvl = 1875, q = "DeepForestIsland", ql = 3, name = "Captain Elephant", giver = "Deep Forest Quest Giver", island = "Floating Turtle", isBoss = true, pos = CFrame.new(-13373.2, 331.7, -9832.2)},
    {lvl = 1900, q = "DeepForestIsland2", ql = 1, name = "Jungle Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", pos = CFrame.new(-12680.4, 389.9, -9902.1)},
    {lvl = 1925, q = "DeepForestIsland2", ql = 2, name = "Musketeer Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", pos = CFrame.new(-12680.4, 389.9, -9902.1)},
    {lvl = 1950, q = "DeepForestIsland2", ql = 3, name = "Beautiful Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", isBoss = true, pos = CFrame.new(5366.5, 71.1, -225.9)},

    -- Haunted Castle (1975-2050)
    {lvl = 1975, q = "HauntedQuest1", ql = 1, name = "Reborn Skeleton", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle", pos = CFrame.new(-9479.3, 141.2, 5566.0)},
    {lvl = 2000, q = "HauntedQuest1", ql = 2, name = "Living Zombie", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle", pos = CFrame.new(-9479.3, 141.2, 5566.0)},
    {lvl = 2025, q = "HauntedQuest2", ql = 1, name = "Demonic Soul", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle", pos = CFrame.new(-9517.0, 172.0, 6078.4)},
    {lvl = 2050, q = "HauntedQuest2", ql = 2, name = "Posessed Mummy", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle", pos = CFrame.new(-9517.0, 172.0, 6078.4)},

    -- Sea of Treats - Peanut Land (2075-2100)
    {lvl = 2075, q = "NutsIslandQuest", ql = 1, name = "Peanut Scout", giver = "Peanut Quest Giver", island = "Sea of Treats", pos = CFrame.new(-2105.6, 37.2, -10195.6)},
    {lvl = 2100, q = "NutsIslandQuest", ql = 2, name = "Peanut President", giver = "Peanut Quest Giver", island = "Sea of Treats", pos = CFrame.new(-2105.6, 37.2, -10195.6)},

    -- Sea of Treats - Ice Cream Land (2125-2175)
    {lvl = 2125, q = "IceCreamIslandQuest", ql = 1, name = "Ice Cream Chef", giver = "Ice Cream Quest Giver", island = "Sea of Treats", pos = CFrame.new(-819.4, 64.9, -10967.3)},
    {lvl = 2150, q = "IceCreamIslandQuest", ql = 2, name = "Ice Cream Commander", giver = "Ice Cream Quest Giver", island = "Sea of Treats", pos = CFrame.new(-819.4, 64.9, -10967.3)},
    {lvl = 2175, q = "IceCreamIslandQuest", ql = 3, name = "Cake Queen", giver = "Ice Cream Quest Giver", island = "Sea of Treats", isBoss = true, pos = CFrame.new(-678.5, 381.9, -11114.3)},

    -- Sea of Treats - Cake Land (2200-2275)
    {lvl = 2200, q = "CakeQuest1", ql = 1, name = "Cookie Crafter", giver = "Cake Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(-2022.3, 36.9, -12031.0)},
    {lvl = 2225, q = "CakeQuest1", ql = 2, name = "Cake Guard", giver = "Cake Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(-2022.3, 36.9, -12031.0)},
    {lvl = 2250, q = "CakeQuest2", ql = 1, name = "Baking Staff", giver = "Cake Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(-1928.3, 37.7, -12840.6)},
    {lvl = 2275, q = "CakeQuest2", ql = 2, name = "Head Baker", giver = "Cake Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(-1928.3, 37.7, -12840.6)},

    -- Sea of Treats - Chocolate Land (2300-2375)
    {lvl = 2300, q = "ChocQuest1", ql = 1, name = "Cocoa Warrior", giver = "Chocolate Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(231.7, 23.8, -12200.3)},
    {lvl = 2325, q = "ChocQuest1", ql = 2, name = "Chocolate Bar Battler", giver = "Chocolate Quest Giver 1", island = "Sea of Treats", pos = CFrame.new(231.7, 23.8, -12200.3)},
    {lvl = 2350, q = "ChocQuest2", ql = 1, name = "Sweet Thief", giver = "Chocolate Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(151.1, 23.8, -12774.7)},
    {lvl = 2375, q = "ChocQuest2", ql = 2, name = "Candy Rebel", giver = "Chocolate Quest Giver 2", island = "Sea of Treats", pos = CFrame.new(151.1, 23.8, -12774.7)},

    -- Sea of Treats - Candy Cane Land (2400-2425)
    {lvl = 2400, q = "CandyQuest1", ql = 1, name = "Candy Pirate", giver = "Candy Cane Quest Giver", island = "Sea of Treats", pos = CFrame.new(-1164.5, 59.2, -14492.7)},
    {lvl = 2425, q = "CandyQuest1", ql = 2, name = "Snow Demon", giver = "Candy Cane Quest Giver", island = "Sea of Treats", pos = CFrame.new(-1164.5, 59.2, -14492.7)},

    -- Tiki Outpost (2450-2575)
    {lvl = 2450, q = "TikiQuest1", ql = 1, name = "Isle Outlaw", giver = "Tiki Quest Giver 1", island = "Tiki Outpost", pos = CFrame.new(-16548.9, 55.6, -172.9)},
    {lvl = 2475, q = "TikiQuest1", ql = 2, name = "Island Boy", giver = "Tiki Quest Giver 1", island = "Tiki Outpost", pos = CFrame.new(-16548.9, 55.6, -172.9)},
    {lvl = 2500, q = "TikiQuest2", ql = 1, name = "Sun-kissed Warrior", giver = "Tiki Quest Giver 2", island = "Tiki Outpost", pos = CFrame.new(-16541.0, 54.8, 1051.5)},
    {lvl = 2525, q = "TikiQuest2", ql = 2, name = "Isle Champion", giver = "Tiki Quest Giver 2", island = "Tiki Outpost", pos = CFrame.new(-16541.0, 54.8, 1051.5)},
    {lvl = 2550, q = "TikiQuest3", ql = 1, name = "Serpent Hunter", giver = "Tiki Quest Giver 3", island = "Tiki Outpost", pos = CFrame.new(-16665.2, 104.5, 1579.6)},
    {lvl = 2575, q = "TikiQuest3", ql = 2, name = "Skull Slayer", giver = "Tiki Quest Giver 3", island = "Tiki Outpost", pos = CFrame.new(-16665.2, 104.5, 1579.6)},

    -- Submerged Island (2600-2700)
    {lvl = 2600, q = "SubmergedQuest1", ql = 1, name = "Reef Bandit", giver = "Submerged Quest Giver 1", island = "Submerged Island", pos = CFrame.new(10780.6, -2088.5, 9260.4)},
    {lvl = 2625, q = "SubmergedQuest1", ql = 2, name = "Coral Pirate", giver = "Submerged Quest Giver 1", island = "Submerged Island", pos = CFrame.new(10780.6, -2088.5, 9260.4)},
    {lvl = 2650, q = "SubmergedQuest2", ql = 1, name = "Sea Chanter", giver = "Submerged Quest Giver 2", island = "Submerged Island", pos = CFrame.new(10883.5, -2086.9, 10034.0)},
    {lvl = 2675, q = "SubmergedQuest2", ql = 2, name = "Ocean Prophet", giver = "Submerged Quest Giver 2", island = "Submerged Island", pos = CFrame.new(10883.5, -2086.9, 10034.0)},
    {lvl = 2675, q = "SubmergedQuest3", ql = 1, name = "High Disciple", giver = "Submerged Quest Giver 3", island = "Submerged Island", pos = CFrame.new(9637.2, -1993.2, 9616.3)},
    {lvl = 2700, q = "SubmergedQuest3", ql = 2, name = "Grand Devotee", giver = "Submerged Quest Giver 3", island = "Submerged Island", pos = CFrame.new(9637.2, -1993.2, 9616.3)}
}

Polar.Data.Bosses = {
    {name = "Stone", q = "PiratePortQuest", ql = 3, giver = "Pirate Port Quest Giver", island = "Port Town", lvl = 1550, cd = 300, pos = Vector3.new(-1109.9, 53.4, 6811.7)},
    {name = "Hydra Leader", q = "VenomCrewQuest", ql = 3, giver = "Hydra Town Quest Giver", island = "Hydra Island", lvl = 1675, cd = 300, pos = Vector3.new(5888.8, 1020.1, -117.8)},
    {name = "Kilo Admiral", q = "MarineTreeIsland", ql = 3, giver = "Marine Tree Quest Giver", island = "Great Tree", lvl = 1750, cd = 300, pos = Vector3.new(2998.3, 508.8, -7344.3)},
    {name = "Captain Elephant", q = "DeepForestIsland", ql = 3, giver = "Deep Forest Quest Giver", island = "Floating Turtle", lvl = 1875, cd = 300, pos = Vector3.new(-13373.2, 331.7, -9832.2)},
    {name = "Beautiful Pirate", q = "DeepForestIsland2", ql = 3, giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", lvl = 1950, cd = 600, pos = Vector3.new(5366.5, 71.1, -225.9)},
    {name = "Cake Queen", q = "IceCreamIslandQuest", ql = 3, giver = "Ice Cream Quest Giver", island = "Sea of Treats", lvl = 2175, cd = 600, pos = Vector3.new(-678.5, 381.9, -11114.3)},
    {name = "Longma", q = nil, ql = nil, giver = nil, island = "Floating Turtle", lvl = 2000, cd = 900, pos = Vector3.new(-10156.2, 337.8, -9445.9)},
    {name = "Soul Reaper", q = nil, ql = nil, giver = nil, island = "Haunted Castle", lvl = 2100, cd = 3600, pos = Vector3.new(-9517.0, 172.0, 6078.4)},
    {name = "Cake Prince", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300, cd = 3600, pos = Vector3.new(-2137.7, 66.3, -12326.3)},
    {name = "Dough King", q = nil, ql = nil, giver = nil, island = "Sea of Treats", lvl = 2300, cd = 3600, pos = Vector3.new(-2137.7, 66.3, -12326.3)},
    {name = "Tyrant of the Skies", q = nil, ql = nil, giver = nil, island = "Tiki Outpost", lvl = 2200, cd = 1200, pos = Vector3.new(-16234.5, 60.1, 452.3)},
    {name = "rip_indra True Form", q = nil, ql = nil, giver = nil, island = "Castle on the Sea", lvl = 5000, cd = 7200, pos = Vector3.new(-5333.1, 423.8, -2672.9)}
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
    if Polar.QuestEngine and Polar.QuestEngine.GetActiveQuestTitle then
        local title = Polar.QuestEngine:GetActiveQuestTitle()
        if title and title ~= "" then
            return title
        end
    end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local mainUI = playerGui:FindFirstChild("Main")
    if not mainUI then return nil end
    local questUI = mainUI:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        local container = questUI:FindFirstChild("Container")
        if container then
            local title = container:FindFirstChild("QuestTitle")
            local titleLbl = (title and title:FindFirstChild("Title")) or title
            if titleLbl and titleLbl:IsA("TextLabel") and titleLbl.Text ~= "" then
                return titleLbl.Text
            end
        end
    end
    return nil
end

function Polar.Functions:AutoAcceptQuest()
    if not getgenv().PolarAutoQuestEnabled then return end
    -- Yield to PolarMastery when it owns the active AutoFarm loop so quests never conflict
    local pm = getgenv().PolarMastery
    if pm and pm.AutoFarm then return end

    local bestQuest = (Polar.QuestEngine and Polar.QuestEngine.GetBestQuest and Polar.QuestEngine:GetBestQuest()) or nil
    if not bestQuest then
        local lvl = Polar.Player and Polar.Player:GetLevel() or 1
        for _, q in ipairs(Polar.Data.QuestInfo) do
            if lvl >= q.lvl and not q.isBoss then
                bestQuest = q
            end
        end
    end
    if not bestQuest then return end

    if Polar.Quest and Polar.Quest.GetTargetEnemyNameFromQuest then
        local currentTarget = Polar.Quest:GetTargetEnemyNameFromQuest()
        if currentTarget and string.lower(currentTarget) == string.lower(bestQuest.name) then
            return
        end
    end

    local hasAny = Polar.QuestEngine and Polar.QuestEngine.HasActiveQuest and Polar.QuestEngine:HasActiveQuest()
    if hasAny and CommF then
        pcall(function() CommF:InvokeServer("AbandonQuest") end)
        task.wait(0.25)
    end

    local giverCF = (Polar.World and Polar.World.GetQuestGiverCFrame and Polar.World:GetQuestGiverCFrame(bestQuest.q, bestQuest.ql, bestQuest.name))
        or (bestQuest.giver and Polar.World and Polar.World.FindNPC and Polar.World:FindNPC(bestQuest.giver))
        or bestQuest.pos
    if giverCF and Polar.Teleport then
        Polar.Teleport:To(giverCF * CFrame.new(0, 2, 3))
        task.wait(0.35)
        pcall(function()
            if CommF then CommF:InvokeServer("StartQuest", bestQuest.q, bestQuest.ql) end
        end)
        task.wait(0.4)
    end
end

-- Only run legacy quest loop if PolarMastery is not loaded
task.spawn(function()
    while true do
        task.wait(1)
        if not getgenv().PolarMastery and getgenv().PolarAutoQuestEnabled and getgenv().PolarAutoFarmEnabled then
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
getgenv().PolarSuppressQuestUpdate = false

-- Restore any previously hooked QuestUpdate callbacks from older hub loads so GuideData/TrackedQuestFrame never break
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local questUpdate = remotes and remotes:FindFirstChild("QuestUpdate")
    if questUpdate and getconnections and restorefunction and isfunctionhooked then
        for _, c in ipairs(getconnections(questUpdate.OnClientEvent)) do
            if c.Function and isfunctionhooked(c.Function) then
                pcall(restorefunction, c.Function)
            end
        end
    end
end)

local function MatchEliteQuestText(text)
    if type(text) ~= "string" or text == "" then return false end
    local lower = string.lower(text)
    for _, name in ipairs(EliteNames) do
        if string.find(lower, string.lower(name), 1, true) then
            return true
        end
    end
    if string.find(lower, "elite", 1, true) or string.find(lower, "élite", 1, true) then
        return true
    end
    return false
end

function Polar.HasEliteQuest()
    if Polar.QuestEngine and Polar.QuestEngine.GetGuideQuestData then
        local qd = Polar.QuestEngine:GetGuideQuestData()
        if qd then
            if MatchEliteQuestText(qd.Title) or MatchEliteQuestText(qd.QuestName) or MatchEliteQuestText(qd.Name) or MatchEliteQuestText(qd.Description) then
                return true
            end
            if type(qd.Objectives) == "table" then
                for _, obj in pairs(qd.Objectives) do
                    if type(obj) == "table" and (MatchEliteQuestText(obj.Name) or MatchEliteQuestText(obj.Title) or MatchEliteQuestText(obj.Text) or MatchEliteQuestText(obj.Description)) then
                        return true
                    end
                end
            end
        end
    end

    local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return false end
    local tq = pgui:FindFirstChild("TrackedQuestFrame")
    if tq then
        for _, inst in ipairs(tq:GetDescendants()) do
            if inst:IsA("TextLabel") and inst.Text ~= "" and MatchEliteQuestText(inst.Text) then
                return true
            end
        end
    end
    local mainUI = pgui:FindFirstChild("Main")
    local questUI = mainUI and mainUI:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        for _, inst in ipairs(questUI:GetDescendants()) do
            if inst:IsA("TextLabel") and inst.Text ~= "" and MatchEliteQuestText(inst.Text) then
                return true
            end
        end
    end
    return false
end

function Polar.IsNearEliteNPC()
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local npcCF = (Polar.World and Polar.World.FindNPC and Polar.World:FindNPC("Elite Hunter"))
    local npcPos = (npcCF and npcCF.Position) or Vector3.new(-5417.6, 313.1, -2822.9)
    return (hrp.Position - npcPos).Magnitude < 45
end

local function FindNearestSea3IslandName(pos)
    if not pos then return "Sea" end
    local bestName, bestDist = "Sea", math.huge
    local candidates = {
        ["Floating Turtle"] = Vector3.new(-12164.6, 331.0, -8454.9),
        ["Hydra Island"] = Vector3.new(5500.0, 600.0, 0.0),
        ["Port Town"] = Vector3.new(-450.2, 107.6, 5950.7),
        ["Great Tree"] = Vector3.new(2485.7, 73.3, -6788.7),
        ["Castle on the Sea"] = Vector3.new(-5417.6, 313.1, -2822.9),
        ["Haunted Castle"] = Vector3.new(-9500.0, 150.0, 5800.0),
    }
    for name, refPos in pairs(candidates) do
        local d = (pos - refPos).Magnitude
        if d < bestDist then
            bestDist = d
            bestName = name
        end
    end
    return bestName
end

local function ScanLiveEliteMob()
    local enemies = workspace:FindFirstChild("Enemies")
    local chars = workspace:FindFirstChild("Characters")
    for _, container in ipairs({enemies, chars}) do
        if container then
            for _, mob in ipairs(container:GetChildren()) do
                for _, ename in ipairs(EliteNames) do
                    if string.find(mob.Name, ename, 1, true) then
                        local hum = mob:FindFirstChildOfClass("Humanoid")
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 then
                            return mob, ename, FindNearestSea3IslandName(hrp.Position)
                        end
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

function Polar.SafeQueryEliteHunter(allowQuest)
    if not CommF then return false, nil end

    -- 1. If already holding an Elite quest, return active cached or live info without remote spam
    if Polar.HasEliteQuest and Polar.HasEliteQuest() then
        local _, liveName, liveIsland = ScanLiveEliteMob()
        if liveName then
            local msg = liveName .. " seen near " .. tostring(liveIsland)
            Polar.LastEliteRawResponse = msg
            return true, msg
        end
        return true, Polar.LastEliteRawResponse or "Active Quest"
    end

    -- 2. Read-only mode: NEVER invoke CommF_("EliteHunter", ...) because any non-"Progress" arg accepts the quest and overwrites active quests!
    if not allowQuest then
        local _, liveName, liveIsland = ScanLiveEliteMob()
        if liveName then
            local msg = liveName .. " seen near " .. tostring(liveIsland)
            Polar.LastEliteRawResponse = msg
            return true, msg
        end
        return false, nil
    end

    -- 3. Explicit accept mode (only when Auto Elite Hunter toggle is actively running)
    if Polar.IsNearEliteNPC and not Polar.IsNearEliteNPC() then
        local npcCF = Polar.World and Polar.World.FindNPC and Polar.World:FindNPC("Elite Hunter")
        if npcCF and Polar.Teleport then
            Polar.Teleport:To(npcCF * CFrame.new(0, 2, 3))
            task.wait(0.25)
        end
    end

    local ok, res = pcall(function()
        return CommF:InvokeServer("EliteHunter")
    end)
    if ok and type(res) == "string" then
        Polar.LastEliteRawResponse = res
    end
    return ok, res
end

local EliteIslandFallbacks = {
    ["Floating Turtle"] = CFrame.new(-12528.0, 337.2, -7489.5),
    ["Hydra Island"] = CFrame.new(5749.0, 610.4, -276.0),
    ["Port Town"] = CFrame.new(-450.2, 107.6, 5950.7),
    ["Great Tree"] = CFrame.new(2485.7, 73.3, -6788.7),
    ["Haunted Castle"] = CFrame.new(-9479.3, 141.2, 5566.0),
    ["Castle on the Sea"] = CFrame.new(-5116.3, 315.7, -3133.6),
    ["Castle on Sea"] = CFrame.new(-5116.3, 315.7, -3133.6)
}

local function ExtractActiveEliteInfo(text)
    if type(text) ~= "string" then return nil, nil end
    local foundName, foundIsland = nil, nil
    for _, name in ipairs(EliteNames) do
        if string.find(text, name, 1, true) then
            foundName = name
            break
        end
    end
    local islands = {"Floating Turtle", "Hydra Island", "Port Town", "Great Tree", "Haunted Castle", "Castle on the Sea", "Castle on Sea"}
    for _, isl in ipairs(islands) do
        if string.find(text, isl, 1, true) then
            foundIsland = isl
            break
        end
    end
    return foundName, foundIsland
end

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoElitePiratesEnabled and not AutoEliteRunning then
            AutoEliteRunning = true
            task.spawn(function()
                while getgenv().PolarAutoElitePiratesEnabled do
                    pcall(function()
                        if not CommF then return end

                        -- 1. Ensure Elite quest is accepted (or read from active GuideData/TrackedQuest)
                        local activeEliteName, activeIsland = nil, nil
                        if Polar.HasEliteQuest and Polar.HasEliteQuest() then
                            activeEliteName, activeIsland = ExtractActiveEliteInfo(Polar.LastEliteRawResponse)
                            if not activeEliteName and Polar.QuestEngine and Polar.QuestEngine.GetActiveQuestTitle then
                                activeEliteName = ExtractActiveEliteInfo(Polar.QuestEngine:GetActiveQuestTitle())
                            end
                        end

                        if not activeEliteName then
                            local ok, res = Polar.SafeQueryEliteHunter(true)
                            if ok and type(res) == "string" then
                                activeEliteName, activeIsland = ExtractActiveEliteInfo(res)
                            end
                        end

                        -- Also check streamed workspace in case Elite Hunter is already nearby
                        if not activeEliteName then
                            local _, liveName, liveIsland = ScanLiveEliteMob()
                            activeEliteName = liveName
                            activeIsland = liveIsland
                        end

                        if not activeEliteName then
                            task.wait(4)
                            return
                        end

                        Polar.LastEliteInfo = { name = activeEliteName, island = activeIsland or "Unknown" }

                        -- 2. Locate and hunt the active Elite mob
                        local targetElite = nil
                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")
                        for _, container in ipairs({enemies, chars}) do
                            if container and not targetElite then
                                for _, npc in ipairs(container:GetChildren()) do
                                    if string.find(npc.Name, activeEliteName, 1, true) then
                                        local hum = npc:FindFirstChildOfClass("Humanoid")
                                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                                        if hum and hrp and hum.Health > 0 then
                                            targetElite = npc
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        if targetElite and targetElite:FindFirstChild("HumanoidRootPart") then
                            local char = LocalPlayer.Character
                            local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                            local eHrp = targetElite.HumanoidRootPart
                            local hoverCF = eHrp.CFrame * CFrame.new(0, 12, 0)
                            if myHrp and (myHrp.Position - hoverCF.Position).Magnitude > 18 then
                                if Polar.Teleport then Polar.Teleport:To(hoverCF) end
                            elseif myHrp then
                                myHrp.CFrame = CFrame.lookAt(hoverCF.Position, eHrp.Position)
                            end
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(0, 0))
                        else
                            if activeIsland and Polar.Teleport and Polar.Teleport.ToIsland then
                                Polar.Teleport:ToIsland(activeIsland)
                                task.wait(1.2)
                            else
                                local targetCF = (activeIsland and EliteIslandFallbacks[activeIsland]) or CFrame.new(-5417.6, 313.1, -2822.9)
                                if Polar.Teleport then
                                    Polar.Teleport:To(targetCF)
                                    task.wait(1.2)
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
                getgenv().PolarFastAttackEnabled = false
                if Polar.Teleport and Polar.Teleport.Cancel then Polar.Teleport:Cancel() end
                AutoEliteRunning = false
            end)
        end
    end
end)

-- ==================== 2. AUTO RIP_INDRA ====================
local RipIndraRunning = false

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoRipIndraEnabled and not RipIndraRunning then
            local lvl = Polar.Player and Polar.Player:GetLevel() or 1
            if lvl < 1500 then
                warn("Polar Hub: Need level 1500+ (Sea 3) for rip_indra.")
                getgenv().PolarAutoRipIndraEnabled = false
            else
                RipIndraRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoRipIndraEnabled do
                        pcall(function()
                            local char = LocalPlayer.Character
                            local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                            local myHum = char and char:FindFirstChildOfClass("Humanoid")
                            if not myHrp or not myHum or myHum.Health <= 0 then
                                task.wait(0.8)
                                return
                            end

                            local enemies = workspace:FindFirstChild("Enemies")
                            local chars = workspace:FindFirstChild("Characters")
                            local enemy = (enemies and (enemies:FindFirstChild("rip_indra True Form") or enemies:FindFirstChild("rip_indra")))
                                or (chars and (chars:FindFirstChild("rip_indra True Form") or chars:FindFirstChild("rip_indra")))
                            local hrp = enemy and enemy:FindFirstChild("HumanoidRootPart")
                            local hum = enemy and enemy:FindFirstChildOfClass("Humanoid")

                            if enemy and hrp and hum and hum.Health > 0 then
                                local hoverCF = hrp.CFrame * CFrame.new(0, 20, 0)
                                if (myHrp.Position - hoverCF.Position).Magnitude > 20 then
                                    if Polar.Teleport then Polar.Teleport:To(hoverCF) end
                                else
                                    myHrp.CFrame = CFrame.lookAt(hoverCF.Position, hrp.Position)
                                end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0, 0))
                            else
                                local backpack = LocalPlayer:FindFirstChild("Backpack")
                                local chalice = (backpack and backpack:FindFirstChild("God's Chalice")) or (char and char:FindFirstChild("God's Chalice"))
                                local mapFolder = workspace:FindFirstChild("Map")
                                local boatCastle = mapFolder and mapFolder:FindFirstChild("Boat Castle")
                                local summoner = boatCastle and (boatCastle:FindFirstChild("Summoner") or boatCastle:FindFirstChild("Detection", true))
                                local summonCF = nil
                                if chalice and summoner then
                                    if summoner:IsA("BasePart") then
                                        summonCF = summoner.CFrame * CFrame.new(0, 3, 0)
                                    elseif summoner:IsA("Model") then
                                        local det = summoner:FindFirstChild("Detection") or summoner.PrimaryPart or summoner:FindFirstChildWhichIsA("BasePart")
                                        if det then summonCF = det.CFrame * CFrame.new(0, 3, 0) end
                                    end
                                end
                                local targetCF = summonCF or CFrame.new(-5333.1, 423.8, -2672.9)
                                if (myHrp.Position - targetCF.Position).Magnitude > 15 then
                                    if Polar.Teleport then Polar.Teleport:To(targetCF) end
                                end
                                if chalice and chalice:IsA("Tool") then
                                    pcall(function() myHum:EquipTool(chalice) end)
                                end
                            end
                        end)
                        task.wait(0.25)
                    end
                    getgenv().PolarFastAttackEnabled = false
                    if Polar.Teleport and Polar.Teleport.Cancel then Polar.Teleport:Cancel() end
                    RipIndraRunning = false
                end)
            end
        end
    end
end)

-- ==================== 3. AUTO DOUGH KING & CAKE PRINCE ====================
local DoughKingRunning = false

local function GetCocoaCount()
    if not CommF then return 0 end
    local ok, inv = pcall(function() return CommF:InvokeServer("getInventory") end)
    if ok and type(inv) == "table" then
        for _, item in ipairs(inv) do
            if type(item) == "table" and item.Name == "Cocoa" then
                return tonumber(item.Count) or tonumber(item.Amount) or 0
            end
        end
    end
    return 0
end

local lastCakeStatusCheck = 0
local lastSweetCraftTry = 0

task.spawn(function()
    while true do
        task.wait(1)
        if (getgenv().PolarAutoDoughKingEnabled or getgenv().PolarAutoCakePrinceEnabled) and not DoughKingRunning then
            DoughKingRunning = true
            task.spawn(function()
                while (getgenv().PolarAutoDoughKingEnabled or getgenv().PolarAutoCakePrinceEnabled) do
                    pcall(function()
                        local char = LocalPlayer.Character
                        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                        local myHum = char and char:FindFirstChildOfClass("Humanoid")
                        if not myHrp or not myHum or myHum.Health <= 0 then
                            task.wait(0.8)
                            return
                        end

                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")

                        local doughKing = (enemies and enemies:FindFirstChild("Dough King")) or (chars and chars:FindFirstChild("Dough King"))
                        local cakePrince = (enemies and enemies:FindFirstChild("Cake Prince")) or (chars and chars:FindFirstChild("Cake Prince"))
                        local boss = doughKing or cakePrince

                        if boss and boss:FindFirstChild("HumanoidRootPart") then
                            local hum = boss:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local hoverCF = boss.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0)
                                if (myHrp.Position - hoverCF.Position).Magnitude > 20 then
                                    if Polar.Teleport then Polar.Teleport:To(hoverCF) end
                                else
                                    myHrp.CFrame = CFrame.lookAt(hoverCF.Position, boss.HumanoidRootPart.Position)
                                end
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(0, 0))
                                return
                            end
                        end

                        -- Auto craft Sweet Chalice via Sweet Crafter when holding God's Chalice + 10 Cocoa
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local hasGodChalice = (backpack and backpack:FindFirstChild("God's Chalice")) or (char and char:FindFirstChild("God's Chalice"))
                        local hasSweetChalice = (backpack and backpack:FindFirstChild("Sweet Chalice")) or (char and char:FindFirstChild("Sweet Chalice"))

                        if getgenv().PolarAutoDoughKingEnabled and not getgenv().PolarIgnoreDoughKingItem and hasGodChalice and not hasSweetChalice and CommF then
                            if tick() - lastSweetCraftTry > 3 and GetCocoaCount() >= 10 then
                                lastSweetCraftTry = tick()
                                local crafterCF = (Polar.World and Polar.World.FindNPC and Polar.World:FindNPC("Sweet Crafter"))
                                    or CFrame.new(223.1, 23.5, -12770.3)
                                if (myHrp.Position - crafterCF.Position).Magnitude > 18 and Polar.Teleport then
                                    Polar.Teleport:To(crafterCF * CFrame.new(0, 2, 3))
                                    task.wait(0.3)
                                end
                                CommF:InvokeServer("SweetChaliceNpc")
                                task.wait(0.4)
                            end
                        end

                        -- Query CakePrinceSpawner status before trying to open Mirror Dimension
                        if CommF and (tick() - lastCakeStatusCheck > 2.5) then
                            lastCakeStatusCheck = tick()
                            local okStatus, status = pcall(function() return CommF:InvokeServer("CakePrinceSpawner", true) end)
                            if okStatus and type(status) == "string" and string.find(string.lower(status), "open the portal") then
                                local shouldOpen = true
                                if getgenv().PolarAutoDoughKingEnabled and not getgenv().PolarAutoCakePrinceEnabled and not getgenv().PolarIgnoreDoughKingItem then
                                    -- In pure Dough King mode, wait for Sweet Chalice unless ignoring Chalice requirement
                                    shouldOpen = hasSweetChalice ~= nil
                                end
                                if shouldOpen then
                                    local dripCF = (Polar.World and Polar.World.FindNPC and Polar.World:FindNPC("drip_mama"))
                                        or CFrame.new(-2137.7, 66.3, -12326.3)
                                    if (myHrp.Position - dripCF.Position).Magnitude > 20 and Polar.Teleport then
                                        Polar.Teleport:To(dripCF * CFrame.new(0, 2, 3))
                                        task.wait(0.3)
                                    end
                                    CommF:InvokeServer("CakePrinceSpawner")
                                    task.wait(0.4)
                                end
                            end
                        end

                        -- Farm Cake Land mobs to decrement portal counter
                        local cakeMobs = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
                        local targetMob = nil
                        if enemies then
                            local bestDist = math.huge
                            for _, mob in ipairs(enemies:GetChildren()) do
                                for _, name in ipairs(cakeMobs) do
                                    if mob.Name == name then
                                        local hum = mob:FindFirstChildOfClass("Humanoid")
                                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                                        if hum and hrp and hum.Health > 0 then
                                            local d = (myHrp.Position - hrp.Position).Magnitude
                                            if d < bestDist then
                                                bestDist = d
                                                targetMob = mob
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            local tHrp = targetMob.HumanoidRootPart
                            local hoverCF = tHrp.CFrame * CFrame.new(0, 12, 0)
                            if (myHrp.Position - hoverCF.Position).Magnitude > 18 then
                                if Polar.Teleport then Polar.Teleport:To(hoverCF) end
                            else
                                myHrp.CFrame = CFrame.lookAt(hoverCF.Position, tHrp.Position)
                            end
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(0, 0))
                        else
                            local waitCF = CFrame.new(-2022.3, 36.9, -12031.0)
                            if (myHrp.Position - waitCF.Position).Magnitude > 25 and Polar.Teleport then
                                Polar.Teleport:To(waitCF)
                            end
                        end
                    end)
                    task.wait(0.25)
                end
                getgenv().PolarFastAttackEnabled = false
                if Polar.Teleport and Polar.Teleport.Cancel then Polar.Teleport:Cancel() end
                DoughKingRunning = false
            end)
        end
    end
end)

-- ==================== 4. AUTO BONES & DEATH KING (HAUNTED CASTLE) ====================
local AutoBonesRunning = false

local function MatchHauntedTarget(text, expectedName)
    if type(text) ~= "string" or text == "" then return false end
    local lower = string.lower(text)
    if expectedName then
        local lowerExp = string.lower(expectedName)
        if string.find(lower, lowerExp, 1, true) then return true end
        if string.find(lowerExp, "mummy", 1, true) and (string.find(lower, "momi", 1, true) or string.find(lower, "possessed", 1, true) or string.find(lower, "posessed", 1, true)) then return true end
        if string.find(lowerExp, "skeleton", 1, true) and string.find(lower, "esquelet", 1, true) then return true end
        if string.find(lowerExp, "zombie", 1, true) and string.find(lower, "zomb", 1, true) then return true end
        if string.find(lowerExp, "soul", 1, true) and string.find(lower, "alma", 1, true) then return true end
        return false
    end
    for _, kw in ipairs({"skeleton", "zombie", "soul", "mummy", "esquelet", "zomb", "alma", "momi", "haunted"}) do
        if string.find(lower, kw, 1, true) then return true end
    end
    return false
end

local function HasHauntedQuestActive(expectedName)
    if Polar.QuestEngine and Polar.QuestEngine.GetGuideQuestData then
        local qd = Polar.QuestEngine:GetGuideQuestData()
        if qd then
            if Polar.Quest and Polar.Quest.GetTargetEnemyNameFromQuest then
                local currentTarget = Polar.Quest:GetTargetEnemyNameFromQuest()
                if currentTarget and MatchHauntedTarget(currentTarget, expectedName) then
                    return true
                end
            end
        end
    end

    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local tq = pgui and pgui:FindFirstChild("TrackedQuestFrame")
    if tq then
        local frame = tq:FindFirstChild("Frame")
        if frame and frame.Visible then
            local descText = ""
            local matchedObjective = false
            for _, inst in ipairs(frame:GetDescendants()) do
                if inst:IsA("TextLabel") and inst.Text ~= "" then
                    local c, m = inst.Text:match("(%d+)%s*/%s*(%d+)")
                    if c and m and tonumber(m) > 0 and tonumber(c) >= tonumber(m) then
                        return false
                    end
                    descText = descText .. " " .. inst.Text
                    if MatchHauntedTarget(inst.Text, expectedName) then
                        matchedObjective = true
                    end
                end
            end
            if matchedObjective then return true end
            if not expectedName and descText ~= "" then return MatchHauntedTarget(descText, nil) end
            return false
        end
    end
    local mainUI = pgui and pgui:FindFirstChild("Main")
    local questUI = mainUI and mainUI:FindFirstChild("Quest")
    if questUI and questUI.Visible then
        local container = questUI:FindFirstChild("Container")
        local title = container and (container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title") or container:FindFirstChild("QuestTitle"))
        if title and title.Text and title.Text ~= "" then
            return MatchHauntedTarget(title.Text, expectedName)
        end
    end
    return false
end

-- Bucle Independiente de Auto Spin Huesos (Death King) - Verifica saldo antes de girar
task.spawn(function()
    while true do
        task.wait(2.5)
        if getgenv().PolarAutoSpinBones then
            pcall(function()
                if not CommF then return end
                local ok, checkRes = pcall(function() return CommF:InvokeServer("Bones", "Check") end)
                local canSpin = true
                if ok and type(checkRes) == "number" and checkRes < 50 then
                    canSpin = false
                elseif ok and type(checkRes) == "table" then
                    local bones = tonumber(checkRes.Bones or checkRes.Count or checkRes[1])
                    local spinsLeft = tonumber(checkRes.Spins or checkRes.SpinsLeft or checkRes[2])
                    if (bones and bones < 50) or (spinsLeft and spinsLeft <= 0) then
                        canSpin = false
                    end
                end
                if canSpin then
                    CommF:InvokeServer("Bones", "Buy", 1, 1)
                end
            end)
        end
    end
end)

-- Bucle fallback de Auto Farm Huesos si PolarMastery no esta activo
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().PolarAutoBonesEnabled and not AutoBonesRunning then
            AutoBonesRunning = true
            task.spawn(function()
                while getgenv().PolarAutoBonesEnabled do
                    pcall(function()
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
                        local qName = "HauntedQuest2"
                        local qIndex = 2
                        local targetMobName = "Posessed Mummy"
                        local fallbackQuestPos = CFrame.new(-9517.0, 172.0, 6078.4)

                        if lvl < 2000 then
                            qName = "HauntedQuest1"
                            qIndex = 1
                            targetMobName = "Reborn Skeleton"
                            fallbackQuestPos = CFrame.new(-9479.3, 141.2, 5566.0)
                        elseif lvl < 2025 then
                            qName = "HauntedQuest1"
                            qIndex = 2
                            targetMobName = "Living Zombie"
                            fallbackQuestPos = CFrame.new(-9479.3, 141.2, 5566.0)
                        elseif lvl < 2050 then
                            qName = "HauntedQuest2"
                            qIndex = 1
                            targetMobName = "Demonic Soul"
                            fallbackQuestPos = CFrame.new(-9517.0, 172.0, 6078.4)
                        end

                        local questPos = (Polar.World and Polar.World.GetQuestGiverCFrame and Polar.World:GetQuestGiverCFrame(qName, qIndex, targetMobName)) or fallbackQuestPos

                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local hasEssence = (backpack and backpack:FindFirstChild("Hallow Essence")) or (char and char:FindFirstChild("Hallow Essence"))
                        if hasEssence then
                            if Polar.Teleport then Polar.Teleport:To(CFrame.new(-8925.4, 147.2, 6055.1)) end
                            task.wait(0.8)
                            if CommF then pcall(function() CommF:InvokeServer("SummonSoulReaper") end) end
                        end

                        local hasQuest = HasHauntedQuestActive(targetMobName)
                        if not hasQuest then
                            if (hrp.Position - questPos.Position).Magnitude > 15 then
                                if Polar.Teleport then Polar.Teleport:To(questPos * CFrame.new(0, 2, 3)) end
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

                        local enemies = workspace:FindFirstChild("Enemies")
                        local chars = workspace:FindFirstChild("Characters")
                        local soulReaper = (enemies and enemies:FindFirstChild("Soul Reaper")) or (chars and chars:FindFirstChild("Soul Reaper"))
                        local targetNpc = nil

                        if soulReaper and soulReaper:FindFirstChild("HumanoidRootPart") and soulReaper:FindFirstChildOfClass("Humanoid") and soulReaper.Humanoid.Health > 0 then
                            targetNpc = soulReaper
                        elseif enemies then
                            local bestDist = math.huge
                            local lowerMob = string.lower(targetMobName)
                            for _, npc in ipairs(enemies:GetChildren()) do
                                if string.find(string.lower(npc.Name), lowerMob, 1, true) then
                                    local nHrp = npc:FindFirstChild("HumanoidRootPart")
                                    local nHum = npc:FindFirstChildOfClass("Humanoid")
                                    if nHrp and nHum and nHum.Health > 0 then
                                        local d = (hrp.Position - nHrp.Position).Magnitude
                                        if d < bestDist then
                                            bestDist = d
                                            targetNpc = npc
                                        end
                                    end
                                end
                            end
                        end

                        if targetNpc and targetNpc:FindFirstChild("HumanoidRootPart") then
                            local tHrp = targetNpc.HumanoidRootPart
                            local targetHoverCF = tHrp.CFrame * CFrame.new(0, (Polar.Combat and Polar.Combat.HoverHeight) or 12.5, 0)

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

                            if enemies and targetNpc ~= soulReaper then
                                local brought = 1
                                for _, other in ipairs(enemies:GetChildren()) do
                                    if other ~= targetNpc and string.find(string.lower(other.Name), string.lower(targetMobName), 1, true) then
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
                            local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
                            if hoverBv then hoverBv:Destroy() end
                            local waitPos = (Polar.World and Polar.World.GetEnemySpawnPosition and Polar.World:GetEnemySpawnPosition(targetMobName)) or questPos
                            if (hrp.Position - waitPos.Position).Magnitude > 25 and Polar.Teleport then
                                Polar.Teleport:To(waitPos * CFrame.new(0, 15, 0))
                            end
                        end
                    end)
                    task.wait(0.15)
                end

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
                    if hoverBv then hoverBv:Destroy() end
                end
                getgenv().PolarFastAttackEnabled = false
                if Polar.Teleport and Polar.Teleport.Cancel then Polar.Teleport:Cancel() end
                AutoBonesRunning = false
            end)
        end
    end
end)

-- ==================== 5. AUTO PULL YAMA & LONGMA (TUSHITA) ====================
function Polar.Functions:AutoPullYama()
    pcall(function()
        local mapFolder = workspace:FindFirstChild("Map")
        local waterfall = mapFolder and mapFolder:FindFirstChild("Waterfall")
        local sealedKatana = waterfall and waterfall:FindFirstChild("SealedKatana")
        local hitbox = sealedKatana and (sealedKatana:FindFirstChild("Hitbox") or sealedKatana:FindFirstChildWhichIsA("BasePart"))
        local caveCF = (hitbox and (hitbox.CFrame * CFrame.new(0, 2, 0))) or CFrame.new(5229.8, 2.3, 983.4)

        if Polar.Teleport then Polar.Teleport:To(caveCF) end
        task.wait(0.6)

        -- Check Elite Hunter progress first and trigger interactive ClickDetector / ProximityPrompt in Waterfall
        local okProg, progRes = false, nil
        if CommF then
            okProg, progRes = pcall(function() return CommF:InvokeServer("EliteHunter", "Progress") end)
        end

        local interacted = false
        if sealedKatana then
            for _, d in ipairs(sealedKatana:GetDescendants()) do
                if d:IsA("ClickDetector") and fireclickdetector then
                    pcall(fireclickdetector, d)
                    interacted = true
                elseif d:IsA("ProximityPrompt") and fireproximityprompt then
                    pcall(fireproximityprompt, d)
                    interacted = true
                end
            end
        end

        if PolarUI and PolarUI.Notify then
            local msg = interacted and "Triggered Yama SealedKatana interaction." or "Moved to Yama SealedKatana cavern."
            if okProg and progRes ~= nil then
                msg = msg .. " Progress: " .. tostring(progRes)
            end
            PolarUI:Notify({ Title = "Polar Hub", Content = msg, Duration = 4 })
        end
    end)
end

function Polar.Functions:AutoKillLongma()
    pcall(function()
        local char = LocalPlayer.Character
        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
        local longmaRoom = CFrame.new(-10220.5, 333.1, -9420.2)
        local enemies = workspace:FindFirstChild("Enemies")
        local longma = enemies and enemies:FindFirstChild("Longma")

        if longma and longma:FindFirstChild("HumanoidRootPart") then
            local hoverCF = longma.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
            if myHrp and (myHrp.Position - hoverCF.Position).Magnitude > 18 then
                if Polar.Teleport then Polar.Teleport:To(hoverCF) end
            elseif myHrp then
                myHrp.CFrame = CFrame.lookAt(hoverCF.Position, longma.HumanoidRootPart.Position)
            end
            EquipWeaponLocal()
            getgenv().PolarFastAttackEnabled = true
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        else
            if Polar.Teleport then Polar.Teleport:To(longmaRoom) end
        end
    end)
end

-- ==================== INTERFAZ Y CONTROLES SEA 3 ====================

local BossNamesList = {}
for _, b in ipairs(Polar.Data.Bosses) do
    if b.q or b.name == "Longma" then
        table.insert(BossNamesList, b.name)
    end
end

-- Sync Sea 3 bosses with Boss Hunter dropdown in TabHome
if Polar.SetBossList then
    Polar.SetBossList(BossNamesList, "Stone")
elseif Polar.BossDropdown and Polar.BossDropdown.SetValues then
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

                -- 4. Elite Hunter (Escaneo seguro local sin sobrescribir misiones activas en servidor)
                local eliteInfo = nil
                local hasQuest = Polar.HasEliteQuest and Polar.HasEliteQuest()
                pcall(function()
                    local ok, res = Polar.SafeQueryEliteHunter(false)
                    if ok and type(res) == "string" then
                        local foundName, foundIsland = ExtractActiveEliteInfo(res)
                        if foundName then
                            eliteInfo = {
                                name = foundName,
                                island = foundIsland or "Mar"
                            }
                            Polar.LastEliteInfo = eliteInfo
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

print("Sea 3 active: Boss Inspector & World Radar initialized.")


-- ==================== 6. AUTO TYRANT OF THE SKIES ====================
local TyrantWasRunning = false
task.spawn(function()
    while true do
        task.wait(0.4)
        if getgenv().PolarAutoTyrant then
            TyrantWasRunning = true
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
                        hrp.CFrame = CFrame.lookAt(hoverCF.Position, tRoot.Position)
                    end
                    EquipWeaponLocal()
                    getgenv().PolarFastAttackEnabled = true
                else
                    local templeCF = CFrame.new(-16234.5, 120.0, 452.3)
                    if (hrp.Position - templeCF.Position).Magnitude > 120 then
                        if Polar.Teleport then Polar.Teleport:To(templeCF) end
                    end
                end
            end)
        elseif TyrantWasRunning then
            TyrantWasRunning = false
            getgenv().PolarFastAttackEnabled = false
            if Polar.Teleport and Polar.Teleport.Cancel then Polar.Teleport:Cancel() end
        end
    end
end)
