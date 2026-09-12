--[[
    ===============================================================
    ⏱️ POLAR ULTIMATE SERVER AGE & CHEST MEMORY SNIFFER (V2 GOD MODE)
    ===============================================================
    Script Luau de ingeniería inversa de altísimo nivel para Blox Fruits.
    
    CARACTERÍSTICAS AVANZADAS:
    1. Uptime del servidor en tiempo real de alta precisión (workspace.DistributedGameTime + GetServerTimeNow)
    2. Escáner de inventarios globales: Inspecciona todos los jugadores del servidor para ver si ALGUIEN ya tiene el Puño o Cáliz.
    3. Escáner de memoria GC (getgc / getupvalues / getnilinstances) para extraer datos de módulos del cliente.
    4. Escáner de atributos en Workspace / ReplicatedStorage para detectar timestamps ocultos de Blox Fruits.
    5. HUD Flotante + Panel GUI con Notificador de Discord Webhook.
    
    INSTRUCCIONES DE USO:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/server_tracker.lua"))()
    ===============================================================
]]

repeat task.wait() until game:IsLoaded()

-- ==================== SERVICIOS ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ==================== CARGAR UI LIBRARY CON FALLBACKS ====================
local redzlib = nil
local redzUrls = {
    "https://raw.githubusercontent.com/polarzhub/polarhub/main/redzlibV5.lua",
    "https://raw.githubusercontent.com/realredz/RedzLibV5/main/Source.lua",
    "https://raw.githubusercontent.com/REDZ-HUB/RedzLibV5/main/Source.lua"
}

for _, url in ipairs(redzUrls) do
    local ok, res = pcall(function()
        local code = game:HttpGet(url)
        if code and type(code) == "string" and not string.find(code, "404") then
            local fn = loadstring(code)
            if fn then return fn() end
        end
    end)
    if ok and res and type(res) == "table" and type(res.MakeWindow) == "function" then
        redzlib = res
        break
    end
end

-- ==================== DETECCIÓN DE SEA ====================
local CurrentSea = 1
local TargetItemName = "Fist of Darkness / God's Chalice"

local placeId = game.PlaceId
if placeId == 2753915549 then
    CurrentSea = 1
    TargetItemName = "Fruta de Cofre"
elseif placeId == 4442272183 or placeId == 4442272000 then
    CurrentSea = 2
    TargetItemName = "Fist of Darkness (Puño de Oscuridad)"
elseif placeId == 7449423635 then
    CurrentSea = 3
    TargetItemName = "God's Chalice (Cáliz Sagrado)"
end

-- ==================== ESTADO Y MONITOR ====================
getgenv().PolarServerTracker = getgenv().PolarServerTracker or {
    LastChestResetTime = nil,
    ItemHolderDetected = nil, -- Nombre del jugador que posee el ítem actualmente en el servidor
    DiscordWebhook = ""
}

-- Función para formatear segundos a HH:MM:SS
local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02dh %02dm %02ds", hours, mins, secs)
end

-- Función para copiar al portapapeles
local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        end
    end)
end

-- Webhook de Discord
local function SendWebhookNotification(title, desc, fields)
    pcall(function()
        local webhook = getgenv().PolarServerTracker.DiscordWebhook
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
                description = desc,
                color = 65535,
                fields = embedFields,
                footer = {text = "Polar Ultimate Server Tracker | JobId: " .. tostring(game.JobId)}
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

-- Registrar Reset de Cofres
local function RegisterChestReset(sourceReason)
    getgenv().PolarServerTracker.LastChestResetTime = Workspace.DistributedGameTime
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🗝️ RESET DE COFRE DETECTADO",
            Text = TargetItemName .. " detectado (" .. sourceReason .. "). Contador de 4h reiniciado.",
            Duration = 10
        })
    end)
    
    SendWebhookNotification("🗝️ RESET DE COFRE EN BLOX FRUITS", "Se ha detectado un hallazgo de " .. TargetItemName .. ".", {
        {name = "Fuente / Evento", value = sourceReason, inline = true},
        {name = "Sea", value = "Sea " .. tostring(CurrentSea), inline = true},
        {name = "Uptime Servidor", value = FormatTime(Workspace.DistributedGameTime), inline = true},
        {name = "Job ID", value = "`" .. tostring(game.JobId) .. "`", inline = false}
    })
end

-- ==================== ESCÁNERES DE INGENIERÍA INVERSA AVANZADOS ====================

