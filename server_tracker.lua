--[[
    ===============================================================
    ⏱️ POLAR SERVER AGE & BLOX FRUITS CHEST TIMER (NEXT CHEST KEY)
    ===============================================================
    Script Luau de nivel avanzado para monitorear en tiempo real:
    1. Tiempo exacto del SERVIDOR de Roblox desde que se creó (workspace.DistributedGameTime)
    2. Hora y fecha exacta de creación del servidor (UTC)
    3. Contador "Next Chest Key" para Blox Fruits (Fist of Darkness / God's Chalice en cofres)
       - Cada 4 horas (14,400s) desde el inicio del servidor o desde que alguien encuentra el ítem en un cofre.
    4. Detector en vivo de notificaciones del sistema cuando alguien obtiene Puño de Oscuridad o Cáliz.
    
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
    LastChestResetTime = nil, -- Marca de tiempo de workspace.DistributedGameTime cuando se encontró un ítem en cofre
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

-- Función para enviar notificaciones de Discord
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
                color = 65535, -- Cyan
                fields = embedFields,
                footer = {text = "Polar Server Tracker | JobId: " .. tostring(game.JobId)}
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

-- ==================== DETECTOR EN VIVO DE ÍTEMS EN COFRES ====================
-- Resetea el contador de 4 horas si detecta que alguien encontró el Puño o Cáliz en un cofre

local function RegisterChestReset(sourceReason)
    getgenv().PolarServerTracker.LastChestResetTime = Workspace.DistributedGameTime
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🗝️ RESET DE COFRE DETECTADO",
            Text = "Un " .. TargetItemName .. " fue encontrado (" .. sourceReason .. "). Contador de 4h reiniciado.",
            Duration = 10
        })
    end)
    
    SendWebhookNotification("🗝️ RESET DE COFRE EN BLOX FRUITS", "Se ha detectado un hallazgo de " .. TargetItemName .. ".", {
        {name = "Razón / Fuente", value = sourceReason, inline = true},
        {name = "Sea", value = "Sea " .. tostring(CurrentSea), inline = true},
        {name = "Uptime Servidor", value = FormatTime(Workspace.DistributedGameTime), inline = true},
        {name = "Job ID", value = "`" .. tostring(game.JobId) .. "`", inline = false}
    })
end

-- Escuchar notificaciones del sistema o chat de Roblox (TextChatService o Legacy Chat System)
pcall(function()
    -- Método 1: TextChatService (Roblox Modern Chat)
    if TextChatService and TextChatService.TextChannels then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("RBXSystem")
        if generalChannel then
            generalChannel.MessageReceived:Connect(function(msg)
                local text = string.lower(msg.Text or "")
                if string.find(text, "fist of darkness") or string.find(text, "god's chalice") or string.find(text, "chalice") or string.find(text, "found") then
                    if string.find(text, "chest") then
                        RegisterChestReset("Chat del Sistema: " .. msg.Text)
                    end
                end
            end)
        end
    end

    -- Método 2: Legacy Chat System
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
end)

-- Escuchar cuando el propio jugador obtiene el ítem en su inventario / backpack
local function WatchBackpack()
    local backpack = LocalPlayer:WaitForChild("Backpack", 5)
    if backpack then
        backpack.ChildAdded:Connect(function(child)
            local name = string.lower(child.Name)
            if string.find(name, "fist of darkness") or string.find(name, "god's chalice") or string.find(name, "chalice") then
                RegisterChestReset("Conseguido por ti en inventario: " .. child.Name)
            end
        end)
    end
end
task.spawn(WatchBackpack)

-- ==================== CÁLCULO DE TIEMPO DEL SERVIDOR ====================

