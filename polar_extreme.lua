-- POLAR EXTREME (God Mode)
-- Script diseñado para romper los límites del juego
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== WIND UI LIBRARY ====================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Error: No se pudo cargar WindUI.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "🔥 POLAR EXTREME | GOD MODE",
    Icon = "skull",
    Folder = "PolarExtreme",
    Size = UDim2.fromOffset(580, 460),
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

local TabExploits = Window:Tab({
    Title = "Exploits Extremos",
    Icon = "flame"
})

-- ==================== HITBOX EXPANDER ====================
getgenv().PolarHitboxSize = 50
getgenv().PolarHitboxEnabled = false
getgenv().PolarHitboxTarget = "Todos" -- Todos, Jugadores, Enemigos

TabExploits:Toggle({
    Title = "Hitbox Expander (Extremo)",
    Desc = "Aumenta el tamaño de la hitbox masivamente para golpear desde lejos.",
    Value = false,
    Callback = function(state)
        getgenv().PolarHitboxEnabled = state
    end
})

TabExploits:Slider({
    Title = "Tamaño de Hitbox",
    Step = 10,
    Min = 10,
    Max = 300,
    Default = 50,
    Callback = function(val)
        getgenv().PolarHitboxSize = val
    end
})

TabExploits:Dropdown({
    Title = "Objetivo de Hitbox",
    Values = {"Todos", "Jugadores", "Enemigos"},
    Default = "Todos",
    Callback = function(val)
        getgenv().PolarHitboxTarget = val
    end
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().PolarHitboxEnabled then
            -- Expandir Jugadores
            if getgenv().PolarHitboxTarget == "Todos" or getgenv().PolarHitboxTarget == "Jugadores" then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(getgenv().PolarHitboxSize, getgenv().PolarHitboxSize, getgenv().PolarHitboxSize)
                        hrp.Transparency = 0.6
                        hrp.BrickColor = BrickColor.new("Really red")
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end
            end
            
            -- Expandir Enemigos
            if getgenv().PolarHitboxTarget == "Todos" or getgenv().PolarHitboxTarget == "Enemigos" then
                for _, folder in ipairs({workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs")}) do
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            local hrp = npc:FindFirstChild("HumanoidRootPart")
                            local hum = npc:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                hrp.Size = Vector3.new(getgenv().PolarHitboxSize, getgenv().PolarHitboxSize, getgenv().PolarHitboxSize)
                                hrp.Transparency = 0.6
                                hrp.BrickColor = BrickColor.new("New Yeller")
                                hrp.Material = Enum.Material.Neon
                                hrp.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== SKYBASE SPAWNER ====================
local skybase = nil
TabExploits:Button({
    Title = "Spawnear Skybase (Isla Privada)",
    Desc = "Genera una isla flotante masiva a 10,000 studs de altura y te teletransporta a ella.",
    Callback = function()
        if not skybase then
            skybase = Instance.new("Part")
            skybase.Name = "PolarSkybase"
            skybase.Size = Vector3.new(500, 10, 500)
            skybase.Position = Vector3.new(0, 10000, 0)
            skybase.Anchored = true
            skybase.BrickColor = BrickColor.new("Dark stone grey")
            skybase.Material = Enum.Material.Grass
            skybase.Parent = workspace
            
            -- Generar paredes invisibles
            local walls = {
                {Size = Vector3.new(500, 100, 5), Pos = Vector3.new(0, 10050, 250)},
                {Size = Vector3.new(500, 100, 5), Pos = Vector3.new(0, 10050, -250)},
                {Size = Vector3.new(5, 100, 500), Pos = Vector3.new(250, 10050, 0)},
                {Size = Vector3.new(5, 100, 500), Pos = Vector3.new(-250, 10050, 0)},
            }
            for _, wData in ipairs(walls) do
                local w = Instance.new("Part")
                w.Size = wData.Size
                w.Position = wData.Pos
                w.Anchored = true
                w.Transparency = 1
                w.Parent = skybase
            end
            
            WindUI:Notify({Title = "Skybase Generada", Content = "Isla privada creada exitosamente.", Duration = 3})
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, 10010, 0)
        end
    end
})

TabExploits:Button({
    Title = "Destruir Skybase",
    Callback = function()
        if skybase then
            skybase:Destroy()
            skybase = nil
            WindUI:Notify({Title = "Skybase Destruida", Content = "La isla ha sido eliminada.", Duration = 3})
        end
    end
})

-- ==================== NOCLIP & MOVEMENT ====================
getgenv().PolarNoclip = false
TabExploits:Toggle({
    Title = "Noclip (Atravesar Paredes)",
    Value = false,
    Callback = function(state)
        getgenv().PolarNoclip = state
    end
})

RunService.Stepped:Connect(function()
    if getgenv().PolarNoclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

Window:SelectTab(1)
