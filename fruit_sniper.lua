--[[
    ===============================================================
    🍎 POLAR FRUIT SNIPER — Script Independiente
    ===============================================================
    Ejecuta este script SOLO (sin Polar Hub) para buscar frutas.
    
    CÓMO FUNCIONA:
    1. Abre una GUI con la lista de frutas deseadas (editable)
    2. Al activar, escanea el mapa buscando frutas tiradas en el suelo
    3. Si encuentra una de tu Wishlist → la recoge INSTANTÁNEAMENTE
    4. Si no hay frutas → salta a otro servidor automáticamente
    5. Se re-ejecuta solo después de cada teleport (loop infinito)
    
    INSTRUCCIONES:
    Ejecuta en tu executor:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/fruit_sniper.lua"))()
    ===============================================================
]]

-- Esperar carga del juego
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ==================== SERVICIOS ====================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ==================== ANTI-AFK ====================
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ==================== CARGAR UI LIBRARY ====================
local success, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/main/redzlibV5.lua"))()
end)

if not success or not redzlib then
    warn("[Fruit Sniper] Error: No se pudo cargar RedzLib V5.")
    return
end

-- ==================== CREAR VENTANA ====================
local Window = redzlib:MakeWindow({
    Name = "🍎 POLAR FRUIT SNIPER",
    SubTitle = "by polar | Buscador de Frutas OP",
    SaveFolder = "PolarFruitSniperConfig.json"
})

local TabSniper = Window:MakeTab({ Title = "Fruit Sniper", Icon = "crosshair" })
local TabConfig = Window:MakeTab({ Title = "Configuración", Icon = "settings" })

-- ==================== ESTADO GLOBAL ====================
getgenv().PolarFruitSniperEnabled = getgenv().PolarFruitSniperEnabled or false
getgenv().PolarFruitSniperAutoExec = getgenv().PolarFruitSniperAutoExec or true
getgenv().PolarFruitSniperServersScanned = getgenv().PolarFruitSniperServersScanned or 0
getgenv().PolarFruitSniperStatus = "Idle"
getgenv().PolarFruitSniperGrabMode = getgenv().PolarFruitSniperGrabMode or "Ultra"
getgenv().PolarFruitSniperDiscordWebhook = getgenv().PolarFruitSniperDiscordWebhook or ""

-- Wishlist por defecto (las frutas más valiosas del juego)
getgenv().PolarFruitWishlist = getgenv().PolarFruitWishlist or {
    "Leopard", "Kitsune", "T-Rex", "Mammoth", "Dragon", "Dough",
    "Spirit", "Control", "Venom", "Shadow", "Rumble", "Buddha",
    "Phoenix", "Blizzard", "Gravity", "Sound", "Pain", "Portal",
    "Rocket", "Spin", "Spike", "Spring", "Smoke", "Flame",
    "Falcon", "Ice", "Sand", "Dark", "Diamond", "Light",
    "Rubber", "Barrier", "Magma", "Quake", "Human Buddha",
    "Love", "Spider", "Door"
}

-- ==================== UTILIDADES ====================
local function GetMainPlaceIdForCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 2753915549 end
    if placeId == 4442272000 or placeId == 79091703265657 or placeId == 4442272183 then return 4442272183 end
    if placeId == 7449423635 then return 7449423635 end
    
    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Kingdom of Rose") or map:FindFirstChild("Green Zone") or map:FindFirstChild("Graveyard") then
            return 4442272183
        elseif map:FindFirstChild("Port Town") or map:FindFirstChild("Turtle") or map:FindFirstChild("Sea Castle") or map:FindFirstChild("Floating Turtle") then
            return 7449423635
        end
    end
    
    local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
    local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
    if lvl >= 1500 then return 7449423635
    elseif lvl >= 700 then return 4442272183
    end
    return 2753915549
end

