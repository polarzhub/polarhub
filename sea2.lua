-- ==================== POLAR HUB | SEA 2 (MÓDULO AVANZADO) ====================
print("Cargando datos del Sea 2...")

local Window = getgenv().PolarWindow
local TabQuest = getgenv().PolarTabQuest
local TabFarm = getgenv().PolarTabFarm
local TabStatus = getgenv().PolarTabStatus
local Players = game:GetService("Players")

-- ==================== BASE DE DATOS DE MISIONES SEA 2 ====================
-- QUEST STRINGS: Escaneados directamente de los remotos internos de Blox Fruits (CommF_)
-- Cada "q" es el argumento EXACTO que CommF:InvokeServer("StartQuest", q, ql) espera.
getgenv().PolarLevelQuests = {
    {lvl = 700, q = "RoseQuest", ql = 1, name = "Raider", giver = "Area 1 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 725, q = "RoseQuest", ql = 2, name = "Mercenary", giver = "Area 1 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 750, q = "RoseQuest", ql = 3, name = "Diamond", giver = "Area 1 Quest Giver", island = "Kingdom of Rose", isBoss = true},
    {lvl = 775, q = "RoseQuest2", ql = 1, name = "Swan Pirate", giver = "Quest Giver 2", island = "Kingdom of Rose"},
    {lvl = 800, q = "RoseQuest2", ql = 2, name = "Factory Staff", giver = "Quest Giver 2", island = "Kingdom of Rose"},
    {lvl = 850, q = "RoseQuest2", ql = 3, name = "Jeremy", giver = "Quest Giver 2", island = "Kingdom of Rose", isBoss = true},
    {lvl = 875, q = "MarineQuest3", ql = 1, name = "Marine Lieutenant", giver = "Marine Quest Giver", island = "Green Zone"},
    {lvl = 900, q = "MarineQuest3", ql = 2, name = "Marine Captain", giver = "Marine Quest Giver", island = "Green Zone"},
    {lvl = 950, q = "ZombieQuest", ql = 1, name = "Zombie", giver = "Zombie Quest Giver", island = "Graveyard"},
    {lvl = 975, q = "ZombieQuest", ql = 2, name = "Vampire", giver = "Zombie Quest Giver", island = "Graveyard"},
    {lvl = 1000, q = "SnowMountainQuest", ql = 1, name = "Snow Trooper", giver = "Snowy Quest Giver", island = "Snow Mountain"},
    {lvl = 1050, q = "SnowMountainQuest", ql = 2, name = "Winter Warrior", giver = "Snowy Quest Giver", island = "Snow Mountain"},
    {lvl = 1100, q = "IceSideQuest", ql = 1, name = "Lab Subordinate", giver = "Alchemist Quest Giver", island = "Hot and Cold"},
    {lvl = 1150, q = "IceSideQuest", ql = 2, name = "Horned Warrior", giver = "Alchemist Quest Giver", island = "Hot and Cold"},
    {lvl = 1200, q = "FireSideQuest", ql = 1, name = "Magma Ninja", giver = "Magma Quest Giver", island = "Hot and Cold"},
    {lvl = 1250, q = "FireSideQuest", ql = 2, name = "Lava Pirate", giver = "Magma Quest Giver", island = "Hot and Cold"},
    {lvl = 1275, q = "FireSideQuest", ql = 3, name = "Smoke Admiral", giver = "Magma Quest Giver", island = "Hot and Cold", isBoss = true},
    {lvl = 1300, q = "ShipQuest1", ql = 1, name = "Ship Deckhand", giver = "Ship Quest Giver", island = "Cursed Ship"},
    {lvl = 1325, q = "ShipQuest1", ql = 2, name = "Ship Engineer", giver = "Ship Quest Giver", island = "Cursed Ship"},
    {lvl = 1350, q = "ShipQuest2", ql = 1, name = "Ship Steward", giver = "Ship Quest Giver 2", island = "Cursed Ship"},
    {lvl = 1375, q = "ShipQuest2", ql = 2, name = "Ship Officer", giver = "Ship Quest Giver 2", island = "Cursed Ship"},
    {lvl = 1400, q = "FrostQuest", ql = 1, name = "Awakened Ice Admiral", giver = "Arctic Quest Giver", island = "Ice Castle", isBoss = true},
    {lvl = 1425, q = "ForgottenQuest", ql = 1, name = "Sea Soldier", giver = "Forgotten Quest Giver", island = "Forgotten Island"},
    {lvl = 1450, q = "ForgottenQuest", ql = 2, name = "Water Fighter", giver = "Forgotten Quest Giver", island = "Forgotten Island"},
    {lvl = 1475, q = "ForgottenQuest", ql = 3, name = "Tide Keeper", giver = "Forgotten Quest Giver", island = "Forgotten Island", isBoss = true}
}

