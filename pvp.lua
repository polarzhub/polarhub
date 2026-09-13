--[[
    ❄️ POLAR PVP LUA | SCRIPT PRINCIPAL
    Desarrollado a medida: UI Custom Obsidian-Cyan, Evasión de Speed, Dash Booster, ESP y AI Bridge.
--]]

repeat task.wait() until game:IsLoaded()

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local TargetParent = gethui and gethui() or (CoreGui:FindFirstChild("RobloxGui") or CoreGui)

-- Limpieza de ejecuciones previas
local oldUI = TargetParent:FindFirstChild("PolarPVP_UI")
if oldUI then
    oldUI:Destroy()
end

-- Variables Globales de Configuración (getgenv)
getgenv().PolarPVP = {
    -- Combat Settings
    CombatModeEnabled = false,
    SilentAimEnabled = false,
    AimLockEnabled = false,
    AimLockKey = Enum.KeyCode.E,
    AimLockSmoothness = 0.25,
    TargetMode = "Closest to Cursor", -- "Closest to Cursor" o "Manual"
    SelectedTarget = nil,
    HitboxEnabled = false,
    HitboxSizeValue = 15,
    KillAuraEnabled = false,
    BringTargetEnabled = false,
    
    -- Movement Settings
    CFrameSpeedEnabled = false,
    CFrameSpeedValue = 50,
    DashBoosterEnabled = false,
    DashMultiplier = 2.0,
    FlyEnabled = false,
    FlySpeedValue = 50,
    
    -- ESP Settings
    ESPEnabled = false,
    ESPChamsEnabled = false,
    ESPNamesEnabled = false,
    ESPHealthEnabled = false,
    ESPDistancesEnabled = false,
    
    -- Automation
    AutoSkillsEnabled = false,
    SelectedWeaponType = "Melee",
    
    -- FOV Settings
    FOVCheckEnabled = false,
    FOVRadius = 150,
    
    -- Metatable Hooks
    OriginalIndex = nil,
    OriginalNamecall = nil
}

local Config = getgenv().PolarPVP

-- ==================== MOTOR DE LIBRERÍA DE INTERFAZ GRÁFICA (POLAR UI) ====================
local PolarUI = {}
PolarUI.Theme = {
    Background = Color3.fromRGB(11, 12, 16),
    Sidebar = Color3.fromRGB(7, 8, 10),
    Container = Color3.fromRGB(14, 15, 20),
    Accent = Color3.fromRGB(69, 243, 255),       -- Cyan Brillante
    AccentDark = Color3.fromRGB(15, 75, 90),
    Text = Color3.fromRGB(240, 245, 255),
    TextMuted = Color3.fromRGB(140, 150, 170),
    Border = Color3.fromRGB(30, 35, 45),
    ControlBg = Color3.fromRGB(18, 20, 26)
}

local function tween(obj, info, props)
    if not obj then return nil end
    local t = nil
    local s = pcall(function()
        t = TweenService:Create(obj, info, props)
        t:Play()
    end)
    if not s then
        pcall(function()
            for k, v in pairs(props) do
                obj[k] = v
            end
        end)
    end
    return t
end

local function addCorner(parent, radius)
    local corner = nil
    pcall(function()
        corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = parent
    end)
    return corner
end

local function addStroke(parent, color, thickness)
    local stroke = nil
    pcall(function()
        stroke = Instance.new("UIStroke")
        stroke.Thickness = thickness or 1
        stroke.Color = color
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = parent
    end)
    return stroke
end