local function GetServerStats()
    -- DistributedGameTime: Tiempo exacto en segundos desde que la máquina del servidor de Roblox encendió esta instancia
    local serverUptime = Workspace.DistributedGameTime
    
    -- Calcular timestamp UTC de creación del servidor
    local currentUnix = os.time()
    local creationUnix = currentUnix - math.floor(serverUptime)
    local creationDateUTC = os.date("!%Y-%m-%d %H:%M:%S UTC", creationUnix)
    
    -- Cálculos para el Next Chest Key (4 horas = 14,400 segundos)
    local CHEST_COOLDOWN = 14400
    local timeSinceLastReset = serverUptime
    
    if getgenv().PolarServerTracker.LastChestResetTime then
        timeSinceLastReset = serverUptime - getgenv().PolarServerTracker.LastChestResetTime
    end
    
    local remainingTime = 0
    local isChestReady = false
    local statusText = ""
    
    if timeSinceLastReset >= CHEST_COOLDOWN then
        isChestReady = true
        remainingTime = 0
        statusText = "✅ ¡DISPONIBLE AHORA! (Puedes encontrar " .. TargetItemName .. " en cofres)"
    else
        isChestReady = false
        remainingTime = CHEST_COOLDOWN - timeSinceLastReset
        statusText = "⏳ Enfriamiento (" .. FormatTime(remainingTime) .. " restantes)"
    end
    
    return {
        UptimeSeconds = serverUptime,
        UptimeFormatted = FormatTime(serverUptime),
        CreationDate = creationDateUTC,
        ChestReady = isChestReady,
        ChestRemainingSeconds = remainingTime,
        ChestRemainingFormatted = FormatTime(remainingTime),
        ChestStatus = statusText
    }
end

-- ==================== CREAR FLOATING HUD OVERLAY ====================

local ScreenGui = Instance.new("ScreenGui")
local randomGuiName = "PolarTracker_" .. tostring(math.random(100000, 999999))
ScreenGui.Name = randomGuiName
ScreenGui.ResetOnSpawn = false

-- Asignar a contenedor protegido
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

-- Frame Principal Glassmorphic
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 210)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.05, 0, 0.04, 0)
TitleLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "⏱️ POLAR SERVER & CHEST TRACKER"
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Divider
local Divider = Instance.new("Frame")
Divider.Parent = MainFrame
Divider.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0.05, 0, 0.2, 0)
Divider.Size = UDim2.new(0.9, 0, 0, 1)

-- Label Tiempo del Servidor
local ServerTimeText = Instance.new("TextLabel")
ServerTimeText.Name = "ServerTimeText"
ServerTimeText.Parent = MainFrame
ServerTimeText.BackgroundTransparency = 1
ServerTimeText.Position = UDim2.new(0.05, 0, 0.23, 0)
ServerTimeText.Size = UDim2.new(0.9, 0, 0.18, 0)
ServerTimeText.Font = Enum.Font.SourceSansSemibold
ServerTimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerTimeText.TextSize = 14
ServerTimeText.TextXAlignment = Enum.TextXAlignment.Left
ServerTimeText.Text = "🌐 Tiempo Servidor: Cargando..."

-- Label Fecha Creación
local ServerCreatedText = Instance.new("TextLabel")
ServerCreatedText.Name = "ServerCreatedText"
ServerCreatedText.Parent = MainFrame
ServerCreatedText.BackgroundTransparency = 1
ServerCreatedText.Position = UDim2.new(0.05, 0, 0.40, 0)
ServerCreatedText.Size = UDim2.new(0.9, 0, 0.15, 0)
ServerCreatedText.Font = Enum.Font.SourceSans
ServerCreatedText.TextColor3 = Color3.fromRGB(180, 200, 220)
ServerCreatedText.TextSize = 12
ServerCreatedText.TextXAlignment = Enum.TextXAlignment.Left
ServerCreatedText.Text = "📅 Creado: Cargando..."

-- Label Next Chest Key (4 Hours)
local ChestTimerText = Instance.new("TextLabel")
ChestTimerText.Name = "ChestTimerText"
ChestTimerText.Parent = MainFrame
ChestTimerText.BackgroundTransparency = 1
ChestTimerText.Position = UDim2.new(0.05, 0, 0.57, 0)
ChestTimerText.Size = UDim2.new(0.9, 0, 0.22, 0)
ChestTimerText.Font = Enum.Font.SourceSansBold
ChestTimerText.TextColor3 = Color3.fromRGB(255, 220, 0)
ChestTimerText.TextSize = 13
ChestTimerText.TextXAlignment = Enum.TextXAlignment.Left
ChestTimerText.TextWrapped = true
ChestTimerText.Text = "🗝️ Next Chest Key: Cargando..."