-- ==================== BASE DE DATOS DE JEFES SEA 2 ====================
getgenv().PolarBosses = {
    {name = "Diamond", q = "Area1Quest", ql = 3, giver = "Quest Giver", island = "Kingdom of Rose", lvl = 750},
    {name = "Jeremy", q = "Area2Quest", ql = 3, giver = "Quest Giver 2", island = "Kingdom of Rose", lvl = 850},
    {name = "Fajita", q = nil, ql = nil, giver = nil, island = "Green Zone", lvl = 925},
    {name = "Don Swan", q = nil, ql = nil, giver = nil, island = "Kingdom of Rose", lvl = 1000},
    {name = "Smoke Admiral", q = "FireQuest1", ql = 3, giver = "Fire Scientist", island = "Hot and Cold", lvl = 1275},
    {name = "Cursed Captain", q = nil, ql = nil, giver = nil, island = "Cursed Ship", lvl = 1325},
    {name = "Awakened Ice Admiral", q = "FrostQuest", ql = 1, giver = "Arctic Warrior", island = "Ice Castle", lvl = 1400},
    {name = "Tide Keeper", q = "WaterQuest", ql = 3, giver = "Water Fighter", island = "Forgotten Island", lvl = 1475},
    {name = "Darkbeard", q = nil, ql = nil, giver = nil, island = "Dark Arena", lvl = 1000}
}

-- ==================== ESCÁNER DINÁMICO DE RENDIMIENTO ====================
-- Este escáner precarga posiciones de NPCs en memoria al instante para evitar búsquedas costosas y subir los FPS
task.spawn(function()
    print("Polar Hub: Inicializando Escáner Dinámico del Sea 2...")
    local Workspace = game:GetService("Workspace")
    local NPCs = Workspace:WaitForChild("NPCs", 5)
    
    if NPCs then
        local foundCount = 0
        getgenv().PolarNPCCache = {}
        for _, npc in ipairs(NPCs:GetChildren()) do
            local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
            if part then
                if not getgenv().PolarNPCCache[npc.Name] then
                    getgenv().PolarNPCCache[npc.Name] = {}
                end
                table.insert(getgenv().PolarNPCCache[npc.Name], part.CFrame)
                foundCount = foundCount + 1
            end
        end
        print("Polar Hub: Escaneo exitoso! " .. tostring(foundCount) .. " NPCs cacheados para MÁXIMA potencia.")
    end
end)



-- ==================== INTERFAZ DE JEFES ====================
TabFarm:Section({ Title = "Cazador de Jefes (Sea 2)" })

local BossNamesList = {}
for _, b in ipairs(getgenv().PolarBosses) do table.insert(BossNamesList, b.name) end
if #BossNamesList == 0 then table.insert(BossNamesList, "Ninguno") end

TabFarm:Dropdown({
    Title = "Seleccionar Jefe",
    Values = BossNamesList,
    Value = BossNamesList[1],
    Callback = function(Value)
        getgenv().PolarSelectedBossToFarm = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm Jefe Seleccionado",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoFarmBossEnabled = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm TODOS los Jefes (Server Hop)",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoFarmAllBossesEnabled = Value
        if Value then getgenv().PolarLastBossCheckedIndex = 1 end
    end
})

