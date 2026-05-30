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
    {lvl = 700, q = "RoseQuest", ql = 1, name = "Raider", giver = "Quest Giver", island = "Kingdom of Rose"},
    {lvl = 725, q = "RoseQuest", ql = 2, name = "Mercenary", giver = "Quest Giver", island = "Kingdom of Rose"},
    {lvl = 750, q = "RoseQuest", ql = 3, name = "Diamond", giver = "Quest Giver", island = "Kingdom of Rose", isBoss = true},
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
        -- Implementación pendiente
        print("Activado Auto Bartilo")
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
