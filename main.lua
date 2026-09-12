-- Polar HUB | Entry Point Loader
-- Subir a GitHub como archivo raw y usar este comando en tu ejecutor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/main.lua"))()

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Limpieza preventiva de interfaces previas para evitar ventanas duplicadas o congeladas
pcall(function()
    local targets = {
        (gethui and gethui()),
        (get_hidden_gui and get_hidden_gui()),
        LocalPlayer:FindFirstChild("PlayerGui"),
        (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"))
    }
    for _, container in ipairs(targets) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "redz Library V5" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end)

-- IMPORTANTE: Cambia esta URL base por la de tu repositorio de GitHub real
local baseURL = "https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/"

-- Detectar juego
local PlaceId = game.PlaceId

-- Asegurar variables globales
getgenv().PolarLevelQuests = {}
getgenv().PolarBosses = {}
getgenv().PolarSelectedBossToFarm = ""
getgenv().PolarNPCCache = {}

-- Función de detección de mar robusta
local function DetectSea()
    if PlaceId == 2753915549 or PlaceId == 85211729168715 then return 1 end
    if PlaceId == 4442272000 or PlaceId == 79091703265657 or PlaceId == 4442272183 then return 2 end
    if PlaceId == 7449423635 or PlaceId == 107567784013444 then return 3 end
    
    -- Fallback por carpetas en Workspace (para servidores privados/custom/subplaces)
    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Jungle") or map:FindFirstChild("MarineStart") or map:FindFirstChild("Fishmen") or map:FindFirstChild("Desert") then
            return 1
        elseif map:FindFirstChild("Kingdom of Rose") or map:FindFirstChild("Green Zone") or map:FindFirstChild("Graveyard") or workspace:FindFirstChild("Factory") then
            return 2
        elseif map:FindFirstChild("Port Town") or map:FindFirstChild("Turtle") or map:FindFirstChild("Sea Castle") or map:FindFirstChild("Floating Turtle") then
            return 3
        end
    end
    
    if workspace:FindFirstChild("NPCs") then
        if workspace.NPCs:FindFirstChild("Area 1 Quest Giver") or workspace.NPCs:FindFirstChild("Zombie Quest Giver") or workspace.NPCs:FindFirstChild("Alchemist") or workspace.NPCs:FindFirstChild("Ship Quest Giver") then
            return 2
        end
    end
    
    -- Fallback por nivel del jugador si no se detecta nada más
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local data = LocalPlayer:FindFirstChild("Data")
    local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
    if lvl >= 1500 then
        return 3
    elseif lvl >= 700 then
        return 2
    end
    
    return 1 -- Por defecto Sea 1
end

-- Anti-Cache dinámico para asegurar siempre la versión más reciente
local cacheBuster = "?t=" .. tostring(os.time())

-- Cargar Core Base primero
print("[Polar Hub] 🚀 Cargando motor principal...")
local success, result = pcall(function()
    loadstring(game:HttpGet(baseURL .. "core.lua" .. cacheBuster))()
end)

if not success then
    warn("[Polar Hub] ⚠️ Advertencia en core.lua:")
    warn(result)
end

-- Cargar script especifico del oceano detectado SIEMPRE
local detectedSea = DetectSea()
print("[Polar Hub] 🌊 Mar detectado con éxito: Sea " .. tostring(detectedSea))

local seaFile = "sea" .. tostring(detectedSea) .. ".lua"
local seaSuccess, seaResult = pcall(function()
    loadstring(game:HttpGet(baseURL .. seaFile .. cacheBuster))()
end)

if not seaSuccess then
    warn("[Polar Hub] ⚠️ Advertencia cargando " .. seaFile .. ":")
    warn(seaResult)
    if detectedSea == 1 then
        pcall(function() loadstring(game:HttpGet(baseURL .. "sea1.lua" .. cacheBuster))() end)
    end
else
    print("[Polar Hub] ❄️ " .. seaFile .. " integrado e inicializado con éxito.")
end

-- Notificación visual de carga completada al 100%
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❄️ Polar Hub",
        Text = "¡Cargado al 100%! Todas las funciones listas.",
        Duration = 4
    })
end)
