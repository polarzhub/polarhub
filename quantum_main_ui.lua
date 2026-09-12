--[[
    ========================================================================
    [POLAR HUB / REVERSE-ENGINEERED MASTER ARTIFACT]
    Quantum Onyx — Main Script UI (Exact 1:1 Pixel-Perfect Recreation)
    ========================================================================
    Extracted directly from live memory dump (5,809 instances):
      - Scale: LibraryUIScale at 1.15 (115% scaling for authentic full sizing & crisp fonts)
      - Main Window: 510x330 px, AnchorPoint (0.5, 0.5), #0A0A0A (Trans 0.05), Corner 10px, Borderless
      - Floating Toggle Icon: 60x60 px Circle at {0.016, 0}, {0.219, 0} (Asset: rbxassetid://87383580130479)
      - Typography: 100% GothamBold for titles, controls, badges, headers, tabs; Gotham for descriptions
      - Detailed Purple/Violet Outlines (UIStroke):
        * Config. & Credits pill buttons: Color #A064F0, Thickness 1.0, Transparency 0.32, Round join
        * Number Badges (180, 22, 400): Color #C084FC, Thickness 1.0, Transparency 0.32, Round join
        * Dropdown Badges (Pirates): Color #C084FC, Thickness 1.0, Transparency 0.32, Round join
        * Slider Tracks: Color #8C5ADC, Thickness 1.0, Transparency 0.50
      - Header Bar: TitleHub ("Quantum Onyx Project", GothamBold 13px), SubtitleHub (Gotham 11px),
        "Config." (81151604784579) and "Credits" (83474083071373) pill buttons with
        left vertical neon gradient accent strips, Minimize (92966930061759) and Close (79324227570635).
      - Authentic Config. Modal (270x270 px) & Credits Modal (270x270 px):
        Icon, Title (GothamBold 15px), gradient divider line, scrolling lists, and bottom purple "Cerrar" button.
      - Tab Bar: SearchBarFrame at {0, 8}, {0, 1} with magnifying glass (3926305904), clear button, and count badge.
        Horizontal scrolling strip of 12 tabs with authentic asset IDs, GothamBold 14px font,
        and glowing gradient underline indicator.
      - Dual-Column Content Architecture:
        Col1 ({0, 240}, {0, 260}) and Col2 ({0, 240}, {0, 260}), ScrollBarThickness = 0, 19px column padding.
      - Subheaders: Centered title (GothamBold 15px white) flanked by dual multi-color cyber gradient lines
        (#3C145A -> #5A2882 -> #3C3CA0 -> #2864BE -> #1E8CC8 at 60 deg).
      - Multi-line Toggles: 63px height for Bypass TP with wrapped Gotham 11px description.
      - Sliders: Frame {1, -25}, {0, 54} with GothamBold 13px title, number badge TextBox ({0, 46}, {0, 20}, GothamBold 12px, #C084FC),
        10px track, lavender fill gradient (#8B5CF6 -> #D8B4FE), and white thumb knob (13x13px) with inner violet dot (#C084FC, 5x5px).
    ========================================================================
]]--

local QuantumOnyxUI = {}
QuantumOnyxUI.__index = QuantumOnyxUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Exact Color Tokens from Memory Dump
local Theme = {
    WindowBase = Color3.fromRGB(10, 10, 10),      -- #0A0A0A (Trans 0.05)
    InnerCard = Color3.fromRGB(25, 25, 25),       -- #191919 (Trans 0.30)
    ControlRow = Color3.fromRGB(5, 5, 5),         -- #050505 (Trans 0.40)
    PillBadge = Color3.fromRGB(12, 12, 18),        -- #0C0C12
    SearchBase = Color3.fromRGB(22, 17, 34),       -- #161122 (Trans 0.40)
    ModalBase = Color3.fromRGB(11, 8, 18),        -- #0B0812
    
    Accent = Color3.fromRGB(192, 132, 252),        -- #C084FC (Primary Violet Bloom)
    AccentGlow = Color3.fromRGB(160, 100, 255),    -- #A064FF
    AccentDeep = Color3.fromRGB(110, 55, 190),     -- #6E37BE
    AccentStroke = Color3.fromRGB(160, 100, 240),   -- #A064F0 (Vivid Purple Outline)
    BadgeStroke = Color3.fromRGB(192, 132, 252),    -- #C084FC (Bright Badge Outline)
    TrackStroke = Color3.fromRGB(140, 90, 220),    -- #8C5ADC
    
    SwitchOff = Color3.fromRGB(15, 15, 15),        -- #0F0F0F
    SwitchOn = Color3.fromRGB(15, 15, 15),         -- #0F0F0F
    
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextLight = Color3.fromRGB(220, 220, 230),     -- #DCDCE6
    TextDim = Color3.fromRGB(210, 210, 220),       -- #D2D2DC
    TextMuted = Color3.fromRGB(120, 120, 120),     -- #787878
    TextDesc = Color3.fromRGB(130, 130, 145),      -- #828291
    TextTabOff = Color3.fromRGB(130, 120, 155)     -- #82789B
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

function QuantumOnyxUI.new(customTitle, customSub)
    local self = setmetatable({}, QuantumOnyxUI)
    
    -- Target Parent
    local parentGui = nil
    if gethui then pcall(function() parentGui = gethui() end) end
    if not parentGui then
        parentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Cleanup of old recreation instances
    local function cleanOld(container)
        if not container then return end
        pcall(function()
            for _, c in ipairs(container:GetChildren()) do
                if c.Name == "QuantumOnyx_Main_Recreation" then
                    c:Destroy()
                end
            end
        end)
    end
    cleanOld(game:GetService("CoreGui"))
    cleanOld(game:GetService("CoreGui"):FindFirstChild("RobloxGui"))
    if gethui then pcall(function() cleanOld(gethui()) end) end

    -- Hide original GUI to prevent double-rendered blurry ghosting
    pcall(function()
        local robloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if robloxGui then
            for _, c in ipairs(robloxGui:GetChildren()) do
                if c:IsA("ScreenGui") and c.Name ~= "QuantumOnyx_Main_Recreation" and #c:GetDescendants() > 2000 then
                    c.Enabled = false
                end
            end
        end
    end)

    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QuantumOnyx_Main_Recreation"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    self.ScreenGui = screenGui

    -- Authentic LibraryUIScale (1.15 for authentic comfortable 15% larger size and crisp fonts)
    local uiScale = Instance.new("UIScale")
    uiScale.Name = "LibraryUIScale"
    uiScale.Scale = 1.15
    uiScale.Parent = screenGui
    self.UIScale = uiScale

    -- 2. Floating Toggle Button (60x60 Circle at {0.016, 0}, {0.219, 0})
    local floatFrame = Instance.new("Frame")
    floatFrame.Name = "FloatToggle"
    floatFrame.Position = UDim2.new(0.016, 0, 0.219, 0)
    floatFrame.Size = UDim2.new(0, 60, 0, 60)
    floatFrame.BackgroundTransparency = 1
    floatFrame.ZIndex = 500
    floatFrame.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatFrame

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "ToggleLogo"
    floatBtn.Size = UDim2.new(1, 0, 1, 0)
    floatBtn.BackgroundTransparency = 1
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
    self.MainFrame = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    -- Toggle visibility animation via Floating Button
    local isVisible = true
    floatBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if isVisible then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 510, 0, 330)
            }):Play()
        else
            local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isVisible then mainFrame.Visible = false end
            end)
        end
    end)

    -- Window Dragging Logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Position.Y - mainFrame.AbsolutePosition.Y <= 34 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
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
    topBar.ZIndex = 205
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleHub"
    titleLabel.Position = UDim2.new(0, 12, 0, 2)
    titleLabel.Size = UDim2.new(1, -255, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = customTitle or "Quantum Onyx Project"
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
    subtitleLabel.RichText = true
    subtitleLabel.Text = customSub or '<font color="#C084FC">Blox Fruit</font> • <font color="#FFD700">v.Premium</font> • <font color="#FF9E9E">Saturday</font>'
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
        modal.BackgroundTransparency = 0
        modal.BorderSizePixel = 0
        modal.ZIndex = 2000
        modal.Parent = mainFrame

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(0, 12)
        mc.Parent = modal

        local ms = Instance.new("UIStroke")
        ms.Color = Theme.AccentStroke
        ms.Thickness = 1.0
        ms.Transparency = 0.35
        ms.LineJoinMode = Enum.LineJoinMode.Round
        ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ms.Parent = modal

        -- Top gradient background header
        local mTop = Instance.new("Frame")
        mTop.Size = UDim2.new(1, 0, 0.45, 0)
        mTop.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
        mTop.BackgroundTransparency = 0.92
        mTop.BorderSizePixel = 0
        mTop.ZIndex = 2001
        mTop.Parent = modal
        local mtc = Instance.new("UICorner")
        mtc.CornerRadius = UDim.new(0, 12)
        mtc.Parent = mTop
        local mtg = Instance.new("UIGradient")
        mtg.Rotation = 90
        mtg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 160))
        })
        mtg.Parent = mTop

        -- Header Icon (20x20 at {0.5, 0}, {0, 14})
        local mIcon = Instance.new("ImageLabel")
        mIcon.AnchorPoint = Vector2.new(0.5, 0)
        mIcon.Position = UDim2.new(0.5, 0, 0, 14)
        mIcon.Size = UDim2.new(0, 20, 0, 20)
        mIcon.BackgroundTransparency = 1
        mIcon.Image = iconId
        mIcon.ImageColor3 = Color3.fromRGB(190, 140, 255)
        mIcon.ZIndex = 2002
        mIcon.Parent = modal

        -- Title (15px GothamBold at {0.5, 0}, {0, 38})
        local mTitle = Instance.new("TextLabel")
        mTitle.AnchorPoint = Vector2.new(0.5, 0)
        mTitle.Position = UDim2.new(0.5, 0, 0, 38)
        mTitle.Size = UDim2.new(1, -24, 0, 16)
        mTitle.BackgroundTransparency = 1
        mTitle.Text = titleText
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 15
        mTitle.TextColor3 = Color3.fromRGB(210, 175, 255)
        mTitle.TextXAlignment = Enum.TextXAlignment.Center
        mTitle.ZIndex = 2002
        mTitle.Parent = modal

        -- Gradient divider line ({0.65, 0}, {0, 1} at {0.5, 0}, {0, 57})
        local mDiv = Instance.new("Frame")
        mDiv.AnchorPoint = Vector2.new(0.5, 0)
        mDiv.Position = UDim2.new(0.5, 0, 0, 57)
        mDiv.Size = UDim2.new(0.65, 0, 0, 1)
        mDiv.BackgroundColor3 = Color3.fromRGB(160, 100, 255)
        mDiv.BackgroundTransparency = 0.72
        mDiv.BorderSizePixel = 0
        mDiv.ZIndex = 2002
        mDiv.Parent = modal
        local mdg = Instance.new("UIGradient")
        mdg.Color = UnderlineGradient
        mdg.Parent = mDiv

        -- Body ScrollingFrame ({1, -16}, {1, -100} at {0.5, 0}, {0, 64})
        local mScroll = Instance.new("ScrollingFrame")
        mScroll.AnchorPoint = Vector2.new(0.5, 0)
        mScroll.Position = UDim2.new(0.5, 0, 0, 64)
        mScroll.Size = UDim2.new(1, -16, 1, -100)
        mScroll.BackgroundTransparency = 1
        mScroll.ScrollBarThickness = 0
        mScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        mScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        mScroll.ZIndex = 2002
        mScroll.Parent = modal

        local ml = Instance.new("UIListLayout")
        ml.Padding = UDim.new(0, 6)
        ml.SortOrder = Enum.SortOrder.LayoutOrder
        ml.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ml.Parent = mScroll

        local mp = Instance.new("UIPadding")
        mp.PaddingLeft = UDim.new(0, 4)
        mp.PaddingRight = UDim.new(0, 4)
        mp.PaddingTop = UDim.new(0, 4)
        mp.PaddingBottom = UDim.new(0, 4)
        mp.Parent = mScroll

        -- Bottom Close Button ("Cerrar" / "Close", {0.52, 0}, {0, 24} at {0.5, 0}, {1, -9})
        local mClose = Instance.new("TextButton")
        mClose.Name = "CloseBtn"
        mClose.AnchorPoint = Vector2.new(0.5, 1)
        mClose.Position = UDim2.new(0.5, 0, 1, -9)
        mClose.Size = UDim2.new(0.52, 0, 0, 24)
        mClose.BackgroundColor3 = Color3.fromRGB(30, 18, 52)
        mClose.BorderSizePixel = 0
        mClose.Text = "Cerrar"
        mClose.Font = Enum.Font.GothamBold
        mClose.TextSize = 11
        mClose.TextColor3 = Color3.fromRGB(180, 135, 255)
        mClose.ZIndex = 2003
        mClose.Parent = modal

        local mcc = Instance.new("UICorner")
        mcc.CornerRadius = UDim.new(0, 6)
        mcc.Parent = mClose

        local mcs = Instance.new("UIStroke")
        mcs.Color = Theme.AccentStroke
        mcs.Thickness = 1.0
        mcs.Transparency = 0.35
        mcs.LineJoinMode = Enum.LineJoinMode.Round
        mcs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        mcs.Parent = mClose

        local function open()
            modalOverlay.Visible = true
            modal.Visible = true
            modal.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 270, 0, 270)
            }):Play()
        end

        local function close()
            local tw = TweenService:Create(modal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            tw:Play()
            tw.Completed:Connect(function()
                modal.Visible = false
                modalOverlay.Visible = false
            end)
        end

        mClose.MouseButton1Click:Connect(close)

        return {
            Frame = modal,
            Body = mScroll,
            CloseBtn = mClose,
            Open = open,
            Close = close
        }
    end

    -- Construct Config. Modal (matching memory dump & user image)
    local configModal = createAuthenticModal("Config", "Config.", "rbxassetid://81151604784579")
    do
        -- 1. Theme Dropdown Box
        local themeBox = Instance.new("TextButton")
        themeBox.Size = UDim2.new(1, 0, 0, 28)
        themeBox.BackgroundColor3 = Color3.fromRGB(18, 13, 30)
        themeBox.BackgroundTransparency = 0.20
        themeBox.BorderSizePixel = 0
        themeBox.Text = "None (theme default)"
        themeBox.Font = Enum.Font.GothamBold
        themeBox.TextSize = 10
        themeBox.TextColor3 = Color3.fromRGB(215, 185, 255)
        themeBox.ZIndex = 2004
        themeBox.Parent = configModal.Body
        local tbc = Instance.new("UICorner")
        tbc.CornerRadius = UDim.new(0, 6)
        tbc.Parent = themeBox
        local tbs = Instance.new("UIStroke")
        tbs.Color = Theme.AccentStroke
        tbs.Thickness = 1
        tbs.Transparency = 0.35
        tbs.LineJoinMode = Enum.LineJoinMode.Round
        tbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        tbs.Parent = themeBox

        -- 2. BG Image Fade Slider Box
        local fadeBox = Instance.new("Frame")
        fadeBox.Size = UDim2.new(1, 0, 0, 48)
        fadeBox.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
        fadeBox.BackgroundTransparency = 0.20
        fadeBox.BorderSizePixel = 0
        fadeBox.ZIndex = 2004
        fadeBox.Parent = configModal.Body
        local fbc = Instance.new("UICorner")
        fbc.CornerRadius = UDim.new(0, 8)
        fbc.Parent = fadeBox
        local fbs = Instance.new("UIStroke")
        fbs.Color = Theme.AccentStroke
        fbs.Thickness = 1
        fbs.Transparency = 0.35
        fbs.LineJoinMode = Enum.LineJoinMode.Round
        fbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        fbs.Parent = fadeBox

        local flbl = Instance.new("TextLabel")
        flbl.Position = UDim2.new(0, 14, 0, 6)
        flbl.Size = UDim2.new(1, -70, 0, 14)
        flbl.BackgroundTransparency = 1
        flbl.Text = "BG Image Fade"
        flbl.Font = Enum.Font.GothamBold
        flbl.TextSize = 11
        flbl.TextColor3 = Color3.fromRGB(215, 185, 255)
        flbl.TextXAlignment = Enum.TextXAlignment.Left
        flbl.ZIndex = 2005
        flbl.Parent = fadeBox

        local fVal = Instance.new("TextLabel")
        fVal.AnchorPoint = Vector2.new(1, 0)
        fVal.Position = UDim2.new(1, -10, 0, 6)
        fVal.Size = UDim2.new(0, 44, 0, 14)
        fVal.BackgroundTransparency = 1
        fVal.Text = "88%"
        fVal.Font = Enum.Font.GothamBold
        fVal.TextSize = 11
        fVal.TextColor3 = Color3.fromRGB(192, 132, 252)
        fVal.TextXAlignment = Enum.TextXAlignment.Right
        fVal.ZIndex = 2005
        fVal.Parent = fadeBox

        local fTrack = Instance.new("Frame")
        fTrack.Position = UDim2.new(0, 12, 0, 28)
        fTrack.Size = UDim2.new(1, -24, 0, 10)
        fTrack.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
        fTrack.BorderSizePixel = 0
        fTrack.ZIndex = 2005
        fTrack.Parent = fadeBox
        local ftc = Instance.new("UICorner")
        ftc.CornerRadius = UDim.new(1, 0)
        ftc.Parent = fTrack
        local fts = Instance.new("UIStroke")
        fts.Color = Theme.TrackStroke
        fts.Thickness = 1
        fts.Transparency = 0.50
        fts.LineJoinMode = Enum.LineJoinMode.Round
        fts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        fts.Parent = fTrack

        local fFill = Instance.new("Frame")
        fFill.Size = UDim2.new(0.88, 0, 1, 0)
        fFill.BackgroundColor3 = Theme.AccentGlow
        fFill.BorderSizePixel = 0
        fFill.ZIndex = 2006
        fFill.Parent = fTrack
        local ffc = Instance.new("UICorner")
        ffc.CornerRadius = UDim.new(1, 0)
        ffc.Parent = fFill
        local ffg = Instance.new("UIGradient")
        ffg.Color = LavenderGradient
        ffg.Parent = fFill
        local fThumb = Instance.new("Frame")
        fThumb.AnchorPoint = Vector2.new(0.5, 0.5)
        fThumb.Position = UDim2.new(0.88, 0, 0.5, 0)
        fThumb.Size = UDim2.new(0, 12, 0, 12)
        fThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fThumb.BorderSizePixel = 0
        fThumb.ZIndex = 2007
        fThumb.Parent = fTrack
        local ftcc = Instance.new("UICorner")
        ftcc.CornerRadius = UDim.new(1, 0)
        ftcc.Parent = fThumb

        -- 3. UI Font Section Header
        local fontHdr = Instance.new("TextLabel")
        fontHdr.Size = UDim2.new(1, 0, 0, 16)
        fontHdr.BackgroundTransparency = 1
        fontHdr.Text = "UI Font"
        fontHdr.Font = Enum.Font.GothamBold
        fontHdr.TextSize = 10
        fontHdr.TextColor3 = Color3.fromRGB(150, 105, 220)
        fontHdr.TextXAlignment = Enum.TextXAlignment.Center
        fontHdr.ZIndex = 2004
        fontHdr.Parent = configModal.Body

        -- 4. Font Option: ✓ Gotham (Active)
        local gothamBtn = Instance.new("TextButton")
        gothamBtn.Size = UDim2.new(1, 0, 0, 26)
        gothamBtn.BackgroundColor3 = Color3.fromRGB(30, 18, 52)
        gothamBtn.BackgroundTransparency = 0.20
        gothamBtn.BorderSizePixel = 0
        gothamBtn.Text = "✓ Gotham"
        gothamBtn.Font = Enum.Font.GothamBold
        gothamBtn.TextSize = 11
        gothamBtn.TextColor3 = Color3.fromRGB(215, 185, 255)
        gothamBtn.ZIndex = 2004
        gothamBtn.Parent = configModal.Body
        local gbc = Instance.new("UICorner")
        gbc.CornerRadius = UDim.new(0, 5)
        gbc.Parent = gothamBtn
        local gbs = Instance.new("UIStroke")
        gbs.Color = Theme.AccentStroke
        gbs.Thickness = 1
        gbs.Transparency = 0.35
        gbs.LineJoinMode = Enum.LineJoinMode.Round
        gbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        gbs.Parent = gothamBtn
    end

    -- Construct Credits Modal (matching memory dump)
    local creditsModal = createAuthenticModal("Credits", "Credits", "rbxassetid://83474083071373")
    do
        local teamHdr = Instance.new("TextLabel")
        teamHdr.Size = UDim2.new(1, 0, 0, 14)
        teamHdr.BackgroundTransparency = 1
        teamHdr.Text = "TEAM"
        teamHdr.Font = Enum.Font.GothamBold
        teamHdr.TextSize = 9
        teamHdr.TextColor3 = Color3.fromRGB(150, 105, 220)
        teamHdr.TextXAlignment = Enum.TextXAlignment.Center
        teamHdr.ZIndex = 2004
        teamHdr.Parent = creditsModal.Body

        local team = {
            { letter = "V", name = "Vin", role = "ServerOwner", color = Color3.fromRGB(255, 200, 80) },
            { letter = "F", name = "Flazhy", role = "MainDeveloper", color = Color3.fromRGB(175, 115, 255) },
            { letter = "K", name = "Kiel", role = "WebDesigner", color = Color3.fromRGB(100, 200, 255) },
            { letter = "C", name = "CudalPH", role = "Tester", color = Color3.fromRGB(80, 225, 160) },
            { letter = "P", name = "Pierce", role = "Support", color = Color3.fromRGB(175, 115, 255) },
        }

        for _, member in ipairs(team) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 50)
            card.BackgroundColor3 = Color3.fromRGB(10, 7, 18)
            card.BorderSizePixel = 0
            card.ZIndex = 2004
            card.Parent = creditsModal.Body
            local cc = Instance.new("UICorner")
            cc.CornerRadius = UDim.new(0, 8)
            cc.Parent = card
            local cs = Instance.new("UIStroke")
            cs.Color = member.color
            cs.Thickness = 1
            cs.Transparency = 0.50
            cs.LineJoinMode = Enum.LineJoinMode.Round
            cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            cs.Parent = card

            -- Avatar Badge
            local av = Instance.new("Frame")
            av.Position = UDim2.new(0, 10, 0.5, -16)
            av.Size = UDim2.new(0, 32, 0, 32)
            av.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
            av.BorderSizePixel = 0
            av.ZIndex = 2005
            av.Parent = card
            local avc = Instance.new("UICorner")
            avc.CornerRadius = UDim.new(1, 0)
            avc.Parent = av
            local avl = Instance.new("TextLabel")
            avl.Size = UDim2.new(1, 0, 1, 0)
            avl.BackgroundTransparency = 1
            avl.Text = member.letter
            avl.Font = Enum.Font.GothamBold
            avl.TextSize = 16
            avl.TextColor3 = member.color
            avl.ZIndex = 2006
            avl.Parent = av

            -- Name
            local nl = Instance.new("TextLabel")
            nl.Position = UDim2.new(0, 50, 0, 8)
            nl.Size = UDim2.new(1, -120, 0, 16)
            nl.BackgroundTransparency = 1
            nl.Text = member.name
            nl.Font = Enum.Font.GothamBold
            nl.TextSize = 13
            nl.TextColor3 = Color3.fromRGB(240, 235, 255)
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.ZIndex = 2005
            nl.Parent = card

            -- Role Badge
            local rb = Instance.new("Frame")
            rb.AnchorPoint = Vector2.new(1, 0.5)
            rb.Position = UDim2.new(1, -8, 0.5, 0)
            rb.Size = UDim2.new(0, 72, 0, 20)
            rb.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
            rb.BorderSizePixel = 0
            rb.ZIndex = 2005
            rb.Parent = card
            local rbc = Instance.new("UICorner")
            rbc.CornerRadius = UDim.new(0, 5)
            rbc.Parent = rb
            local rbl = Instance.new("TextLabel")
            rbl.Size = UDim2.new(1, 0, 1, 0)
            rbl.BackgroundTransparency = 1
            rbl.Text = member.role
            rbl.Font = Enum.Font.GothamBold
            rbl.TextSize = 9
            rbl.TextColor3 = member.color
            rbl.ZIndex = 2006
            rbl.Parent = rb
        end
    end

    -- Header Button Builder (Config. & Credits with authentic glowing purple border)
    local function createHeaderPillButton(name, text, iconId, xOffset, onClick)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.AnchorPoint = Vector2.new(1, 0)
        btn.Position = UDim2.new(1, xOffset, 0, 4)
        btn.Size = UDim2.new(0, 83, 0, 23)
        btn.BackgroundColor3 = Color3.fromRGB(14, 10, 22)
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = 206
        btn.Parent = topBar

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = btn

        -- Authentic Purple Border (visible and fine)
        local bs = Instance.new("UIStroke")
        bs.Color = Theme.AccentStroke
        bs.Thickness = 1.0
        bs.Transparency = 0.32
        bs.LineJoinMode = Enum.LineJoinMode.Round
        bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bs.Parent = btn

        -- Left Vertical Neon Gradient Strip
        local strip = Instance.new("Frame")
        strip.Position = UDim2.new(0, 0, 0.5, -7)
        strip.Size = UDim2.new(0, 2, 0, 14)
        strip.BackgroundColor3 = Color3.fromRGB(160, 100, 240)
        strip.BorderSizePixel = 0
        strip.ZIndex = 207
        strip.Parent = btn
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = strip
        local sg = Instance.new("UIGradient")
        sg.Rotation = 90
        sg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 60, 220))
        })
        sg.Parent = strip

        -- Icon
        local icon = Instance.new("ImageLabel")
        icon.Position = UDim2.new(0, 8, 0.5, -7)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = Color3.fromRGB(185, 140, 255)
        icon.ZIndex = 207
        icon.Parent = btn

        -- Label
        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 27, 0, 0)
        lbl.Size = UDim2.new(1, -30, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(195, 155, 255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 207
        lbl.Parent = btn

        if onClick then
            btn.MouseButton1Click:Connect(onClick)
        end

        return btn
    end

    local configBtn = createHeaderPillButton("ConfigBtn", "Config.", "rbxassetid://81151604784579", -153, function()
        configModal.Open()
    end)
    local creditsBtn = createHeaderPillButton("CreditsBtn", "Credits", "rbxassetid://83474083071373", -62, function()
        creditsModal.Open()
    end)

    -- Minimize Button
    local minBtn = Instance.new("ImageButton")
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -34, 0, 16)
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.BackgroundTransparency = 1
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

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = searchBar

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
    searchIcon.Image = "rbxassetid://3926305904"
    searchIcon.ImageColor3 = Color3.fromRGB(175, 140, 230)
    searchIcon.ZIndex = 207
    searchIcon.Parent = searchBar

    local searchBox = Instance.new("TextBox")
    searchBox.Position = UDim2.new(0, 21, 0, 0)
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.BackgroundTransparency = 1
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
    searchCount.Text = "6"
    searchCount.Font = Enum.Font.GothamBold
    searchCount.TextSize = 9
    searchCount.TextColor3 = Color3.fromRGB(240, 225, 255)
    searchCount.ZIndex = 208
    searchCount.Parent = searchBar
    local scc = Instance.new("UICorner")
    scc.CornerRadius = UDim.new(1, 0)
    scc.Parent = searchCount

    -- Horizontal Scrollable Tab Strip ({0, 140}, {0, -3}, Size {1, -148}, {0, 30})
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Position = UDim2.new(0, 140, 0, -3)
    tabScroll.Size = UDim2.new(1, -148, 0, 30)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
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
    contentFrame.ZIndex = 205
    contentFrame.Parent = mainFrame

    -- Authenticated Tab Definitions with Memory-Extracted Asset IDs & Widths
    local TabDefs = {
        { name = "Main",          icon = "rbxassetid://88050097561287",  width = 63 },
        { name = "Home",          icon = "rbxassetid://130439434919073", width = 68 },
        { name = "Sub Farm",      icon = "rbxassetid://88173691221304",  width = 90 },
        { name = "Sea Event",     icon = "rbxassetid://115481449706054", width = 93 },
        { name = "Player",        icon = "rbxassetid://83474083071373",  width = 73 },
        { name = "Dragon Update", icon = "rbxassetid://102173201308116", width = 122 },
        { name = "Dungeon",       icon = "rbxassetid://104575804564229", width = 88 },
        { name = "Trials",        icon = "rbxassetid://138575837887336", width = 68 },
        { name = "Travel",        icon = "rbxassetid://125480398387209", width = 73 },
        { name = "Tiktok Shop",   icon = "rbxassetid://137995400175306", width = 104 },
        { name = "Misc",          icon = "rbxassetid://137985950260873", width = 60 },
        { name = "Webhook",       icon = "rbxassetid://82115431450716",  width = 89 },
    }

    self.TabFrames = {}
    self.TabDefs = TabDefs

    for idx, def in ipairs(TabDefs) do
        local isDefaultActive = (def.name == "Home")

        -- Tab Button (GothamBold 14px)
        local btn = Instance.new("TextButton")
        btn.Name = "TabBtn_" .. def.name
        btn.Size = UDim2.new(0, def.width, 0, 24)
        btn.BackgroundTransparency = 1
        btn.Text = def.name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = isDefaultActive and Theme.TextWhite or Theme.TextTabOff
        btn.TextXAlignment = Enum.TextXAlignment.Right
        btn.ZIndex = 207
        btn.Parent = tabScroll

        local btnPad = Instance.new("UIPadding")
        btnPad.PaddingRight = UDim.new(0, 4)
        btnPad.Parent = btn

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Position = UDim2.new(0, 5, 0.5, 0)
        tabIcon.AnchorPoint = Vector2.new(0, 0.5)
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = def.icon
        tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        tabIcon.ZIndex = 208
        tabIcon.Parent = btn

        -- Active Indicator (Glowing Violet Underline)
        local underline = Instance.new("Frame")
        underline.Name = "Tab_Underline"
        underline.AnchorPoint = Vector2.new(0.5, 0)
        underline.Position = UDim2.new(0.5, 0, 1, 1)
        underline.Size = UDim2.new(0.5, 0, 0, 3)
        underline.Visible = isDefaultActive
        underline.BackgroundColor3 = Theme.AccentDeep
        underline.BorderSizePixel = 0
        underline.ZIndex = 209
        underline.Parent = btn
        local uc = Instance.new("UICorner")
        uc.CornerRadius = UDim.new(1, 0)
        uc.Parent = underline
        local ug = Instance.new("UIGradient")
        ug.Color = UnderlineGradient
        ug.Rotation = 0
        ug.Parent = underline

        -- Container View for this Tab
        local tabView = Instance.new("Frame")
        tabView.Name = "TabView_" .. def.name
        tabView.Size = UDim2.new(1, 0, 1, 0)
        tabView.BackgroundTransparency = 1
        tabView.Visible = isDefaultActive
        tabView.ZIndex = 206
        tabView.Parent = contentFrame

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
        col1.ScrollBarThickness = 0
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
        col2.ScrollBarThickness = 0
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

        self.TabFrames[def.name] = {
            View = tabView,
            Col1 = col1,
            Col2 = col2,
            Btn = btn,
            Underline = underline,
            Icon = tabIcon
        }

        btn.MouseButton1Click:Connect(function()
            for name, tabData in pairs(self.TabFrames) do
                local isActive = (name == def.name)
                tabData.View.Visible = isActive
                tabData.Btn.TextColor3 = isActive and Theme.TextWhite or Theme.TextTabOff
                tabData.Underline.Visible = isActive
            end
        end)
    end

    screenGui.Parent = parentGui
    return self
end

-- ============================================================================
-- EXACT SECTION BUILDER (Section -> InnerSection Container)
-- ============================================================================
function QuantumOnyxUI:CreateSectionCard(columnParent, titleText)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. titleText
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundTransparency = 1
    section.ZIndex = 208
    section.Parent = columnParent

    -- The Real Dark Translucent Container (#191919 at 0.30 trans, Corner 6px, Center-aligned)
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

    local isc = Instance.new("UICorner")
    isc.CornerRadius = UDim.new(0, 6)
    isc.Parent = innerSection

    local isLayout = Instance.new("UIListLayout")
    isLayout.Padding = UDim.new(0, 3)
    isLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    isLayout.SortOrder = Enum.SortOrder.LayoutOrder
    isLayout.Parent = innerSection

    innerSection:SetAttribute("Order", 1)

    -- Subheader with Multi-Color Cyber Gradient Lines ({1, 0}, {0, 22})
    local subheader = Instance.new("Frame")
    subheader.Name = "Subheader"
    subheader.LayoutOrder = 1
    subheader.Size = UDim2.new(1, 0, 0, 22)
    subheader.BackgroundTransparency = 1
    subheader.ZIndex = 209
    subheader.Parent = innerSection

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0.2, 0, 0, 0)
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextColor3 = Theme.TextWhite
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 210
    title.Parent = subheader

    -- Flanking Cyber Gradient Lines ({0.2, 0}, {0, 10} with UICorner 0.5, 0 and 60 deg gradient)
    local function createCyberLine(pos)
        local f = Instance.new("Frame")
        f.Position = pos
        f.Size = UDim2.new(0.2, 0, 0, 10)
        f.BackgroundColor3 = Theme.Accent
        f.BorderSizePixel = 0
        f.ZIndex = 209
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.5, 0)
        c.Parent = f
        local g = Instance.new("UIGradient")
        g.Rotation = 60
        g.Color = CyberGradient
        g.Parent = f
        f.Parent = subheader
    end

    createCyberLine(UDim2.new(0, 0, 0.5, -1))
    createCyberLine(UDim2.new(0.8, 0, 0.5, -1))

    return innerSection
