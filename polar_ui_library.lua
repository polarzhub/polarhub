--[[
    ========================================================================
    [POLAR HUB MASTER UI ENGINE]
    Pixel-Perfect Quantum Onyx Architecture for Polar Hub (1:1 Visual Protocol)
    ========================================================================
    - Window Base: 510x330 px, #0A0A0A (Trans 0.05), Corner 10px, Borderless
    - UIScale: 1.15 (115% scaling for authentic sizing & crisp typography)
    - Typography: 100% GothamBold (titles, controls, badges, tabs) & Gotham (descriptions)
    - CyberGradient: #3C145A -> #5A2882 -> #3C3CA0 -> #2864BE -> #1E8CC8
    - Outlines: UIStroke restricted exclusively to authentic elements (badges, tracks, pill buttons)
    - Rogue Borders: BorderSizePixel = 0 & ScrollBarImageTransparency = 1 on all containers
    - Floating Toggle: 60x60 Circle at {0.016, 0}, {0.219, 0}
    - 2-Column Responsive Section Architecture with flanking 60-deg cyber lines
    - Full Drop-in Replacement API for redzlib: MakeWindow, MakeTab, AddSection,
      AddToggle, AddSlider, AddDropdown, AddButton, AddParagraph, AddTextBox.
    ========================================================================
]]--

local PolarUI = {}
PolarUI.__index = PolarUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Theme Color Tokens
local Theme = {
    WindowBase   = Color3.fromRGB(10, 10, 10),      -- #0A0A0A (Trans 0.05)
    InnerCard    = Color3.fromRGB(25, 25, 25),       -- #191919 (Trans 0.30)
    ControlRow   = Color3.fromRGB(5, 5, 5),         -- #050505 (Trans 0.40)
    PillBadge    = Color3.fromRGB(12, 12, 18),      -- #0C0C12
    SearchBase   = Color3.fromRGB(22, 17, 34),      -- #161122 (Trans 0.40)
    ModalBase    = Color3.fromRGB(11, 8, 18),       -- #0B0812
    
    Accent       = Color3.fromRGB(192, 132, 252),   -- #C084FC (Primary Violet Bloom)
    AccentGlow   = Color3.fromRGB(160, 100, 255),   -- #A064FF
    AccentDeep   = Color3.fromRGB(110, 55, 190),    -- #6E37BE
    AccentStroke = Color3.fromRGB(160, 100, 240),   -- #A064F0 (Vivid Purple Outline)
    BadgeStroke  = Color3.fromRGB(192, 132, 252),   -- #C084FC (Bright Badge Outline)
    TrackStroke  = Color3.fromRGB(140, 90, 220),    -- #8C5ADC (Slider Track Outline)
    
    SwitchOff    = Color3.fromRGB(15, 15, 15),      -- #0F0F0F
    SwitchOn     = Color3.fromRGB(15, 15, 15),      -- #0F0F0F
    
    TextWhite    = Color3.fromRGB(255, 255, 255),
    TextLight    = Color3.fromRGB(220, 220, 230),   -- #DCDCE6
    TextDim      = Color3.fromRGB(210, 210, 220),   -- #D2D2DC
    TextMuted    = Color3.fromRGB(120, 120, 120),   -- #787878
    TextDesc     = Color3.fromRGB(130, 130, 145),   -- #828291
    TextTabOff   = Color3.fromRGB(130, 120, 155)    -- #82789B
}

-- 5-Color Cyber Gradient Sequence (#3C145A -> #5A2882 -> #3C3CA0 -> #2864BE -> #1E8CC8)
local CyberGradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(60, 20, 90)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90, 40, 130)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(60, 60, 160)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(40, 100, 190)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 140, 200))
})

-- Lavender Fill Gradient (#8B5CF6 -> #D8B4FE)
local LavenderGradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(216, 180, 254))
})

-- Authentic Tab Underline Gradient (#A064FF -> #5A28B4)
local UnderlineGradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(160, 100, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 40, 180))
})

-- Built-in Theme Registry for backwards compatibility with redzlib calls
PolarUI.Themes = {
    ["Polar Ice"] = Theme,
    ["Liquid Glass"] = Theme,
    ["Blizzard"] = Theme,
    ["Arctic Aurora"] = Theme,
    ["Cyberpunk Neon"] = Theme,
    ["Midnight Violet"] = Theme,
    ["Darker"] = Theme,
    ["Dark"] = Theme,
    ["Purple"] = Theme
}

-- Global Icon and Tab Width Map
local TabMeta = {
    ["Farm"]         = { icon = "rbxassetid://88050097561287",  width = 68 },
    ["Quest Farm"]   = { icon = "rbxassetid://88173691221304",  width = 105 },
    ["Stats"]        = { icon = "rbxassetid://83474083071373",  width = 68 },
    ["Status"]       = { icon = "rbxassetid://130439434919073", width = 74 },
    ["Shop"]         = { icon = "rbxassetid://137995400175306", width = 68 },
    ["Teleport"]     = { icon = "rbxassetid://125480398387209", width = 84 },
    ["Combat PvP"]   = { icon = "rbxassetid://102173201308116", width = 110 },
    ["Server Hop"]   = { icon = "rbxassetid://82115431450716",  width = 105 },
    ["Misc"]         = { icon = "rbxassetid://137985950260873", width = 65 },
    ["Sea Event"]    = { icon = "rbxassetid://115481449706054", width = 93 },
    ["Dungeon"]      = { icon = "rbxassetid://104575804564229", width = 88 },
    ["Trials"]       = { icon = "rbxassetid://138575837887336", width = 68 }
}

-- Library Scale & State
PolarUI.CurrentScale = 1.15
PolarUI.ActiveWindows = {}

function PolarUI:SetScale(scaleVal)
    if type(scaleVal) == "number" then
        if scaleVal > 100 then
            local scaleMap = {
                [950] = 0.95,
                [800] = 1.05,
                [650] = 1.15,
                [500] = 1.25
            }
            PolarUI.CurrentScale = scaleMap[scaleVal] or (1.15 * (650 / scaleVal))
        else
            PolarUI.CurrentScale = math.clamp(scaleVal, 0.75, 1.45)
        end
    end
    for _, win in ipairs(PolarUI.ActiveWindows) do
        if win.UIScale then
            win.UIScale.Scale = PolarUI.CurrentScale
        end
    end
end

function PolarUI:SetTheme(themeName)
    -- Intentionally preserved for Onyx visual consistency
end

function PolarUI:Notify(cfg)
    local title = type(cfg) == "table" and (cfg.Title or "Polar Hub") or tostring(cfg)
    local text = type(cfg) == "table" and (cfg.Content or cfg.Text or cfg.Description or "") or ""
    local dur = type(cfg) == "table" and (cfg.Duration or 4) or 4
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur
        })
    end)
end