-- Soporte de Arrastre (Drag)
local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function PolarUI:CreateWindow(titleText)
    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PolarPVP_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = TargetParent
    Window.Screen = ScreenGui
    
    -- Main Window Frame (Frame simple para máxima compatibilidad)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 570, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -285, 0.5, -210)
    MainFrame.BackgroundColor3 = PolarUI.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Window.MainFrame = MainFrame
    
    local MainCorner = addCorner(MainFrame, 12)
    local MainStroke = addStroke(MainFrame, PolarUI.Theme.Border, 1.2)
    
    -- Left Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = PolarUI.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarRightBorder.BackgroundColor3 = PolarUI.Theme.Border
    SidebarRightBorder.BorderSizePixel = 0
    SidebarRightBorder.Parent = Sidebar
    
    -- Title/Logo inside Sidebar
    local Logo = Instance.new("TextLabel")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.BackgroundTransparency = 1
    Logo.Text = "❄️ POLAR PVP"
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 16
    Logo.TextColor3 = PolarUI.Theme.Accent
    Logo.Parent = Sidebar
    
    -- Contenedor de pestañas (Frame simple para 100% compatibilidad)
    local TabScroll = Instance.new("Frame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1, -10, 1, -80)
    TabScroll.Position = UDim2.new(0, 5, 0, 55)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.Parent = Sidebar
    
    local TabScrollLayout = Instance.new("UIListLayout")
    TabScrollLayout.Padding = UDim.new(0, 5)
    TabScrollLayout.Parent = TabScroll
    
    -- Status Bar (Footer) de conexión en Sidebar
    local StatusBar = Instance.new("TextLabel")
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(1, -10, 0, 20)
    StatusBar.Position = UDim2.new(0, 5, 1, -25)
    StatusBar.BackgroundTransparency = 1
    StatusBar.Text = "Bridge: Buscando..."
    StatusBar.Font = Enum.Font.GothamSemibold
    StatusBar.TextSize = 10
    StatusBar.TextColor3 = PolarUI.Theme.TextMuted
    StatusBar.TextXAlignment = Enum.TextXAlignment.Left
    StatusBar.Parent = Sidebar
    Window.StatusText = StatusBar
    
    -- Main Container (Derecho)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -165, 1, 0)
    Container.Position = UDim2.new(0, 165, 0, 0)
    Container.BackgroundColor3 = PolarUI.Theme.Container
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame
    Window.Container = Container
    
    -- Botón de Minimizar/Cerrar (Superior Derecho)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -28, 0, 10)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = PolarUI.Theme.TextMuted
    CloseButton.TextSize = 14
    CloseButton.ZIndex = 10
    CloseButton.Parent = MainFrame
    
    CloseButton.MouseEnter:Connect(function()
        CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
    CloseButton.MouseLeave:Connect(function()
        CloseButton.TextColor3 = PolarUI.Theme.TextMuted
    end)
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)
    
    -- Soporte para tecla de ocultar (Insert / RightControl)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    makeDraggable(MainFrame, Sidebar)
    
    -- Método de Creación de Pestaña
    function Window:CreateTab(name)
        local Tab = {
            Active = false,
            Elements = {}
        }
        
        -- Botón de Pestaña en Sidebar
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabScroll
        
        local TabBtnCorner = addCorner(TabButton, 6)
        
        local TabBtnStroke = addStroke(TabButton, PolarUI.Theme.Border, 1)
        if TabBtnStroke then TabBtnStroke.Transparency = 1 end
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -15, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 12
        TabLabel.TextColor3 = PolarUI.Theme.TextMuted
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Indicador activo (pequeña barra cyan en el botón)
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size = UDim2.new(0, 3, 0, 16)
        ActiveBar.Position = UDim2.new(0, 0, 0.5, -8)
        ActiveBar.BackgroundColor3 = PolarUI.Theme.Accent
        ActiveBar.BackgroundTransparency = 1
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Parent = TabButton
        
        -- Scrolling Frame para los Controles de esta pestaña
        local TabScrollFrame = Instance.new("ScrollingFrame")
        TabScrollFrame.Name = name .. "_Scroll"
        TabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
        TabScrollFrame.BackgroundTransparency = 1
        TabScrollFrame.BorderSizePixel = 0
        TabScrollFrame.ScrollBarThickness = 2
        TabScrollFrame.ScrollBarImageColor3 = PolarUI.Theme.Accent
        TabScrollFrame.Visible = false
        TabScrollFrame.Parent = Container
        
        local TabScrollPadding = Instance.new("UIPadding")
        TabScrollPadding.PaddingTop = UDim.new(0, 12)
        TabScrollPadding.PaddingBottom = UDim.new(0, 12)
        TabScrollPadding.PaddingLeft = UDim.new(0, 12)
        TabScrollPadding.PaddingRight = UDim.new(0, 12)
        TabScrollPadding.Parent = TabScrollFrame
        
        local TabScrollLayout = Instance.new("UIListLayout")
        TabScrollLayout.Padding = UDim.new(0, 6)
        TabScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabScrollLayout.Parent = TabScrollFrame
        
        -- Evasión de bug de AutomaticCanvasSize en ejecutores
        TabScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, TabScrollLayout.AbsoluteContentSize.Y + 24)
        end)
        
        -- Lógica de Selección de Pestaña
        local function Select()
            if Window.CurrentTab then
                local prev = Window.CurrentTab
                prev.Active = false
                prev.ScrollFrame.Visible = false
                tween(prev.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1})
                tween(prev.BtnStroke, TweenInfo.new(0.2), {Transparency = 1})
                tween(prev.Label, TweenInfo.new(0.2), {TextColor3 = PolarUI.Theme.TextMuted})
                tween(prev.Bar, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            end
            
            Tab.Active = true
            Window.CurrentTab = Tab
            TabScrollFrame.Visible = true
            tween(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(30, 45, 55)})
            tween(TabBtnStroke, TweenInfo.new(0.2), {Transparency = 0.5})
            tween(TabLabel, TweenInfo.new(0.2), {TextColor3 = PolarUI.Theme.Accent})
            tween(ActiveBar, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        end
        
        TabButton.MouseButton1Click:Connect(Select)
        
        -- Hover Effects
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                tween(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.95, BackgroundColor3 = PolarUI.Theme.Text})
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                tween(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            end
        end)
        
        Tab.Button = TabButton
        Tab.BtnStroke = TabBtnStroke
        Tab.Label = TabLabel
        Tab.Bar = ActiveBar
        Tab.ScrollFrame = TabScrollFrame
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Select()
        end
        
        -- CONTROLES DENTRO DE LA PESTAÑA
        
        -- 1. Section (Separador)
        function Tab:Section(title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = title .. "_Section"
            SectionFrame.Size = UDim2.new(1, -2, 0, 24)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabScrollFrame
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = string.upper(title)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.TextColor3 = PolarUI.Theme.Accent
            TextLabel.TextSize = 10
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = SectionFrame
            
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, -120, 0, 1)
            Line.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0.5, 0)
            Line.BackgroundColor3 = PolarUI.Theme.Border
            Line.BorderSizePixel = 0
            Line.Parent = SectionFrame
            
            TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                Line.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0.5, 0)
                Line.Size = UDim2.new(1, - (TextLabel.TextBounds.X + 25), 0, 1)
            end)
        end
        
        -- 2. Toggle (Interruptor)
        function Tab:Toggle(title, desc, default, callback)
            local ToggleVal = default or false
            
            local TFrame = Instance.new("Frame")
            TFrame.Name = title .. "_Toggle"
            TFrame.Size = UDim2.new(1, -2, 0, desc and 42 or 36)
            TFrame.BackgroundColor3 = PolarUI.Theme.ControlBg
            TFrame.Parent = TabScrollFrame
            
            local TCorner = addCorner(TFrame, 6)
            
            local TStroke = addStroke(TFrame, PolarUI.Theme.Border, 1)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -60, desc and 0.5 or 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 2)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.TextColor3 = PolarUI.Theme.Text
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = TFrame
            
            if desc then
                local DescLabel = Instance.new("TextLabel")
                DescLabel.Size = UDim2.new(1, -60, 0.5, -4)
                DescLabel.Position = UDim2.new(0, 10, 0.5, 0)
                DescLabel.BackgroundTransparency = 1
                DescLabel.Text = desc
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.TextColor3 = PolarUI.Theme.TextMuted
                DescLabel.TextSize = 10
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.Parent = TFrame
            end
            
            -- Botón de switch
            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -46, 0.5, -9)
            Switch.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
            Switch.Text = ""
            Switch.AutoButtonColor = false
            Switch.Parent = TFrame
            
            local SwitchCorner = addCorner(Switch, 9)
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Knob.BorderSizePixel = 0
            Knob.Parent = Switch
            
            local KnobCorner = addCorner(Knob, 7)
            
            local function Update()
                if ToggleVal then
                    tween(Switch, TweenInfo.new(0.15), {BackgroundColor3 = PolarUI.Theme.AccentDark})
                    tween(Knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 20, 0.5, -7), BackgroundColor3 = PolarUI.Theme.Accent})
                    tween(TStroke, TweenInfo.new(0.15), {Color = PolarUI.Theme.Accent})
                else
                    tween(Switch, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 38, 45)})
                    tween(Knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)})
                    tween(TStroke, TweenInfo.new(0.15), {Color = PolarUI.Theme.Border})
                end
            end
            
            local function Click()
                ToggleVal = not ToggleVal
                Update()
                task.spawn(function() callback(ToggleVal) end)
            end
            
            Switch.MouseButton1Click:Connect(Click)
            
            -- Detectar click en todo el panel de Toggle
            local InvisibleBtn = Instance.new("TextButton")
            InvisibleBtn.Size = UDim2.new(1, -50, 1, 0)
            InvisibleBtn.BackgroundTransparency = 1
            InvisibleBtn.Text = ""
            InvisibleBtn.Parent = TFrame
            InvisibleBtn.MouseButton1Click:Connect(Click)
            
            -- Inicializar
            Update()
            
            -- Retornar controlador externo
            local ToggleControl = {}
            function ToggleControl:Set(val)
                ToggleVal = val
                Update()
                task.spawn(function() callback(ToggleVal) end)
            end
            return ToggleControl
        end
        
        -- 3. Slider (Deslizador)
        function Tab:Slider(title, min, max, default, callback)
            local SliderVal = default or min
            
            local SFrame = Instance.new("Frame")
            SFrame.Name = title .. "_Slider"
            SFrame.Size = UDim2.new(1, -2, 0, 46)
            SFrame.BackgroundColor3 = PolarUI.Theme.ControlBg
            SFrame.Parent = TabScrollFrame
            
            local SCorner = addCorner(SFrame, 6)
            
            local SStroke = addStroke(SFrame, PolarUI.Theme.Border, 1)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.7, 0, 0, 22)
            TitleLabel.Position = UDim2.new(0, 10, 0, 2)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.TextColor3 = PolarUI.Theme.Text
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SFrame
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.3, -10, 0, 22)
            ValLabel.Position = UDim2.new(0.7, 0, 0, 2)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(SliderVal)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextColor3 = PolarUI.Theme.Accent
            ValLabel.TextSize = 12
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SFrame
            
            -- Track & Fill
            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(1, -20, 0, 4)
            Track.Position = UDim2.new(0, 10, 0, 32)
            Track.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
            Track.Text = ""
            Track.AutoButtonColor = false
            Track.Parent = SFrame
            
            local TrackCorner = addCorner(Track, 2)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((SliderVal - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = PolarUI.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local FillCorner = addCorner(Fill, 2)
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 10, 0, 10)
            Knob.Position = UDim2.new(1, -5, 0.5, -5)
            Knob.BackgroundColor3 = PolarUI.Theme.Text
            Knob.BorderSizePixel = 0
            Knob.Parent = Fill
            
            local KnobCorner = addCorner(Knob, 5)
            
            local dragging = false
            
            local function Update(inputX)
                local percentage = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local rawVal = min + (max - min) * percentage
                -- Redondear a 1 decimal
                SliderVal = math.floor(rawVal * 10 + 0.5) / 10
                if SliderVal % 1 == 0 then SliderVal = math.floor(SliderVal) end
                
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                ValLabel.Text = tostring(SliderVal)
                task.spawn(function() callback(SliderVal) end)
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input.Position.X)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input.Position.X)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        
        -- 4. Dropdown (Acordeón Desplegable con Scroll)
        function Tab:Dropdown(title, values, default, callback)
            local SelectedVal = default or (values[1] or "Ninguno")
            local DropdownExpanded = false
            
            local DFrame = Instance.new("Frame")
            DFrame.Name = title .. "_Dropdown"
            DFrame.Size = UDim2.new(1, -2, 0, 36)
            DFrame.BackgroundColor3 = PolarUI.Theme.ControlBg
            DFrame.ClipsDescendants = true
            DFrame.Parent = TabScrollFrame
            
            local DCorner = addCorner(DFrame, 6)
            
            local DStroke = addStroke(DFrame, PolarUI.Theme.Border, 1)
            
            -- Header Clickable
            local Header = Instance.new("TextButton")
            Header.Size = UDim2.new(1, 0, 0, 36)
            Header.BackgroundTransparency = 1
            Header.Text = ""
            Header.AutoButtonColor = false
            Header.Parent = DFrame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.TextColor3 = PolarUI.Theme.Text
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = Header
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.4, -25, 1, 0)
            SelectedLabel.Position = UDim2.new(0.6, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = SelectedVal
            SelectedLabel.Font = Enum.Font.GothamBold
            SelectedLabel.TextColor3 = PolarUI.Theme.Accent
            SelectedLabel.TextSize = 11
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.Parent = Header
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 18, 1, 0)
            Arrow.Position = UDim2.new(1, -22, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextColor3 = PolarUI.Theme.TextMuted
            Arrow.TextSize = 10
            Arrow.Parent = Header
            
            -- Contenedor de opciones (Scrolling Frame)
            local OptionsScroll = Instance.new("ScrollingFrame")
            OptionsScroll.Size = UDim2.new(1, -10, 0, 120)
            OptionsScroll.Position = UDim2.new(0, 5, 0, 38)
            OptionsScroll.BackgroundTransparency = 1
            OptionsScroll.BorderSizePixel = 0
            OptionsScroll.ScrollBarThickness = 2
            OptionsScroll.ScrollBarImageColor3 = PolarUI.Theme.Accent
            OptionsScroll.Parent = DFrame
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Padding = UDim.new(0, 2)
            OptionsLayout.Parent = OptionsScroll
            
            -- Evasión de bug de AutomaticCanvasSize en ejecutores
            OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 10)
            end)
            
            local function DrawOptions(list)
                -- Limpiar anteriores
                for _, child in ipairs(OptionsScroll:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for _, val in ipairs(list) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, -4, 0, 24)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    OptBtn.Parent = OptionsScroll
                    
                    local OptCorner = addCorner(OptBtn, 4)
                    
                    local OptStroke = addStroke(OptBtn, PolarUI.Theme.Border, 0.5)
                    
                    local OptLabel = Instance.new("TextLabel")
                    OptLabel.Size = UDim2.new(1, -10, 1, 0)
                    OptLabel.Position = UDim2.new(0, 8, 0, 0)
                    OptLabel.BackgroundTransparency = 1
                    OptLabel.Text = tostring(val)
                    OptLabel.Font = Enum.Font.GothamMedium
                    OptLabel.TextSize = 11
                    OptLabel.TextColor3 = (val == SelectedVal) and PolarUI.Theme.Accent or PolarUI.Theme.Text
                    OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptLabel.Parent = OptBtn
                    
                    OptBtn.MouseEnter:Connect(function()
                        tween(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 36, 48)})
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        tween(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 27, 35)})
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedVal = val
                        SelectedLabel.Text = tostring(val)
                        
                        -- Colorear activo
                        for _, sibling in ipairs(OptionsScroll:GetChildren()) do
                            if sibling:IsA("TextButton") and sibling:FindFirstChild("TextLabel") then
                                sibling.TextLabel.TextColor3 = (sibling.TextLabel.Text == tostring(val)) and PolarUI.Theme.Accent or PolarUI.Theme.Text
                            end
                        end
                        
                        -- Colapsar
                        DropdownExpanded = false
                        tween(DFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -2, 0, 36)})
                        Arrow.Text = "▼"
                        
                        task.spawn(function() callback(val) end)
                    end)
                end
            end
            
            DrawOptions(values)
            
            -- Toggle de expansión
            Header.MouseButton1Click:Connect(function()
                DropdownExpanded = not DropdownExpanded
                if DropdownExpanded then
                    local expHeight = 36 + math.min(#values * 26 + 10, 130)
                    tween(DFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -2, 0, expHeight)})
                    Arrow.Text = "▲"
                else
                    tween(DFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -2, 0, 36)})
                    Arrow.Text = "▼"
                end
            end)
            
            -- Controlador de Dropdown externo para actualización dinámica
            local DropdownControl = {}
            function DropdownControl:SetValues(newList)
                values = newList
                DrawOptions(newList)
                if not table.find(newList, SelectedVal) then
                    SelectedVal = newList[1] or "Ninguno"
                    SelectedLabel.Text = SelectedVal
                end
            end
            function DropdownControl:Refresh(newList)
                self:SetValues(newList)
            end
            function DropdownControl:UpdateValues(newList)
                self:SetValues(newList)
            end
            function DropdownControl:Set(data)
                if data and data.Values then
                    self:SetValues(data.Values)
                end
            end
            return DropdownControl
        end
        
        -- 5. Button (Botón ejecutor)
        function Tab:Button(title, callback)
            local BFrame = Instance.new("Frame")
            BFrame.Name = title .. "_BtnFrame"
            BFrame.Size = UDim2.new(1, -2, 0, 36)
            BFrame.BackgroundColor3 = PolarUI.Theme.ControlBg
            BFrame.Parent = TabScrollFrame
            
            local BCorner = addCorner(BFrame, 6)
            
            local BStroke = addStroke(BFrame, PolarUI.Theme.Border, 1)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = title
            Btn.Font = Enum.Font.GothamBold
            Btn.TextColor3 = PolarUI.Theme.Text
            Btn.TextSize = 12
            Btn.Parent = BFrame
            
            Btn.MouseEnter:Connect(function()
                tween(BFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 30, 40)})
                tween(BStroke, TweenInfo.new(0.2), {Color = PolarUI.Theme.Accent})
            end)
            
            Btn.MouseLeave:Connect(function()
                tween(BFrame, TweenInfo.new(0.2), {BackgroundColor3 = PolarUI.Theme.ControlBg})
                tween(BStroke, TweenInfo.new(0.2), {Color = PolarUI.Theme.Border})
            end)
            
            Btn.MouseButton1Click:Connect(function()
                -- Efecto rebote rápido en click
                BFrame.Size = UDim2.new(1, -6, 0, 34)
                task.wait(0.05)
                BFrame.Size = UDim2.new(1, -2, 0, 36)
                task.spawn(callback)
            end)
        end
        
        -- 6. Keybind (Enlace de tecla física)
        function Tab:Keybind(title, default, callback)
            local CurrentKey = default
            local Listening = false
            
            local KFrame = Instance.new("Frame")
            KFrame.Name = title .. "_Keybind"
            KFrame.Size = UDim2.new(1, -2, 0, 36)
            KFrame.BackgroundColor3 = PolarUI.Theme.ControlBg
            KFrame.Parent = TabScrollFrame
            
            local KCorner = addCorner(KFrame, 6)
            
            local KStroke = addStroke(KFrame, PolarUI.Theme.Border, 1)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.TextColor3 = PolarUI.Theme.Text
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = KFrame
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 60, 0, 20)
            BindBtn.Position = UDim2.new(1, -70, 0.5, -10)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 42)
            BindBtn.Text = CurrentKey and CurrentKey.Name or "..."
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextColor3 = PolarUI.Theme.Accent
            BindBtn.TextSize = 10
            BindBtn.Parent = KFrame
            
            local BindCorner = addCorner(BindBtn, 4)
            
            BindBtn.MouseButton1Click:Connect(function()
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if Listening then
                    Listening = false
                    if input.KeyCode ~= Enum.KeyCode.Escape then
                        CurrentKey = input.KeyCode
                        BindBtn.Text = input.KeyCode.Name
                    else
                        CurrentKey = nil
                        BindBtn.Text = "Nulo"
                    end
                    BindBtn.TextColor3 = PolarUI.Theme.Accent
                    task.spawn(function() callback(CurrentKey) end)
                end
            end)
        end
        
        -- 7. Paragraph (Cuadro Informativo dinámico)
        function Tab:Paragraph(title, desc)
            local PFrame = Instance.new("Frame")
            PFrame.Name = title .. "_Paragraph"
            PFrame.Size = UDim2.new(1, -2, 0, 56)
            PFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
            PFrame.Parent = TabScrollFrame
            
            local PCorner = addCorner(PFrame, 6)
            
            local PStroke = addStroke(PFrame, PolarUI.Theme.Border, 0.8)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -20, 0, 20)
            TitleLabel.Position = UDim2.new(0, 10, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextColor3 = PolarUI.Theme.Accent
            TitleLabel.TextSize = 11
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = PFrame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, -20, 1, -24)
            DescLabel.Position = UDim2.new(0, 10, 0, 20)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = desc
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = PolarUI.Theme.TextMuted
            DescLabel.TextSize = 10
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextYAlignment = Enum.TextYAlignment.Top
            DescLabel.TextWrapped = true
            DescLabel.Parent = PFrame
            
            local ParagraphControl = {}
            function ParagraphControl:SetDesc(newDesc)
                DescLabel.Text = newDesc
            end
            function ParagraphControl:Set(data)
                if data and data.Desc then
                    DescLabel.Text = data.Desc
                end
            end
            return ParagraphControl
        end
        
        return Tab
    end
    
    return Window