end

-- Selector Card Control (e.g. Debug Functions / Secret Quests)
function QuantumOnyxUI:AddSelectorCard(innerParent, labelText, valueText, callback)
    callback = callback or function() end
    local ord = (innerParent:GetAttribute("Order") or 1) + 1; innerParent:SetAttribute("Order", ord)

    local card = Instance.new("Frame")
    card.Name = "Card_" .. labelText
    card.LayoutOrder = ord
    card.Size = UDim2.new(1, -24, 0, 62)
    card.BackgroundColor3 = Theme.ControlRow
    card.BackgroundTransparency = 0.40
    card.BorderSizePixel = 0
    card.ZIndex = 210
    card.Parent = innerParent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = card

    local cs = Instance.new("UIStroke")
    cs.Color = Theme.AccentStroke
    cs.Thickness = 1.0
    cs.Transparency = 0.55
    cs.LineJoinMode = Enum.LineJoinMode.Round
    cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cs.Parent = card

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
    titleLbl.Text = labelText
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
    descLbl.BackgroundTransparency = 1
    descLbl.Text = valueText or "None"
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 11
    descLbl.TextColor3 = Theme.TextDesc
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 211
    descLbl.Parent = card

    return card
end

-- Dropdown Selector Control (Pill Badge with Fine Violet Outline & Chevron Icon 95968409641902)
function QuantumOnyxUI:AddDropdown(innerParent, labelText, options, defaultOption, callback)
    callback = callback or function(opt) end
    local selected = defaultOption or (options[1] or "Select...")
    local ord = (innerParent:GetAttribute("Order") or 1) + 1; innerParent:SetAttribute("Order", ord)

    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. labelText
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, 32)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 12, 0, 0)
    tLabel.Size = UDim2.new(1, -95, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextScaled = true
    tLabel.TextColor3 = Theme.TextLight
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 211
    tLabel.Parent = frame
    local tcConstraint = Instance.new("UITextSizeConstraint")
    tcConstraint.MaxTextSize = 13
    tcConstraint.MinTextSize = 8
    tcConstraint.Parent = tLabel

    -- Option Pill Badge (#0C0C12, fine authentic violet stroke #C084FC)
    local pillBadge = Instance.new("Frame")
    pillBadge.Position = UDim2.new(1, -90, 0.5, -11)
    pillBadge.Size = UDim2.new(0, 68, 0, 22)
    pillBadge.BackgroundColor3 = Theme.PillBadge
    pillBadge.BackgroundTransparency = 0.15
    pillBadge.BorderSizePixel = 0
    pillBadge.ZIndex = 211
    pillBadge.Parent = frame

    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 5)
    pbc.Parent = pillBadge

    -- Fine detailed violet border (crisp and visible)
    local pbs = Instance.new("UIStroke")
    pbs.Color = Theme.BadgeStroke
    pbs.Thickness = 1.0
    pbs.Transparency = 0.32
    pbs.LineJoinMode = Enum.LineJoinMode.Round
    pbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pbs.Parent = pillBadge

    local valLabel = Instance.new("TextLabel")
    valLabel.Position = UDim2.new(0, 6, 0, 0)
    valLabel.Size = UDim2.new(1, -8, 1, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = selected
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextScaled = true
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Left
    valLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valLabel.ZIndex = 212
    valLabel.Parent = pillBadge
    local vbcConstraint = Instance.new("UITextSizeConstraint")
    vbcConstraint.MaxTextSize = 11
    vbcConstraint.MinTextSize = 8
    vbcConstraint.Parent = valLabel

    -- Dropdown Arrow (asset 95968409641902)
    local arrow = Instance.new("ImageButton")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://95968409641902"
    arrow.ImageColor3 = Theme.Accent
    arrow.ZIndex = 212
    arrow.Parent = frame

    -- Dropdown Selection Modal
    local modal = Instance.new("Frame")
    modal.Name = "DropdownModal_" .. labelText
    modal.Visible = false
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.Size = UDim2.new(0, 250, 0, 260)
    modal.BackgroundColor3 = Theme.ModalBase
    modal.BorderSizePixel = 0
    modal.ZIndex = 2000
    modal.Parent = self.MainFrame

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 8)
    mc.Parent = modal

    local ms = Instance.new("UIStroke")
    ms.Color = Theme.AccentStroke
    ms.Thickness = 1.0
    ms.Transparency = 0.35
    ms.LineJoinMode = Enum.LineJoinMode.Round
    ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ms.Parent = modal

    local mHeader = Instance.new("Frame")
    mHeader.Size = UDim2.new(1, 0, 0, 30)
    mHeader.BackgroundTransparency = 1
    mHeader.ZIndex = 2001
    mHeader.Parent = modal

    local mTitle = Instance.new("TextLabel")
    mTitle.Position = UDim2.new(0, 12, 0, 0)
    mTitle.Size = UDim2.new(1, -40, 1, 0)
    mTitle.BackgroundTransparency = 1
    mTitle.Text = labelText
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 13
    mTitle.TextColor3 = Theme.TextWhite
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 2002
    mTitle.Parent = mHeader

    local mClose = Instance.new("TextButton")
    mClose.AnchorPoint = Vector2.new(1, 0.5)
    mClose.Position = UDim2.new(1, -8, 0.5, 0)
    mClose.Size = UDim2.new(0, 20, 0, 20)
    mClose.BackgroundTransparency = 1
    mClose.Text = "✕"
    mClose.Font = Enum.Font.GothamBold
    mClose.TextSize = 12
    mClose.TextColor3 = Theme.Accent
    mClose.ZIndex = 2002
    mClose.Parent = mHeader

    local mScroll = Instance.new("ScrollingFrame")
    mScroll.Position = UDim2.new(0, 10, 0, 34)
    mScroll.Size = UDim2.new(1, -20, 1, -42)
    mScroll.BackgroundTransparency = 1
    mScroll.ScrollBarThickness = 2
    mScroll.ScrollBarImageColor3 = Theme.AccentDeep
    mScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mScroll.ZIndex = 2001
    mScroll.Parent = modal

    local ml = Instance.new("UIListLayout")
    ml.Padding = UDim.new(0, 4)
    ml.SortOrder = Enum.SortOrder.LayoutOrder
    ml.Parent = mScroll

    local function openModal()
        modal.Visible = true
        modal.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 260)
        }):Play()
    end

    local function closeModal()
        local tw = TweenService:Create(modal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            modal.Visible = false
        end)
    end

    mClose.MouseButton1Click:Connect(closeModal)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = Theme.ControlRow
        optBtn.BackgroundTransparency = 0.4
        optBtn.Text = "  " .. opt
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 11
        optBtn.TextColor3 = (opt == selected) and Theme.Accent or Theme.TextWhite
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 2003
        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 4)
        oc.Parent = optBtn
        optBtn.Parent = mScroll

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            valLabel.Text = opt
            closeModal()
            callback(opt)
        end)
    end

    local clickBlock = Instance.new("TextButton")
    clickBlock.Size = UDim2.new(1, 0, 1, 0)
    clickBlock.BackgroundTransparency = 1
    clickBlock.Text = ""
    clickBlock.ZIndex = 213
    clickBlock.Parent = frame
    clickBlock.MouseButton1Click:Connect(openModal)
    arrow.MouseButton1Click:Connect(openModal)

    return frame