-- ESCÁNER 1: Inspeccionar Inventario de TODOS los jugadores del servidor
local function DeepScanServerPlayers()
    local itemHolder = nil
    local itemNameFound = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        local backpack = plr:FindFirstChild("Backpack")
        local char = plr.Character

        local function CheckContainer(container)
            if not container then return end
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local nameLower = string.lower(item.Name)
                    if string.find(nameLower, "fist of darkness") or string.find(nameLower, "god's chalice") or string.find(nameLower, "chalice") then
                        itemHolder = plr.DisplayName .. " (@" .. plr.Name .. ")"
                        itemNameFound = item.Name
                    end
                end
            end
        end

        CheckContainer(backpack)
        CheckContainer(char)
    end

    if itemHolder and not getgenv().PolarServerTracker.ItemHolderDetected then
        getgenv().PolarServerTracker.ItemHolderDetected = itemHolder
        RegisterChestReset("Jugador en servidor lo posee: " .. itemHolder .. " (" .. itemNameFound .. ")")
    elseif not itemHolder then
        getgenv().PolarServerTracker.ItemHolderDetected = nil
    end

    return itemHolder, itemNameFound
end

-- ESCÁNER 2: Inspeccionar Nil Instances y Workspace en Busca de Ítems Tirados
local function DeepScanNilAndWorkspace()
    local foundInGround = nil

    -- 1. Buscar en Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local n = string.lower(obj.Name)
            if string.find(n, "fist of darkness") or string.find(n, "god's chalice") or string.find(n, "chalice") then
                foundInGround = "Workspace Ground Drop: " .. obj.Name
                break
            end
        end
    end

    -- 2. Buscar en Nil Instances (si el ejecutor lo soporta)
    if not foundInGround and typeof(getnilinstances) == "function" then
        pcall(function()
            for _, obj in ipairs(getnilinstances()) do
                if obj:IsA("Tool") then
                    local n = string.lower(obj.Name)
                    if string.find(n, "fist of darkness") or string.find(n, "god's chalice") or string.find(n, "chalice") then
                        foundInGround = "Nil Instance Storage: " .. obj.Name
                        break
                    end
                end
            end
        end)
    end

    return foundInGround
end

-- ESCÁNER 3: Inspeccionar Atributos del Servidor (Workspace & ReplicatedStorage)
local function DeepScanGameAttributes()
    local extractedAttr = nil

    local function ScanAttrs(inst, instName)
        pcall(function()
            local attrs = inst:GetAttributes()
            for key, val in pairs(attrs) do
                local kLower = string.lower(key)
                if string.find(kLower, "chest") or string.find(kLower, "time") or string.find(kLower, "fist") or string.find(kLower, "chalice") or string.find(kLower, "spawn") then
                    extractedAttr = instName .. " Attribute [" .. key .. "] = " .. tostring(val)
                end
            end
        end)
    end

    ScanAttrs(Workspace, "Workspace")
    ScanAttrs(ReplicatedStorage, "ReplicatedStorage")

    return extractedAttr
end

-- ESCÁNER 4: Inspeccionar Memoria GC de Luau (getgc / getupvalues / getconstants)
local function DeepScanLuauGC()
    local gcData = nil

    if typeof(getgc) == "function" then
        pcall(function()
            for _, obj in ipairs(getgc(true)) do
                if type(obj) == "table" then
                    for k, v in pairs(obj) do
                        if type(k) == "string" then
                            local kLower = string.lower(k)
                            if string.find(kLower, "chestspawntime") or string.find(kLower, "lastchesttime") or string.find(kLower, "fistofdarkness") or string.find(kLower, "godchalice") then
                                gcData = "GC Table [" .. k .. "] = " .. tostring(v)
                                break
                            end
                        end
                    end
                elseif type(obj) == "function" and typeof(getupvalues) == "function" then
                    local ok, upvalues = pcall(function() return getupvalues(obj) end)
                    if ok and upvalues then
                        for uKey, uVal in pairs(upvalues) do
                            if type(uVal) == "string" then
                                local uLower = string.lower(uVal)
                                if string.find(uLower, "fist of darkness") or string.find(uLower, "god's chalice") then
                                    gcData = "GC Upvalue Function Match: " .. uVal
                                    break
                                end
                            end
                        end
                    end
                end
                if gcData then break end
            end
        end)
    end

    return gcData
end