end

-- ==================== INICIALIZAR UI POLAR PVP ====================
local Window = PolarUI:CreateWindow("❄️ POLAR PVP | PRO")
local TabCombat = Window:CreateTab("🎯 Combate")
local TabMovement = Window:CreateTab("⚡ Movimiento")
local TabVisuals = Window:CreateTab("👁️ Visuales")
local TabAutomation = Window:CreateTab("⚔️ Auto Combos")

-- ==================== SECCIÓN DE COMBATE (LÓGICA PVP) ====================

local SelectedTarget = nil

TabCombat:Section("⚡ Modo Combate (Master Switch)")

TabCombat:Toggle("Activar Combate", "Gatea Hitbox y Aimbot para eliminar lag si no estás peleando.", false, function(v)
    Config.CombatModeEnabled = v
end)

TabCombat:Section("Aimbot & Hitbox")

local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = PolarUI.Theme.Accent
    FOVCircle.Thickness = 1.2
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Config.FOVRadius
    FOVCircle.Filled = false
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        pcall(function()
            if FOVCircle.Visible then
                FOVCircle.Position = UserInputService:GetMouseLocation()
            end
        end)
    end
end)

TabCombat:Toggle("Silent Aim (Aimbot)", "Redirige Mouse.Hit y habilidades al objetivo seleccionado.", false, function(v)
    Config.SilentAimEnabled = v
end)