-- Botón Copiar JobId
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

-- Botón Ocultar / Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
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
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeBtn.Text = "👁️ Mostrar HUD"
    else
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 210), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeBtn.Text = "🙈 Ocultar HUD"
    end
end)

-- ==================== RENDER LOOP DE TIEMPO REAL ====================

local lastNotifiedReady = false

RunService.RenderStepped:Connect(function()
    local stats = GetServerStats()
    
    ServerTimeText.Text = "🌐 Uptime Servidor: " .. stats.UptimeFormatted
    ServerCreatedText.Text = "📅 Creado el: " .. stats.CreationDate
    ChestTimerText.Text = "🗝️ " .. TargetItemName .. ":\n" .. stats.ChestStatus
    
    if stats.ChestReady then
        ChestTimerText.TextColor3 = Color3.fromRGB(0, 255, 120)
        if not lastNotifiedReady then
            lastNotifiedReady = true
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "🗝️ COFRES LISTOS (4 HORAS CUMPLIDAS)",
                    Text = "¡El servidor ha superado las 4 horas! Ya pueden salir " .. TargetItemName .. " en los cofres.",
                    Duration = 15
                })
            end)
            SendWebhookNotification("🗝️ COFRES LISTOS EN SERVIDOR", "El servidor de Blox Fruits ha superado las 4 horas de vida. Ya pueden salir " .. TargetItemName .. ".", {
                {name = "Uptime Servidor", value = stats.UptimeFormatted, inline = true},
                {name = "Sea", value = "Sea " .. tostring(CurrentSea), inline = true},
                {name = "JobId", value = "`" .. tostring(game.JobId) .. "`", inline = false}
            })
        end
    else
        ChestTimerText.TextColor3 = Color3.fromRGB(255, 200, 50)
        lastNotifiedReady = false
    end
end)

-- ==================== INTEGRACIÓN CON REDZLIB GUI ====================

if redzlib then
    local Window = redzlib:MakeWindow({
        Name = "⏱️ POLAR SERVER TRACKER",
        SubTitle = "Server Uptime & Chest Key Monitor",
        SaveFolder = "PolarTrackerConfig.json"
    })

    local TabTracker = Window:MakeTab({ Title = "Server & Chests", Icon = "clock" })

    TabTracker:AddSection("🌐 Información de Servidor")

    TabTracker:AddButton({
        Name = "📋 Copiar Job ID de este Servidor",
        Callback = function()
            CopyToClipboard(tostring(game.JobId))
        end
    })

    TabTracker:AddButton({
        Name = "⏱️ Ver Estadísticas en Consola / Chat",
        Callback = function()
            local stats = GetServerStats()
            print("==================================================")
            print("🌐 SERVIDOR UPTIME REAL: " .. stats.UptimeFormatted)
            print("📅 FECHA CREACIÓN UTC: " .. stats.CreationDate)
            print("🗝️ CHEST KEY STATUS: " .. stats.ChestStatus)
            print("🔑 JOB ID: " .. tostring(game.JobId))
            print("==================================================")
        end
    })

    TabTracker:AddSection("🔔 Configuración de Notificaciones")

    TabTracker:AddTextBox({
        Name = "Discord Webhook (Alertas de 4h)",
        PlaceholderText = "https://discord.com/api/webhooks/...",
        Callback = function(v)
            getgenv().PolarServerTracker.DiscordWebhook = v
        end
    })

    TabTracker:AddButton({
        Name = "🔄 Forzar Reset Manual de 4h",
        Callback = function()
            RegisterChestReset("Reset Manual de Usuario")
        end
    })
end

print("⏱️ [Polar Server Tracker] Cargado con éxito. Monitoreando Uptime del Servidor y Next Chest Key.")