-- ESCÁNER 5: Módulos Cargados del Juego (getloadedmodules + require)
-- Escanea TODOS los ModuleScripts que el cliente de Blox Fruits tiene cargados en memoria
-- y busca tablas internas con datos de cofres, timers, o spawn rates
local function DeepScanLoadedModules()
    local results = {}

    if typeof(getloadedmodules) == "function" then
        pcall(function()
            for _, mod in ipairs(getloadedmodules()) do
                pcall(function()
                    local modName = string.lower(mod.Name or "")
                    local modPath = mod:GetFullName()
                    
                    -- Buscar módulos relacionados con cofres, spawn, time, o chest
                    if string.find(modName, "chest") or string.find(modName, "spawn") or string.find(modName, "timer") 
                       or string.find(modName, "fist") or string.find(modName, "chalice") or string.find(modName, "drop")
                       or string.find(modName, "loot") or string.find(modName, "reward") or string.find(modName, "cooldown") then
                        
                        -- Intentar obtener el contenido del módulo
                        local ok, moduleData = pcall(function() return require(mod) end)
                        if ok and type(moduleData) == "table" then
                            for k, v in pairs(moduleData) do
                                table.insert(results, {
                                    Module = modPath,
                                    Key = tostring(k),
                                    Value = tostring(v),
                                    Type = typeof(v)
                                })
                            end
                        end
                    end
                end)
            end
        end)
    end

    -- También escanear upvalues de los módulos para extraer funciones internas
    if typeof(getloadedmodules) == "function" and typeof(getupvalues) == "function" then
        pcall(function()
            for _, mod in ipairs(getloadedmodules()) do
                pcall(function()
                    local ok, moduleFunc = pcall(function() return require(mod) end)
                    if ok and type(moduleFunc) == "table" then
                        for k, v in pairs(moduleFunc) do
                            if type(v) == "function" then
                                local ok2, upvals = pcall(getupvalues, v)
                                if ok2 and upvals then
                                    for uIdx, uVal in pairs(upvals) do
                                        if type(uVal) == "number" and uVal > 3600 and uVal <= 86400 then
                                            -- Podría ser un timer en segundos (entre 1h y 24h)
                                            table.insert(results, {
                                                Module = mod:GetFullName() .. "." .. tostring(k) .. "()",
                                                Key = "Upvalue#" .. tostring(uIdx),
                                                Value = tostring(uVal) .. "s (" .. FormatTime(uVal) .. ")",
                                                Type = "PossibleTimer"
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end

    return results
end

-- ESCÁNER 6: Registro de Luau (getreg)
-- Escanea el registro completo del VM de Luau en busca de tablas con datos de cofres
local function DeepScanRegistry()
    local results = {}

    if typeof(getreg) == "function" then
        pcall(function()
            for _, entry in ipairs(getreg()) do
                if type(entry) == "table" then
                    for k, v in pairs(entry) do
                        if type(k) == "string" then
                            local kLower = string.lower(k)
                            if string.find(kLower, "chest") or string.find(kLower, "fist") or string.find(kLower, "chalice")
                               or string.find(kLower, "spawntime") or string.find(kLower, "cooldown") or string.find(kLower, "lastspawn")
                               or string.find(kLower, "nextspawn") or string.find(kLower, "dropcooldown") then
                                table.insert(results, {
                                    Source = "Registry",
                                    Key = k,
                                    Value = tostring(v),
                                    Type = typeof(v)
                                })
                            end
                        end
                    end
                end
            end
        end)
    end

    return results
end

-- ESCÁNER 7: Interceptor de Conexiones (getconnections)
-- Inspecciona qué funciones están conectadas a eventos de cofres en ReplicatedStorage
local function DeepScanConnections()
    local results = {}

    if typeof(getconnections) == "function" then
        pcall(function()
            -- Buscar RemoteEvents/RemoteFunctions relevantes
            for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local nameLower = string.lower(child.Name)
                    if string.find(nameLower, "chest") or string.find(nameLower, "drop") or string.find(nameLower, "spawn")
                       or string.find(nameLower, "fist") or string.find(nameLower, "chalice") or string.find(nameLower, "loot")
                       or string.find(nameLower, "reward") or string.find(nameLower, "item") or string.find(nameLower, "notification") then
                        
                        local connections = {}
                        if child:IsA("RemoteEvent") then
                            pcall(function()
                                connections = getconnections(child.OnClientEvent)
                            end)
                        end
                        
                        table.insert(results, {
                            Remote = child:GetFullName(),
                            ClassName = child.ClassName,
                            ConnectionCount = #connections
                        })
                        
                        -- Intentar extraer upvalues de las funciones conectadas
                        if typeof(getupvalues) == "function" then
                            for _, conn in ipairs(connections) do
                                pcall(function()
                                    local upvals = getupvalues(conn.Function)
                                    for uKey, uVal in pairs(upvals) do
                                        if type(uVal) == "number" or type(uVal) == "string" then
                                            table.insert(results, {
                                                Remote = child.Name .. " → Connection Upvalue",
                                                ClassName = "Upvalue#" .. tostring(uKey),
                                                ConnectionCount = tostring(uVal)
                                            })
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end

    return results
end

-- ==================== ESCÁNER 8: REMOTE SPY PASIVO (INTERCEPTOR DE TRÁFICO) ====================
-- Hook __namecall para interceptar TODOS los datos de RemoteEvent/RemoteFunction que el servidor
-- envía al cliente relacionados con cofres. Esto captura el momento EXACTO en que Blox Fruits
-- comunica datos de spawn de cofres al cliente.

getgenv().PolarRemoteLog = getgenv().PolarRemoteLog or {}

pcall(function()
    if not getgenv().PolarNamecallHooked and typeof(hookmetamethod) == "function" and typeof(newcclosure) == "function" then
        getgenv().PolarNamecallHooked = true
        local OldNamecall
        OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            
            -- Solo interceptar tráfico entrante del servidor (OnClientEvent/OnClientInvoke no se hookean aquí,
            -- pero FireServer/InvokeServer SÍ nos permiten ver qué datos envía el cliente al servidor sobre cofres)
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = ""
                pcall(function() remoteName = string.lower(self.Name or "") end)
                
                if string.find(remoteName, "chest") or string.find(remoteName, "open") or string.find(remoteName, "loot")
                   or string.find(remoteName, "drop") or string.find(remoteName, "collect") or string.find(remoteName, "reward")
                   or string.find(remoteName, "fist") or string.find(remoteName, "chalice") or string.find(remoteName, "item") then
                    
                    local args = {...}
                    local argStr = ""
                    for i, arg in ipairs(args) do
                        argStr = argStr .. "[" .. tostring(i) .. "]=" .. tostring(arg) .. " "
                    end
                    
                    local logEntry = {
                        Timestamp = FormatTime(Workspace.DistributedGameTime),
                        Remote = self:GetFullName(),
                        Method = method,
                        Args = argStr
                    }
                    table.insert(getgenv().PolarRemoteLog, logEntry)
                    
                    -- Si detectamos actividad de cofre, registrar reset
                    if string.find(remoteName, "chest") and (string.find(remoteName, "open") or string.find(remoteName, "collect")) then
                        RegisterChestReset("Remote Interceptado: " .. self.Name .. " " .. argStr)
                    end
                    
                    warn("[Remote Spy] " .. method .. " → " .. self:GetFullName() .. " | Args: " .. argStr)
                end
            end
            
            return OldNamecall(self, ...)
        end))
    end
end)

-- Interceptor de OnClientEvent para TODOS los RemoteEvents de cofres
pcall(function()
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local nameLower = string.lower(child.Name)
            if string.find(nameLower, "chest") or string.find(nameLower, "drop") or string.find(nameLower, "spawn")
               or string.find(nameLower, "notification") or string.find(nameLower, "reward") or string.find(nameLower, "loot") then
                child.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local argStr = ""
                    for i, arg in ipairs(args) do
                        argStr = argStr .. "[" .. tostring(i) .. "]=" .. tostring(arg) .. " "
                    end
                    
                    local logEntry = {
                        Timestamp = FormatTime(Workspace.DistributedGameTime),
                        Remote = child:GetFullName(),
                        Method = "OnClientEvent",
                        Args = argStr
                    }
                    table.insert(getgenv().PolarRemoteLog, logEntry)
                    
                    -- Detectar si es un evento de spawn de cofre/ítem
                    local fullStr = string.lower(argStr)
                    if string.find(fullStr, "fist") or string.find(fullStr, "chalice") or string.find(fullStr, "darkness") then
                        RegisterChestReset("OnClientEvent: " .. child.Name .. " → " .. argStr)
                    end
                    
                    warn("[Remote Spy IN] " .. child:GetFullName() .. " | Data: " .. argStr)
                end)
            end
        end
    end
end)

-- ==================== RECEPTOR EN TIEMPO REAL DE EVENTOS Y CHAT ====================

pcall(function()
    if TextChatService and TextChatService.TextChannels then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("RBXSystem")
        if generalChannel then
            generalChannel.MessageReceived:Connect(function(msg)
                local text = string.lower(msg.Text or "")
                if (string.find(text, "fist of darkness") or string.find(text, "god's chalice") or string.find(text, "chalice")) and string.find(text, "chest") then
                    RegisterChestReset("Chat del Sistema: " .. msg.Text)
                end
            end)
        end
    end

    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local onMessage = chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessage and onMessage:IsA("RemoteEvent") then
            onMessage.OnClientEvent:Connect(function(messageData)
                if messageData and messageData.Message then
                    local text = string.lower(messageData.Message)
                    if (string.find(text, "fist of darkness") or string.find(text, "chalice") or string.find(text, "god's chalice")) and string.find(text, "chest") then
                        RegisterChestReset("Legacy Chat: " .. messageData.Message)
                    end
                end
            end)
        end
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        playerGui.DescendantAdded:Connect(function(desc)
            if desc:IsA("TextLabel") then
                task.wait(0.05) -- esperar a que el texto se asigne
                local text = string.lower(desc.Text or "")
                if (string.find(text, "fist of darkness") or string.find(text, "god's chalice") or string.find(text, "chalice")) and string.find(text, "chest") then
                    RegisterChestReset("UI Notice Banner: " .. desc.Text)
                end
            end
        end)
    end
end)

-- Loop de escaneo continuo de inventarios
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            DeepScanServerPlayers()
            DeepScanNilAndWorkspace()
        end)
    end
end)

-- ==================== CÁLCULO DE TIEMPO DEL SERVIDOR ====================

local function GetServerStats()
    local serverUptime = Workspace.DistributedGameTime
    local serverTimeNow = pcall(function() return Workspace:GetServerTimeNow() end) and Workspace:GetServerTimeNow() or os.time()
    local bootUnix = math.floor(serverTimeNow - serverUptime)
    local creationDateUTC = os.date("!%Y-%m-%d %H:%M:%S UTC", bootUnix)
    
    local CHEST_COOLDOWN = 14400
    local timeSinceLastReset = serverUptime
    
    if getgenv().PolarServerTracker.LastChestResetTime then
        timeSinceLastReset = serverUptime - getgenv().PolarServerTracker.LastChestResetTime
    end
    
    local currentCycle = math.floor(serverUptime / CHEST_COOLDOWN) + 1
    local remainingTime = 0
    local isChestReady = false
    local statusText = ""
    
    if getgenv().PolarServerTracker.ItemHolderDetected then
        isChestReady = false
        statusText = "⚠️ Poseído en inventario por: " .. getgenv().PolarServerTracker.ItemHolderDetected
    elseif timeSinceLastReset >= CHEST_COOLDOWN then
        isChestReady = true
        remainingTime = 0
        statusText = "✅ ¡DISPONIBLE AHORA! (Puedes encontrar " .. TargetItemName .. " en cofres)"
    else
        isChestReady = false
        remainingTime = CHEST_COOLDOWN - timeSinceLastReset
        statusText = "⏳ Enfriamiento (Ciclo #" .. tostring(currentCycle) .. " — " .. FormatTime(remainingTime) .. " restantes)"
    end
    
    return {
        UptimeSeconds = serverUptime,
        UptimeFormatted = FormatTime(serverUptime),
        CreationDate = creationDateUTC,
        CurrentCycle = currentCycle,
        ChestReady = isChestReady,
        ChestRemainingSeconds = remainingTime,
        ChestRemainingFormatted = FormatTime(remainingTime),
        ChestStatus = statusText
    }
end

-- ==================== HUD OVERLAY FLOTANTE ====================

if getgenv().PolarTrackerGui then
    pcall(function() getgenv().PolarTrackerGui:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
local randomGuiName = "PolarTracker_" .. tostring(math.random(100000, 999999))
ScreenGui.Name = randomGuiName
ScreenGui.ResetOnSpawn = false
getgenv().PolarTrackerGui = ScreenGui

local container = nil
if typeof(gethui) == "function" then
    pcall(function() container = gethui() end)
end
if not container then
    pcall(function()
        if typeof(cloneref) == "function" and game:GetService("CoreGui") then
            container = cloneref(game:GetService("CoreGui"))
        else
            container = game:GetService("CoreGui")
        end
    end)
end
if not container then
    container = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer.PlayerGui
end
if typeof(protectgui) == "function" then pcall(function() protectgui(ScreenGui) end) end
ScreenGui.Parent = container

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
MainFrame.BackgroundTransparency = 0.12
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.22, 0)
MainFrame.Size = UDim2.new(0, 330, 0, 220)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 220, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.25
UIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.05, 0, 0.04, 0)
TitleLabel.Size = UDim2.new(0.9, 0, 0.14, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "⏱️ POLAR SERVER & CHEST TRACKER V2"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local Divider = Instance.new("Frame")
Divider.Parent = MainFrame
Divider.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0.05, 0, 0.19, 0)
Divider.Size = UDim2.new(0.9, 0, 0, 1)