TabCombat:Toggle("Mostrar Círculo FOV", "Ver el rango límite para el auto-apuntado.", false, function(v)
    Config.FOVCheckEnabled = v
    if FOVCircle then
        pcall(function() FOVCircle.Visible = v end)
    end
end)

TabCombat:Slider("Radio de FOV", 50, 400, Config.FOVRadius, function(v)
    Config.FOVRadius = v
    if FOVCircle then
        pcall(function() FOVCircle.Radius = v end)
    end
end)

TabCombat:Toggle("Activar Hitbox Expander", "Aumenta la caja de colisión del enemigo (Neon Rojo).", false, function(v)
    Config.HitboxEnabled = v
    if not v then
        -- Restaurar
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function()
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    p.Character.HumanoidRootPart.Transparency = 1
                    p.Character.HumanoidRootPart.CanCollide = true
                    p.Character.HumanoidRootPart.Material = Enum.Material.Plastic
                end
            end)
        end
    end
end)

TabCombat:Slider("Tamaño de Hitbox", 5, 40, Config.HitboxSizeValue, function(v)
    Config.HitboxSizeValue = v
end)

-- Bucle de Hitbox Expander
local lastHitboxUpdate = 0
RunService.Heartbeat:Connect(function()
    if Config.CombatModeEnabled and Config.HitboxEnabled and tick() - lastHitboxUpdate > 0.05 then
        lastHitboxUpdate = tick()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(Config.HitboxSizeValue, Config.HitboxSizeValue, Config.HitboxSizeValue)
                    hrp.Transparency = 0.6
                    hrp.Color = Color3.fromRGB(255, 0, 50)
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end)
            end
        end
    end