-- ============================================================================
-- MAIN WINDOW CREATION (Window Object)
-- ============================================================================
function PolarUI:MakeWindow(config)
    config = config or {}
    local customTitle = config.Name or config.Title or "POLAR HUB"
    local customSub = config.SubTitle or '<font color="#00E5FF">Blox Fruits</font> • <font color="#C084FC">v.Powerhouse</font> • <font color="#FFD700">Official</font>'
    
    local selfWindow = setmetatable({}, { __index = PolarUI })
    table.insert(PolarUI.ActiveWindows, selfWindow)
    
    -- Target Parent
    local parentGui = nil
    if gethui then pcall(function() parentGui = gethui() end) end
    if not parentGui then
        parentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Cleanup of old instances
    local function cleanOld(container)
        if not container then return end
        pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "PolarHub_Onyx_UI" or child.Name == "redz Library V5" then
                    pcall(function() child:Destroy() end)
                end
            end
        end)
    end
    if gethui then pcall(function() cleanOld(gethui()) end) end
    pcall(function() cleanOld(game:GetService("CoreGui"):FindFirstChild("RobloxGui")) end)
    pcall(function() cleanOld(game:GetService("CoreGui")) end)
    pcall(function() cleanOld(LocalPlayer:FindFirstChild("PlayerGui")) end)

    -- 1. ScreenGui Container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PolarHub_Onyx_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, screenGui)
    end

    -- 115% Precision Scaling (LibraryUIScale)
    local uiScale = Instance.new("UIScale")
    uiScale.Name = "LibraryUIScale"
    uiScale.Scale = PolarUI.CurrentScale
    uiScale.Parent = screenGui
    selfWindow.UIScale = uiScale

    -- 2. Floating Toggle Button (60x60 Circle at {0.016, 0}, {0.219, 0})
    local floatFrame = Instance.new("Frame")
    floatFrame.Name = "FloatToggle"
    floatFrame.Position = UDim2.new(0.016, 0, 0.219, 0)
    floatFrame.Size = UDim2.new(0, 60, 0, 60)
    floatFrame.BackgroundTransparency = 1
    floatFrame.BorderSizePixel = 0
    floatFrame.ZIndex = 500
    floatFrame.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatFrame

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "ToggleLogo"
    floatBtn.Size = UDim2.new(1, 0, 1, 0)
    floatBtn.BackgroundTransparency = 1
    floatBtn.BorderSizePixel = 0
    floatBtn.Image = "rbxassetid://87383580130479"
    floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.ZIndex = 501
    floatBtn.Parent = floatFrame

    local floatBtnCorner = Instance.new("UICorner")
    floatBtnCorner.CornerRadius = UDim.new(1, 0)
    floatBtnCorner.Parent = floatBtn

    -- 3. Main Window Frame (510x330, sleek borderless #0A0A0A trans 0.05, corner 10px)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 510, 0, 330)
    mainFrame.BackgroundColor3 = Theme.WindowBase
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 200
    mainFrame.Parent = screenGui
    selfWindow.MainFrame = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    -- Toggle visibility animation
    local isVisible = true
    floatBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if isVisible then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 480, 0, 310)
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 510, 0, 330),
                BackgroundTransparency = 0.05
            }):Play()
        else
            local tw = TweenService:Create(mainFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 480, 0, 310),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isVisible then mainFrame.Visible = false end
            end)
        end
    end)

    -- Window Dragging Logic
    local dragging = false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- 4. Top Bar (Header at {0, 0}, {0, 0}, Size {1, 0}, {0, 32})
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 205
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleHub"
    titleLabel.Position = UDim2.new(0, 12, 0, 2)
    titleLabel.Size = UDim2.new(1, -255, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = customTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = Theme.TextLight
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 206
    titleLabel.Parent = topBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleHub"
    subtitleLabel.Position = UDim2.new(0, 12, 0, 18)
    subtitleLabel.Size = UDim2.new(1, -255, 0, 12)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.BorderSizePixel = 0
    subtitleLabel.RichText = true
    subtitleLabel.Text = customSub
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 11
    subtitleLabel.TextColor3 = Color3.fromRGB(165, 165, 185)
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.ZIndex = 206
    subtitleLabel.Parent = topBar

    -- Centered Modals Overlay Container
    local modalOverlay = Instance.new("Frame")
    modalOverlay.Name = "ModalOverlay"
    modalOverlay.Visible = false
    modalOverlay.Size = UDim2.new(1, 0, 1, 0)
    modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modalOverlay.BackgroundTransparency = 0.55
    modalOverlay.BorderSizePixel = 0
    modalOverlay.ZIndex = 1000
    modalOverlay.Parent = mainFrame

    -- Authentic 270x270 Modal Builder
    local function createAuthenticModal(name, titleText, iconId)
        local modal = Instance.new("Frame")
        modal.Name = "Modal_" .. name
        modal.Visible = false
        modal.AnchorPoint = Vector2.new(0.5, 0.5)
        modal.Position = UDim2.new(0.5, 0, 0.5, 0)
        modal.Size = UDim2.new(0, 270, 0, 270)
        modal.BackgroundColor3 = Theme.ModalBase
        modal.BorderSizePixel = 0
        modal.ClipsDescendants = true
        modal.ZIndex = 2000
        modal.Parent = mainFrame

        local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 10); mc.Parent = modal

        local ms = Instance.new("UIStroke")
        ms.Color = Theme.AccentStroke
        ms.Thickness = 1.0
        ms.Transparency = 0.45
        ms.LineJoinMode = Enum.LineJoinMode.Round
        ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ms.Parent = modal

        local mTop = Instance.new("Frame")
        mTop.Size = UDim2.new(1, 0, 0, 56)
        mTop.BackgroundTransparency = 1
        mTop.BorderSizePixel = 0
        mTop.ZIndex = 2001
        mTop.Parent = modal

        local mIcon = Instance.new("ImageLabel")
        mIcon.AnchorPoint = Vector2.new(0.5, 0)
        mIcon.Position = UDim2.new(0.5, 0, 0, 8)
        mIcon.Size = UDim2.new(0, 20, 0, 20)
        mIcon.BackgroundTransparency = 1
        mIcon.BorderSizePixel = 0
        mIcon.Image = iconId
        mIcon.ImageColor3 = Theme.Accent
        mIcon.ZIndex = 2002
        mIcon.Parent = mTop

        local mTitle = Instance.new("TextLabel")
        mTitle.AnchorPoint = Vector2.new(0.5, 0)
        mTitle.Position = UDim2.new(0.5, 0, 0, 32)
        mTitle.Size = UDim2.new(1, -24, 0, 18)
        mTitle.BackgroundTransparency = 1
        mTitle.BorderSizePixel = 0
        mTitle.Text = titleText
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 15
        mTitle.TextColor3 = Theme.TextWhite
        mTitle.TextXAlignment = Enum.TextXAlignment.Center
        mTitle.ZIndex = 2002
        mTitle.Parent = mTop

        local mDiv = Instance.new("Frame")
        mDiv.Position = UDim2.new(0, 12, 0, 56)
        mDiv.Size = UDim2.new(1, -24, 0, 1)
        mDiv.BackgroundColor3 = Theme.AccentStroke
        mDiv.BorderSizePixel = 0
        mDiv.ZIndex = 2002
        mDiv.Parent = modal

        local mScroll = Instance.new("ScrollingFrame")
        mScroll.AnchorPoint = Vector2.new(0.5, 0)
        mScroll.Position = UDim2.new(0.5, 0, 0, 64)
        mScroll.Size = UDim2.new(1, -16, 1, -100)
        mScroll.BackgroundTransparency = 1
        mScroll.BorderSizePixel = 0
        mScroll.ScrollBarThickness = 0
        mScroll.ScrollBarImageTransparency = 1
        mScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        mScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        mScroll.ZIndex = 2002
        mScroll.Parent = modal

        local ml = Instance.new("UIListLayout")
        ml.Padding = UDim.new(0, 6)
        ml.SortOrder = Enum.SortOrder.LayoutOrder
        ml.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ml.Parent = mScroll

        local mClose = Instance.new("TextButton")
        mClose.AnchorPoint = Vector2.new(0.5, 1)
        mClose.Position = UDim2.new(0.5, 0, 1, -10)
        mClose.Size = UDim2.new(1, -24, 0, 26)
        mClose.BackgroundColor3 = Color3.fromRGB(35, 20, 55)
        mClose.BorderSizePixel = 0
        mClose.Text = "Cerrar"
        mClose.Font = Enum.Font.GothamBold
        mClose.TextSize = 13
        mClose.TextColor3 = Theme.TextWhite
        mClose.ZIndex = 2003
        mClose.Parent = modal

        local mcc = Instance.new("UICorner"); mcc.CornerRadius = UDim.new(0, 6); mcc.Parent = mClose
        local mcs = Instance.new("UIStroke")
        mcs.Color = Theme.AccentStroke
        mcs.Thickness = 1.0
        mcs.Transparency = 0.50
        mcs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        mcs.Parent = mClose

        local function open()
            modalOverlay.Visible = true
            modal.Visible = true
            modal.Size = UDim2.new(0, 240, 0, 240)
            modal.BackgroundTransparency = 0.5
            TweenService:Create(modal, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 270, 0, 270),
                BackgroundTransparency = 0
            }):Play()
        end

        local function close()
            local tw = TweenService:Create(modal, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 240, 0, 240),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function()
                modal.Visible = false
                modalOverlay.Visible = false
            end)
        end

        mClose.MouseButton1Click:Connect(close)
        return { Modal = modal, Scroll = mScroll, Open = open, Close = close }
    end

    -- Create Config Modal
    local configModal = createAuthenticModal("Config", "Config.", "rbxassetid://81151604784579")
    do
        local themeBox = Instance.new("TextButton")
        themeBox.Size = UDim2.new(1, -8, 0, 28)
        themeBox.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
        themeBox.BorderSizePixel = 0
        themeBox.Text = "  Tema: Polar Onyx Bloom"
        themeBox.Font = Enum.Font.GothamBold
        themeBox.TextSize = 12
        themeBox.TextColor3 = Theme.TextLight
        themeBox.TextXAlignment = Enum.TextXAlignment.Left
        themeBox.ZIndex = 2003
        themeBox.Parent = configModal.Scroll
        local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 6); tbc.Parent = themeBox

        local fadeBox = Instance.new("Frame")
        fadeBox.Size = UDim2.new(1, -8, 0, 48)
        fadeBox.BackgroundColor3 = Color3.fromRGB(18, 15, 28)
        fadeBox.BorderSizePixel = 0
        fadeBox.ZIndex = 2003
        fadeBox.Parent = configModal.Scroll
        local fbc = Instance.new("UICorner"); fbc.CornerRadius = UDim.new(0, 6); fbc.Parent = fadeBox

        local flbl = Instance.new("TextLabel")
        flbl.Position = UDim2.new(0, 10, 0, 6)
        flbl.Size = UDim2.new(1, -50, 0, 16)
        flbl.BackgroundTransparency = 1
        flbl.BorderSizePixel = 0
        flbl.Text = "Escala de la Interfaz"
        flbl.Font = Enum.Font.GothamBold
        flbl.TextSize = 12
        flbl.TextColor3 = Theme.TextLight
        flbl.TextXAlignment = Enum.TextXAlignment.Left
        flbl.ZIndex = 2004
        flbl.Parent = fadeBox

        local fVal = Instance.new("TextLabel")
        fVal.Position = UDim2.new(1, -45, 0, 6)
        fVal.Size = UDim2.new(0, 35, 0, 16)
        fVal.BackgroundTransparency = 1
        fVal.BorderSizePixel = 0
        fVal.Text = tostring(math.floor(PolarUI.CurrentScale * 100)) .. "%"
        fVal.Font = Enum.Font.GothamBold
        fVal.TextSize = 11
        fVal.TextColor3 = Theme.Accent
        fVal.ZIndex = 2004
        fVal.Parent = fadeBox

        local fTrack = Instance.new("Frame")
        fTrack.Position = UDim2.new(0, 10, 0, 28)
        fTrack.Size = UDim2.new(1, -20, 0, 8)
        fTrack.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
        fTrack.BorderSizePixel = 0
        fTrack.ZIndex = 2004
        fTrack.Parent = fadeBox
        local ftc = Instance.new("UICorner"); ftc.CornerRadius = UDim.new(1, 0); ftc.Parent = fTrack

        local fFill = Instance.new("Frame")
        fFill.Size = UDim2.new(0.65, 0, 1, 0)
        fFill.BackgroundColor3 = Theme.Accent
        fFill.BorderSizePixel = 0
        fFill.ZIndex = 2005
        fFill.Parent = fTrack
        local ffc = Instance.new("UICorner"); ffc.CornerRadius = UDim.new(1, 0); ffc.Parent = fFill

        local fontHdr = Instance.new("TextLabel")
        fontHdr.Size = UDim2.new(1, -8, 0, 18)
        fontHdr.BackgroundTransparency = 1
        fontHdr.BorderSizePixel = 0
        fontHdr.Text = "Tipografía Oficial: GothamBold"
        fontHdr.Font = Enum.Font.GothamBold
        fontHdr.TextSize = 11
        fontHdr.TextColor3 = Color3.fromRGB(180, 175, 200)
        fontHdr.TextXAlignment = Enum.TextXAlignment.Center
        fontHdr.ZIndex = 2003
        fontHdr.Parent = configModal.Scroll
    end

    -- Create Credits Modal
    local creditsModal = createAuthenticModal("Credits", "Credits", "rbxassetid://83474083071373")
    do
        local teamHdr = Instance.new("TextLabel")
        teamHdr.Size = UDim2.new(1, -8, 0, 18)
        teamHdr.BackgroundTransparency = 1
        teamHdr.BorderSizePixel = 0
        teamHdr.Text = "Equipo Polar Hub"
        teamHdr.Font = Enum.Font.GothamBold
        teamHdr.TextSize = 12
        teamHdr.TextColor3 = Theme.Accent
        teamHdr.TextXAlignment = Enum.TextXAlignment.Left
        teamHdr.ZIndex = 2003
        teamHdr.Parent = creditsModal.Scroll

        local members = {
            { name = "Polar", role = "Lead Developer", tag = "P" },
            { name = "Polar Hub Team", role = "Powerhouse Core", tag = "H" },
            { name = "Community", role = "Testers & Feedback", tag = "C" }
        }

        for _, m in ipairs(members) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -8, 0, 36)
            card.BackgroundColor3 = Color3.fromRGB(18, 15, 28)
            card.BorderSizePixel = 0
            card.ZIndex = 2003
            card.Parent = creditsModal.Scroll
            local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = card

            local cs = Instance.new("UIStroke")
            cs.Color = Theme.AccentStroke
            cs.Thickness = 1.0
            cs.Transparency = 0.65
            cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            cs.Parent = card

            local av = Instance.new("Frame")
            av.Position = UDim2.new(0, 6, 0.5, -11)
            av.Size = UDim2.new(0, 22, 0, 22)
            av.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
            av.BorderSizePixel = 0
            av.ZIndex = 2004
            av.Parent = card
            local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(1, 0); avc.Parent = av

            local avl = Instance.new("TextLabel")
            avl.Size = UDim2.new(1, 0, 1, 0)
            avl.BackgroundTransparency = 1
            avl.BorderSizePixel = 0
            avl.Text = m.tag
            avl.Font = Enum.Font.GothamBold
            avl.TextSize = 11
            avl.TextColor3 = Theme.Accent
            avl.ZIndex = 2005
            avl.Parent = av

            local nl = Instance.new("TextLabel")
            nl.Position = UDim2.new(0, 36, 0, 0)
            nl.Size = UDim2.new(0.5, 0, 1, 0)
            nl.BackgroundTransparency = 1
            nl.BorderSizePixel = 0
            nl.Text = m.name
            nl.Font = Enum.Font.GothamBold
            nl.TextSize = 12
            nl.TextColor3 = Theme.TextWhite
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.ZIndex = 2004
            nl.Parent = card

            local rb = Instance.new("Frame")
            rb.AnchorPoint = Vector2.new(1, 0.5)
            rb.Position = UDim2.new(1, -6, 0.5, 0)
            rb.Size = UDim2.new(0, 74, 0, 18)
            rb.BackgroundColor3 = Color3.fromRGB(28, 22, 42)
            rb.BorderSizePixel = 0
            rb.ZIndex = 2004
            rb.Parent = card
            local rbc = Instance.new("UICorner"); rbc.CornerRadius = UDim.new(0, 4); rbc.Parent = rb

            local rbl = Instance.new("TextLabel")
            rbl.Size = UDim2.new(1, 0, 1, 0)
            rbl.BackgroundTransparency = 1
            rbl.BorderSizePixel = 0
            rbl.Text = m.role
            rbl.Font = Enum.Font.GothamBold
            rbl.TextSize = 8
            rbl.TextColor3 = Theme.Accent
            rbl.ZIndex = 2005
            rbl.Parent = rb
        end
    end

    -- Header Pill Button Builder ("Config.", "Credits")
    local function createHeaderPillButton(name, text, iconId, xOffset, onClick)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, xOffset, 0, 16)
        btn.Size = UDim2.new(0, 83, 0, 23)
        btn.BackgroundColor3 = Theme.PillBadge
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = 206
        btn.Parent = topBar

        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn

        local bs = Instance.new("UIStroke")
        bs.Color = Theme.AccentStroke
        bs.Thickness = 1.0
        bs.Transparency = 0.32
        bs.LineJoinMode = Enum.LineJoinMode.Round
        bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bs.Parent = btn

        local strip = Instance.new("Frame")
        strip.Position = UDim2.new(0, 1, 0, 2)
        strip.Size = UDim2.new(0, 4, 1, -4)
        strip.BorderSizePixel = 0
        strip.ZIndex = 207
        strip.Parent = btn

        local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 2); sc.Parent = strip

        local sg = Instance.new("UIGradient")
        sg.Color = CyberGradient
        sg.Rotation = 90
        sg.Parent = strip

        local icon = Instance.new("ImageLabel")
        icon.Position = UDim2.new(0, 10, 0.5, -6)
        icon.Size = UDim2.new(0, 12, 0, 12)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Image = iconId
        icon.ImageColor3 = Theme.Accent
        icon.ZIndex = 207
        icon.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 25, 0, 0)
        lbl.Size = UDim2.new(1, -26, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = Theme.TextWhite
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 207
        lbl.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if onClick then onClick() end
        end)

        return btn
    end

    createHeaderPillButton("ConfigBtn", "Config.", "rbxassetid://81151604784579", -153, function()
        configModal.Open()
    end)
    createHeaderPillButton("CreditsBtn", "Credits", "rbxassetid://83474083071373", -62, function()
        creditsModal.Open()
    end)

    -- Minimize Button
    local minBtn = Instance.new("ImageButton")
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -34, 0, 16)
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.BackgroundTransparency = 1
    minBtn.BorderSizePixel = 0
    minBtn.Image = "rbxassetid://92966930061759"
    minBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.ZIndex = 206
    minBtn.Parent = topBar

    -- Close Button
    local closeBtn = Instance.new("ImageButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -8, 0, 16)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.Image = "rbxassetid://79324227570635"
    closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.ZIndex = 206
    closeBtn.Parent = topBar

    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        isVisible = false
    end)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- 5. Tab Bar Header ({0, 0}, {0, 36}, Size {1, 0}, {0, 40})
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Position = UDim2.new(0, 0, 0, 36)
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 205
    tabBar.Parent = mainFrame

    -- SearchBarFrame at {0, 8}, {0, 1}, Size {0, 126}, {0, 22}
    local searchBar = Instance.new("Frame")
    searchBar.Name = "SearchBarFrame"
    searchBar.Position = UDim2.new(0, 8, 0, 1)
    searchBar.Size = UDim2.new(0, 126, 0, 22)
    searchBar.BackgroundColor3 = Theme.SearchBase
    searchBar.BackgroundTransparency = 0.40
    searchBar.BorderSizePixel = 0
    searchBar.ZIndex = 206
    searchBar.Parent = tabBar

    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 6); sc.Parent = searchBar

    local ss = Instance.new("UIStroke")
    ss.Color = Theme.AccentStroke
    ss.Thickness = 1.0
    ss.Transparency = 0.55
    ss.LineJoinMode = Enum.LineJoinMode.Round
    ss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ss.Parent = searchBar

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Position = UDim2.new(0, 6, 0.5, -6)
    searchIcon.Size = UDim2.new(0, 12, 0, 12)
    searchIcon.BackgroundTransparency = 1
    searchIcon.BorderSizePixel = 0
    searchIcon.Image = "rbxassetid://3926305904"
    searchIcon.ImageColor3 = Color3.fromRGB(175, 140, 230)
    searchIcon.ZIndex = 207
    searchIcon.Parent = searchBar

    local searchBox = Instance.new("TextBox")
    searchBox.Position = UDim2.new(0, 21, 0, 0)
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(175, 145, 215)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.TextColor3 = Color3.fromRGB(235, 230, 250)
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 207
    searchBox.Parent = searchBar

    local searchClear = Instance.new("TextButton")
    searchClear.Position = UDim2.new(1, -3, 0.5, 0)
    searchClear.AnchorPoint = Vector2.new(1, 0.5)
    searchClear.Size = UDim2.new(0, 14, 0, 14)
    searchClear.BackgroundTransparency = 1
    searchClear.BorderSizePixel = 0
    searchClear.Text = "×"
    searchClear.Font = Enum.Font.GothamBold
    searchClear.TextSize = 12
    searchClear.TextColor3 = Color3.fromRGB(175, 145, 215)
    searchClear.ZIndex = 207
    searchClear.Parent = searchBar
    searchClear.MouseButton1Click:Connect(function() searchBox.Text = "" end)

    local searchCount = Instance.new("TextLabel")
    searchCount.Position = UDim2.new(1, -2, 0, -6)
    searchCount.Size = UDim2.new(0, 22, 0, 14)
    searchCount.BackgroundColor3 = Theme.AccentDeep
    searchCount.BackgroundTransparency = 0.20
    searchCount.BorderSizePixel = 0
    searchCount.Text = "0"
    searchCount.Font = Enum.Font.GothamBold
    searchCount.TextSize = 9
    searchCount.TextColor3 = Color3.fromRGB(240, 225, 255)
    searchCount.ZIndex = 208
    searchCount.Parent = searchBar
    local scc = Instance.new("UICorner"); scc.CornerRadius = UDim.new(1, 0); scc.Parent = searchCount

    -- Horizontal Scrollable Tab Strip ({0, 140}, {0, -3}, Size {1, -148}, {0, 30})
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Position = UDim2.new(0, 140, 0, -3)
    tabScroll.Size = UDim2.new(1, -148, 0, 30)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.ScrollBarImageTransparency = 1
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.ZIndex = 206
    tabScroll.Parent = tabBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroll

    -- 6. Main Content Area ({0, 5}, {0, 70}, Size {0, 500}, {0, 255})
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Position = UDim2.new(0, 5, 0, 70)
    contentFrame.Size = UDim2.new(0, 500, 0, 255)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ZIndex = 205
    contentFrame.Parent = mainFrame

    -- Registry
    selfWindow.TabFrames = {}
    selfWindow.ContentFrame = contentFrame
    selfWindow.TabScroll = tabScroll
    selfWindow.RegisteredControls = {}

    -- Real-time Search Handler
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        local matched = 0
        for _, ctrl in ipairs(selfWindow.RegisteredControls) do
            local matches = (query == "") or string.find(string.lower(ctrl.Name), query) or (ctrl.Desc and string.find(string.lower(ctrl.Desc), query))
            ctrl.Instance.Visible = matches
            if matches then matched = matched + 1 end
        end
        searchCount.Text = tostring(matched)
    end)

    -- Universal Border & Scrollbar Sanitizer to ensure zero rogue border lines
    local function sanitizeGuiObject(obj)
        if obj:IsA("GuiObject") then
            obj.BorderSizePixel = 0
        end
        if obj:IsA("ScrollingFrame") then
            obj.ScrollBarImageTransparency = 1
        end
    end
    mainFrame.DescendantAdded:Connect(sanitizeGuiObject)
    for _, desc in ipairs(mainFrame:GetDescendants()) do
        sanitizeGuiObject(desc)
    end

    screenGui.Parent = parentGui
    return selfWindow