local ServerTimeText = Instance.new("TextLabel")
ServerTimeText.Name = "ServerTimeText"
ServerTimeText.Parent = MainFrame
ServerTimeText.BackgroundTransparency = 1
ServerTimeText.Position = UDim2.new(0.05, 0, 0.22, 0)
ServerTimeText.Size = UDim2.new(0.9, 0, 0.18, 0)
ServerTimeText.Font = Enum.Font.SourceSansSemibold
ServerTimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerTimeText.TextSize = 14
ServerTimeText.TextXAlignment = Enum.TextXAlignment.Left
ServerTimeText.Text = "🌐 Uptime Servidor: Cargando..."

local ServerCreatedText = Instance.new("TextLabel")
ServerCreatedText.Name = "ServerCreatedText"
ServerCreatedText.Parent = MainFrame
ServerCreatedText.BackgroundTransparency = 1
ServerCreatedText.Position = UDim2.new(0.05, 0, 0.39, 0)
ServerCreatedText.Size = UDim2.new(0.9, 0, 0.15, 0)
ServerCreatedText.Font = Enum.Font.SourceSans
ServerCreatedText.TextColor3 = Color3.fromRGB(180, 200, 220)
ServerCreatedText.TextSize = 12
ServerCreatedText.TextXAlignment = Enum.TextXAlignment.Left
ServerCreatedText.Text = "📅 Creado el: Cargando..."

