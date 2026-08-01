--[[
    ===============================================================
    🎯 POLAR VISION & AIM SUITE — Script Independiente
    ===============================================================
    Script Luau optimizado para Roblox / Blox Fruits que incluye:
    - ESP Engine 2D/3D (Nombre, Vida en tiempo real, Distancia, Cajas/Highlights)
    - Aim Assist / Silent Aim (Selección de objetivo por FOV, suavizado y tecla de activación)
    
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
    warn("[Polar Vision] Error: No se pudo cargar RedzLib V5. Inicializando fallback...")
end

-- ==================== CONFIGURACIÓN GLOBAL ====================
getgenv().PolarESP = getgenv().PolarESP or {
    Enabled = true,
    ShowPlayers = true,
    ShowNPCs = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowBoxes = true,
    ShowTracers = false,
    TextSize = 14,
    MaxDistance = 2500
}

getgenv().PolarAim = getgenv().PolarAim or {
    Enabled = true,
    TargetPart = "Head", -- "Head" o "HumanoidRootPart"
    FOV = 150,
    ShowFOV = true,
    Smoothness = 0.2, -- 0 = Instantáneo, 1 = Ultra Suave
    AimKey = Enum.UserInputType.MouseButton2, -- Clic Derecho por defecto
    TargetNPCs = true,
    TargetPlayers = true,
    WallCheck = false
}

-- ==================== FOV CIRCLE (DRAWING API) ====================
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.Color = Color3.fromRGB(0, 225, 255)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.8
        FOVCircle.NumSides = 36
        FOVCircle.Radius = getgenv().PolarAim.FOV
        FOVCircle.Visible = getgenv().PolarAim.ShowFOV
    end
end)

-- ==================== ESP STORAGE ====================
local ESPCache = {}

local function RemoveESP(instance)
    if ESPCache[instance] then
        for _, v in pairs(ESPCache[instance]) do
            pcall(function() v:Destroy() end)
        end
        ESPCache[instance] = nil
    end
end

-- Crear BillboardGui para ESP sobre la cabeza
local function CreateESP(char, isPlayer, name)
    if not char or ESPCache[char] then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PolarESP_Billboard"
    billboard.Adornee = head or hrp
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    -- Label Nombre + Distancia
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = billboard
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = getgenv().PolarESP.TextSize
    nameLabel.TextColor3 = isPlayer and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(255, 215, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Text = name

    -- Marco Barra de Vida
    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.Parent = billboard
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BorderSizePixel = 1
    healthBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.Size = UDim2.new(0.8, 0, 0.15, 0)
    healthBg.Position = UDim2.new(0.1, 0, 0.45, 0)

    -- Barra de Vida Relleno
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Parent = healthBg
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)

    -- Texto de Vida (ej: 100/100)
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Parent = billboard
    healthLabel.BackgroundTransparency = 1
    healthLabel.Size = UDim2.new(1, 0, 0.35, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.65, 0)
    healthLabel.Font = Enum.Font.SourceSansSemibold
    healthLabel.TextSize = getgenv().PolarESP.TextSize - 2
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextStrokeTransparency = 0.2
    healthLabel.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)

    -- Highlight (Caja 3D Brillante)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PolarESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = isPlayer and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 180, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = isPlayer and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0.2
    highlight.Enabled = getgenv().PolarESP.ShowBoxes

    -- Intentar guardar en Parent seguro (CoreGui o PlayerGui)
    local targetParent = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    billboard.Parent = targetParent
    highlight.Parent = targetParent

    ESPCache[char] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthFill = healthFill,
        HealthLabel = healthLabel,
        Highlight = highlight,
        Character = char,
        Humanoid = hum,
        HRP = hrp,
        IsPlayer = isPlayer
    }
end

