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

-- ==================== CARGAR UI LIBRARY ====================
local success, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/main/redzlibV5.lua"))()
end)

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
                local text = string.lower(desc.Text)
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

local ScreenGui = Instance.new("ScreenGui")
local randomGuiName = "PolarTracker_" .. tostring(math.random(100000, 999999))
ScreenGui.Name = randomGuiName
ScreenGui.ResetOnSpawn = false

local container = nil
if typeof(gethui) == "function" then
    container = gethui()
elseif typeof(cloneref) == "function" and game:GetService("CoreGui") then
    container = cloneref(game:GetService("CoreGui"))
else
    container = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
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
end

print("⏱️ [Polar Server Tracker V2 God Mode] Inyectado correctamente.")