local ChestTimerText = Instance.new("TextLabel")
ChestTimerText.Name = "ChestTimerText"
ChestTimerText.Parent = MainFrame
ChestTimerText.BackgroundTransparency = 1
ChestTimerText.Position = UDim2.new(0.05, 0, 0.55, 0)
ChestTimerText.Size = UDim2.new(0.9, 0, 0.24, 0)
ChestTimerText.Font = Enum.Font.SourceSansBold
ChestTimerText.TextColor3 = Color3.fromRGB(255, 220, 0)
ChestTimerText.TextSize = 13
ChestTimerText.TextXAlignment = Enum.TextXAlignment.Left
ChestTimerText.TextWrapped = true
ChestTimerText.Text = "🗝️ Next Chest Key: Cargando..."

local CopyJobBtn = Instance.new("TextButton")
CopyJobBtn.Name = "CopyJobBtn"
CopyJobBtn.Parent = MainFrame
CopyJobBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
CopyJobBtn.BorderSizePixel = 0
CopyJobBtn.Position = UDim2.new(0.05, 0, 0.81, 0)
CopyJobBtn.Size = UDim2.new(0.42, 0, 0.14, 0)
CopyJobBtn.Font = Enum.Font.SourceSansBold
CopyJobBtn.Text = "📋 Copiar JobId"
CopyJobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyJobBtn.TextSize = 12

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 4)
BtnCorner1.Parent = CopyJobBtn