local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        end
    end)
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function SendDiscordWebhook(title, description, fields)
    pcall(function()
        local webhook = getgenv().PolarFruitSniperDiscordWebhook
        if not webhook or webhook == "" then return end
        
        local embedFields = {}
        if fields then
            for _, f in ipairs(fields) do
                table.insert(embedFields, {name = f.name, value = f.value, inline = f.inline or false})
            end
        end
        
        local payload = HttpService:JSONEncode({
            embeds = {{
                title = title,
                description = description,
                color = 16744576, -- naranja
                fields = embedFields,
                footer = {text = "Polar Fruit Sniper | " .. os.date("%H:%M:%S")},
            }}
        })
        
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if req then
            req({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end
    end)
end

-- ==================== MOTOR DE ESCANEO DE FRUTAS ====================

-- Escanea workspace buscando frutas del Wishlist tiradas en el suelo
local function ScanForWishlistFruits()
    local found = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        local isFruit = false
        local fruitName = ""
        
        -- Método 1: Tool con ToolTip "Blox Fruit" (frutas tiradas en el suelo)
        if obj:IsA("Tool") and obj.ToolTip and string.find(string.lower(obj.ToolTip), "fruit") then
            isFruit = true
            fruitName = obj.Name
        end
        
        -- Método 2: Tool cuyo nombre contiene "Fruit" y no está en un Character/Backpack
        if not isFruit and obj:IsA("Tool") and string.find(obj.Name, "Fruit") then
            local parent = obj.Parent
            if parent and parent == workspace then
                isFruit = true
                fruitName = obj.Name
            elseif parent and not parent:FindFirstChildOfClass("Humanoid") and parent ~= LocalPlayer:FindFirstChild("Backpack") then
                -- Podría estar en una carpeta del mapa
                isFruit = true
                fruitName = obj.Name
            end
        end
        
        -- Método 3: Modelos con nombre de fruta y Handle (Blox Fruits a veces los pone así)
        if not isFruit and obj:IsA("Model") and obj:FindFirstChild("Handle") then
            if string.find(obj.Name, "Fruit") then
                isFruit = true
                fruitName = obj.Name
            end
        end
        
        if isFruit and fruitName ~= "" then
            -- Verificar contra la wishlist
            for _, wishFruit in ipairs(getgenv().PolarFruitWishlist) do
                if string.find(string.lower(fruitName), string.lower(wishFruit)) then
                    table.insert(found, {
                        Instance = obj,
                        Name = fruitName,
                        FruitMatch = wishFruit,
                        Position = nil -- se calcula al recoger
                    })
                    break
                end
            end
        end
    end
    
    return found
end

-- Obtiene la posición de un objeto fruta
local function GetFruitPosition(fruitObj)
    if not fruitObj or not fruitObj.Parent then return nil end
    
    -- Si es Tool, buscar Handle
    local handle = fruitObj:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle.Position
    end
    
    -- Si es BasePart directamente
    if fruitObj:IsA("BasePart") then
        return fruitObj.Position
    end
    
    -- Si es Model, buscar PrimaryPart o primera BasePart
    if fruitObj:IsA("Model") then
        if fruitObj.PrimaryPart then
            return fruitObj.PrimaryPart.Position
        end
        for _, child in ipairs(fruitObj:GetDescendants()) do
            if child:IsA("BasePart") then
                return child.Position
            end
        end
    end
    
    return nil
end

-- Función ultra-rápida para recoger una fruta
local function GrabFruitInstantly(fruitObj)
    local grabbed = false
    
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not fruitObj or not fruitObj.Parent then return end
        
        local fruitPos = GetFruitPosition(fruitObj)
        if not fruitPos then return end
        
        -- FASE 1: Teleport instantáneo a la fruta (múltiples intentos ultra-rápidos)
        for i = 1, 5 do
            if not fruitObj or not fruitObj.Parent then break end
            hrp.CFrame = CFrame.new(fruitPos + Vector3.new(0, 2, 0))
            task.wait(0.05)
        end
        
        -- FASE 2: Intentar recoger con TODOS los métodos posibles simultáneamente
        
        -- Método A: fireproximityprompt (el más fiable en Blox Fruits)
        pcall(function()
            -- Buscar ProximityPrompts en la fruta y alrededores
            local searchTargets = {fruitObj}
            if fruitObj.Parent then table.insert(searchTargets, fruitObj.Parent) end
            
            for _, target in ipairs(searchTargets) do
                for _, desc in ipairs(target:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        -- Forzar que sea activable
                        desc.MaxActivationDistance = 9999
                        fireproximityprompt(desc)
                    end
                end
            end
        end)
        
        -- Método B: VirtualInputManager (simular tecla E)
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            for i = 1, 3 do
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.02)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.02)
            end
        end)
        
        -- Método C: Reparentar Tool directamente al Backpack
        pcall(function()
            if fruitObj:IsA("Tool") then
                fruitObj.Parent = LocalPlayer.Backpack
            end
        end)
        
        -- Método D: fireclickdetector si tiene ClickDetector
        pcall(function()
            for _, desc in ipairs(fruitObj:GetDescendants()) do
                if desc:IsA("ClickDetector") then
                    fireclickdetector(desc)
                end
            end
        end)
        
        -- Método E: Simular click en la posición de la fruta
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            local cam = workspace.CurrentCamera
            local screenPos, onScreen = cam:WorldToScreenPoint(fruitPos)
            if onScreen then
                VIM:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
            end
        end)
        
        task.wait(0.3)
        
        -- Verificar si se recogió
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                    grabbed = true
                    return
                end
            end
        end
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                    grabbed = true
                    return
                end
            end
        end
    end)
    
    return grabbed
