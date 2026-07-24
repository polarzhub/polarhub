-- ==================== POLAR HUB | SEA 2 (MÓDULO AVANZADO) ====================
print("❄️ Cargando datos del Sea 2 con detección unificada Polar Engine...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)

local Polar = getgenv().Polar
local Window = Polar.Window or getgenv().PolarWindow
local TabFarm = Polar.TabFarm or getgenv().PolarTabFarm
local TabStatus = Polar.TabStatus or getgenv().PolarTabStatus
local TabQuest = Polar.TabQuest or getgenv().PolarTabQuest

-- ==================== DATA REGISTRY SEA 2 ====================
Polar.Data.AllowedQuests = {
    "RoseQuest", "RoseQuest2", "MarineQuest3", "ZombieQuest", 
    "SnowMountainQuest", "IceSideQuest", "FireSideQuest", 
    "ShipQuest1", "FrostQuest", "ForgottenQuest"
}

Polar.Data.QuestInfo = {
    {lvl = 700, q = "RoseQuest", ql = 1, name = "Raider", giver = "Area 1 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 725, q = "RoseQuest", ql = 2, name = "Mercenary", giver = "Area 1 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 750, q = "RoseQuest", ql = 3, name = "Diamond", giver = "Area 1 Quest Giver", island = "Kingdom of Rose", isBoss = true},
    {lvl = 775, q = "RoseQuest2", ql = 1, name = "Swan Pirate", giver = "Area 2 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 800, q = "RoseQuest2", ql = 2, name = "Factory Staff", giver = "Area 2 Quest Giver", island = "Kingdom of Rose"},
    {lvl = 850, q = "RoseQuest2", ql = 3, name = "Jeremy", giver = "Area 2 Quest Giver", island = "Kingdom of Rose", isBoss = true},
    {lvl = 875, q = "MarineQuest3", ql = 1, name = "Marine Lieutenant", giver = "Marine Quest Giver", island = "Green Zone"},
    {lvl = 900, q = "MarineQuest3", ql = 2, name = "Marine Captain", giver = "Marine Quest Giver", island = "Green Zone"},
    {lvl = 950, q = "ZombieQuest", ql = 1, name = "Zombie", giver = "Zombie Quest Giver", island = "Graveyard"},
    {lvl = 975, q = "ZombieQuest", ql = 2, name = "Vampire", giver = "Zombie Quest Giver", island = "Graveyard"},
    {lvl = 1000, q = "SnowMountainQuest", ql = 1, name = "Snow Trooper", giver = "Snowy Quest Giver", island = "Snow Mountain"},
    {lvl = 1050, q = "SnowMountainQuest", ql = 2, name = "Winter Warrior", giver = "Snowy Quest Giver", island = "Snow Mountain"},
    {lvl = 1100, q = "IceSideQuest", ql = 1, name = "Lab Subordinate", giver = "Ice Quest Giver", island = "Hot and Cold"},
    {lvl = 1150, q = "IceSideQuest", ql = 2, name = "Horned Warrior", giver = "Ice Quest Giver", island = "Hot and Cold"},
    {lvl = 1200, q = "FireSideQuest", ql = 1, name = "Magma Ninja", giver = "Fire Quest Giver", island = "Hot and Cold"},
    {lvl = 1225, q = "FireSideQuest", ql = 2, name = "Lava Pirate", giver = "Fire Quest Giver", island = "Hot and Cold"},
    {lvl = 1250, q = "ShipQuest1", ql = 1, name = "Ship Deckhand", giver = "Rear Crew Quest Giver", island = "Cursed Ship"},
    {lvl = 1275, q = "ShipQuest1", ql = 2, name = "Ship Engineer", giver = "Rear Crew Quest Giver", island = "Cursed Ship"},
    {lvl = 1275, q = "FireSideQuest", ql = 3, name = "Smoke Admiral", giver = "Fire Quest Giver", island = "Hot and Cold", isBoss = true},
    {lvl = 1300, q = "ShipQuest1", ql = 3, name = "Ship Steward", giver = "Front Crew Quest Giver", island = "Cursed Ship"},
    {lvl = 1325, q = "ShipQuest1", ql = 4, name = "Ship Officer", giver = "Front Crew Quest Giver", island = "Cursed Ship"},
    {lvl = 1350, q = "FrostQuest", ql = 1, name = "Arctic Warrior", giver = "Frost Quest Giver", island = "Ice Castle"},
    {lvl = 1375, q = "FrostQuest", ql = 2, name = "Snow Lurker", giver = "Frost Quest Giver", island = "Ice Castle"},
    {lvl = 1400, q = "FrostQuest", ql = 3, name = "Awakened Ice Admiral", giver = "Frost Quest Giver", island = "Ice Castle", isBoss = true},
    {lvl = 1425, q = "ForgottenQuest", ql = 1, name = "Sea Soldier", giver = "Forgotten Quest Giver", island = "Forgotten Island"},
    {lvl = 1450, q = "ForgottenQuest", ql = 2, name = "Water Fighter", giver = "Forgotten Quest Giver", island = "Forgotten Island"},
    {lvl = 1475, q = "ForgottenQuest", ql = 3, name = "Tide Keeper", giver = "Forgotten Quest Giver", island = "Forgotten Island", isBoss = true}
}

Polar.Data.Bosses = {
    {name = "Diamond", q = "RoseQuest", ql = 3, giver = "Area 1 Quest Giver", island = "Kingdom of Rose", lvl = 750},
    {name = "Jeremy", q = "RoseQuest2", ql = 3, giver = "Area 2 Quest Giver", island = "Kingdom of Rose", lvl = 850},
    {name = "Fajita", q = nil, ql = nil, giver = nil, island = "Green Zone", lvl = 925},
    {name = "Don Swan", q = nil, ql = nil, giver = nil, island = "Kingdom of Rose", lvl = 1000},
    {name = "Smoke Admiral", q = "FireSideQuest", ql = 3, giver = "Fire Quest Giver", island = "Hot and Cold", lvl = 1275},
    {name = "Cursed Captain", q = nil, ql = nil, giver = nil, island = "Cursed Ship", lvl = 1325},
    {name = "Awakened Ice Admiral", q = "FrostQuest", ql = 3, giver = "Frost Quest Giver", island = "Ice Castle", lvl = 1400},
    {name = "Tide Keeper", q = "ForgottenQuest", ql = 3, giver = "Forgotten Quest Giver", island = "Forgotten Island", lvl = 1475},
    {name = "Darkbeard", q = nil, ql = nil, giver = nil, island = "Dark Arena", lvl = 1000}
}

-- Mapeos Dinámicos
for _, q in ipairs(Polar.Data.QuestInfo) do
    Polar.Data.QuestToIsland[q.q] = q.island
    Polar.Data.QuestGiver[q.q] = q.giver
end

-- ==================== MEJORAS DE AUTOMATIZACIÓN SEA 2 ====================

local function EquipWeaponLocal()
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if not currentTool then
        local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool:FindFirstChild("Combat")) then
                    hum:EquipTool(tool)
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
            local coreModel, coreHRP = Polar.Detection:FindEnemy("Core")
            if coreHRP then
                Polar.Teleport:To(coreHRP.CFrame * CFrame.new(0, 15, 0))
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
            local lvl = Polar.Player:GetLevel()
            if lvl < 850 then
                warn("Polar Hub: Necesitas Nivel 850 para hacer la misión de Bartilo.")
                getgenv().PolarAutoBartiloEnabled = false
            else
                BartiloQuestRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoBartiloEnabled do
                        local progress = nil
                        pcall(function() progress = CommF:InvokeServer("BartiloQuestProgress", "Bartilo") end)
                        
                        if progress == 0 or progress == nil then
                            warn("Polar Hub: Hablando con Bartilo (Quest 1)...")
                            pcall(function() CommF:InvokeServer("StartQuest", "BartiloQuest", 1) end)
                            task.wait(1)
                            
                            while getgenv().PolarAutoBartiloEnabled do
                                local title = Polar.QuestEngine and Polar.QuestEngine:GetActiveQuestTitle() or ""
                                if not string.find(string.lower(title), "swan pirate") then
                                    local status = nil
                                    pcall(function() status = CommF:InvokeServer("BartiloQuestProgress", "Bartilo") end)
                                    if status ~= 0 then break end
                                    pcall(function() CommF:InvokeServer("StartQuest", "BartiloQuest", 1) end)
                                    task.wait(1)
                                end
                                
                                local mob, hrp = Polar.Detection:FindEnemy("Swan Pirate")
                                if hrp then
                                    Polar.Teleport:To(hrp.CFrame * CFrame.new(0, 10, 0))
                                    EquipWeaponLocal()
                                    getgenv().PolarFastAttackEnabled = true
                                    game:GetService("VirtualUser"):CaptureController()
                                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                else
                                    Polar.Teleport:ToIsland("Kingdom of Rose")
                                end
                                task.wait(0.2)
                            end
                            getgenv().PolarFastAttackEnabled = false
                            
                        elseif progress == 1 then
                            warn("Polar Hub: Hablando con Bartilo (Quest 2)...")
                            pcall(function() CommF:InvokeServer("StartQuest", "BartiloQuest", 2) end)
                            task.wait(2)
                            
                        elseif progress == 2 then
                            warn("Polar Hub: Derrotando a Jeremy...")
                            while getgenv().PolarAutoBartiloEnabled do
                                local status = nil
                                pcall(function() status = CommF:InvokeServer("BartiloQuestProgress", "Bartilo") end)
                                if status ~= 2 then break end
                                
                                local mob, hrp = Polar.Detection:FindEnemy("Jeremy")
                                if hrp then
                                    Polar.Teleport:To(hrp.CFrame * CFrame.new(0, 10, 0))
                                    EquipWeaponLocal()
                                    getgenv().PolarFastAttackEnabled = true
                                    game:GetService("VirtualUser"):CaptureController()
                                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                else
                                    local spawnCF = Polar.Detection:GetEnemySpawnCFrame("Jeremy") or CFrame.new(2316, 449, 787)
                                    Polar.Teleport:To(spawnCF)
                                end
                                task.wait(0.2)
                            end
                            getgenv().PolarFastAttackEnabled = false
                            
                        elseif progress == 3 then
                            warn("Polar Hub: Resolviendo Puzzle del Coliseo...")
                            local colosseum = workspace:FindFirstChild("Colosseum", true) or workspace.Map:FindFirstChild("Colosseum", true)
                            if colosseum then
                                local plates = {"Y", "Infinity", "C", "S", "M", "F", "N", "B"}
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    for _, plateName in ipairs(plates) do
                                        local plate = colosseum:FindFirstChild(plateName, true)
                                        if plate and plate:IsA("BasePart") then
                                            Polar.Teleport:To(plate.CFrame)
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
                            pcall(function() CommF:InvokeServer("StartQuest", "BartiloQuest", 3) end)
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
            local lvl = Polar.Player:GetLevel()
            if lvl < 850 then
                warn("Polar Hub: Necesitas Nivel 850 para Raza V2.")
                getgenv().PolarAutoAlchemistEnabled = false
            else
                AlchemistQuestRunning = true
                task.spawn(function()
                    while getgenv().PolarAutoAlchemistEnabled do
                        pcall(function() CommF:InvokeServer("Alchemist", "1") end)
                        task.wait(1)
                        
                        local hasRed = Polar.Detection:FindObject("Red Flower")
                        local hasBlue = Polar.Detection:FindObject("Blue Flower")
                        local hasYellow = Polar.Detection:FindObject("Yellow Flower")
                        
                        if hasRed and hasBlue and hasYellow then
                            warn("Polar Hub: Flores colectadas. Entregando misión al Alquimista...")
                            local alchemistCF = Polar.Detection:FindNPC("Alchemist") or CFrame.new(612, 38, -5074)
                            Polar.Teleport:To(alchemistCF)
                            task.wait(1)
                            pcall(function() CommF:InvokeServer("Alchemist", "2") end)
                            task.wait(2)
                            warn("Polar Hub: ¡Raza V2 Desbloqueada!")
                            getgenv().PolarAutoAlchemistEnabled = false
                            break
                        end
                        
                        if not hasYellow then
                            warn("Polar Hub: Farmeando NPCs para obtener Flor Amarilla...")
                            local mob, hrp = Polar.Detection:FindEnemy("Swan Pirate")
                            if hrp then
                                Polar.Teleport:To(hrp.CFrame * CFrame.new(0, 10, 0))
                                EquipWeaponLocal()
                                getgenv().PolarFastAttackEnabled = true
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                            else
                                Polar.Teleport:ToIsland("Kingdom of Rose")
                            end
                            task.wait(0.2)
                        
                        elseif not hasRed then
                            warn("Polar Hub: Buscando Flor Roja (Durante el día)...")
                            local time = game.Lighting.ClockTime
                            if time >= 6 and time <= 18 then
                                local flower = workspace:FindFirstChild("Red Flower") or workspace.Map:FindFirstChild("Red Flower", true)
                                if flower then
                                    Polar.Teleport:To(flower.CFrame)
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
                                        if not getgenv().PolarAutoAlchemistEnabled or Polar.Detection:FindObject("Red Flower") then break end
                                        Polar.Teleport:To(sp)
                                        task.wait(1.5)
                                    end
                                end
                            else
                                warn("Polar Hub: Es de noche, esperando al amanecer para Flor Roja.")
                                task.wait(5)
                            end
                        
                        elseif not hasBlue then
                            warn("Polar Hub: Buscando Flor Azul (Durante la noche)...")
                            local time = game.Lighting.ClockTime
                            if time < 6 or time > 18 then
                                local flower = workspace:FindFirstChild("Blue Flower") or workspace.Map:FindFirstChild("Blue Flower", true)
                                if flower then
                                    Polar.Teleport:To(flower.CFrame)
                                    task.wait(1)
                                else
                                    local spawns = {
                                        CFrame.new(2316, 449, 787),
                                        CFrame.new(-2544, 256, -429),
                                        CFrame.new(-5154, 8, -714),
                                        CFrame.new(943, 121, 1269)
                                    }
                                    for _, sp in ipairs(spawns) do
                                        if not getgenv().PolarAutoAlchemistEnabled or Polar.Detection:FindObject("Blue Flower") then break end
                                        Polar.Teleport:To(sp)
                                        task.wait(1.5)
                                    end
                                end
                            else
                                warn("Polar Hub: Es de día, esperando a la noche para Flor Azul.")
                                task.wait(5)
                            end
                        end
                        task.wait(1)
                    end
                    AlchemistQuestRunning = false
                end)
            end
        end
    end
end)