end)

TabCombat:Section("Bounty Hunter Tracker (Selección)")

local TargetModeDropdown = TabCombat:Dropdown("Modo de Objetivo", {"Closest to Cursor", "Manual"}, "Closest to Cursor", function(v)
    Config.TargetMode = v
end)

local PlayerDropdown = TabCombat:Dropdown("Seleccionar Víctima", {"Auto"}, "Auto", function(v)
    if v ~= "Auto" then
        SelectedTarget = Players:FindFirstChild(v)
    else
        SelectedTarget = nil
    end
    Config.SelectedTarget = SelectedTarget
end)

local function RefreshPlayerList()
    local list = {"Auto"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    pcall(function()
        PlayerDropdown:Refresh(list)
    end)
end

task.delay(1, RefreshPlayerList)
Players.PlayerAdded:Connect(function() task.delay(1, RefreshPlayerList) end)
Players.PlayerRemoving:Connect(function(p)
    if SelectedTarget == p then SelectedTarget = nil Config.SelectedTarget = nil end
    task.delay(0.5, RefreshPlayerList)
end)

TabCombat:Button("Actualizar Jugadores del Servidor", RefreshPlayerList)

local LabelTargetInfo = TabCombat:Paragraph("Inspección Táctica (Víctima)", "Selecciona un objetivo para inspeccionar...")

-- Buscador del jugador más cercano al cursor (dentro del FOV si está activo)
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local cam = workspace.CurrentCamera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDistance then
                    if not Config.FOVCheckEnabled or dist < Config.FOVRadius then
                        shortestDistance = dist
                        closestPlayer = p
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Bucle de Inspección y Auto-Target
task.spawn(function()
    while task.wait(0.5) do
        -- Auto Target closest to cursor si está en ese modo
        if Config.TargetMode == "Closest to Cursor" then
            SelectedTarget = GetClosestPlayerToCursor()
            Config.SelectedTarget = SelectedTarget
        end
        
        if SelectedTarget and SelectedTarget.Parent and SelectedTarget.Character then
            local bounty = "Oculto"
            pcall(function()
                local data = SelectedTarget:FindFirstChild("Data")
                if data and data:FindFirstChild("Bounty") then
                    bounty = tostring(math.floor(data.Bounty.Value / 1000) / 1000) .. "M"
                elseif SelectedTarget:FindFirstChild("leaderstats") and SelectedTarget.leaderstats:FindFirstChild("Bounty") then
                    bounty = tostring(math.floor(SelectedTarget.leaderstats.Bounty.Value / 1000) / 1000) .. "M"
                end
            end)
            
            local health = "0/0"
            pcall(function()
                local hum = SelectedTarget.Character:FindFirstChild("Humanoid")
                if hum then
                    health = tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth))
                end
            end)
            
            local fruit = "Ninguna"
            pcall(function()
                local data = SelectedTarget:FindFirstChild("Data")
                if data and data:FindFirstChild("BloxFruit") and data.BloxFruit.Value ~= "" then
                    fruit = data.BloxFruit.Value
                end
            end)
            
            local info = string.format("🎯 Objetivo: %s\n❤️ Vida: %s\n💰 Bounty: %s\n🍎 Fruta: %s\n📏 Distancia: %d studs", 
                SelectedTarget.Name, health, bounty, fruit, 
                math.floor((SelectedTarget.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude))
            
            LabelTargetInfo:SetDesc(info)
        else
            LabelTargetInfo:SetDesc("Buscando objetivo válido en rango...")
        end
    end
end)