end

-- ==================== SERVER HOP ENGINE ====================

local serverHopCache = {}
local serverHopIndex = 1

-- Manejar teleports fallidos
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage, placeId)
    if player == LocalPlayer then
        warn("[Fruit Sniper] Teleport falló: " .. tostring(errorMessage) .. " — Reintentando...")
        if #serverHopCache > 0 and serverHopIndex < #serverHopCache then
            serverHopIndex = serverHopIndex + 1
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId or GetMainPlaceIdForCurrentSea(), serverHopCache[serverHopIndex], LocalPlayer)
            end)
        end
    end
end)

local function FetchServerList(placeId)
    local servers = {}
    local cursor = ""
    local attempts = 0
    
    while attempts < 3 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if ok and result and result.data then
            for _, v in ipairs(result.data) do
                if type(v) == "table" and v.playing and v.maxPlayers and v.id ~= game.JobId then
                    if v.playing >= 1 and v.playing < v.maxPlayers - 1 then
                        table.insert(servers, v.id)
                    end
                end
            end
            if not result.nextPageCursor or #servers >= 50 then break end
            cursor = result.nextPageCursor
        else
            break
        end
        attempts = attempts + 1
        task.wait(0.2)
    end
    
    return servers
end

local function HopToNextServer()
    getgenv().PolarFruitSniperServersScanned = getgenv().PolarFruitSniperServersScanned + 1
    getgenv().PolarFruitSniperStatus = "Saltando... (#" .. tostring(getgenv().PolarFruitSniperServersScanned) .. ")"
    
    local placeId = GetMainPlaceIdForCurrentSea()
    local servers = FetchServerList(placeId)
    
    if #servers == 0 then
        warn("[Fruit Sniper] No se encontraron servidores. Reintentando en 5s...")
        getgenv().PolarFruitSniperStatus = "Sin servidores, esperando..."
        task.wait(5)
        return false
    end
    
    -- Elegir servidor aleatorio
    local shuffled = {}
    local copy = {unpack(servers)}
    while #copy > 0 do
        table.insert(shuffled, table.remove(copy, math.random(1, #copy)))
    end
    serverHopCache = shuffled
    serverHopIndex = 1
    
    -- Configurar auto re-ejecución
    if getgenv().PolarFruitSniperAutoExec then
        pcall(function()
            local queueOnTeleport = queue_on_teleport 
                or (syn and syn.queue_on_teleport) 
                or (fluxus and fluxus.queue_on_teleport)
            
            if queueOnTeleport then
                queueOnTeleport([[
                    getgenv().PolarFruitSniperEnabled = true
                    getgenv().PolarFruitSniperAutoExec = true
                    getgenv().PolarFruitSniperServersScanned = ]] .. tostring(getgenv().PolarFruitSniperServersScanned) .. [[
                    
                    getgenv().PolarFruitWishlist = {]] .. (function()
                        local parts = {}
                        for _, f in ipairs(getgenv().PolarFruitWishlist) do
                            table.insert(parts, '"' .. f .. '"')
                        end
                        return table.concat(parts, ",")
                    end)() .. [[}
                    
                    getgenv().PolarFruitSniperDiscordWebhook = "]] .. tostring(getgenv().PolarFruitSniperDiscordWebhook or "") .. [["
                    
                    task.wait(5)
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/fruit_sniper.lua"))()
                ]])
                warn("[Fruit Sniper] Auto re-ejecución configurada.")
            else
                warn("[Fruit Sniper] ⚠ queue_on_teleport no disponible. El sniper NO se re-ejecutará automáticamente.")
            end
        end)
    end
    
    warn("[Fruit Sniper] Saltando al servidor #" .. tostring(getgenv().PolarFruitSniperServersScanned) .. "...")
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, shuffled[1], LocalPlayer)
    end)
    
    return true
end

-- ==================== MOTOR PRINCIPAL (BACKGROUND LOOP) ====================

task.spawn(function()
    task.wait(3)
    
    while true do
        if not getgenv().PolarFruitSniperEnabled then
            getgenv().PolarFruitSniperStatus = "Idle"
            task.wait(1)
            continue
        end
        
        -- FASE 1: Escanear mapa actual
        getgenv().PolarFruitSniperStatus = "Escaneando mapa..."
        
        -- Esperar un poco para que workspace cargue completamente
        task.wait(1)
        
        -- Primer escaneo
        local fruitsFound = ScanForWishlistFruits()
        
        if #fruitsFound == 0 then
            -- Segundo escaneo después de 2 segundos (a veces las frutas tardan en cargar)
            task.wait(2)
            fruitsFound = ScanForWishlistFruits()
        end
        
        if #fruitsFound > 0 then
            -- ===== ¡¡FRUTA ENCONTRADA!! =====
            local fruit = fruitsFound[1]
            getgenv().PolarFruitSniperStatus = "¡¡ENCONTRADA!! → " .. fruit.Name
            
            warn("[Fruit Sniper] 🍎🍎🍎 ¡¡" .. fruit.Name .. " ENCONTRADA en este servidor!!")
            
            -- Notificación visual gigante
            Notify("🍎🍎 ¡¡FRUTA ENCONTRADA!!", fruit.Name .. " → Recogiéndola...", 30)
            
            -- Intentar recogerla (múltiples intentos)
            local grabbed = false
            for attempt = 1, 5 do
                if not fruit.Instance or not fruit.Instance.Parent then break end
                grabbed = GrabFruitInstantly(fruit.Instance)
                if grabbed then break end
                task.wait(0.2)
            end
            
            -- Copiar JobId al portapapeles por si acaso
            CopyToClipboard(game.JobId)
            
            -- Notificación Discord
            SendDiscordWebhook("🍎🍎 ¡¡FRUTA ENCONTRADA!!", "El Fruit Sniper ha encontrado una fruta de tu Wishlist.", {
                {name = "🍎 Fruta", value = "**" .. fruit.Name .. "**", inline = true},
                {name = "🎯 Match", value = fruit.FruitMatch, inline = true},
                {name = "🌐 Servidor", value = "`" .. tostring(game.JobId) .. "`", inline = false},
                {name = "📊 Servidores Escaneados", value = tostring(getgenv().PolarFruitSniperServersScanned), inline = true},
                {name = "✅ Recogida", value = grabbed and "SÍ" or "NO (ve al servidor manualmente)", inline = true},
                {name = "🌊 Sea/PlaceId", value = tostring(game.PlaceId), inline = true}
            })
            
            if grabbed then
                Notify("✅ ¡FRUTA RECOGIDA!", fruit.Name .. " está en tu inventario.", 15)
                getgenv().PolarFruitSniperStatus = "✅ RECOGIDA: " .. fruit.Name
            else
                Notify("⚠ Fruta localizada", fruit.Name .. " encontrada. JobId copiado al portapapeles.", 15)
                getgenv().PolarFruitSniperStatus = "⚠ Localizada (no recogida): " .. fruit.Name
            end
            
            -- Detener el sniper
            getgenv().PolarFruitSniperEnabled = false
        else
            -- No hay frutas → saltar al siguiente servidor
            getgenv().PolarFruitSniperStatus = "Sin frutas. Servidores: " .. tostring(getgenv().PolarFruitSniperServersScanned)
            
            local hopped = HopToNextServer()
            if hopped then
                task.wait(15) -- Esperar teleport
            else
                task.wait(5)
            end
        end
    end
end)

-- ==================== INTERFAZ GRÁFICA ====================

-- === TAB PRINCIPAL: SNIPER ===
TabSniper:AddSection("🍎 Control del Fruit Sniper")

TabSniper:AddToggle({
    Name = "🔥 ACTIVAR FRUIT SNIPER",
    Desc = "Escanea servidor por servidor buscando frutas de tu Wishlist. Cuando encuentra una, la recoge al instante y te avisa.",
    Callback = function(Value)
        getgenv().PolarFruitSniperEnabled = Value
        if Value then
            Notify("🍎 Fruit Sniper", "Activado. Buscando frutas...", 5)
        else
            getgenv().PolarFruitSniperStatus = "Idle"
            Notify("⏸ Fruit Sniper", "Desactivado.", 3)
        end
    end
})

TabSniper:AddToggle({
    Name = "🔄 Auto Re-Ejecución",
    Desc = "Re-ejecuta este script automáticamente después de cada server hop. Sin esto, el sniper se detiene al cambiar de servidor.",
    Default = true,
    Callback = function(Value)
        getgenv().PolarFruitSniperAutoExec = Value
    end
})

TabSniper:AddSection("📋 Wishlist de Frutas")

TabSniper:AddTextBox({
    Name = "Editar Wishlist",
    PlaceholderText = "Leopard, Kitsune, Dragon, Dough, Spirit...",
    Default = table.concat(getgenv().PolarFruitWishlist, ", "),
    Callback = function(Value)
        local newList = {}
        for fruit in string.gmatch(Value, "[^,]+") do
            fruit = fruit:match("^%s*(.-)%s*$")
            if fruit and #fruit > 0 then
                table.insert(newList, fruit)
            end
        end
        if #newList > 0 then
            getgenv().PolarFruitWishlist = newList
            warn("[Fruit Sniper] Wishlist actualizada: " .. table.concat(newList, ", "))
            Notify("📋 Wishlist", #newList .. " frutas configuradas.", 3)
        end
    end
})

TabSniper:AddButton({
    Name = "🔎 Escanear AHORA (sin hop)",
    Callback = function()
        local fruits = ScanForWishlistFruits()
        if #fruits > 0 then
            local names = {}
            for _, f in ipairs(fruits) do table.insert(names, f.Name) end
            Notify("🍎 ¡Frutas encontradas!", table.concat(names, ", "), 10)
        else
            Notify("❌ Sin frutas", "No se encontraron frutas de la Wishlist en este servidor.", 5)
        end
    end
})

TabSniper:AddSection("📊 Estado")

TabSniper:AddButton({
    Name = "📊 Ver Estado Actual",
    Callback = function()
        local status = getgenv().PolarFruitSniperStatus or "Desconocido"
        local scanned = getgenv().PolarFruitSniperServersScanned or 0
        local wishCount = #(getgenv().PolarFruitWishlist or {})
        Notify("📊 Estado", "Estado: " .. status .. " | Servidores: " .. tostring(scanned) .. " | Wishlist: " .. tostring(wishCount) .. " frutas", 8)
    end
})

TabSniper:AddButton({
    Name = "🔄 Resetear Contador",
    Callback = function()
        getgenv().PolarFruitSniperServersScanned = 0
        Notify("🔄 Reset", "Contador de servidores reseteado a 0.", 3)
    end
})

-- === TAB CONFIGURACIÓN ===
TabConfig:AddSection("🌐 Discord Webhook")

TabConfig:AddTextBox({
    Name = "URL del Webhook",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    Callback = function(Value)
        getgenv().PolarFruitSniperDiscordWebhook = Value
        Notify("🌐 Webhook", "Configurado correctamente.", 3)
    end
})

TabConfig:AddButton({
    Name = "📤 Probar Webhook",
    Callback = function()
        SendDiscordWebhook("🧪 Test de Webhook", "Si ves este mensaje, el webhook funciona correctamente.", {
            {name = "Script", value = "Polar Fruit Sniper", inline = true},
            {name = "Servidor", value = "`" .. tostring(game.JobId) .. "`", inline = true}
        })
        Notify("📤 Webhook", "Mensaje de prueba enviado.", 3)
    end
})

TabConfig:AddSection("🌊 Servidor Actual")

TabConfig:AddButton({
    Name = "📋 Copiar Job ID",
    Callback = function()
        CopyToClipboard(tostring(game.JobId))
        Notify("📋 Copiado", "Job ID copiado al portapapeles.", 3)
    end
})

TabConfig:AddButton({
    Name = "🌊 Info del Sea",
    Callback = function()
        local sea = "Desconocido"
        local placeId = game.PlaceId
        if placeId == 2753915549 then sea = "Sea 1 (Old World)"
        elseif placeId == 4442272183 or placeId == 4442272000 then sea = "Sea 2 (New World)"
        elseif placeId == 7449423635 then sea = "Sea 3 (Third Sea)"
        end
        Notify("🌊 Sea Actual", sea .. " | PlaceId: " .. tostring(placeId), 8)
    end
})

-- ==================== NOTIFICACIÓN DE INICIO ====================
local wishCount = #getgenv().PolarFruitWishlist
local scanned = getgenv().PolarFruitSniperServersScanned

if scanned > 0 then
    Notify("🍎 Fruit Sniper", "Re-ejecutado. Servidores: " .. tostring(scanned) .. " | Wishlist: " .. tostring(wishCount) .. " frutas", 5)
else
    Notify("🍎 Fruit Sniper", "Cargado. " .. tostring(wishCount) .. " frutas en la Wishlist. Activa el toggle para empezar.", 5)
end

-- Si el sniper estaba activo antes del hop, activarlo automáticamente
if getgenv().PolarFruitSniperEnabled then
    warn("[Fruit Sniper] Re-activado automáticamente después del server hop.")
    Notify("🔥 AUTO-ACTIVADO", "El Fruit Sniper sigue buscando (servidor #" .. tostring(scanned) .. ")...", 5)
end

warn("[Fruit Sniper] ✅ Script cargado correctamente. " .. tostring(wishCount) .. " frutas en la Wishlist.")