-- ==================== INTERFAZ Y CONTROLES SEA 2 ====================
if TabFarm then
    TabFarm:AddSection("Cazador de Jefes (Sea 2)")

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
    TabQuest:AddSection("Eventos Especiales (Sea 2)")

    TabQuest:AddToggle({
        Name = "Auto Factory Raid",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoFactoryEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Bartilo Quest (Coliseo)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoBartiloEnabled = Value
        end
    })

    TabQuest:AddToggle({
        Name = "Auto Raza V2 (Alchemist)",
        Default = false,
        Callback = function(Value)
            getgenv().PolarAutoAlchemistEnabled = Value
        end
    })
end

if TabStatus then
    TabStatus:AddSection("Radar de Jefes Globales")

    local LabelDarkbeard = TabStatus:AddParagraph({ Title = "Darkbeard Status", Text = "Buscando..." })
    local LabelFactory = TabStatus:AddParagraph({ Title = "Factory Status", Text = "Calculando..." })

    task.spawn(function()
        while true do
            task.wait(5)
            local hasDarkbeard = false
            local hasFactory = false
            
            local darkbeardModel, darkbeardHRP = Polar.Detection:FindEnemy("Darkbeard")
            local coreModel, coreHRP = Polar.Detection:FindEnemy("Core")
            
            hasDarkbeard = darkbeardHRP ~= nil
            hasFactory = coreHRP ~= nil
            
            pcall(function()
                if LabelDarkbeard and LabelDarkbeard.SetDesc then
                    LabelDarkbeard:SetDesc(hasDarkbeard and "¡VIVO! (En la Arena Oscura)" or "Muerto / No Spawneado")
                end
                if LabelFactory and LabelFactory.SetDesc then
                    LabelFactory:SetDesc(hasFactory and "¡ABIERTA! (Ve a la Fábrica)" or "Cerrada / Destruida")
                end
            end)
        end
    end)
end

print("✅ Sea 2 optimizado con Polar Engine Detección Unificada.")