end

-- ============================================================================
-- TAB CREATION (MakeTab)
-- ============================================================================
function PolarUI:MakeTab(tabConfig)
    local tabTitle = type(tabConfig) == "table" and (tabConfig.Title or tabConfig.Name or tabConfig[1]) or tostring(tabConfig)
    local meta = TabMeta[tabTitle] or {}
    local tabIconId = (type(tabConfig) == "table" and tabConfig.Icon and (string.find(tostring(tabConfig.Icon), "rbxassetid") and tabConfig.Icon)) or meta.icon or "rbxassetid://88050097561287"
    local tabWidth = meta.width or math.max(68, #tabTitle * 8 + 36)

    local isFirstTab = (next(self.TabFrames) == nil)

    -- Tab Button (GothamBold 14px)
    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. tabTitle
    btn.Size = UDim2.new(0, tabWidth, 0, 24)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = tabTitle
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = isFirstTab and Theme.TextWhite or Theme.TextTabOff
    btn.TextXAlignment = Enum.TextXAlignment.Right
    btn.ZIndex = 207
    btn.Parent = self.TabScroll

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingRight = UDim.new(0, 4)
    btnPad.Parent = btn

    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Position = UDim2.new(0, 5, 0.5, 0)
    tabIcon.AnchorPoint = Vector2.new(0, 0.5)
    tabIcon.Size = UDim2.new(0, 16, 0, 16)
    tabIcon.BackgroundTransparency = 1
    tabIcon.BorderSizePixel = 0
    tabIcon.Image = tabIconId
    tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    tabIcon.ZIndex = 208
    tabIcon.Parent = btn

    -- Glowing Violet Underline
    local underline = Instance.new("Frame")
    underline.Name = "Tab_Underline"
    underline.AnchorPoint = Vector2.new(0.5, 0)
    underline.Position = UDim2.new(0.5, 0, 1, 1)
    underline.Size = UDim2.new(0.5, 0, 0, 3)
    underline.Visible = isFirstTab
    underline.BackgroundColor3 = Theme.AccentDeep
    underline.BorderSizePixel = 0
    underline.ZIndex = 209
    underline.Parent = btn

    local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1, 0); uc.Parent = underline
    local ug = Instance.new("UIGradient"); ug.Color = UnderlineGradient; ug.Parent = underline

    -- Container View for this Tab
    local tabView = Instance.new("Frame")
    tabView.Name = "TabView_" .. tabTitle
    tabView.Size = UDim2.new(1, 0, 1, 0)
    tabView.BackgroundTransparency = 1
    tabView.BorderSizePixel = 0
    tabView.Visible = isFirstTab
    tabView.ZIndex = 206
    tabView.Parent = self.ContentFrame

    local tvLayout = Instance.new("UIListLayout")
    tvLayout.FillDirection = Enum.FillDirection.Horizontal
    tvLayout.Padding = UDim.new(0, 19)
    tvLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tvLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tvLayout.Parent = tabView

    -- Dual Columns: Col1 ({0, 240}, {0, 260}) and Col2 ({0, 240}, {0, 260})
    local col1 = Instance.new("ScrollingFrame")
    col1.Name = "SectionScroll1"
    col1.Position = UDim2.new(0, 0, 0, 0)
    col1.Size = UDim2.new(0, 240, 0, 260)
    col1.BackgroundTransparency = 1
    col1.BorderSizePixel = 0
    col1.ScrollBarThickness = 0
    col1.ScrollBarImageTransparency = 1
    col1.CanvasSize = UDim2.new(0, 0, 0, 0)
    col1.AutomaticCanvasSize = Enum.AutomaticSize.Y
    col1.ClipsDescendants = true
    col1.ZIndex = 207
    col1.Parent = tabView

    local l1 = Instance.new("UIListLayout")
    l1.Padding = UDim.new(0, 7)
    l1.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l1.SortOrder = Enum.SortOrder.LayoutOrder
    l1.Parent = col1

    local col2 = Instance.new("ScrollingFrame")
    col2.Name = "SectionScroll2"
    col2.Position = UDim2.new(0, 0, 0, 0)
    col2.Size = UDim2.new(0, 240, 0, 260)
    col2.BackgroundTransparency = 1
    col2.BorderSizePixel = 0
    col2.ScrollBarThickness = 0
    col2.ScrollBarImageTransparency = 1
    col2.CanvasSize = UDim2.new(0, 0, 0, 0)
    col2.AutomaticCanvasSize = Enum.AutomaticSize.Y
    col2.ClipsDescendants = true
    col2.ZIndex = 207
    col2.Parent = tabView

    local l2 = Instance.new("UIListLayout")
    l2.Padding = UDim.new(0, 7)
    l2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l2.SortOrder = Enum.SortOrder.LayoutOrder
    l2.Parent = col2

    local tabData = {
        Title = tabTitle,
        View = tabView,
        Col1 = col1,
        Col2 = col2,
        Btn = btn,
        Underline = underline,
        Icon = tabIcon,
        Window = self,
        SectionCount = 0,
        CurrentSection = nil
    }

    self.TabFrames[tabTitle] = tabData

    btn.MouseButton1Click:Connect(function()
        for name, data in pairs(self.TabFrames) do
            local active = (name == tabTitle)
            data.View.Visible = active
            data.Btn.TextColor3 = active and Theme.TextWhite or Theme.TextTabOff
            data.Underline.Visible = active
        end
    end)

    local TabObj = setmetatable(tabData, { __index = PolarUI })
    return TabObj