TabCombat:Section("Combate Avanzado")

TabCombat:Toggle("Atraer Víctima (Bring Target)", "Mantiene a tu víctima frente a ti. Combo mortal con Silent Aim.", false, function(v)
    Config.BringTargetEnabled = v
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        if Config.CombatModeEnabled and Config.BringTargetEnabled and SelectedTarget and SelectedTarget.Character then
            pcall(function()
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local enemyHrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and enemyHrp then
                    enemyHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -4.5)
                    enemyHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    end
end)

TabCombat:Button("Teletransportar al Objetivo", function()
    if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
        end)
    end
end)

-- Metatable Hooks de Silent Aim
-- Intercepta el Mouse del Cliente y los Eventos Remotos
pcall(function()
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller or checkcaller() then
            return OldIndex(self, key)
        end
        if Config.CombatModeEnabled and Config.SilentAimEnabled and SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            if key == "Hit" and self == LocalPlayer:GetMouse() then
                return SelectedTarget.Character.HumanoidRootPart.CFrame
            elseif key == "Target" and self == LocalPlayer:GetMouse() then
                return SelectedTarget.Character.HumanoidRootPart
            end
        end
        return OldIndex(self, key)
    end))
    Config.OriginalIndex = OldIndex
end)

pcall(function()
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not checkcaller or checkcaller() then
            return OldNamecall(self, ...)
        end
        
        local method = getnamecallmethod()
        if Config.CombatModeEnabled and Config.SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
            local name = self.Name
            local isCombatRemote = false
            
            -- Detectar remotos de combate comunes por nombre o parent
            if string.find(string.lower(name), "hit") or string.find(string.lower(name), "attack") or string.find(string.lower(name), "damage") or string.find(string.lower(name), "shoot") then
                isCombatRemote = true
            elseif self.Parent and (self.Parent.Name == "Net" or self.Parent.Name == "Remotes") then
                isCombatRemote = true
            end
            
            if isCombatRemote and SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = SelectedTarget.Character.HumanoidRootPart
                local args = {...}
                for i, arg in pairs(args) do
                    if typeof(arg) == "CFrame" then
                        args[i] = targetHrp.CFrame
                    elseif typeof(arg) == "Vector3" then
                        args[i] = targetHrp.Position
                    end
                end
                return OldNamecall(self, unpack(args))
            end
        end
        
        return OldNamecall(self, ...)
    end))
    Config.OriginalNamecall = OldNamecall
end)

-- AimLock (Rotación de Cámara)
local AimLockActive = false
TabCombat:Toggle("Aim Lock (Cam Snap)", "Rota la cámara automáticamente hacia el objetivo.", false, function(v)
    Config.AimLockEnabled = v
end)

TabCombat:Keybind("Tecla Aim Lock", Config.AimLockKey, function(key)
    Config.AimLockKey = key
end)

TabCombat:Slider("Suavidad de Aim Lock", 0.05, 1.0, Config.AimLockSmoothness, function(v)
    Config.AimLockSmoothness = v
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Config.AimLockEnabled and input.KeyCode == Config.AimLockKey then
        AimLockActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.AimLockKey then
        AimLockActive = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.AimLockEnabled and AimLockActive and SelectedTarget and SelectedTarget.Character then
        local head = SelectedTarget.Character:FindFirstChild("Head")
        local cam = workspace.CurrentCamera
        if head and cam then
            local lookCF = CFrame.new(cam.CFrame.Position, head.Position)
            cam.CFrame = cam.CFrame:Lerp(lookCF, Config.AimLockSmoothness) head = head
        end
    end
end)