CopyJobBtn.MouseButton1Click:Connect(function()
    CopyToClipboard(tostring(game.JobId))
    CopyJobBtn.Text = "✅ ¡Copiado!"
    task.wait(1.5)
    CopyJobBtn.Text = "📋 Copiar JobId"
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(0.53, 0, 0.81, 0)
MinimizeBtn.Size = UDim2.new(0.42, 0, 0.14, 0)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "🙈 Ocultar HUD"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 230, 240)
MinimizeBtn.TextSize = 12

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 4)
BtnCorner2.Parent = MinimizeBtn

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 330, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeBtn.Text = "👁️ Mostrar HUD"
    else
        MainFrame:TweenSize(UDim2.new(0, 330, 0, 220), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeBtn.Text = "🙈 Ocultar HUD"
    end
end)

-- Render Loop en Tiempo Real
RunService.RenderStepped:Connect(function()
    local stats = GetServerStats()
    
    ServerTimeText.Text = "🌐 Uptime Servidor: " .. stats.UptimeFormatted
    ServerCreatedText.Text = "📅 Creado el: " .. stats.CreationDate
    ChestTimerText.Text = "🗝️ " .. TargetItemName .. ":\n" .. stats.ChestStatus
    
    if stats.ChestReady then
        ChestTimerText.TextColor3 = Color3.fromRGB(0, 255, 120)
    elseif getgenv().PolarServerTracker.ItemHolderDetected then
        ChestTimerText.TextColor3 = Color3.fromRGB(255, 70, 70)
    else
        ChestTimerText.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end)

-- ==================== INTEGRACIÓN GUI REDZLIB ====================

