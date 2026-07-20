-- ==================== POLAR HUB | SEA 3 (MÓDULO FINAL) ====================
print("Cargando datos del Sea 3...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)

local Polar = getgenv().Polar
local Window = Polar.Window or getgenv().PolarWindow
local TabFarm = Polar.TabFarm or getgenv().PolarTabFarm
local TabStatus = Polar.TabStatus or getgenv().PolarTabStatus
local TabQuest = Polar.TabQuest or getgenv().PolarTabQuest

-- ==================== DATA REGISTRY SEA 3 ====================
Polar.Data.AllowedQuests = {
    "PortQuest", "DragonQuest", "HydraQuest", "MarineTreeQuest", 
    "TurtleQuest", "DeepForestQuest", "HauntedQuest1", "HauntedQuest2",
    "PeanutQuest", "IceCreamQuest", "CakeQuest1", "CakeQuest2",
    "ChocolateQuest1", "ChocolateQuest2", "CandyCaneQuest",
    "TikiQuest1", "TikiQuest2", "TikiQuest3",
    "SubmergedQuest1", "SubmergedQuest2", "SubmergedQuest3"
}

Polar.Data.QuestInfo = {
    -- Port Town (1500-1550)
    {lvl = 1500, q = "PortQuest", ql = 1, name = "Pirate Millionaire", giver = "Pirate Port Quest Giver", island = "Port Town"},
    {lvl = 1525, q = "PortQuest", ql = 2, name = "Pistol Billionaire", giver = "Pirate Port Quest Giver", island = "Port Town"},
    {lvl = 1550, q = "PortQuest", ql = 3, name = "Stone", giver = "Pirate Port Quest Giver", island = "Port Town", isBoss = true},
    -- Hydra Island (1575-1675)
    {lvl = 1575, q = "DragonQuest", ql = 1, name = "Dragon Crew Warrior", giver = "Dragon Crew Quest Giver", island = "Hydra Island"},
    {lvl = 1600, q = "DragonQuest", ql = 2, name = "Dragon Crew Archer", giver = "Dragon Crew Quest Giver", island = "Hydra Island"},
    {lvl = 1625, q = "HydraQuest", ql = 1, name = "Hydra Enforcer", giver = "Hydra Town Quest Giver", island = "Hydra Island"},
    {lvl = 1650, q = "HydraQuest", ql = 2, name = "Venomous Assailant", giver = "Hydra Town Quest Giver", island = "Hydra Island"},
    {lvl = 1675, q = "HydraQuest", ql = 3, name = "Hydra Leader", giver = "Hydra Town Quest Giver", island = "Hydra Island", isBoss = true},
    -- Great Tree (1700-1750)
    {lvl = 1700, q = "MarineTreeQuest", ql = 1, name = "Marine Commodore", giver = "Marine Tree Quest Giver", island = "Great Tree"},
    {lvl = 1725, q = "MarineTreeQuest", ql = 2, name = "Marine Rear Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree"},
    {lvl = 1750, q = "MarineTreeQuest", ql = 3, name = "Kilo Admiral", giver = "Marine Tree Quest Giver", island = "Great Tree", isBoss = true},
    -- Floating Turtle (1775-1950)
    {lvl = 1775, q = "TurtleQuest", ql = 1, name = "Fishman Raider", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle"},
    {lvl = 1800, q = "TurtleQuest", ql = 2, name = "Fishman Captain", giver = "Turtle Adventure Quest Giver", island = "Floating Turtle"},
    {lvl = 1825, q = "DeepForestQuest", ql = 1, name = "Forest Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle"},
    {lvl = 1850, q = "DeepForestQuest", ql = 2, name = "Mythological Pirate", giver = "Deep Forest Quest Giver", island = "Floating Turtle"},
    {lvl = 1875, q = "DeepForestQuest", ql = 3, name = "Captain Elephant", giver = "Deep Forest Quest Giver", island = "Floating Turtle", isBoss = true},
    {lvl = 1900, q = "DeepForestQuest2", ql = 1, name = "Jungle Pirates", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle"},
    {lvl = 1925, q = "DeepForestQuest2", ql = 2, name = "Musketeer Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle"},
    {lvl = 1950, q = "DeepForestQuest2", ql = 3, name = "Beautiful Pirate", giver = "Deep Forest Area 2 Quest Giver", island = "Floating Turtle", isBoss = true},
    -- Haunted Castle (1975-2050)
    {lvl = 1975, q = "HauntedQuest1", ql = 1, name = "Reborn Skeleton", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle"},
    {lvl = 2000, q = "HauntedQuest1", ql = 2, name = "Living Zombie", giver = "Haunted Castle Quest Giver 1", island = "Haunted Castle"},
    {lvl = 2025, q = "HauntedQuest2", ql = 1, name = "Demonic Soul", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle"},
    {lvl = 2050, q = "HauntedQuest2", ql = 2, name = "Posessed Mummy", giver = "Haunted Castle Quest Giver 2", island = "Haunted Castle"},
    -- Sea of Treats - Peanut Land (2075-2100)
    {lvl = 2075, q = "PeanutQuest", ql = 1, name = "Peanut Scout", giver = "Peanut Quest Giver", island = "Sea of Treats"},
    {lvl = 2100, q = "PeanutQuest", ql = 2, name = "Peanut President", giver = "Peanut Quest Giver", island = "Sea of Treats"},
    -- Sea of Treats - Ice Cream Land (2125-2175)
    {lvl = 2125, q = "IceCreamQuest", ql = 1, name = "Ice Cream Chef", giver = "Ice Cream Quest Giver", island = "Sea of Treats"},
    {lvl = 2150, q = "IceCreamQuest", ql = 2, name = "Ice Cream Commander", giver = "Ice Cream Quest Giver", island = "Sea of Treats"},
    {lvl = 2175, q = "IceCreamQuest", ql = 3, name = "Cake Queen", giver = "Ice Cream Quest Giver", island = "Sea of Treats", isBoss = true},
    -- Sea of Treats - Cake Land (2200-2275)
    {lvl = 2200, q = "CakeQuest1", ql = 1, name = "Cookie Crafter", giver = "Cake Quest Giver 1", island = "Sea of Treats"},
    {lvl = 2225, q = "CakeQuest1", ql = 2, name = "Cake Guard", giver = "Cake Quest Giver 1", island = "Sea of Treats"},
    {lvl = 2250, q = "CakeQuest2", ql = 1, name = "Baking Staff", giver = "Cake Quest Giver 2", island = "Sea of Treats"},
    {lvl = 2275, q = "CakeQuest2", ql = 2, name = "Head Baker", giver = "Cake Quest Giver 2", island = "Sea of Treats"},
    -- Sea of Treats - Chocolate Land (2300-2375)
    {lvl = 2300, q = "ChocolateQuest1", ql = 1, name = "Cocoa Warrior", giver = "Chocolate Quest Giver 1", island = "Sea of Treats"},
    {lvl = 2325, q = "ChocolateQuest1", ql = 2, name = "Chocolate Bar Battler", giver = "Chocolate Quest Giver 1", island = "Sea of Treats"},
    {lvl = 2350, q = "ChocolateQuest2", ql = 1, name = "Sweet Thief", giver = "Chocolate Quest Giver 2", island = "Sea of Treats"},
    {lvl = 2375, q = "ChocolateQuest2", ql = 2, name = "Candy Rebel", giver = "Chocolate Quest Giver 2", island = "Sea of Treats"},
    -- Sea of Treats - Candy Cane Land (2400-2425)
    {lvl = 2400, q = "CandyCaneQuest", ql = 1, name = "Candy Pirate", giver = "Candy Cane Quest Giver", island = "Sea of Treats"},
    {lvl = 2425, q = "CandyCaneQuest", ql = 2, name = "Snow Demon", giver = "Candy Cane Quest Giver", island = "Sea of Treats"},
    -- Tiki Outpost (2450-2575)
    {lvl = 2450, q = "TikiQuest1", ql = 1, name = "Isle Outlaw", giver = "Tiki Quest Giver 1", island = "Tiki Outpost"},
    {lvl = 2475, q = "TikiQuest1", ql = 2, name = "Island Boy", giver = "Tiki Quest Giver 1", island = "Tiki Outpost"},
    {lvl = 2500, q = "TikiQuest2", ql = 1, name = "Sun-kissed Warrior", giver = "Tiki Quest Giver 2", island = "Tiki Outpost"},
    {lvl = 2525, q = "TikiQuest2", ql = 2, name = "Isle Champion", giver = "Tiki Quest Giver 2", island = "Tiki Outpost"},
    {lvl = 2550, q = "TikiQuest3", ql = 1, name = "Serpent Hunter", giver = "Tiki Quest Giver 3", island = "Tiki Outpost"},
    {lvl = 2575, q = "TikiQuest3", ql = 2, name = "Skull Slayer", giver = "Tiki Quest Giver 3", island = "Tiki Outpost"},
    -- Submerged Island (2600-2700)
    {lvl = 2600, q = "SubmergedQuest1", ql = 1, name = "Reef Bandit", giver = "Submerged Quest Giver 1", island = "Submerged Island"},
    {lvl = 2625, q = "SubmergedQuest1", ql = 2, name = "Coral Pirate", giver = "Submerged Quest Giver 1", island = "Submerged Island"},
    {lvl = 2650, q = "SubmergedQuest2", ql = 1, name = "Sea Chanter", giver = "Submerged Quest Giver 2", island = "Submerged Island"},
    {lvl = 2675, q = "SubmergedQuest2", ql = 2, name = "Ocean Prophet", giver = "Submerged Quest Giver 2", island = "Submerged Island"},
    {lvl = 2675, q = "SubmergedQuest3", ql = 1, name = "High Disciple", giver = "Submerged Quest Giver 3", island = "Submerged Island"},
    {lvl = 2700, q = "SubmergedQuest3", ql = 2, name = "Grand Devotee", giver = "Submerged Quest Giver 3", island = "Submerged Island"}
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
    {name = "Tyrant of the Skies", q = nil, ql = nil, giver = nil, island = "Tiki Outpost", lvl = 2200}
}

-- Mapeos Dinámicos
for _, q in ipairs(Polar.Data.QuestInfo) do
    Polar.Data.QuestToIsland[q.q] = q.island
    Polar.Data.QuestGiver[q.q] = q.giver
end

-- ==================== MEJORAS DE AUTOMATIZACIÓN SEA 3 ====================

local function EquipWeaponLocal()
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local currentTool = char:FindFirstChildOfClass("Tool")
    if not currentTool then
        local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool:FindFirstChild("Combat")) then
                    char.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
end

-- 1. LOOP AUTO ELITE PIRATES
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoElitePiratesEnabled then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, npc in ipairs(enemies:GetChildren()) do
                    if string.find(string.lower(npc.Name), "elite") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
                        Polar.Teleport:To(npc.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                        getgenv().PolarFastAttackEnabled = true
                        EquipWeaponLocal()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0,0))
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- 2. LOOP AUTO RIP_INDRA
local RipIndraRunning = false
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoRipIndraEnabled and not RipIndraRunning then
            local lvl = Polar.Player:GetLevel()
            if lvl < 2000 then
                warn("Polar Hub: Necesitas Nivel 2000 para rip_indra.")
                getgenv().PolarAutoRipIndraEnabled = false
            else
                RipIndraRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoRipIndraEnabled do
                        local enemy = workspace.Enemies:FindFirstChild("rip_indra") or workspace.Characters:FindFirstChild("rip_indra")
                        if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                            Polar.Teleport:To(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                        else
                            -- Ir al Castle on Sea para summonear
                            local castleCF = CFrame.new(-5085, 316, 3152)
                            Polar.Teleport:To(castleCF)
                            task.wait(2)
                            -- Intentar summonear si tiene God's Chalice
                            local hasChalice = LocalPlayer.Backpack:FindFirstChild("God's Chalice") or LocalPlayer.Character:FindFirstChild("God's Chalice")
                            if hasChalice then
                                pcall(function() CommF:InvokeServer("SummonRipIndra") end)
                            end
                        end
                        task.wait(0.2)
                    end
                    getgenv().PolarFastAttackEnabled = false
                    RipIndraRunning = false
                end)
            end
        end
    end
end)

-- 3. LOOP AUTO DOUGH KING
local DoughKingRunning = false
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoDoughKingEnabled and not DoughKingRunning then
            local lvl = Polar.Player:GetLevel()
            if lvl < 2300 then
                warn("Polar Hub: Necesitas Nivel 2300 para Dough King.")
                getgenv().PolarAutoDoughKingEnabled = false
            else
                DoughKingRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoDoughKingEnabled do
                        local enemy = workspace.Enemies:FindFirstChild("Dough King") or workspace.Characters:FindFirstChild("Dough King")
                        if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                            Polar.Teleport:To(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            EquipWeaponLocal()
                            getgenv().PolarFastAttackEnabled = true
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                        else
                            -- Ir a Sea of Treats
                            Polar.Teleport:ToIsland("Sea of Treats")
                        end
                        task.wait(0.2)
                    end
                    getgenv().PolarFastAttackEnabled = false
                    DoughKingRunning = false
                end)
            end
        end
    end
end)

-- ==================== INTERFAZ Y CONTROLES SEA 3 ====================
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

TabQuest:AddSection("Eventos Especiales (Sea 3)")

TabQuest:AddToggle({
    Name = "Auto Elite Pirates (God's Chalice)",
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
    Name = "Auto Dough King (Sea of Treats)",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoDoughKingEnabled = Value
    end
})

TabStatus:AddSection("Radar de Jefes Sea 3")

local LabelRipIndra = TabStatus:AddParagraph({ Title = "rip_indra Status", Text = "Buscando..." })
local LabelElitePirates = TabStatus:AddParagraph({ Title = "Elite Pirates", Text = "Esperando spawn..." })
local LabelDoughKing = TabStatus:AddParagraph({ Title = "Dough King Status", Text = "Buscando..." })

task.spawn(function()
    while true do
        task.wait(5)
        local hasRipIndra = false
        local hasElite = false
        local hasDoughKing = false
        
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, obj in ipairs(enemies:GetChildren()) do
                if obj.Name == "rip_indra" then hasRipIndra = true end
                if string.find(string.lower(obj.Name), "elite") then hasElite = true end
                if obj.Name == "Dough King" then hasDoughKing = true end
            end
        end
        
        pcall(function()
            LabelRipIndra:SetDesc(hasRipIndra and "¡VIVO! (Castle on Sea)" or "Muerto / No Spawneado")
            LabelElitePirates:SetDesc(hasElite and "¡SPAWNEADO! (Farm para God's Chalice)" or "Esperando spawn (10 min)")
            LabelDoughKing:SetDesc(hasDoughKing and "¡VIVO! (Sea of Treats)" or "Muerto / No Spawneado")
        end)
    end
end)

print("✅ Sea 3 cargado exitosamente.")