-- ==================== SECCIÓN DE MOVIMIENTO (EVASIÓN Y BYPASS) ====================

TabMovement:Section("Evasión de Velocidad (Speed Hack)")

TabMovement:Toggle("Activar CFrame Speed", "Mueve el personaje en tiempo real sin modificar WalkSpeed (Anti-Cheat Safe).", false, function(v)
    Config.CFrameSpeedEnabled = v
end)

TabMovement:Slider("Velocidad de Movimiento", 16, 200, Config.CFrameSpeedValue, function(v)
    Config.CFrameSpeedValue = v
end)

RunService.Heartbeat:Connect(function(dt)
    if Config.CFrameSpeedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Config.CFrameSpeedValue * dt))
        end
    end
end)

TabMovement:Section("Dash Booster (Impulsor Q)")

TabMovement:Toggle("Dash Booster", "Aumenta la distancia de tu Dash e ignora su cooldown.", false, function(v)
    Config.DashBoosterEnabled = v
end)

TabMovement:Slider("Multiplicador de Dash", 1.0, 5.0, Config.DashMultiplier, function(v)
    Config.DashMultiplier = v
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Config.DashBoosterEnabled and input.KeyCode == Enum.KeyCode.Q then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            task.wait(0.02)
            local dir = hum.MoveDirection
            if dir.Magnitude == 0 then
                dir = hrp.CFrame.LookVector
            end
            -- Teleport adelante multiplicando por 16 studs
            hrp.CFrame = hrp.CFrame + (dir * (16 * Config.DashMultiplier))
        end
    end
end)

TabMovement:Section("Modo Fly (Vuelo WASD)")

local flyBV = nil
local flyBG = nil

local function ToggleFly(v)
    Config.FlyEnabled = v
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if v and hrp then
        if hrp:FindFirstChild("PolarPVP_FlyBV") then hrp.PolarPVP_FlyBV:Destroy() end
        if hrp:FindFirstChild("PolarPVP_FlyBG") then hrp.PolarPVP_FlyBG:Destroy() end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "PolarPVP_FlyBV"
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0,0,0)
        flyBV.Parent = hrp
        
        flyBG = Instance.new("BodyGyro")
        flyBG.Name = "PolarPVP_FlyBG"
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.D = 10
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
    else
        if hrp then
            local bv = hrp:FindFirstChild("PolarPVP_FlyBV")
            local bg = hrp:FindFirstChild("PolarPVP_FlyBG")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        flyBV = nil
        flyBG = nil
    end
end

TabMovement:Toggle("Vuelo WASD", "Vuela en dirección de tu cámara.", false, ToggleFly)
TabMovement:Slider("Velocidad de Vuelo", 20, 300, Config.FlySpeedValue, function(v)
    Config.FlySpeedValue = v
end)

RunService.RenderStepped:Connect(function()
    if Config.FlyEnabled and flyBV and flyBG then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dir = Vector3.new()
            local cam = workspace.CurrentCamera
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            
            flyBV.Velocity = dir * Config.FlySpeedValue
            flyBG.CFrame = cam.CFrame
        end
    end
end)


-- ==================== SECCIÓN DE VISUALES (ESP) ====================

TabVisuals:Section("Visuales Extracheat (ESP)")

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                -- Chams Highlight
                local highlight = char:FindFirstChild("PolarPVP_Highlight")
                if Config.ESPEnabled and Config.ESPChamsEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "PolarPVP_Highlight"
                        highlight.FillColor = PolarUI.Theme.Accent
                        highlight.OutlineColor = PolarUI.Theme.Accent
                        highlight.FillTransparency = 0.7
                        highlight.OutlineTransparency = 0.2
                        highlight.Adornee = char
                        highlight.Parent = char
                    end
                else
                    if highlight then highlight:Destroy() end
                end
                
                -- Billboard Nametags
                local head = char:FindFirstChild("Head")
                if head then
                    local billboard = head:FindFirstChild("PolarPVP_Billboard")
                    if Config.ESPEnabled and (Config.ESPNamesEnabled or Config.ESPHealthEnabled or Config.ESPDistancesEnabled) then
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "PolarPVP_Billboard"
                            billboard.Size = UDim2.new(0, 180, 0, 40)
                            billboard.AlwaysOnTop = true
                            billboard.Adornee = head
                            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                            
                            local label = Instance.new("TextLabel")
                            label.Name = "Tag"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = PolarUI.Theme.Text
                            label.TextStrokeTransparency = 0.2
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 9
                            label.Parent = billboard
                            
                            billboard.Parent = head
                        end
                        
                        -- Actualizar información
                        local text = ""
                        if Config.ESPNamesEnabled then
                            text = text .. p.Name
                        end
                        if Config.ESPHealthEnabled then
                            local hum = char:FindFirstChild("Humanoid")
                            if hum then
                                text = text .. " [" .. tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth)) .. " HP]"
                            end
                        end
                        if Config.ESPDistancesEnabled then
                            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local hisHrp = char:FindFirstChild("HumanoidRootPart")
                            if myHrp and hisHrp then
                                local dist = math.floor((myHrp.Position - hisHrp.Position).Magnitude)
                                text = text .. " (" .. tostring(dist) .. "m)"
                            end
                        end
                        billboard.Tag.Text = text
                    else
                        if billboard then billboard:Destroy() end
                    end
                end
            end
        end
    end
end

TabVisuals:Toggle("Activar ESP Maestro", "Habilitar renderizado de información en pantalla.", false, function(v)
    Config.ESPEnabled = v
    UpdateESP()
end)