if redzlib then
    local Window = redzlib:MakeWindow({
        Name = "⏱️ POLAR TRACKER V2 GOD MODE",
        SubTitle = "Server Uptime & Deep Memory Sniffer",
        SaveFolder = "PolarTrackerConfig.json"
    })

    local TabTracker = Window:MakeTab({ Title = "Server & Chests", Icon = "clock" })
    local TabDeepScan = Window:MakeTab({ Title = "Deep Scanner 🔍", Icon = "search" })

    TabTracker:AddSection("🌐 Estadísticas de Servidor")

    TabTracker:AddButton({
        Name = "📋 Copiar Job ID de este Servidor",
        Callback = function()
            CopyToClipboard(tostring(game.JobId))
        end
    })

    TabTracker:AddSection("🔔 Alertas y Reset Manual")

    TabTracker:AddTextBox({
        Name = "Discord Webhook (Alertas 4h)",
        PlaceholderText = "https://discord.com/api/webhooks/...",
        Callback = function(v)
            getgenv().PolarServerTracker.DiscordWebhook = v
        end
    })

    TabTracker:AddButton({
        Name = "🔄 Resetear Contador de 4h Manualmente",
        Callback = function()
            RegisterChestReset("Reset Manual de Usuario")
        end
    })

    -- TAB DEEP SCANNER
    TabDeepScan:AddSection("👥 Inventario de Jugadores del Servidor")

    TabDeepScan:AddButton({
        Name = "🔎 Escanear Inventarios de Todos los Jugadores",
        Callback = function()
            local holder, item = DeepScanServerPlayers()
            if holder then
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "⚠️ ¡ÍTEM DETECTADO EN INVENTARIO!",
                        Text = holder .. " posee " .. item,
                        Duration = 10
                    })
                end)
            else
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "✅ Inventarios Limpios",
                        Text = "Ningún jugador en el servidor tiene el " .. TargetItemName .. " en inventario.",
                        Duration = 5
                    })
                end)
            end
        end
    })

    TabDeepScan:AddSection("🧠 Memoria Luau GC & Nil Instances")

    TabDeepScan:AddButton({
        Name = "🔍 Escanear Nil Instances & Suelo",
        Callback = function()
            local drop = DeepScanNilAndWorkspace()
            if drop then
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "📦 Ítem Detectado en Memoria",
                        Text = drop,
                        Duration = 10
                    })
                end)
            else
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "❌ Sin Drops",
                        Text = "No se encontraron " .. TargetItemName .. " tirados en el mapa ni en Nil Instances.",
                        Duration = 5
                    })
                end)
            end
        end
    })

    TabDeepScan:AddButton({
        Name = "🧬 Escanear Atributos del Servidor",
        Callback = function()
            local attr = DeepScanGameAttributes()
            if attr then
                print("🧬 [Attributes Scan] " .. attr)
            else
                print("🧬 [Attributes Scan] No hay atributos de cofre registrados en Workspace/ReplicatedStorage.")
            end
        end
    })

    TabDeepScan:AddButton({
        Name = "⚡ Escanear Memoria GC (getgc)",
        Callback = function()
            local gcResult = DeepScanLuauGC()
            if gcResult then
                print("⚡ [GC Scan] " .. gcResult)
            else
                print("⚡ [GC Scan] Escaneo GC completado sin coincidencias de upvalues de cofre.")
            end
        end
    })

    TabDeepScan:AddSection("📦 Módulos Cargados & Registro")

    TabDeepScan:AddButton({
        Name = "📜 Escanear ModuleScripts Cargados (getloadedmodules)",
        Callback = function()
            local results = DeepScanLoadedModules()
            print("📜 [Loaded Modules Scan] Se encontraron " .. tostring(#results) .. " coincidencias de módulos:")
            for i, res in ipairs(results) do
                print(string.format("  [%d] %s | Key: %s = %s (%s)", i, res.Module, res.Key, res.Value, res.Type))
            end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "📜 Escaneo de Módulos",
                    Text = "Se analizaron " .. tostring(#results) .. " entradas en módulos. Revisa la consola (F9).",
                    Duration = 5
                })
            end)
        end
    })

    TabDeepScan:AddButton({
        Name = "🗂️ Escanear Registro Luau VM (getreg)",
        Callback = function()
            local regResults = DeepScanRegistry()
            print("🗂️ [Registry Scan] Se encontraron " .. tostring(#regResults) .. " entradas:")
            for i, res in ipairs(regResults) do
                print(string.format("  [%d] Key: %s = %s (%s)", i, res.Key, res.Value, res.Type))
            end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "🗂️ Escaneo de Registro",
                    Text = "Se encontraron " .. tostring(#regResults) .. " claves en el VM Registry. Revisa la consola (F9).",
                    Duration = 5
                })
            end)
        end
    })

    TabDeepScan:AddButton({
        Name = "🔗 Escanear Conexiones de Eventos (getconnections)",
        Callback = function()
            local connResults = DeepScanConnections()
            print("🔗 [Connections Scan] Se encontraron " .. tostring(#connResults) .. " conexiones activas:")
            for i, res in ipairs(connResults) do
                print(string.format("  [%d] Remote: %s | Class: %s | Conexiones/Upvalues: %s", i, res.Remote, res.ClassName, tostring(res.ConnectionCount)))
            end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "🔗 Conexiones de Eventos",
                    Text = "Se inspeccionaron " .. tostring(#connResults) .. " remotos/conexiones. Revisa la consola (F9).",
                    Duration = 5
                })
            end)
        end
    })

    TabDeepScan:AddSection("📡 Remote Spy Tráfico de Cofres")

    TabDeepScan:AddButton({
        Name = "📡 Ver Registro de Remotos Interceptados (Remote Spy)",
        Callback = function()
            local logs = getgenv().PolarRemoteLog or {}
            print("📡 [Remote Spy Log] Registros capturados: " .. tostring(#logs))
            for i, log in ipairs(logs) do
                print(string.format("  [%d] [%s] %s (%s) → %s", i, log.Timestamp, log.Remote, log.Method, log.Args))
            end
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "📡 Remote Spy Log",
                    Text = "Se imprimieron " .. tostring(#logs) .. " eventos de remotos en la consola (F9).",
                    Duration = 5
                })
            end)
        end
    })
