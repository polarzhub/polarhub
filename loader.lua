-- Polar HUB | Loader
-- Subir todos estos archivos a tu repo de GitHub como 'raw' y ejecutar este loader

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
    if PlaceId == 2753915549 then return 1 end
    if PlaceId == 4442272000 or PlaceId == 79091703265657 then return 2 end
    if PlaceId == 7449423635 then return 3 end
    
    -- Fallback por carpetas en Workspace (para servidores privados/custom/subplaces)
    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Kingdom of Rose") or map:FindFirstChild("Green Zone") or map:FindFirstChild("Graveyard") or workspace:FindFirstChild("Factory") then
            return 2
        elseif map:FindFirstChild("Port Town") or map:FindFirstChild("Turtle") or map:FindFirstChild("Sea Castle") or map:FindFirstChild("Floating Turtle") then
            return 3
        end
    end
    
    if workspace:FindFirstChild("NPCs") then
        if workspace.NPCs:FindFirstChild("Area 1 Quest Giver") or workspace.NPCs:FindFirstChild("Zombie Quest Giver") or workspace.NPCs:FindFirstChild("Alchemist") then
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

-- Cargar Core Base primero
print("Polar Hub: Cargando motor principal...")
local success, result = pcall(function()
    loadstring(game:HttpGet(baseURL .. "core.lua"))()
end)

if not success then
    warn("Polar Hub Error: No se pudo cargar core.lua. Asegurate de haberlo subido a GitHub y de tener la URL correcta.")
    warn(result)
    return
end

-- Cargar script especifico del oceano detectado
local detectedSea = DetectSea()
if detectedSea == 1 then
    print("Polar Hub: Sea 1 detectado.")
    loadstring(game:HttpGet(baseURL .. "sea1.lua"))()
elseif detectedSea == 2 then
    print("Polar Hub: Sea 2 detectado.")
    loadstring(game:HttpGet(baseURL .. "sea2.lua"))()
elseif detectedSea == 3 then
    print("Polar Hub: Sea 3 detectado (Cargando Sea 2 por defecto).")
    loadstring(game:HttpGet(baseURL .. "sea2.lua"))()
else
    warn("Polar Hub: Sea no reconocido. Cargando Sea 1 por defecto.")
    loadstring(game:HttpGet(baseURL .. "sea1.lua"))()
end