end

-- Tab selection helper
function PolarUI:SelectTab(tabTitle)
    for name, data in pairs(self.TabFrames) do
        local active = (name == tabTitle)
        data.View.Visible = active
        data.Btn.TextColor3 = active and Theme.TextWhite or Theme.TextTabOff
        data.Underline.Visible = active
    end
end

-- ============================================================================
-- SECTION BUILDER (AddSection)
-- ============================================================================
function PolarUI:AddSection(sectionConfig)
    local titleText = type(sectionConfig) == "table" and (sectionConfig.Title or sectionConfig.Name or sectionConfig[1]) or tostring(sectionConfig)
    
    self.SectionCount = (self.SectionCount or 0) + 1
    local targetCol = (self.SectionCount % 2 == 1) and self.Col1 or self.Col2

    local section = Instance.new("Frame")
    section.Name = "Section_" .. titleText
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundTransparency = 1
    section.BorderSizePixel = 0
    section.ZIndex = 208
    section.Parent = targetCol

    -- Authentic Dark Translucent Container (#191919 at 0.30 trans, Corner 6px, Center-aligned)
    local innerSection = Instance.new("Frame")
    innerSection.Name = "InnerSection"
    innerSection.Position = UDim2.new(0, 5, 0, 0)
    innerSection.Size = UDim2.new(1, -10, 0, 0)
    innerSection.AutomaticSize = Enum.AutomaticSize.Y
    innerSection.BackgroundColor3 = Theme.InnerCard
    innerSection.BackgroundTransparency = 0.30
    innerSection.BorderSizePixel = 0
    innerSection.ZIndex = 208
    innerSection.Parent = section

    local isc = Instance.new("UICorner"); isc.CornerRadius = UDim.new(0, 6); isc.Parent = innerSection

    local isLayout = Instance.new("UIListLayout")
    isLayout.Padding = UDim.new(0, 3)
    isLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    isLayout.SortOrder = Enum.SortOrder.LayoutOrder
    isLayout.Parent = innerSection

    innerSection:SetAttribute("Order", 1)

    -- Centered Subheader with Multi-Color Cyber Gradient Lines ({1, 0}, {0, 22})
    local subheader = Instance.new("Frame")
    subheader.Name = "Subheader"
    subheader.LayoutOrder = 1
    subheader.Size = UDim2.new(1, 0, 0, 22)
    subheader.BackgroundTransparency = 1
    subheader.BorderSizePixel = 0
    subheader.ZIndex = 209
    subheader.Parent = innerSection

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0.2, 0, 0, 0)
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Theme.TextWhite
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 210
    title.Parent = subheader

    -- Flanking Cyber Gradient Lines (60-degree rotation)
    local function createCyberLine(pos)
        local f = Instance.new("Frame")
        f.Position = pos
        f.Size = UDim2.new(0.2, 0, 0, 8)
        f.BackgroundColor3 = Theme.Accent
        f.BorderSizePixel = 0
        f.ZIndex = 209
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = f
        local g = Instance.new("UIGradient"); g.Rotation = 60; g.Color = CyberGradient; g.Parent = f
        f.Parent = subheader
    end

    createCyberLine(UDim2.new(0, 0, 0.5, -1))
    createCyberLine(UDim2.new(0.8, 0, 0.5, -1))

    self.CurrentSection = innerSection

    local secObj = {
        InnerParent = innerSection,
        Tab = self,
        Title = titleText
    }

    function secObj:AddToggle(cfg, def, cb) return self.Tab:AddToggle(cfg, def, cb, self.InnerParent) end
    function secObj:AddSlider(cfg, min, max, def, cb) return self.Tab:AddSlider(cfg, min, max, def, cb, self.InnerParent) end
    function secObj:AddDropdown(cfg, opt, def, cb) return self.Tab:AddDropdown(cfg, opt, def, cb, self.InnerParent) end
    function secObj:AddButton(cfg, cb) return self.Tab:AddButton(cfg, cb, self.InnerParent) end
    function secObj:AddParagraph(cfg, text) return self.Tab:AddParagraph(cfg, text, self.InnerParent) end
    function secObj:AddTextBox(cfg, ph, def, cb) return self.Tab:AddTextBox(cfg, ph, def, cb, self.InnerParent) end
    function secObj:Visible(bool)
        if section then
            if bool == nil then section.Visible = not section.Visible
            else section.Visible = bool end
        end
    end

    return secObj