end

-- Toggle Switch Control (Switch Pill #0F0F0F + Asset 12266946128 Knob with 90-degree Cyber Gradient)
function QuantumOnyxUI:AddToggle(innerParent, labelText, descText, defaultVal, callback)
    callback = callback or function(v) end
    local isToggled = defaultVal or false
    -- Height: 63px for multi-line description (like Bypass TP), 32px for single line
    local isMultiLine = descText and #descText > 30
    local height = isMultiLine and 63 or (descText and 42 or 32)
    local ord = (innerParent:GetAttribute("Order") or 1) + 1; innerParent:SetAttribute("Order", ord)

    local btn = Instance.new("TextButton")
    btn.Name = "Toggle_" .. labelText
    btn.LayoutOrder = ord
    btn.Size = UDim2.new(1, -25, 0, height)
    btn.BackgroundColor3 = Theme.ControlRow
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 210
    btn.Parent = innerParent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, descText and 4 or 0)
    tLabel.Size = UDim2.new(1, -66, 0, descText and 18 or height)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText
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

    if descText then
        local dLabel = Instance.new("TextLabel")
        dLabel.Name = "DescLabel"
        dLabel.Position = UDim2.new(0, 10, 0, 22)
        dLabel.Size = UDim2.new(1, -60, 0, isMultiLine and 35 or 14)
        dLabel.BackgroundTransparency = 1
        dLabel.Text = descText
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 11
        dLabel.TextColor3 = Theme.TextDesc
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextYAlignment = Enum.TextYAlignment.Top
        dLabel.TextWrapped = true
        dLabel.ZIndex = 211
        dLabel.Parent = btn
    end

    -- Switch Capsule (36x18 at {1, -50}, {0.5, -9})
    local capsule = Instance.new("Frame")
    capsule.Position = UDim2.new(1, -50, 0.5, -9)
    capsule.Size = UDim2.new(0, 36, 0, 18)
    capsule.BackgroundColor3 = Theme.SwitchOff
    capsule.BorderSizePixel = 0
    capsule.ZIndex = 211
    capsule.Parent = btn

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = capsule

    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(100, 100, 120)
    cs.Thickness = 1.2
    cs.Transparency = 0.55
    cs.LineJoinMode = Enum.LineJoinMode.Round
    cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cs.Parent = capsule

    -- Knob ImageLabel (asset 12266946128) with 90-degree 5-color cyber gradient
    local knob = Instance.new("ImageLabel")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = isToggled and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundTransparency = 1
    knob.ImageTransparency = isToggled and 0.0 or 0.5
    knob.Image = "http://www.roblox.com/asset/?id=12266946128"
    knob.ImageColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 212
    knob.Parent = capsule

    local kg = Instance.new("UIGradient")
    kg.Rotation = 90
    kg.Color = CyberGradient
    kg.Parent = knob

    btn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        local targetPos = isToggled and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetTextCol = isToggled and Theme.TextWhite or Theme.TextMuted

        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPos,
            ImageTransparency = isToggled and 0.0 or 0.5
        }):Play()
        tLabel.TextColor3 = targetTextCol

        callback(isToggled)
    end)

    return btn