else
    -- Fallback: Si redzlib falla o no carga en el ejecutor, crear un menú modal independiente en la pantalla
    local BuiltInMenu = Instance.new("Frame")
    BuiltInMenu.Name = "BuiltInMenu"
    BuiltInMenu.Parent = ScreenGui
    BuiltInMenu.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    BuiltInMenu.Position = UDim2.new(0.5, -200, 0.5, -150)
    BuiltInMenu.Size = UDim2.new(0, 400, 0, 300)
    BuiltInMenu.Visible = false
    BuiltInMenu.Active = true
    BuiltInMenu.Draggable = true

    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 10)
    MenuCorner.Parent = BuiltInMenu

    local MenuTitle = Instance.new("TextLabel")
    MenuTitle.Parent = BuiltInMenu
    MenuTitle.BackgroundTransparency = 1
    MenuTitle.Position = UDim2.new(0.05, 0, 0.04, 0)
    MenuTitle.Size = UDim2.new(0.9, 0, 0.12, 0)
    MenuTitle.Font = Enum.Font.SourceSansBold
    MenuTitle.Text = "⏱️ POLAR DEEP MEMORY SCANNER (BUILT-IN)"
    MenuTitle.TextColor3 = Color3.fromRGB(0, 230, 255)
    MenuTitle.TextSize = 14

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = BuiltInMenu
    Scroll.BackgroundTransparency = 1
    Scroll.Position = UDim2.new(0.05, 0, 0.18, 0)
    Scroll.Size = UDim2.new(0.9, 0, 0.78, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    Scroll.ScrollBarThickness = 4

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Scroll
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)

    local function AddBuiltInButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = Scroll
        btn.BackgroundColor3 = Color3.fromRGB(28, 38, 55)
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(230, 240, 255)
        btn.TextSize = 12
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 5)
        c.Parent = btn
        btn.MouseButton1Click:Connect(callback)
    end

    AddBuiltInButton("👥 Escanear Inventario de Jugadores", function()
        local holder, item = DeepScanServerPlayers()
        print("👥 [Inventario] " .. (holder and (holder .. " posee " .. item) or "Limpio."))
    end)

    AddBuiltInButton("🔍 Escanear Nil Instances & Suelo", function()
        local drop = DeepScanNilAndWorkspace()
        print("🔍 [Nil Scan] " .. (drop or "Sin drops."))
    end)

    AddBuiltInButton("📜 Escanear ModuleScripts Cargados", function()
        local res = DeepScanLoadedModules()
        print("📜 [ModuleScripts] Coincidencias: " .. tostring(#res))
    end)

    AddBuiltInButton("🗂️ Escanear Registro Luau VM (getreg)", function()
        local res = DeepScanRegistry()
        print("🗂️ [Registry] Entradas: " .. tostring(#res))
    end)

    AddBuiltInButton("📡 Ver Logs Remote Spy", function()
        local logs = getgenv().PolarRemoteLog or {}
        print("📡 [Remote Spy] Capturados: " .. tostring(#logs))
    end)

    -- Botón en HUD para abrir el Menú Built-in si Redzlib falló
    local OpenMenuBtn = Instance.new("TextButton")
    OpenMenuBtn.Parent = MainFrame
    OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 130)
    OpenMenuBtn.BorderSizePixel = 0
    OpenMenuBtn.Position = UDim2.new(0.05, 0, 0.98, 0)
    OpenMenuBtn.Size = UDim2.new(0.9, 0, 0.12, 0)
    OpenMenuBtn.Font = Enum.Font.SourceSansBold
    OpenMenuBtn.Text = "🛠️ Abrir Menú de Escáneres"
    OpenMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenMenuBtn.TextSize = 11

    local cBtn = Instance.new("UICorner")
    cBtn.CornerRadius = UDim.new(0, 4)
    cBtn.Parent = OpenMenuBtn

    OpenMenuBtn.MouseButton1Click:Connect(function()
        BuiltInMenu.Visible = not BuiltInMenu.Visible
    end)
end

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "⏱️ POLAR TRACKER INYECTADO",
        Text = "Tracker de Servidor y Escáneres cargados correctamente.",
        Duration = 6
    })
end)

print("⏱️ [Polar Server Tracker V2 God Mode] Inyectado correctamente.")