end

-- Internal helper to resolve the container parent for a control
local function resolveParent(self, targetParent)
    if targetParent then return targetParent end
    if self.InnerParent then return self.InnerParent end
    if self.CurrentSection then return self.CurrentSection end
    -- Fallback: auto-create general section
    local sec = self:AddSection("General")
    return sec.InnerParent
end

-- ============================================================================
-- TOGGLE CONTROL (AddToggle)
-- ============================================================================
function PolarUI:AddToggle(cfg, def, cb, overrideParent)
    local name, desc, defaultVal, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1]
        desc = cfg.Desc or cfg.Description or cfg.SubTitle
        defaultVal = cfg.Default or cfg.Value or false
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        defaultVal = def or false
        callback = cb or function() end
    end

    local innerParent = resolveParent(self, overrideParent)
    local isToggled = defaultVal or false
    local isMultiLine = desc and #desc > 30
    local height = isMultiLine and 63 or (desc and 42 or 32)
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local btn = Instance.new("TextButton")
    btn.Name = "Toggle_" .. name
    btn.LayoutOrder = ord
    btn.Size = UDim2.new(1, -25, 0, height)
    btn.BackgroundColor3 = Theme.ControlRow
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 210
    btn.Parent = innerParent

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, desc and 4 or 0)
    tLabel.Size = UDim2.new(1, -66, 0, desc and 18 or height)
    tLabel.BackgroundTransparency = 1
    tLabel.BorderSizePixel = 0
    tLabel.Text = name
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextScaled = true
    tLabel.TextColor3 = isToggled and Theme.TextWhite or Theme.TextMuted
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 211
    tLabel.Parent = btn

    local tlc = Instance.new("UITextSizeConstraint")
    tlc.MaxTextSize = 13
    tlc.MinTextSize = 8
    tlc.Parent = tLabel

    if desc then
        local dLabel = Instance.new("TextLabel")
        dLabel.Name = "DescLabel"
        dLabel.Position = UDim2.new(0, 10, 0, 22)
        dLabel.Size = UDim2.new(1, -60, 0, isMultiLine and 35 or 14)
        dLabel.BackgroundTransparency = 1
        dLabel.BorderSizePixel = 0
        dLabel.Text = desc
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 11
        dLabel.TextColor3 = Theme.TextDesc
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextYAlignment = Enum.TextYAlignment.Top
        dLabel.TextWrapped = true
        dLabel.ZIndex = 211
        dLabel.Parent = btn
    end

    -- Switch Capsule (36x18)
    local capsule = Instance.new("Frame")
    capsule.Position = UDim2.new(1, -50, 0.5, -9)
    capsule.Size = UDim2.new(0, 36, 0, 18)
    capsule.BackgroundColor3 = Theme.SwitchOff
    capsule.BorderSizePixel = 0
    capsule.ZIndex = 211
    capsule.Parent = btn

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = capsule

    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(100, 100, 120)
    cs.Thickness = 1.2
    cs.Transparency = 0.55
    cs.LineJoinMode = Enum.LineJoinMode.Round
    cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cs.Parent = capsule

    -- Knob ImageLabel (asset 12266946128)
    local knob = Instance.new("ImageLabel")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = isToggled and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundTransparency = 1
    knob.BorderSizePixel = 0
    knob.ImageTransparency = isToggled and 0.0 or 0.5
    knob.Image = "http://www.roblox.com/asset/?id=12266946128"
    knob.ImageColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 212
    knob.Parent = capsule

    local kg = Instance.new("UIGradient")
    kg.Rotation = 90
    kg.Color = CyberGradient
    kg.Enabled = isToggled
    kg.Parent = knob

    local function setVisualState(toggled)
        isToggled = toggled
        kg.Enabled = isToggled
        local targetPos = isToggled and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetTextCol = isToggled and Theme.TextWhite or Theme.TextMuted

        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPos,
            ImageTransparency = isToggled and 0.0 or 0.5
        }):Play()
        tLabel.TextColor3 = targetTextCol
    end

    btn.MouseButton1Click:Connect(function()
        setVisualState(not isToggled)
        callback(isToggled)
    end)

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = name, Desc = desc, Instance = btn })
    end

    local toggleObj = {
        Instance = btn,
        Name = name,
        Set = function(_, val)
            setVisualState(val)
            callback(val)
        end,
        GetValue = function(_) return isToggled end
    }
    return toggleObj