end

-- Slider Control (Authentic Track + Lavender Fill Gradient + Number Badge with Detailed Purple Stroke)
function QuantumOnyxUI:AddSlider(innerParent, labelText, minVal, maxVal, defaultVal, callback)
    callback = callback or function(v) end
    local currentVal = defaultVal or minVal
    local ord = (innerParent:GetAttribute("Order") or 1) + 1; innerParent:SetAttribute("Order", ord)

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. labelText
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, 54)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -70, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = labelText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Theme.TextLight
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 211
    title.Parent = frame

    -- Value Badge TextBox ({0, 46}, {0, 20} at {1, -56}, {0, 6}, GothamBold 12px, #C084FC)
    -- With AUTHENTIC VIVID VIOLET OUTLINE
    local valBox = Instance.new("TextBox")
    valBox.Position = UDim2.new(1, -56, 0, 6)
    valBox.Size = UDim2.new(0, 46, 0, 20)
    valBox.BackgroundColor3 = Theme.PillBadge
    valBox.BackgroundTransparency = 0.20
    valBox.Text = tostring(currentVal)
    valBox.Font = Enum.Font.GothamBold
    valBox.TextSize = 12
    valBox.TextColor3 = Theme.Accent
    valBox.ClearTextOnFocus = false
    valBox.ZIndex = 211
    local vbc = Instance.new("UICorner")
    vbc.CornerRadius = UDim.new(0, 5)
    vbc.Parent = valBox
    
    -- Fine detailed violet border (crisp and visible)
    local vbs = Instance.new("UIStroke")
    vbs.Color = Theme.BadgeStroke
    vbs.Thickness = 1.0
    vbs.Transparency = 0.32
    vbs.LineJoinMode = Enum.LineJoinMode.Round
    vbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    vbs.Parent = valBox
    valBox.Parent = frame

    -- Slider Track Frame ({1, -24}, {0, 10} at {0, 12}, {0, 34})
    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 12, 0, 34)
    track.Size = UDim2.new(1, -24, 0, 10)
    track.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    track.BackgroundTransparency = 0.10
    track.BorderSizePixel = 0
    track.ZIndex = 211
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track
    local ts = Instance.new("UIStroke")
    ts.Color = Theme.TrackStroke
    ts.Thickness = 1.0
    ts.Transparency = 0.50
    ts.LineJoinMode = Enum.LineJoinMode.Round
    ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ts.Parent = track
    track.Parent = frame

    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentGlow
    fill.BorderSizePixel = 0
    fill.ZIndex = 212
    local filc = Instance.new("UICorner")
    filc.CornerRadius = UDim.new(1, 0)
    filc.Parent = fill
    local filg = Instance.new("UIGradient")
    filg.Color = LavenderGradient
    filg.Parent = fill
    fill.Parent = track

    -- Thumb Knob (13x13px white circle with stroke #C084FC and 5x5px inner dot)
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, 13, 0, 13)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 214
    local thc = Instance.new("UICorner")
    thc.CornerRadius = UDim.new(1, 0)
    thc.Parent = thumb
    local ths = Instance.new("UIStroke")
    ths.Color = Theme.Accent
    ths.Thickness = 1.5
    ths.Transparency = 0.30
    ths.LineJoinMode = Enum.LineJoinMode.Round
    ths.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ths.Parent = thumb
    thumb.Parent = track

    local innerDot = Instance.new("Frame")
    innerDot.Name = "InnerDot"
    innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerDot.Size = UDim2.new(0, 5, 0, 5)
    innerDot.BackgroundColor3 = Theme.Accent
    innerDot.BorderSizePixel = 0
    innerDot.ZIndex = 215
    local idc = Instance.new("UICorner")
    idc.CornerRadius = UDim.new(1, 0)
    idc.Parent = innerDot
    innerDot.Parent = thumb

    local dragging = false
    local function update(input)
        local posX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(posX, 0, 1, 0)
        thumb.Position = UDim2.new(posX, 0, 0.5, 0)
        local val = math.floor(minVal + ((maxVal - minVal) * posX))
        valBox.Text = tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    valBox.FocusLost:Connect(function()
        local num = tonumber(valBox.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            valBox.Text = tostring(num)
            local p = (num - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            callback(num)
        else
            valBox.Text = tostring(currentVal)
        end
    end)

    return frame
end

-- Action Button Control
function QuantumOnyxUI:AddButton(innerParent, labelText, callback)
    callback = callback or function() end
    local ord = (innerParent:GetAttribute("Order") or 1) + 1; innerParent:SetAttribute("Order", ord)

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. labelText
    btn.LayoutOrder = ord
    btn.Size = UDim2.new(1, -25, 0, 32)
    btn.BackgroundColor3 = Theme.ControlRow
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 210
    btn.Parent = innerParent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = Theme.AccentStroke
    bs.Thickness = 1.0
    bs.Transparency = 0.55
    bs.LineJoinMode = Enum.LineJoinMode.Round
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bs.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -36, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
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
    arrow.Text = "›"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextColor3 = Theme.Accent
    arrow.ZIndex = 211
    arrow.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================================
-- POPULATE HOME & SUB FARM TABS MATCHING ORIGINAL QUANTUM ONYX EXACTLY
-- ============================================================================

local app = QuantumOnyxUI.new()

-- 1. HOME TAB (Exact memory replica)
local homeTab = app.TabFrames["Home"]

-- Col1, Section 1: Magnet Event
local secMagnet = app:CreateSectionCard(homeTab.Col1, "Magnet Event")
app:AddToggle(secMagnet, "Auto Farm Magnet Tokens", nil, false)
app:AddToggle(secMagnet, "Auto Roll Magnet Gacha", nil, false)
app:AddButton(secMagnet, "Open Magnet Gacha GUI", function() print("[MAGNET] Opened Gacha GUI") end)
app:AddToggle(secMagnet, "Auto Complete Secret Quests", nil, false)
app:AddSelectorCard(secMagnet, "Secret Quests: 2/12 (16%)", "Completed: 2 | Remaining: 10")
app:AddDropdown(secMagnet, "Finished Secret Quests", {"Windmill Maintenance", "Bandit Cleanup", "Pirate Bounty"}, "Windmill Maintenance")
app:AddButton(secMagnet, "Refresh Secret Quests Tracker", function() print("[MAGNET] Refreshed Tracker") end)

-- Col1, Section 2: Main Farm
local secMainFarm = app:CreateSectionCard(homeTab.Col1, "Main Farm")
app:AddSelectorCard(secMainFarm, "Debug Functions", "None")
app:AddToggle(secMainFarm, "Auto Farm", nil, false)
app:AddToggle(secMainFarm, "Take Quest", "Accept Quest for Bones/Cakes", false)
app:AddToggle(secMainFarm, "Auto Bones", nil, false)
app:AddToggle(secMainFarm, "Enable Mastery", nil, false)
app:AddToggle(secMainFarm, "Auto Random Surprise", nil, false)
app:AddToggle(secMainFarm, "Auto Pray", nil, false)
app:AddToggle(secMainFarm, "Auto Try Luck", nil, false)
app:AddToggle(secMainFarm, "Auto Katakuri", nil, false)
app:AddToggle(secMainFarm, "Ignore Katakuri", nil, false)
app:AddToggle(secMainFarm, "Auto Dough King", nil, false)
app:AddToggle(secMainFarm, "Ignore Farm Dough King Item", nil, false)
app:AddDropdown(secMainFarm, "Select Material", {"Bones", "Demonic Soul", "Ectoplasm", "Scrap Metal"}, "Bones")
app:AddToggle(secMainFarm, "Auto Farm Material", nil, false)

-- Col1, Section 3: Boss Farm
local secBoss = app:CreateSectionCard(homeTab.Col1, "Boss Farm")
app:AddDropdown(secBoss, "Select Boss", {"Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader", "Vice Admiral", "Saber Expert"}, "Gorilla King")
app:AddToggle(secBoss, "Auto Farm Boss", nil, false)
app:AddToggle(secBoss, "Auto Kill All Bosses", nil, false)
app:AddToggle(secBoss, "Get Boss Quest", nil, false)

-- Col2, Section 1: Farm Settings
local secFarmSettings = app:CreateSectionCard(homeTab.Col2, "Farm Settings")
app:AddDropdown(secFarmSettings, "Select Team", {"Pirates", "Marines"}, "Pirates")
app:AddToggle(secFarmSettings, "Bypass TP", "Instantly teleports between distant islands (>3500 studs) via spawn point reset", false)
app:AddSlider(secFarmSettings, "Tweening Speed", 100, 350, 180)
app:AddSlider(secFarmSettings, "Farm Distance", 10, 60, 22)
app:AddSlider(secFarmSettings, "Bring Radius", 100, 600, 400)
app:AddToggle(secFarmSettings, "Start Bring", nil, true)
app:AddToggle(secFarmSettings, "Fast Attack", nil, true)
app:AddToggle(secFarmSettings, "Quantum Attack", nil, true)
app:AddToggle(secFarmSettings, "Auto Attack Gun", nil, false)
app:AddToggle(secFarmSettings, "Remove Fast Attack Animation", nil, false)
app:AddToggle(secFarmSettings, "attack mobs", nil, true)
app:AddToggle(secFarmSettings, "attack players", nil, false)
app:AddToggle(secFarmSettings, "Auto Activate Observation Haki", nil, false)
app:AddToggle(secFarmSettings, "Auto Set Spawn Point", nil, false)
app:AddToggle(secFarmSettings, "Debounce Quests", nil, false)
app:AddToggle(secFarmSettings, "Bypass Get Quest", nil, false)
app:AddToggle(secFarmSettings, "Auto Load Script on Load", nil, false)
app:AddToggle(secFarmSettings, "Disable Damage Counter", nil, false)
app:AddToggle(secFarmSettings, "Disable Notifications", nil, false)
app:AddToggle(secFarmSettings, "Walk in Water", nil, false)
app:AddToggle(secFarmSettings, "Auto Hop when 30mins", nil, false)
app:AddToggle(secFarmSettings, "Auto Hop When Admin Joined", nil, true)
app:AddToggle(secFarmSettings, "Anti Afk", nil, true)
app:AddToggle(secFarmSettings, "Remove Effects", nil, false)

-- Col2, Section 2: Skills Settings
local secSkills = app:CreateSectionCard(homeTab.Col2, "Skills Settings")
app:AddDropdown(secSkills, "Gun Skills", {"Z", "X", "C", "V"}, "Z")
app:AddToggle(secSkills, "Auto Use Skills", nil, false)
app:AddSlider(secSkills, "Gun Skill Delay (ms)", 0, 1000, 250)

-- 2. SUB FARM TAB
local subTab = app.TabFrames["Sub Farm"]
local secMat = app:CreateSectionCard(subTab.Col1, "Materials & Mastery")
app:AddDropdown(secMat, "Select Material", {"Ectoplasm", "Scrap Metal", "Magma Ore", "Dragon Scale", "Fish Tail"}, "Ectoplasm")
app:AddToggle(secMat, "Auto Farm Material", nil, false)
app:AddDropdown(secMat, "Mastery Weapon", {"Sword", "Gun", "Blox Fruit", "Melee"}, "Sword")
app:AddToggle(secMat, "Auto Farm Mastery", "Farms low health mobs to level weapons", false)

local secSubBoss = app:CreateSectionCard(subTab.Col2, "Boss Hunting")
app:AddDropdown(secSubBoss, "Select Boss", {"Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader", "Vice Admiral", "Saber Expert"}, "Gorilla King")
app:AddToggle(secSubBoss, "Auto Farm Boss", nil, false)
app:AddToggle(secSubBoss, "Auto Hop When Killed", "Server hops when target boss is dead", false)

-- 3. SEA EVENT TAB
local seaTab = app.TabFrames["Sea Event"]
local secBoat = app:CreateSectionCard(seaTab.Col1, "Sea Exploration")
app:AddDropdown(secBoat, "Select Boat", {"PirateBrigade", "Grand Brigade", "Sloop", "Dinghy"}, "PirateBrigade")
app:AddToggle(secBoat, "Auto Sail to Sea 6", nil, false)
app:AddSlider(secBoat, "Boat Speed", 100, 350, 230)

local secMonsters = app:CreateSectionCard(seaTab.Col2, "Sea Targets")
app:AddToggle(secMonsters, "Auto Kill Sea Beast", nil, false)
app:AddToggle(secMonsters, "Auto Kill Terror Shark", nil, false)
app:AddToggle(secMonsters, "Dodge Terror Shark", nil, true)

return QuantumOnyxUI