-- ==================== EVENTOS Y MISIONES ESPECIALES SEA 2 ====================
TabQuest:Section({ Title = "Eventos Especiales (Sea 2)" })

TabQuest:Toggle({
    Title = "Auto Factory Raid",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoFactoryEnabled = Value
    end
})

TabQuest:Toggle({
    Title = "Auto Bartilo Quest (Coliseo)",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoBartiloEnabled = Value
    end
})

TabQuest:Toggle({
    Title = "Auto Raza V2 (Alchemist)",
    Default = false,
    Callback = function(Value)
        getgenv().PolarAutoAlchemistEnabled = Value
    end
})

TabStatus:Section({ Title = "Radar de Jefes Globales" })

local LabelDarkbeard = TabStatus:Paragraph({
    Title = "Darkbeard Status",
    Desc = "Buscando..."
})

local LabelFactory = TabStatus:Paragraph({
    Title = "Factory Status",
    Desc = "Calculando..."
})

task.spawn(function()
    while true do
        task.wait(5)
        local hasDarkbeard = false
        local hasFactory = false
        
        for _, obj in ipairs(workspace.Enemies:GetChildren()) do
            if obj.Name == "Darkbeard" then hasDarkbeard = true end
            if obj.Name == "Core" and obj.Parent.Name == "Factory" then hasFactory = true end
        end
        
        LabelDarkbeard:SetDesc(hasDarkbeard and "¡VIVO! (En la Arena Oscura)" or "Muerto / No Spawneado")
        LabelFactory:SetDesc(hasFactory and "¡ABIERTA! (Ve a la Fábrica)" or "Cerrada / Destruida")
    end
end)

-- ==================== MEJORAS DE AUTOMATIZACIÓN SEA 2 ====================

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

-- 1. LOOP AUTO FACTORY RAID
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoFactoryEnabled then
            local enemies = workspace:FindFirstChild("Enemies")
            local core = enemies and enemies:FindFirstChild("Core")
            if core and core:FindFirstChild("HumanoidRootPart") then
                getgenv().PolarBypassTeleport(core.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                getgenv().PolarFastAttackEnabled = true
                EquipWeaponLocal()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
            else
                getgenv().PolarFastAttackEnabled = false
            end
        end
    end
end)