end

-- ============================================================================
-- SLIDER CONTROL (AddSlider)
-- ============================================================================
function PolarUI:AddSlider(cfg, min, max, def, cb, overrideParent)
    local name, minVal, maxVal, defaultVal, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1]
        minVal = cfg.MinValue or cfg.Min or 0
        maxVal = cfg.MaxValue or cfg.Max or 100
        defaultVal = cfg.Default or cfg.Value or minVal
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        minVal = min or 0
        maxVal = max or 100
        defaultVal = def or minVal
        callback = cb or function() end
    end

    local innerParent = resolveParent(self, overrideParent)
    local currentVal = defaultVal or minVal
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. name
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, 54)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 10, 0, 8)
    title.Size = UDim2.new(1, -65, 0, 18)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Text = name
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Theme.TextLight
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 211
    title.Parent = frame

    -- Number Badge TextBox ({0, 46}, {0, 20} with #C084FC outline)
    local valBox = Instance.new("TextBox")
    valBox.AnchorPoint = Vector2.new(1, 0)
    valBox.Position = UDim2.new(1, -10, 0, 7)
    valBox.Size = UDim2.new(0, 46, 0, 20)
    valBox.BackgroundColor3 = Theme.PillBadge
    valBox.BorderSizePixel = 0
    valBox.Text = tostring(currentVal)
    valBox.Font = Enum.Font.GothamBold
    valBox.TextSize = 12
    valBox.TextColor3 = Theme.Accent
    valBox.ClearTextOnFocus = false
    valBox.ZIndex = 211
    valBox.Parent = frame

    local vbc = Instance.new("UICorner"); vbc.CornerRadius = UDim.new(0, 5); vbc.Parent = valBox
    local vbs = Instance.new("UIStroke")
    vbs.Color = Theme.BadgeStroke
    vbs.Thickness = 1.0
    vbs.Transparency = 0.32
    vbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    vbs.Parent = valBox

    -- Slider Track ({1, -20}, {0, 10} with #8C5ADC outline)
    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 10, 0, 34)
    track.Size = UDim2.new(1, -20, 0, 10)
    track.BackgroundColor3 = Theme.SwitchOff
    track.BorderSizePixel = 0
    track.ZIndex = 211
    track.Parent = frame

    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track
    local ts = Instance.new("UIStroke")
    ts.Color = Theme.TrackStroke
    ts.Thickness = 1.0
    ts.Transparency = 0.50
    ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ts.Parent = track

    -- Lavender Gradient Fill
    local fill = Instance.new("Frame")
    local pct = math.clamp((currentVal - minVal) / math.max(1, maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 212
    fill.Parent = track

    local filc = Instance.new("UICorner"); filc.CornerRadius = UDim.new(1, 0); filc.Parent = fill
    local filg = Instance.new("UIGradient"); filg.Color = LavenderGradient; filg.Parent = fill

    -- Thumb Knob (13x13 white circle with 5x5 violet inner dot)
    local thumb = Instance.new("Frame")
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, 13, 0, 13)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 213
    thumb.Parent = track

    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb
    local ths = Instance.new("UIStroke")
    ths.Color = Theme.AccentDeep
    ths.Thickness = 1.0
    ths.Transparency = 0.40
    ths.Parent = thumb

    local innerDot = Instance.new("Frame")
    innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerDot.Size = UDim2.new(0, 5, 0, 5)
    innerDot.BackgroundColor3 = Theme.Accent
    innerDot.BorderSizePixel = 0
    innerDot.ZIndex = 214
    innerDot.Parent = thumb
    local idc = Instance.new("UICorner"); idc.CornerRadius = UDim.new(1, 0); idc.Parent = innerDot

    -- Drag & Click Math
    local sliding = false
    local function update(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * p + 0.5)
        currentVal = val
        valBox.Text = tostring(val)
        fill.Size = UDim2.new(p, 0, 1, 0)
        thumb.Position = UDim2.new(p, 0, 0.5, 0)
        callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then sliding = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    valBox.FocusLost:Connect(function()
        local num = tonumber(valBox.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            currentVal = num
            valBox.Text = tostring(num)
            local p = math.clamp((num - minVal) / math.max(1, maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            callback(num)
        else
            valBox.Text = tostring(currentVal)
        end
    end)

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = name, Instance = frame })
    end

    local sliderObj = {
        Instance = frame,
        Name = name,
        Set = function(_, num)
            num = math.clamp(tonumber(num) or minVal, minVal, maxVal)
            currentVal = num
            valBox.Text = tostring(num)
            local p = math.clamp((num - minVal) / math.max(1, maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            callback(num)
        end,
        GetValue = function(_) return currentVal end
    }
    return sliderObj
end

-- ============================================================================
-- DROPDOWN CONTROL (AddDropdown)
-- ============================================================================
function PolarUI:AddDropdown(cfg, opt, def, cb, overrideParent)
    local name, options, defaultOption, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1]
        options = cfg.Options or cfg.Values or {}
        defaultOption = cfg.Default or cfg.Value or options[1]
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        options = opt or {}
        defaultOption = def or options[1]
        callback = cb or function() end
    end

    local innerParent = resolveParent(self, overrideParent)
    local selectedVal = defaultOption or (options[1] or "None")
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. name
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, 36)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 0)
    tLabel.Size = UDim2.new(0.5, -10, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.BorderSizePixel = 0
    tLabel.Text = name
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextScaled = true
    tLabel.TextColor3 = Theme.TextWhite
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 211
    tLabel.Parent = frame

    local tcConstraint = Instance.new("UITextSizeConstraint")
    tcConstraint.MaxTextSize = 13
    tcConstraint.MinTextSize = 9
    tcConstraint.Parent = tLabel

    -- PillBadge Button with #C084FC border
    local pillBadge = Instance.new("Frame")
    pillBadge.AnchorPoint = Vector2.new(1, 0.5)
    pillBadge.Position = UDim2.new(1, -8, 0.5, 0)
    pillBadge.Size = UDim2.new(0.5, 0, 0, 24)
    pillBadge.BackgroundColor3 = Theme.PillBadge
    pillBadge.BorderSizePixel = 0
    pillBadge.ZIndex = 211
    pillBadge.Parent = frame

    local pbc = Instance.new("UICorner"); pbc.CornerRadius = UDim.new(0, 6); pbc.Parent = pillBadge
    local pbs = Instance.new("UIStroke")
    pbs.Color = Theme.BadgeStroke
    pbs.Thickness = 1.0
    pbs.Transparency = 0.32
    pbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pbs.Parent = pillBadge

    local valLabel = Instance.new("TextLabel")
    valLabel.Position = UDim2.new(0, 8, 0, 0)
    valLabel.Size = UDim2.new(1, -26, 1, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.BorderSizePixel = 0
    valLabel.Text = tostring(selectedVal)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextScaled = true
    valLabel.TextColor3 = Color3.fromRGB(216, 180, 254)
    valLabel.TextXAlignment = Enum.TextXAlignment.Left
    valLabel.ZIndex = 212
    valLabel.Parent = pillBadge

    local vbcConstraint = Instance.new("UITextSizeConstraint")
    vbcConstraint.MaxTextSize = 12
    vbcConstraint.MinTextSize = 8
    vbcConstraint.Parent = valLabel

    local arrow = Instance.new("ImageButton")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.BackgroundTransparency = 1
    arrow.BorderSizePixel = 0
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = Theme.Accent
    arrow.ZIndex = 212
    arrow.Parent = pillBadge

    -- Dropdown Pop-Up Modal
    local modal = Instance.new("Frame")
    modal.Name = "DropdownModal_" .. name
    modal.Visible = false
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.Size = UDim2.new(0, 220, 0, 180)
    modal.BackgroundColor3 = Theme.ModalBase
    modal.BorderSizePixel = 0
    modal.ClipsDescendants = true
    modal.ZIndex = 2000
    modal.Parent = self.Window and self.Window.MainFrame or frame

    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = modal
    local ms = Instance.new("UIStroke")
    ms.Color = Theme.AccentStroke
    ms.Thickness = 1.0
    ms.Transparency = 0.40
    ms.Parent = modal

    local mHeader = Instance.new("Frame")
    mHeader.Size = UDim2.new(1, 0, 0, 30)
    mHeader.BackgroundTransparency = 1
    mHeader.BorderSizePixel = 0
    mHeader.ZIndex = 2001
    mHeader.Parent = modal

    local mTitle = Instance.new("TextLabel")
    mTitle.Position = UDim2.new(0, 10, 0, 0)
    mTitle.Size = UDim2.new(1, -40, 1, 0)
    mTitle.BackgroundTransparency = 1
    mTitle.BorderSizePixel = 0
    mTitle.Text = name
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 12
    mTitle.TextColor3 = Theme.TextWhite
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 2002
    mTitle.Parent = mHeader

    local mClose = Instance.new("TextButton")
    mClose.Position = UDim2.new(1, -26, 0.5, -9)
    mClose.Size = UDim2.new(0, 18, 0, 18)
    mClose.BackgroundTransparency = 1
    mClose.BorderSizePixel = 0
    mClose.Text = "×"
    mClose.Font = Enum.Font.GothamBold
    mClose.TextSize = 14
    mClose.TextColor3 = Theme.Accent
    mClose.ZIndex = 2002
    mClose.Parent = mHeader

    local mScroll = Instance.new("ScrollingFrame")
    mScroll.Position = UDim2.new(0, 8, 0, 32)
    mScroll.Size = UDim2.new(1, -16, 1, -38)
    mScroll.BackgroundTransparency = 1
    mScroll.BorderSizePixel = 0
    mScroll.ScrollBarThickness = 2
    mScroll.ScrollBarImageColor3 = Theme.AccentDeep
    mScroll.ScrollBarImageTransparency = 0.5
    mScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mScroll.ZIndex = 2001
    mScroll.Parent = modal

    local ml = Instance.new("UIListLayout")
    ml.Padding = UDim.new(0, 4)
    ml.SortOrder = Enum.SortOrder.LayoutOrder
    ml.Parent = mScroll

    local function openModal()
        modal.Visible = true
        modal.Size = UDim2.new(0, 190, 0, 150)
        TweenService:Create(modal, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 180)
        }):Play()
    end

    local function closeModal()
        local tw = TweenService:Create(modal, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 190, 0, 150)
        })
        tw:Play()
        tw.Completed:Connect(function()
            modal.Visible = false
        end)
    end

    mClose.MouseButton1Click:Connect(closeModal)

    local function rebuildOptions(optList)
        for _, ch in ipairs(mScroll:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _, optName in ipairs(optList) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 24)
            optBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
            optBtn.BorderSizePixel = 0
            optBtn.Text = "  " .. tostring(optName)
            optBtn.Font = Enum.Font.GothamBold
            optBtn.TextSize = 11
            optBtn.TextColor3 = (tostring(optName) == tostring(selectedVal)) and Theme.TextWhite or Theme.TextTabOff
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 2002
            optBtn.Parent = mScroll

            local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0, 4); oc.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                selectedVal = optName
                valLabel.Text = tostring(optName)
                closeModal()
                callback(optName)
            end)
        end
    end

    rebuildOptions(options)

    local clickBlock = Instance.new("TextButton")
    clickBlock.Size = UDim2.new(1, 0, 1, 0)
    clickBlock.BackgroundTransparency = 1
    clickBlock.BorderSizePixel = 0
    clickBlock.Text = ""
    clickBlock.ZIndex = 213
    clickBlock.Parent = frame
    clickBlock.MouseButton1Click:Connect(openModal)
    arrow.MouseButton1Click:Connect(openModal)

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = name, Instance = frame })
    end

    local dropdownObj = {
        Instance = frame,
        Name = name,
        Set = function(_, optVal)
            selectedVal = optVal
            valLabel.Text = tostring(optVal)
            callback(optVal)
        end,
        SetValues = function(_, newOptions)
            options = newOptions
            rebuildOptions(newOptions)
        end,
        UpdateValues = function(_, newOptions)
            options = newOptions
            rebuildOptions(newOptions)
        end,
        GetValue = function(_) return selectedVal end
    }
    return dropdownObj
