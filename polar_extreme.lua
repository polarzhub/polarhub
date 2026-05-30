-- POLAR EXTREME V2 (MAX EXECUTOR POWER)
-- Script diseñado para romper los límites del juego
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==================== ANTI-CHEAT BYPASS (NIVEL EXECUTOR) ====================
-- Usamos hookmetamethod para ocultarle al servidor nuestros verdaderos stats
local oldIndex, oldNewIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == LocalPlayer.Character:FindFirstChild("Humanoid") then
        if key == "WalkSpeed" then return 16 end
        if key == "JumpPower" then return 50 end
    end
    return oldIndex(self, key)
end)
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if not checkcaller() and self == LocalPlayer.Character:FindFirstChild("Humanoid") then
        if key == "WalkSpeed" or key == "JumpPower" then return end
    end
    return oldNewIndex(self, key, value)
end)

-- ==================== WIND UI LIBRARY ====================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Error: No se pudo cargar WindUI.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "🔥 POLAR EXTREME | MAX OP",
    Icon = "skull",
    Folder = "PolarExtreme",
    Size = UDim2.fromOffset(600, 500),
    Transparent = true,
    Theme = "Dark",
    OpenButton = {
		Title = "🔥 POLAR EXTREME",
		CornerRadius = UDim.new(0, 8),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		Scale = 1,
        OnlyMobile = false
	}
})

local TabCombat = Window:Tab({ Title = "Combat OP", Icon = "swords" })
local TabMovement = Window:Tab({ Title = "Movimiento", Icon = "zap" })
local TabWorld = Window:Tab({ Title = "Mundo", Icon = "globe" })

-- ==================== HITBOX EXPANDER (FORZADO EN LOOP) ====================
getgenv().PolarHitboxSize = 50
getgenv().PolarHitboxEnabled = false
getgenv().PolarHitboxTarget = "Todos"

TabCombat:Toggle({
    Title = "Hitbox Expander Inmortal",
    Desc = "Fuerza el tamaño masivo 60 veces por segundo para evitar que el juego lo resetee.",
    Value = false,
    Callback = function(state) getgenv().PolarHitboxEnabled = state end
})

TabCombat:Slider({
    Title = "Tamaño (Studs)", Step = 10, Min = 10, Max = 300, Default = 50,
    Callback = function(val) getgenv().PolarHitboxSize = val end
})

TabCombat:Dropdown({
    Title = "Objetivo", Values = {"Todos", "Jugadores", "Enemigos"}, Default = "Todos",
    Callback = function(val) getgenv().PolarHitboxTarget = val end
})

RunService.RenderStepped:Connect(function()
    if getgenv().PolarHitboxEnabled then
        local size = Vector3.new(getgenv().PolarHitboxSize, getgenv().PolarHitboxSize, getgenv().PolarHitboxSize)
        
        -- Jugadores
        if getgenv().PolarHitboxTarget == "Todos" or getgenv().PolarHitboxTarget == "Jugadores" then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = size
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                    hrp.Massless = true -- Evita bugs físicos
                end
            end
        end
        
        -- Enemigos
        if getgenv().PolarHitboxTarget == "Todos" or getgenv().PolarHitboxTarget == "Enemigos" then
            for _, folder in ipairs({workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs")}) do
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        local hum = npc:FindFirstChild("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            hrp.Size = size
                            hrp.Transparency = 0.7
                            hrp.BrickColor = BrickColor.new("New Yeller")
                            hrp.Material = Enum.Material.Neon
                            hrp.CanCollide = false
                            hrp.Massless = true
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== MAGNET (BRING MOBS) ====================
getgenv().PolarMagnet = false
TabCombat:Toggle({
    Title = "Magnet Mobs (Aura Negra)",
    Desc = "Atrae a todos los enemigos a tu posición usando vulnerabilidades de Network Ownership.",
    Value = false,
    Callback = function(state) getgenv().PolarMagnet = state end
})

RunService.Heartbeat:Connect(function()
    if getgenv().PolarMagnet then
        pcall(function()
            if setsimulationradius then setsimulationradius(math.huge, math.huge)
            elseif sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
        end)
        
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if workspace:FindFirstChild("Enemies") then
            for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                local nHrp = npc:FindFirstChild("HumanoidRootPart")
                local nHum = npc:FindFirstChild("Humanoid")
                if nHrp and nHum and nHum.Health > 0 then
                    if (nHrp.Position - hrp.Position).Magnitude < 350 then
                        nHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                        nHum.PlatformStand = true
                        nHum.WalkSpeed = 0
                        nHum.JumpPower = 0
                    end
                end
            end
        end
    end
end)

-- ==================== MOVIMIENTO ====================
getgenv().PolarInfJump = false
TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Permite saltar en el aire infinitamente.",
    Value = false,
    Callback = function(state) getgenv().PolarInfJump = state end
})

UserInputService.JumpRequest:Connect(function()
    if getgenv().PolarInfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

TabMovement:Slider({
    Title = "Velocidad de Dios (WalkSpeed)", Step = 10, Min = 16, Max = 500, Default = 16,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

getgenv().PolarNoclip = false
TabMovement:Toggle({
    Title = "Noclip (Fantasma)",
    Value = false,
    Callback = function(state) getgenv().PolarNoclip = state end
})

RunService.Stepped:Connect(function()
    if getgenv().PolarNoclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ==================== SKYBASE & MUNDO ====================
local skybase = nil
TabWorld:Button({
    Title = "Spawnear Skybase (Fuerte Aéreo)",
    Callback = function()
        if not skybase then
            skybase = Instance.new("Part")
            skybase.Name = "PolarSkybase"
            skybase.Size = Vector3.new(1000, 10, 1000)
            skybase.Position = Vector3.new(0, 100000, 0)
            skybase.Anchored = true
            skybase.BrickColor = BrickColor.new("Dark stone grey")
            skybase.Material = Enum.Material.ForceField
            skybase.Parent = workspace
            WindUI:Notify({Title = "Skybase Creada", Content = "Isla a 100,000 studs.", Duration = 3})
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0, 100010, 0) end
    end
})

Window:SelectTab(1)