-- Update Loop de ESP
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = getgenv().PolarAim.FOV
        FOVCircle.Visible = getgenv().PolarAim.Enabled and getgenv().PolarAim.ShowFOV
    end

    if not getgenv().PolarESP.Enabled then
        for char, _ in pairs(ESPCache) do
            RemoveESP(char)
        end
        return
    end

    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    -- Mapear Jugadores
    if getgenv().PolarESP.ShowPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not ESPCache[plr.Character] then
                    CreateESP(plr.Character, true, plr.DisplayName or plr.Name)
                end
            end
        end
    end

    -- Mapear NPCs / Enemigos
    if getgenv().PolarESP.ShowNPCs then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChildOfClass("Humanoid") then
                    if not ESPCache[npc] then
                        CreateESP(npc, false, npc.Name)
                    end
                end
            end
        end
    end

    -- Actualizar cada objeto en cache
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

                -- Vida
                local hp = math.max(0, data.Humanoid.Health)
                local maxHp = math.max(1, data.Humanoid.MaxHealth)
                local pct = math.clamp(hp / maxHp, 0, 1)

                data.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                data.HealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - pct), 255 * pct, 50)

                -- Texto
                local distText = getgenv().PolarESP.ShowDistance and (" [" .. math.floor(dist) .. "m]") or ""
                data.NameLabel.Text = (char.Name) .. distText
                
                if getgenv().PolarESP.ShowHealth then
                    data.HealthLabel.Text = math.floor(hp) .. " / " .. math.floor(maxHp) .. " HP"
                    data.HealthLabel.Visible = true
                else
                    data.HealthLabel.Visible = false
                end
            end
        end
    end
end)

-- ==================== AIM ASSIST ENGINE ====================

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

-- Buscar objetivo más cercano al cursor del mouse dentro del FOV
local function GetClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDist = getgenv().PolarAim.FOV

    local function CheckChar(char, isPlayer)
        if not char or not char.Parent then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(getgenv().PolarAim.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not part then return end

        -- Convertir posición 3D a 2D en pantalla
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if mouseDist < shortestDist then
                shortestDist = mouseDist
                closestTarget = part
            end
        end
    end

    -- Revisar Jugadores
    if getgenv().PolarAim.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                CheckChar(plr.Character, true)
            end
        end
    end

    -- Revisar NPCs
    if getgenv().PolarAim.TargetNPCs then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs")
        if enemiesFolder then
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                CheckChar(npc, false)
            end
        end
    end

    return closestTarget
end

-- Loop de Apuntado (RenderStepped para suavidad máxima)
RunService.RenderStepped:Connect(function()
    if getgenv().PolarAim.Enabled and isAiming then
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position
            local camCFrame = Camera.CFrame
            local desiredCFrame = CFrame.new(camCFrame.Position, targetPos)

            -- Interpolación suave (Lerp)
            local smoothFactor = math.clamp(1 - getgenv().PolarAim.Smoothness, 0.05, 1)
            Camera.CFrame = camCFrame:Lerp(desiredCFrame, smoothFactor)
        end
    end
end)

-- ==================== CONSTRUCCIÓN DE LA GUI ====================

if redzlib then
    local Window = redzlib:MakeWindow({
        Name = "🎯 POLAR VISION & AIM",
        SubTitle = "ESP Engine & Aim Assist | Blox Fruits",
        SaveFolder = "PolarVisionConfig.json"
    })

    -- TAB 1: ESP
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

    -- TAB 2: AIM ASSIST
    local TabAim = Window:MakeTab({ Title = "Aim Assist", Icon = "crosshair" })

    TabAim:AddToggle({
        Name = "Activar Aim Assist",
        Desc = "Mantén presionado Clic Derecho para apuntar suavemente al objetivo.",
        Default = getgenv().PolarAim.Enabled,
        Callback = function(v) getgenv().PolarAim.Enabled = v end
    })

    TabAim:AddToggle({
        Name = "Mostrar Círculo FOV",
        Default = getgenv().PolarAim.ShowFOV,
        Callback = function(v) getgenv().PolarAim.ShowFOV = v end
    })

    TabAim:AddDropdown({
        Name = "Parte a Apuntar",
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
        Name = "Suavizado de Apuntado (Smoothness)",
        Min = 0,
        Max = 9,
        Increase = 1,
        Default = 2,
        Callback = function(v) getgenv().PolarAim.Smoothness = v / 10 end
    })

    TabAim:AddToggle({
        Name = "Apuntar a Enemigos / NPCs",
        Default = getgenv().PolarAim.TargetNPCs,
        Callback = function(v) getgenv().PolarAim.TargetNPCs = v end
    })

    TabAim:AddToggle({
        Name = "Apuntar a Jugadores",
        Default = getgenv().PolarAim.TargetPlayers,
        Callback = function(v) getgenv().PolarAim.TargetPlayers = v end
    })
end

print("🎯 [Polar Vision & Aim] Carga completada con éxito.")
