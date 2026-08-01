--[[
    ===============================================================
    🎯 POLAR VISION & AIM — Edición Ultra-Fluida (0% Lag)
    ===============================================================
    Script Luau optimizado para Roblox / Blox Fruits.
    
    INSTRUCCIONES DE USO:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/polar_esp_aim.lua"))()
    ===============================================================
]]

repeat task.wait() until game:IsLoaded()

-- ==================== SERVICIOS ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CARGAR UI LIBRARY ====================
local success, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/main/redzlibV5.lua"))()
end)

if not success or not redzlib then
    warn("[Polar Vision] Error: No se pudo cargar RedzLib V5.")
end

-- ==================== CONFIGURACIÓN GLOBAL ====================
getgenv().PolarESP = getgenv().PolarESP or {
    Enabled = true,
    ShowPlayers = true,
    ShowNPCs = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowBoxes = true,
    TextSize = 14,
    MaxDistance = 2000
}

getgenv().PolarAim = getgenv().PolarAim or {
    Enabled = true,
    AutoLock = false, -- Si es true, apunta siempre; si es false, solo cuando se presiona la tecla
    TargetPart = "Head", -- "Head" o "HumanoidRootPart"
    FOV = 150,
    ShowFOV = true,
    Smoothness = 0.15, -- 0.05 = Rápido, 0.5 = Suave
    AimKey = Enum.UserInputType.MouseButton2,
    TargetNPCs = true,
    TargetPlayers = true
}

-- ==================== FOV CIRCLE (DRAWING API) ====================
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.Color = Color3.fromRGB(0, 230, 255)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.7
        FOVCircle.NumSides = 32
        FOVCircle.Radius = getgenv().PolarAim.FOV
        FOVCircle.Visible = getgenv().PolarAim.ShowFOV
    end
end)

-- ==================== ESP SYSTEM (EVENT DRIVEN) ====================
local ESPCache = {}

local function RemoveESP(instance)
    if ESPCache[instance] then
        for _, obj in pairs(ESPCache[instance].Objs or {}) do
            pcall(function() obj:Destroy() end)
        end
        ESPCache[instance] = nil
    end
end

local function CreateESP(char, isPlayer, name)
    if not char or ESPCache[char] then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local randomId = tostring(math.random(100000, 999999))

    -- BillboardGui sobre la cabeza
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GUI_" .. randomId
    billboard.Adornee = head or hrp
    billboard.Size = UDim2.new(0, 180, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true

    -- Texto Nombre + Distancia
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Txt_" .. randomId
    nameLabel.Parent = billboard
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = getgenv().PolarESP.TextSize
    nameLabel.TextColor3 = isPlayer and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 210, 0)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.Text = name

    -- Barra de Vida Fondo
    local healthBg = Instance.new("Frame")
    healthBg.Name = "Bg_" .. randomId
    healthBg.Parent = billboard
    healthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    healthBg.BorderSizePixel = 1
    healthBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.Size = UDim2.new(0.8, 0, 0.15, 0)
    healthBg.Position = UDim2.new(0.1, 0, 0.45, 0)

    -- Barra de Vida Relleno
    local healthFill = Instance.new("Frame")
    healthFill.Name = "Fill_" .. randomId
    healthFill.Parent = healthBg
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)

    -- Texto Vida HP
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Hp_" .. randomId
    healthLabel.Parent = billboard
    healthLabel.BackgroundTransparency = 1
    healthLabel.Size = UDim2.new(1, 0, 0.35, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.65, 0)
    healthLabel.Font = Enum.Font.SourceSansSemibold
    healthLabel.TextSize = getgenv().PolarESP.TextSize - 2
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextStrokeTransparency = 0.3
    healthLabel.Text = math.floor(hum.Health) .. " HP"

    -- Highlight 3D (Caja resplandeciente)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Hl_" .. randomId
    highlight.Adornee = char
    highlight.FillColor = isPlayer and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 170, 0)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3

    -- Contenedor seguro
    local container = nil
    if typeof(gethui) == "function" then
        container = gethui()
    else
        container = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    if typeof(protectgui) == "function" then
        pcall(function() protectgui(billboard) end)
        pcall(function() protectgui(highlight) end)
    end

    billboard.Parent = container
    highlight.Parent = container

    ESPCache[char] = {
        Objs = {billboard, highlight},
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthFill = healthFill,
        HealthLabel = healthLabel,
        Highlight = highlight,
        Humanoid = hum,
        HRP = hrp,
        IsPlayer = isPlayer
    }