TabVisuals:Toggle("ESP Chams (Paredes)", "Resalta el cuerpo del enemigo detrás de los objetos.", false, function(v)
    Config.ESPChamsEnabled = v
    UpdateESP()
end)

TabVisuals:Toggle("Mostrar Nombres", "Muestra el nombre del jugador.", false, function(v)
    Config.ESPNamesEnabled = v
    UpdateESP()
end)

TabVisuals:Toggle("Mostrar Salud", "Muestra barra/números de vida del jugador.", false, function(v)
    Config.ESPHealthEnabled = v
    UpdateESP()
end)

TabVisuals:Toggle("Mostrar Distancias", "Muestra la distancia de separación.", false, function(v)
    Config.ESPDistancesEnabled = v
    UpdateESP()
end)

-- Bucle de ESP
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.ESPEnabled then
            pcall(UpdateESP)
        end
    end
end)


-- ==================== SECCIÓN DE AUTOMATIZACIÓN (COMBOS) ====================

TabAutomation:Section("Auto-Combo de Habilidades")

TabAutomation:Toggle("Auto Skills en Objetivo", "Activa el spam inteligente de Z, X, C, V al estar cerca del objetivo.", false, function(v)
    Config.AutoSkillsEnabled = v
end)

TabAutomation:Dropdown("Arma de Combate", {"Melee", "Sword", "Blox Fruit", "Gun"}, "Melee", function(v)
    Config.SelectedWeaponType = v
end)

-- Bucle de combo automático
task.spawn(function()
    while true do
        task.wait(0.25)
        if Config.CombatModeEnabled and Config.AutoSkillsEnabled and SelectedTarget and SelectedTarget.Character then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            if myHrp and targetHrp and (targetHrp.Position - myHrp.Position).Magnitude < 40 then
                -- Auto equipar
                pcall(function()
                    local bp = LocalPlayer.Backpack
                    local char = LocalPlayer.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    local tool = nil
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and t.ToolTip == Config.SelectedWeaponType then
                            tool = t
                            break
                        end
                    end
                    if not tool then
                        for _, t in ipairs(char:GetChildren()) do
                            if t:IsA("Tool") and t.ToolTip == Config.SelectedWeaponType then
                                tool = t
                                break
                            end
                        end
                    end
                    
                    if tool and tool.Parent == bp and hum then
                        hum:EquipTool(tool)
                    end
                end)
                
                -- Ejecutar skills
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:SetKeyDown("Z") task.wait(0.05) VirtualUser:SetKeyUp("Z")
                    VirtualUser:SetKeyDown("X") task.wait(0.05) VirtualUser:SetKeyUp("X")
                    VirtualUser:SetKeyDown("C") task.wait(0.05) VirtualUser:SetKeyUp("C")
                    VirtualUser:SetKeyDown("V") task.wait(0.05) VirtualUser:SetKeyUp("V")
                end)
            end
        end
    end
end)


-- ==================== INTEGRACIÓN CON AI BRIDGE (LOCAL SERVER) ====================

local function StartBridge()
    local LogService = game:GetService("LogService")
    local request_func = (http_request or request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
    
    if not request_func then
        Window.StatusText.Text = "Bridge: Ejecutor no compatible"
        Window.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    Window.StatusText.Text = "Bridge: Servidor Conectado"
    Window.StatusText.TextColor3 = PolarUI.Theme.Accent
    
    -- Puente de Logs en tiempo real
    LogService.MessageOut:Connect(function(message, messageType)
        pcall(function()
            request_func({
                Url = "http://127.0.0.1:3000/log",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    message = message,
                    type = tostring(messageType)
                })
            })
        end)
    end)
    
    -- Bucle de Evaluación de Comandos
    task.spawn(function()
        while true do
            task.wait(1.5)
            pcall(function()
                local response = request_func({
                    Url = "http://127.0.0.1:3000/eval",
                    Method = "GET"
                })
                if response and response.StatusCode == 200 and response.Body and response.Body ~= "" and response.Body ~= "NO_COMMAND" then
                    local code = response.Body
                    print("📥 [Polar Hub AI] Recibido comando remoto para ejecutar...")
                    
                    local fn, err = loadstring(code)
                    if not fn then
                        warn("❌ Error de compilación en comando remoto: " .. tostring(err))
                        request_func({
                            Url = "http://127.0.0.1:3000/eval_result",
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({
                                success = false,
                                error = "Compilation error: " .. tostring(err)
                            })
                        })
                    else
                        local success, run_err = pcall(fn)
                        if not success then
                            warn("❌ Error de ejecución en comando remoto: " .. tostring(run_err))
                            request_func({
                                Url = "http://127.0.0.1:3000/eval_result",
                                Method = "POST",
                                Headers = { ["Content-Type"] = "application/json" },
                                Body = HttpService:JSONEncode({
                                    success = false,
                                    error = "Runtime error: " .. tostring(run_err)
                                })
                            })
                        else
                            print("✅ Comando remoto ejecutado con éxito.")
                            request_func({
                                Url = "http://127.0.0.1:3000/eval_result",
                                Method = "POST",
                                Headers = { ["Content-Type"] = "application/json" },
                                Body = HttpService:JSONEncode({
                                    success = true,
                                    result = "Executed successfully"
                                })
                            })
                        end
                    end
                end
            end)
        end
    end)
end

-- Iniciar conexión con el bridge en segundo plano
task.spawn(StartBridge)

-- Función de limpieza global si se recarga el script
_G.PolarPVPCleanup = function()
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() FOVCircle:Remove() end)
    pcall(function()
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end)
    -- Restaurar metatablas
    pcall(function()
        if Config.OriginalIndex then
            hookmetamethod(game, "__index", Config.OriginalIndex)
        end
        if Config.OriginalNamecall then
            hookmetamethod(game, "__namecall", Config.OriginalNamecall)
        end
    end)
    print("❄️ Polar PVP: Cleanup completado.")
end

print("✅ Polar PVP: Script cargado con éxito en el cliente.")