end

-- ============================================================================
-- ACTION BUTTON CONTROL (AddButton)
-- ============================================================================
function PolarUI:AddButton(cfg, cb, overrideParent)
    local name, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1]
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        callback = cb or function() end
    end

    local innerParent = resolveParent(self, overrideParent)
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. name
    btn.LayoutOrder = ord
    btn.Size = UDim2.new(1, -25, 0, 32)
    btn.BackgroundColor3 = Theme.ControlRow
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 210
    btn.Parent = innerParent

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextScaled = true
    lbl.TextColor3 = Theme.TextLight
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 211
    lbl.Parent = btn

    local lcConstraint = Instance.new("UITextSizeConstraint")
    lcConstraint.MaxTextSize = 13
    lcConstraint.MinTextSize = 8
    lcConstraint.Parent = lbl

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -12, 0.5, 0)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.BackgroundTransparency = 1
    arrow.BorderSizePixel = 0
    arrow.Text = "›"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextColor3 = Theme.TrackStroke
    arrow.ZIndex = 211
    arrow.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(30, 20, 45)
        }):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = Theme.ControlRow
            }):Play()
        end)
        callback()
    end)

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = name, Instance = btn })
    end

    local buttonObj = {
        Instance = btn,
        Name = name,
        Set = function(_, newName)
            lbl.Text = tostring(newName)
        end,
        Fire = function(_) callback() end
    }
    return buttonObj