end

-- ==================== BÚSQUEDA EFICIENTE DE ENEMIGOS ====================

local function UpdateESP()
    if not getgenv().PolarESP.Enabled then
        if next(ESPCache) then
            for char, _ in pairs(ESPCache) do RemoveESP(char) end
        end
        return
    end

    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    -- 1. Agregar Jugadores
    if getgenv().PolarESP.ShowPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if not ESPCache[plr.Character] then
                    CreateESP(plr.Character, true, plr.DisplayName or plr.Name)
                end
            end
        end
    end

    -- 2. Agregar NPCs / Enemigos de Blox Fruits
    if getgenv().PolarESP.ShowNPCs then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                if not ESPCache[npc] then
                    CreateESP(npc, false, npc.Name)
                end
            end
        end
    end

    -- 3. Actualizar Renderizado de ESP existente
    for char, data in pairs(ESPCache) do
        if not char or not char.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
            RemoveESP(char)
        else
            local dist = myHrp and (data.HRP.Position - myHrp.Position).Magnitude or 0
            if dist > getgenv().PolarESP.MaxDistance then
                data.Billboard.Enabled = false
                data.Highlight.Enabled = false
            else
                data.Billboard.Enabled = true
                data.Highlight.Enabled = getgenv().PolarESP.ShowBoxes

                local hp = math.clamp(data.Humanoid.Health, 0, data.Humanoid.MaxHealth)
                local maxHp = math.max(1, data.Humanoid.MaxHealth)
                local pct = hp / maxHp

                data.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                data.HealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - pct), 255 * pct, 40)

                local distStr = getgenv().PolarESP.ShowDistance and (" [" .. math.floor(dist) .. "m]") or ""
                data.NameLabel.Text = char.Name .. distStr
                data.HealthLabel.Text = math.floor(hp) .. " / " .. math.floor(maxHp) .. " HP"
                data.HealthLabel.Visible = getgenv().PolarESP.ShowHealth
            end
        end
    end
end

-- ==================== MOTOR AIMBOT FLUIDO (0% LAG) ====================

local isAiming = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == getgenv().PolarAim.AimKey or input.KeyCode == getgenv().PolarAim.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == getgenv().PolarAim.AimKey or input.KeyCode == getgenv().PolarAim.AimKey then
        isAiming = false
    end
end)

