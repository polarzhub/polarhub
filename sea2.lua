-- ==================== POLAR HUB | SEA 2 ====================
print("Cargando datos del Sea 2...")

local Window = getgenv().PolarWindow
local TabQuest = getgenv().PolarTabQuest
local TabFarm = getgenv().PolarTabFarm
local TabStatus = getgenv().PolarTabStatus

-- Bases de Datos Sea 2
getgenv().PolarLevelQuests = {
    -- Ejemplo: {lvl = 700, q = "Area1Quest", ql = 1, name = "Raider", giver = "Quest Giver", island = "Kingdom of Rose"},
}

getgenv().PolarBosses = {
    -- Ejemplo: {name = "Diamond", q = "Area1Quest", ql = 3, giver = "Quest Giver", island = "Kingdom of Rose", lvl = 750},
}

-- Pestaña Bosses Sea 2
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

TabQuest:Section({ Title = "Eventos Sea 2" })
TabQuest:Button({
    Title = "Auto Factory Raid (Proximamente)",
    Callback = function()
        print("En desarrollo")
    end
})