end

-- ============================================================================
-- PARAGRAPH / TELEMETRY CARD (AddParagraph)
-- ============================================================================
function PolarUI:AddParagraph(cfg, textArg, overrideParent)
    local titleText, descText
    if type(cfg) == "table" then
        titleText = cfg.Title or cfg.Name or cfg[1] or "Info"
        descText = cfg.Text or cfg.Content or cfg.Desc or cfg[2] or ""
    else
        titleText = tostring(cfg)
        descText = tostring(textArg or "")
    end

    local innerParent = resolveParent(self, overrideParent)
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local card = Instance.new("Frame")
    card.Name = "Card_" .. titleText
    card.LayoutOrder = ord
    card.Size = UDim2.new(1, -24, 0, 62)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.ControlRow
    card.BackgroundTransparency = 0.40
    card.BorderSizePixel = 0
    card.ZIndex = 210
    card.Parent = innerParent

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = card

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 8)
    cPad.PaddingBottom = UDim.new(0, 8)
    cPad.PaddingLeft = UDim.new(0, 12)
    cPad.PaddingRight = UDim.new(0, 12)
    cPad.Parent = card

    local cl = Instance.new("UIListLayout")
    cl.Padding = UDim.new(0, 4)
    cl.SortOrder = Enum.SortOrder.LayoutOrder
    cl.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "TitleLabel"
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.BackgroundTransparency = 1
    titleLbl.BorderSizePixel = 0
    titleLbl.Text = titleText
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = Theme.TextLight
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 211
    titleLbl.Parent = card

    local div = Instance.new("Frame")
    div.Name = "Divider"
    div.Size = UDim2.new(1, 0, 0, 1)
    div.BackgroundColor3 = Theme.AccentDeep
    div.BackgroundTransparency = 0.78
    div.BorderSizePixel = 0
    div.ZIndex = 211
    div.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Name = "DescLabel"
    descLbl.Size = UDim2.new(1, 0, 0, 16)
    descLbl.AutomaticSize = Enum.AutomaticSize.Y
    descLbl.BackgroundTransparency = 1
    descLbl.BorderSizePixel = 0
    descLbl.Text = descText
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 11
    descLbl.TextColor3 = Theme.TextDesc
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextYAlignment = Enum.TextYAlignment.Top
    descLbl.TextWrapped = true
    descLbl.ZIndex = 211
    descLbl.Parent = card

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = titleText, Desc = descText, Instance = card })
    end

    local paraObj = {
        Instance = card,
        Name = titleText,
        Set = function(_, newCfg)
            if type(newCfg) == "table" then
                if newCfg.Title then titleLbl.Text = tostring(newCfg.Title) end
                if newCfg.Text or newCfg.Desc or newCfg.Content then
                    descLbl.Text = tostring(newCfg.Text or newCfg.Desc or newCfg.Content)
                end
            else
                descLbl.Text = tostring(newCfg)
            end
        end,
        SetTitle = function(_, newTitle)
            titleLbl.Text = tostring(newTitle)
        end,
        SetDesc = function(_, newDesc)
            descLbl.Text = tostring(newDesc)
        end,
        SetText = function(_, newText)
            descLbl.Text = tostring(newText)
        end
    }
    return paraObj
end

-- ============================================================================
-- TEXTBOX INPUT CONTROL (AddTextBox)
-- ============================================================================
function PolarUI:AddTextBox(cfg, ph, def, cb, overrideParent)
    local name, placeholder, defaultVal, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1]
        placeholder = cfg.PlaceholderText or cfg.Placeholder or "Escribe aquí..."
        defaultVal = cfg.Default or cfg.Value or ""
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        placeholder = ph or "Escribe aquí..."
        defaultVal = def or ""
        callback = cb or function() end
    end

    local innerParent = resolveParent(self, overrideParent)
    local ord = (innerParent:GetAttribute("Order") or 1) + 1
    innerParent:SetAttribute("Order", ord)

    local frame = Instance.new("Frame")
    frame.Name = "TextBox_" .. name
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, 36)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 0)
    tLabel.Size = UDim2.new(0.45, -10, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.BorderSizePixel = 0
    tLabel.Text = name
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextColor3 = Theme.TextLight
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 211
    tLabel.Parent = frame

    local inputContainer = Instance.new("Frame")
    inputContainer.AnchorPoint = Vector2.new(1, 0.5)
    inputContainer.Position = UDim2.new(1, -8, 0.5, 0)
    inputContainer.Size = UDim2.new(0.55, 0, 0, 24)
    inputContainer.BackgroundColor3 = Theme.PillBadge
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 211
    inputContainer.Parent = frame

    local icCorner = Instance.new("UICorner"); icCorner.CornerRadius = UDim.new(0, 6); icCorner.Parent = inputContainer
    local icStroke = Instance.new("UIStroke")
    icStroke.Color = Theme.BadgeStroke
    icStroke.Thickness = 1.0
    icStroke.Transparency = 0.45
    icStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    icStroke.Parent = inputContainer

    local box = Instance.new("TextBox")
    box.Position = UDim2.new(0, 6, 0, 0)
    box.Size = UDim2.new(1, -12, 1, 0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Text = tostring(defaultVal)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(160, 150, 185)
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.TextColor3 = Color3.fromRGB(240, 235, 255)
    box.ClearTextOnFocus = false
    box.ZIndex = 212
    box.Parent = inputContainer

    box.FocusLost:Connect(function()
        callback(box.Text)
    end)

    if self.Window and self.Window.RegisteredControls then
        table.insert(self.Window.RegisteredControls, { Name = name, Instance = frame })
    end

    local textBoxObj = {
        Instance = frame,
        Name = name,
        Set = function(_, val)
            box.Text = tostring(val)
            callback(val)
        end,
        GetValue = function(_) return box.Text end
    }
    return textBoxObj
end

return PolarUI