-- 2. LOOP AUTO BARTILO QUEST
local BartiloQuestRunning = false
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoBartiloEnabled and not BartiloQuestRunning then
            local lvl = game.Players.LocalPlayer.Data.Level.Value
            if lvl < 850 then
                warn("Polar Hub: Necesitas Nivel 850 para hacer la misión de Bartilo.")
                getgenv().PolarAutoBartiloEnabled = false
            else
                BartiloQuestRunning = true
                task.spawn(function()
                    local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                    
                    while getgenv().PolarAutoBartiloEnabled do
                        local progress = CommF:InvokeServer("BartiloQuestProgress", "Bartilo")
                        
                        if progress == 0 or progress == nil then
                            warn("Polar Hub: Hablando con Bartilo (Quest 1 - Swan Pirates)...")
                            CommF:InvokeServer("StartQuest", "BartiloQuest", 1)
                            task.wait(1)
                            
                            warn("Polar Hub: Derrotando 50 Swan Pirates...")
                            while getgenv().PolarAutoBartiloEnabled do
                                local q = game.Players.LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
                                if not (q and q.Visible and string.find(q.Container.QuestTitle.Title.Text, "Swan Pirate")) then
                                    local status = CommF:InvokeServer("BartiloQuestProgress", "Bartilo")
                                    if status ~= 0 then break end
                                    CommF:InvokeServer("StartQuest", "BartiloQuest", 1)
                                    task.wait(1)
                                end
                                
                                local enemy = nil
                                for _, v in ipairs(workspace.Enemies:GetChildren()) do
                                    if v.Name == "Swan Pirate" and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                        enemy = v
                                        break
                                    end
                                end
                                if enemy then
                                    getgenv().PolarBypassTeleport(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                    EquipWeaponLocal()
                                    getgenv().PolarFastAttackEnabled = true
                                    game:GetService("VirtualUser"):CaptureController()
                                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                else
                                    getgenv().PolarBypassTeleport(CFrame.new(943, 121, 1269))
                                end
                                task.wait(0.2)
                            end
                            getgenv().PolarFastAttackEnabled = false
                            
                        elseif progress == 1 then
                            warn("Polar Hub: Hablando con Bartilo (Quest 2 - Jeremy)...")
                            CommF:InvokeServer("StartQuest", "BartiloQuest", 2)
                            task.wait(2)
                            
                        elseif progress == 2 then
                            warn("Polar Hub: Derrotando a Jeremy...")
                            while getgenv().PolarAutoBartiloEnabled do
                                local status = CommF:InvokeServer("BartiloQuestProgress", "Bartilo")
                                if status ~= 2 then break end
                                
                                local enemy = workspace.Enemies:FindFirstChild("Jeremy") or workspace.Characters:FindFirstChild("Jeremy")
                                if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                                    getgenv().PolarBypassTeleport(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                    EquipWeaponLocal()
                                    getgenv().PolarFastAttackEnabled = true
                                    game:GetService("VirtualUser"):CaptureController()
                                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                else
                                    getgenv().PolarBypassTeleport(CFrame.new(2316, 449, 787))
                                end
                                task.wait(0.2)
                            end
                            getgenv().PolarFastAttackEnabled = false
                            
                        elseif progress == 3 then
                            warn("Polar Hub: Resolviendo Puzzle del Coliseo...")
                            local colosseum = workspace:FindFirstChild("Colosseum", true) or workspace.Map:FindFirstChild("Colosseum", true)
                            if colosseum then
                                local plates = {"Y", "Infinity", "C", "S", "M", "F", "N", "B"}
                                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    for _, plateName in ipairs(plates) do
                                        local plate = colosseum:FindFirstChild(plateName, true)
                                        if plate and plate:IsA("BasePart") then
                                            getgenv().PolarBypassTeleport(plate.CFrame)
                                            task.wait(0.5)
                                            firetouchinterest(hrp, plate, 0)
                                            task.wait(0.1)
                                            firetouchinterest(hrp, plate, 1)
                                            task.wait(0.5)
                                        end
                                    end
                                end
                            end
                            task.wait(2)
                            CommF:InvokeServer("StartQuest", "BartiloQuest", 3)
                            task.wait(1)
                            warn("Polar Hub: ¡Misión de Bartilo completada con éxito!")
                            getgenv().PolarAutoBartiloEnabled = false
                            break
                        else
                            warn("Polar Hub: Misión de Bartilo ya completada.")
                            getgenv().PolarAutoBartiloEnabled = false
                            break
                        end
                        task.wait(1)
                    end
                    
                    BartiloQuestRunning = false
                end)
            end
        end
    end
end)

-- 3. LOOP AUTO RAZA V2 (ALCHEMIST FLOWER QUEST)
local AlchemistQuestRunning = false
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().PolarAutoAlchemistEnabled and not AlchemistQuestRunning then
            local lvl = game.Players.LocalPlayer.Data.Level.Value
            if lvl < 850 then
                warn("Polar Hub: Necesitas Nivel 850 para Raza V2.")
                getgenv().PolarAutoAlchemistEnabled = false
            else
                AlchemistQuestRunning = true
                task.spawn(function()
                    local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                    
                    while getgenv().PolarAutoAlchemistEnabled do
                        CommF:InvokeServer("Alchemist", "1")
                        task.wait(1)
                        
                        local hasRed = game.Players.LocalPlayer.Backpack:FindFirstChild("Red Flower") or game.Players.LocalPlayer.Character:FindFirstChild("Red Flower")
                        local hasBlue = game.Players.LocalPlayer.Backpack:FindFirstChild("Blue Flower") or game.Players.LocalPlayer.Character:FindFirstChild("Blue Flower")
                        local hasYellow = game.Players.LocalPlayer.Backpack:FindFirstChild("Yellow Flower") or game.Players.LocalPlayer.Character:FindFirstChild("Yellow Flower")
                        
                        if hasRed and hasBlue and hasYellow then
                            warn("Polar Hub: Flores colectadas. Entregando misión al Alquimista...")
                            getgenv().PolarBypassTeleport(CFrame.new(612, 38, -5074))
                            task.wait(1)
                            CommF:InvokeServer("Alchemist", "2")
                            task.wait(2)
                            warn("Polar Hub: ¡Raza V2 Desbloqueada!")
                            getgenv().PolarAutoAlchemistEnabled = false
                            break
                        end
                        
                        if not hasYellow then
                            warn("Polar Hub: Farmeando NPCs para obtener Flor Amarilla...")
                            local enemy = nil
                            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                                if v.Name == "Swan Pirate" and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    enemy = v
                                    break
                                end
                            end
                            if enemy then
                                getgenv().PolarBypassTeleport(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                            else
                                getgenv().PolarBypassTeleport(CFrame.new(943, 121, 1269))
                            end
                            task.wait(0.2)
                        
                        elseif not hasRed then
                            warn("Polar Hub: Buscando Flor Roja (Durante el día)...")
                            local time = game.Lighting.ClockTime
                            if time >= 6 and time <= 18 then
                                local flower = workspace:FindFirstChild("Red Flower") or workspace.Map:FindFirstChild("Red Flower", true)
                                if flower then
                                    getgenv().PolarBypassTeleport(flower.CFrame)
                                    task.wait(1)
                                else
                                    local spawns = {
                                        CFrame.new(-2544, 256, -429),
                                        CFrame.new(-3046, 239, -961),
                                        CFrame.new(639, 44, -5137),
                                        CFrame.new(-312, 190, -4933),
                                        CFrame.new(785, 142, 608)
                                    }
                                    for _, sp in ipairs(spawns) do
                                        if not getgenv().PolarAutoAlchemistEnabled or game.Players.LocalPlayer.Backpack:FindFirstChild("Red Flower") then break end
                                        getgenv().PolarBypassTeleport(sp)
                                        task.wait(1.5)
                                    end
                                end
                            else
                                warn("Polar Hub: Esperando que sea de día para buscar la Flor Roja...")
                                task.wait(5)
                            end
                            getgenv().PolarFastAttackEnabled = false
                            
                        elseif not hasBlue then
                            warn("Polar Hub: Buscando Flor Azul (Durante la noche)...")
                            local time = game.Lighting.ClockTime
                            if time < 6 or time > 18 then
                                local flower = workspace:FindFirstChild("Blue Flower") or workspace.Map:FindFirstChild("Blue Flower", true)
                                if flower then
                                    getgenv().PolarBypassTeleport(flower.CFrame)
                                    task.wait(1)
                                else
                                    local spawns = {
                                        CFrame.new(3716, 75, -6527),
                                        CFrame.new(-925, 40, 1699),
                                        CFrame.new(-1052, 38, 1530),
                                        CFrame.new(3716, 120, -6527)
                                    }
                                    for _, sp in ipairs(spawns) do
                                        if not getgenv().PolarAutoAlchemistEnabled or game.Players.LocalPlayer.Backpack:FindFirstChild("Blue Flower") then break end
                                        getgenv().PolarBypassTeleport(sp)
                                        task.wait(1.5)
                                    end
                                end
                            else
                                warn("Polar Hub: Esperando que sea de noche para buscar la Flor Azul...")
                                task.wait(5)
                            end
                            getgenv().PolarFastAttackEnabled = false
                        end
                        task.wait(1)
                    end
                    
                    AlchemistQuestRunning = false
                end)
            end
        end
    end
end)
