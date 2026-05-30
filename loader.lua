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

-- Cargar script especifico del oceano
if PlaceId == 2753915549 then
    print("Polar Hub: Sea 1 detectado.")
    loadstring(game:HttpGet(baseURL .. "sea1.lua"))()
elseif PlaceId == 4442272000 or PlaceId == 79091703265657 then
    print("Polar Hub: Sea 2 detectado.")
    loadstring(game:HttpGet(baseURL .. "sea2.lua"))()
elseif PlaceId == 7449423635 then
    print("Polar Hub: Sea 3 detectado.")
    loadstring(game:HttpGet(baseURL .. "sea3.lua"))()
else
    warn("Polar Hub: PlaceId no reconocido ("..tostring(PlaceId).."). Cargando Sea 1 por defecto.")
    loadstring(game:HttpGet(baseURL .. "sea1.lua"))()
end