-- Buscar el mejor objetivo en pantalla dentro del FOV
local function GetBestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local bestPart = nil
    local shortestDist = getgenv().PolarAim.FOV

    local function CheckChar(char)
        if not char or not char.Parent then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(getgenv().PolarAim.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not part then return end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist2D < shortestDist then
                shortestDist = dist2D
                bestPart = part
            end
        end
    end

    if getgenv().PolarAim.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then CheckChar(plr.Character) end
        end
    end

    if getgenv().PolarAim.TargetNPCs then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                CheckChar(npc)
            end
        end
    end

    return bestPart
end

-- Render Loop Ultra-Fluido
RunService.RenderStepped:Connect(function()
    -- Actualizar Círculo FOV
    if FOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = getgenv().PolarAim.FOV
        FOVCircle.Visible = getgenv().PolarAim.Enabled and getgenv().PolarAim.ShowFOV
    end

    -- Actualizar ESP
    UpdateESP()

    -- Ejecutar Aim Assist si está activado
    if getgenv().PolarAim.Enabled and (isAiming or getgenv().PolarAim.AutoLock) then
        local target = GetBestTarget()
        if target then
            local targetPos = target.Position
            local camCFrame = Camera.CFrame
            local desiredCFrame = CFrame.new(camCFrame.Position, targetPos)

            -- Movimiento de cámara 100% fluido (Lerp)
            local lerpSpeed = math.clamp(getgenv().PolarAim.Smoothness, 0.01, 1)
            Camera.CFrame = camCFrame:Lerp(desiredCFrame, lerpSpeed)
        end
    end
end)

-- ==================== GUI REDZLIB ====================

if redzlib then
    local Window = redzlib:MakeWindow({
        Name = "🎯 POLAR VISION & AIM",
        SubTitle = "Edición Ultra-Fluida | Blox Fruits",
        SaveFolder = "PolarVisionConfig.json"
    })

    -- TAB ESP
    local TabESP = Window:MakeTab({ Title = "ESP Visuales", Icon = "eye" })

    TabESP:AddToggle({
        Name = "Activar ESP System",
        Default = getgenv().PolarESP.Enabled,
        Callback = function(v) getgenv().PolarESP.Enabled = v end
    })

    TabESP:AddToggle({
        Name = "Ver Jugadores",
        Default = getgenv().PolarESP.ShowPlayers,
        Callback = function(v) getgenv().PolarESP.ShowPlayers = v end
    })

    TabESP:AddToggle({
        Name = "Ver NPCs / Enemigos",
        Default = getgenv().PolarESP.ShowNPCs,
        Callback = function(v) getgenv().PolarESP.ShowNPCs = v end
    })

    TabESP:AddToggle({
        Name = "Mostrar Vida (HP)",
        Default = getgenv().PolarESP.ShowHealth,
        Callback = function(v) getgenv().PolarESP.ShowHealth = v end
    })

    TabESP:AddToggle({
        Name = "Mostrar Distancia",
        Default = getgenv().PolarESP.ShowDistance,
        Callback = function(v) getgenv().PolarESP.ShowDistance = v end
    })

    TabESP:AddToggle({
        Name = "Cajas / Highlights 3D",
        Default = getgenv().PolarESP.ShowBoxes,
        Callback = function(v) getgenv().PolarESP.ShowBoxes = v end
    })

    -- TAB AIMBOT
    local TabAim = Window:MakeTab({ Title = "Aim Assist", Icon = "crosshair" })

    TabAim:AddToggle({
        Name = "Activar Aim Assist",
        Default = getgenv().PolarAim.Enabled,
        Callback = function(v) getgenv().PolarAim.Enabled = v end
    })

    TabAim:AddToggle({
        Name = "Auto-Lock Continuo",
        Desc = "Apunta siempre al objetivo dentro del FOV sin tener que presionar botones.",
        Default = getgenv().PolarAim.AutoLock,
        Callback = function(v) getgenv().PolarAim.AutoLock = v end
    })

    TabAim:AddToggle({
        Name = "Mostrar Círculo FOV",
        Default = getgenv().PolarAim.ShowFOV,
        Callback = function(v) getgenv().PolarAim.ShowFOV = v end
    })

    TabAim:AddDropdown({
        Name = "Parte Objetivo",
        Options = {"Head", "HumanoidRootPart"},
        Default = "Head",
        Callback = function(v) getgenv().PolarAim.TargetPart = v end
    })

    TabAim:AddSlider({
        Name = "Radio del FOV",
        Min = 50,
        Max = 500,
        Increase = 10,
        Default = getgenv().PolarAim.FOV,
        Callback = function(v) getgenv().PolarAim.FOV = v end
    })

    TabAim:AddSlider({
        Name = "Velocidad de Apuntado (Suavizado)",
        Min = 1,
        Max = 10,
        Increase = 1,
        Default = 3,
        Callback = function(v) getgenv().PolarAim.Smoothness = v / 20 end
    })

    TabAim:AddToggle({
        Name = "Apuntar a NPCs / Enemigos",
        Default = getgenv().PolarAim.TargetNPCs,
        Callback = function(v) getgenv().PolarAim.TargetNPCs = v end
    })

    TabAim:AddToggle({
        Name = "Apuntar a Jugadores",
        Default = getgenv().PolarAim.TargetPlayers,
        Callback = function(v) getgenv().PolarAim.TargetPlayers = v end
    })
end

print("🎯 [Polar Vision & Aim] Versión Ultra-Fluida cargada.")
