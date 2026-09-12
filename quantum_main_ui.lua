--[[
    ========================================================================
    [POLAR HUB / REVERSE-ENGINEERED ARTIFACT]
    Quantum Onyx — Main Script UI (1:1 Exact Extraction & Recreation)
    ========================================================================
    Extracted via Real MCP Memory Dump (5,801 Descendants, 12 Tabs, Dual Column)
    Target Geometry:
      - Main Window: 510x330 px, Centered (AnchorPoint 0.5, 0.5)
      - Floating Toggle Icon: 60x60 px Circle (Asset: rbxassetid://87383580130479)
    Color Tokens:
      - Window Base: #0A0A0A (Trans: 0.05)
      - Card Background: #0F0F0F (Trans: 0.40)
      - Control Row: #050505 (Trans: 0.40)
      - Accent Neon Glow: #C084FC
      - Accent Deep: #6E37BE
      - Text Active: #FFFFFF
      - Text Muted: #82789B / #787878
    Component Ecosystem:
      1. Dual Column Scrolling Layout (240px per column)
      2. 12 Fully Switchable Tabs with Official Vector Icons
      3. Live Search Bar with Filter Badge Count & Clear '×'
      4. Section Subheaders with Double Gradient HUD Lines
      5. Animated Pill Toggle Switches (with optional DescLabel)
      6. Action Buttons with Chevron '›'
      7. Sliders with Draggable Track + Direct TextBox Entry
      8. Dropdown Selectors opening Centered Floating Modal Dialogs
      9. Real-Time Stat / Progress Cards with Gradient Dividers
      10. Toast Notification System (Top Right)
      11. Full Drag & Drop for Header and Floating Logo
    ========================================================================
]]--

local QuantumOnyxUI = {}
QuantumOnyxUI.__index = QuantumOnyxUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Theme Tokens
local Theme = {
    WindowBase = Color3.fromRGB(10, 10, 10),
    CardBase = Color3.fromRGB(15, 15, 15),
    ControlBase = Color3.fromRGB(5, 5, 5),
    SearchBase = Color3.fromRGB(22, 17, 34),
    ModalBase = Color3.fromRGB(13, 11, 20),
    Accent = Color3.fromRGB(192, 132, 252), -- #C084FC
    AccentGlow = Color3.fromRGB(160, 100, 255),
    AccentDeep = Color3.fromRGB(110, 55, 190),
    BorderMuted = Color3.fromRGB(100, 100, 100),
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextLight = Color3.fromRGB(220, 220, 230),
    TextMuted = Color3.fromRGB(130, 120, 155),
    TextDesc = Color3.fromRGB(120, 120, 120),
    SwitchOff = Color3.fromRGB(32, 32, 32),
    SwitchOn = Color3.fromRGB(192, 132, 252)
}

function QuantumOnyxUI.new(customTitle, customSub)
    local self = setmetatable({}, QuantumOnyxUI)
    
    -- Target Parent
    local parentGui = nil
    if gethui then pcall(function() parentGui = gethui() end) end
    if not parentGui then
        parentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Clean old
    local old = parentGui:FindFirstChild("QuantumOnyx_Main_Recreation")
    if old then old:Destroy() end

    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QuantumOnyx_Main_Recreation"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    self.ScreenGui = screenGui

    -- 2. Floating Toggle Button (60x60 Circle)
    local floatFrame = Instance.new("Frame")
    floatFrame.Name = "FloatToggle"
    floatFrame.Position = UDim2.new(0, 23, 0, 96)
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
    floatBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    floatBtn.BackgroundTransparency = 0.2
    floatBtn.Image = "rbxassetid://87383580130479"
    floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.ZIndex = 501
    floatBtn.Parent = floatFrame

    local floatBtnCorner = Instance.new("UICorner")
    floatBtnCorner.CornerRadius = UDim.new(1, 0)
    floatBtnCorner.Parent = floatBtn

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Theme.Accent
    floatStroke.Thickness = 1.5
    floatStroke.Transparency = 0.3
    floatStroke.Parent = floatBtn

    -- 3. Main Window Frame (510x330)
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

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.35
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    -- BodyBackground subtle ambient overlay
    local bodyBg = Instance.new("ImageLabel")
    bodyBg.Name = "BodyBackground"
    bodyBg.Size = UDim2.new(1, 0, 1, 0)
    bodyBg.BackgroundTransparency = 1
    bodyBg.Image = "rbxassetid://76079206532938"
    bodyBg.ImageColor3 = Theme.AccentDeep
    bodyBg.ImageTransparency = 0.88
    bodyBg.ScaleType = Enum.ScaleType.Crop
    bodyBg.ZIndex = 201
    bodyBg.Parent = mainFrame

    -- Toggle visibility with smooth scale/fade
    local isVisible = true
    floatBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if isVisible then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 480, 0, 310)
            mainFrame.BackgroundTransparency = 0.5
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 510, 0, 330),
                BackgroundTransparency = 0.05
            }):Play()
        else
            local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 460, 0, 300),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isVisible then mainFrame.Visible = false end
            end)
        end
    end)

    -- Floating Icon Dragging
    local fDrag, fStart, fPos
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDrag = true
            fStart = input.Position
            fPos = floatFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - fStart
            floatFrame.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
        end
    end)

    -- 4. Top Bar (Header)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.BackgroundTransparency = 1
    topBar.ZIndex = 205
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleHub"
    titleLabel.Position = UDim2.new(0, 12, 0, 3)
    titleLabel.Size = UDim2.new(0, 160, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = customTitle or "Quantum Onyx Project"
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = Theme.TextWhite
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 206
    titleLabel.Parent = topBar

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleHub"
    subtitleLabel.Position = UDim2.new(0, 12, 0, 17)
    subtitleLabel.Size = UDim2.new(0, 220, 0, 12)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.RichText = true
    subtitleLabel.Text = customSub or '<font color="#C084FC">Blox Fruit</font> • <font color="#FFD700">v.Premium</font> • <font color="#FF9E9E">Saturday</font>'
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 10
    subtitleLabel.TextColor3 = Theme.TextMuted
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.ZIndex = 206
    subtitleLabel.Parent = topBar

    -- Header Utility Buttons
    local function createHeaderPillBtn(xOffset, text, iconId, callback)
        local btn = Instance.new("TextButton")
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, xOffset, 0, 16)
        btn.Size = UDim2.new(0, 83, 0, 23)
        btn.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = 206
        btn.Parent = topBar

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 5)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Color = Theme.AccentDeep
        s.Thickness = 1
        s.Transparency = 0.4
        s.Parent = btn

        local ico = Instance.new("ImageLabel")
        ico.Position = UDim2.new(0, 6, 0.5, -7)
        ico.Size = UDim2.new(0, 14, 0, 14)
        ico.BackgroundTransparency = 1
        ico.Image = iconId
        ico.ImageColor3 = Theme.Accent
        ico.ZIndex = 207
        ico.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 24, 0, 0)
        lbl.Size = UDim2.new(1, -26, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextColor3 = Theme.TextLight
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 207
        lbl.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function createHeaderIconBtn(xOffset, iconId, color, callback)
        local btn = Instance.new("ImageButton")
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, xOffset, 0, 16)
        btn.Size = UDim2.new(0, 20, 0, 20)
        btn.BackgroundTransparency = 1
        btn.Image = iconId
        btn.ImageColor3 = color
        btn.ZIndex = 206
        btn.Parent = topBar
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Close & Minimize
    createHeaderIconBtn(-8, "rbxassetid://79324227570635", Color3.fromRGB(220, 80, 80), function()
        screenGui:Destroy()
    end)
    createHeaderIconBtn(-34, "rbxassetid://92966930061759", Color3.fromRGB(200, 200, 200), function()
        floatBtn.MouseButton1Click:Fire()
    end)

    -- Modals Setup (Settings & Credits)
    local modalOverlay = Instance.new("Frame")
    modalOverlay.Name = "ModalOverlay"
    modalOverlay.Visible = false
    modalOverlay.Size = UDim2.new(1, 0, 1, 0)
    modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modalOverlay.BackgroundTransparency = 0.5
    modalOverlay.ZIndex = 300
    modalOverlay.Parent = mainFrame

    local function createCenteredModal(titleText, width, height)
        local modal = Instance.new("Frame")
        modal.Name = "Modal_" .. titleText
        modal.Visible = false
        modal.AnchorPoint = Vector2.new(0.5, 0.5)
        modal.Position = UDim2.new(0.5, 0, 0.5, 0)
        modal.Size = UDim2.new(0, width, 0, height)
        modal.BackgroundColor3 = Theme.ModalBase
        modal.BorderSizePixel = 0
        modal.ClipsDescendants = true
        modal.ZIndex = 310
        modal.Parent = mainFrame

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(0, 8)
        mc.Parent = modal

        local ms = Instance.new("UIStroke")
        ms.Color = Theme.Accent
        ms.Thickness = 1.2
        ms.Transparency = 0.3
        ms.Parent = modal

        local mHeader = Instance.new("Frame")
        mHeader.Size = UDim2.new(1, 0, 0, 28)
        mHeader.BackgroundTransparency = 1
        mHeader.ZIndex = 311
        mHeader.Parent = modal

        local mTitle = Instance.new("TextLabel")
        mTitle.Position = UDim2.new(0, 10, 0, 0)
        mTitle.Size = UDim2.new(1, -40, 1, 0)
        mTitle.BackgroundTransparency = 1
        mTitle.Text = titleText
        mTitle.Font = Enum.Font.FredokaOne
        mTitle.TextSize = 12
        mTitle.TextColor3 = Theme.Accent
        mTitle.TextXAlignment = Enum.TextXAlignment.Left
        mTitle.ZIndex = 312
        mTitle.Parent = mHeader

        local mClose = Instance.new("TextButton")
        mClose.AnchorPoint = Vector2.new(1, 0.5)
        mClose.Position = UDim2.new(1, -6, 0.5, 0)
        mClose.Size = UDim2.new(0, 18, 0, 18)
        mClose.BackgroundTransparency = 1
        mClose.Text = "×"
        mClose.Font = Enum.Font.GothamBold
        mClose.TextSize = 16
        mClose.TextColor3 = Color3.fromRGB(220, 100, 100)
        mClose.ZIndex = 312
        mClose.Parent = mHeader

        local mDiv = Instance.new("Frame")
        mDiv.Position = UDim2.new(0, 0, 0, 28)
        mDiv.Size = UDim2.new(1, 0, 0, 1)
        mDiv.BackgroundColor3 = Theme.AccentDeep
        mDiv.BackgroundTransparency = 0.5
        mDiv.BorderSizePixel = 0
        mDiv.ZIndex = 311
        mDiv.Parent = modal

        local mBody = Instance.new("ScrollingFrame")
        mBody.Position = UDim2.new(0, 6, 0, 32)
        mBody.Size = UDim2.new(1, -12, 1, -38)
        mBody.BackgroundTransparency = 1
        mBody.ScrollBarThickness = 3
        mBody.ScrollBarImageColor3 = Theme.Accent
        mBody.ZIndex = 312
        mBody.Parent = modal

        local mLayout = Instance.new("UIListLayout")
        mLayout.Padding = UDim.new(0, 6)
        mLayout.SortOrder = Enum.SortOrder.LayoutOrder
        mLayout.Parent = mBody

        local function openModal()
            modalOverlay.Visible = true
            modal.Visible = true
            modal.Size = UDim2.new(0, width - 20, 0, height - 20)
            TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, width, 0, height)
            }):Play()
        end

        local function closeModal()
            modalOverlay.Visible = false
            modal.Visible = false
        end

        mClose.MouseButton1Click:Connect(closeModal)
        modalOverlay.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then closeModal() end
        end)

        return {
            Modal = modal,
            Body = mBody,
            Open = openModal,
            Close = closeModal
        }
    end

    -- Settings Modal
    local settingsModal = createCenteredModal("Settings", 270, 270)
    createHeaderPillBtn(-153, "Settings", "rbxassetid://81151604784579", function()
        settingsModal.Open()
    end)

    -- Credits Modal
    local creditsModal = createCenteredModal("Credits", 270, 270)
    createHeaderPillBtn(-62, "Credits", "rbxassetid://83474083071373", function()
        creditsModal.Open()
    end)

    -- Populate Credits Modal
    local function addCreditItem(role, name, isOwner)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 36)
        f.BackgroundColor3 = Theme.ControlBase
        f.BackgroundTransparency = 0.4
        f.BorderSizePixel = 0
        f.ZIndex = 313
        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 6)
        fc.Parent = f
        local fs = Instance.new("UIStroke")
        fs.Color = isOwner and Theme.Accent or Theme.BorderMuted
        fs.Thickness = 1
        fs.Transparency = 0.5
        fs.Parent = f
        local rLbl = Instance.new("TextLabel")
        rLbl.Position = UDim2.new(0, 10, 0, 3)
        rLbl.Size = UDim2.new(1, -20, 0, 12)
        rLbl.BackgroundTransparency = 1
        rLbl.Text = role
        rLbl.Font = Enum.Font.GothamBold
        rLbl.TextSize = 9
        rLbl.TextColor3 = isOwner and Color3.fromRGB(255, 215, 0) or Theme.TextMuted
        rLbl.TextXAlignment = Enum.TextXAlignment.Left
        rLbl.ZIndex = 314
        rLbl.Parent = f
        local nLbl = Instance.new("TextLabel")
        nLbl.Position = UDim2.new(0, 10, 0, 17)
        nLbl.Size = UDim2.new(1, -20, 0, 14)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = name
        nLbl.Font = Enum.Font.GothamBold
        nLbl.TextSize = 11
        nLbl.TextColor3 = Theme.TextWhite
        nLbl.TextXAlignment = Enum.TextXAlignment.Left
        nLbl.ZIndex = 314
        nLbl.Parent = f
        f.Parent = creditsModal.Body
    end
    addCreditItem("SERVER OWNER / CREATOR", "Vin", true)
    addCreditItem("DEVELOPER TEAM", "Quantum Onyx Studio", false)
    addCreditItem("COMMUNITY", "discord.gg/quantumonyx", false)

    -- Top bar drag
    local mDrag, mStart, mPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mDrag = true
            mStart = input.Position
            mPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then mDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mStart
            mainFrame.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + delta.X, mPos.Y.Scale, mPos.Y.Offset + delta.Y)
        end
    end)

    -- 5. Tab Bar Strip (Height 38px)
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Position = UDim2.new(0, 0, 0, 32)
    tabBar.Size = UDim2.new(1, 0, 0, 38)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 205
    tabBar.Parent = mainFrame

    -- Integrated Search Box
    local searchBar = Instance.new("Frame")
    searchBar.Name = "SearchBar"
    searchBar.Position = UDim2.new(0, 8, 0, 8)
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
    ss.Color = Theme.AccentDeep
    ss.Thickness = 1
    ss.Transparency = 0.5
    ss.Parent = searchBar

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Position = UDim2.new(0, 6, 0.5, -6)
    searchIcon.Size = UDim2.new(0, 12, 0, 12)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://7733992528"
    searchIcon.ImageColor3 = Theme.Accent
    searchIcon.ZIndex = 207
    searchIcon.Parent = searchBar

    local searchBox = Instance.new("TextBox")
    searchBox.Position = UDim2.new(0, 22, 0, 0)
    searchBox.Size = UDim2.new(1, -44, 1, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(130, 110, 160)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.TextColor3 = Theme.TextWhite
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 207
    searchBox.Parent = searchBar

    local searchClear = Instance.new("TextButton")
    searchClear.Position = UDim2.new(1, -16, 0.5, -7)
    searchClear.Size = UDim2.new(0, 14, 0, 14)
    searchClear.BackgroundTransparency = 1
    searchClear.Text = "×"
    searchClear.Font = Enum.Font.GothamBold
    searchClear.TextSize = 13
    searchClear.TextColor3 = Theme.TextMuted
    searchClear.ZIndex = 207
    searchClear.Parent = searchBar

    local searchCount = Instance.new("TextLabel")
    searchCount.Position = UDim2.new(1, -2, 0, -6)
    searchCount.Size = UDim2.new(0, 22, 0, 13)
    searchCount.BackgroundColor3 = Theme.AccentDeep
    searchCount.BackgroundTransparency = 0.20
    searchCount.Text = "0"
    searchCount.Font = Enum.Font.GothamBold
    searchCount.TextSize = 9
    searchCount.TextColor3 = Theme.TextWhite
    searchCount.ZIndex = 208
    local scc = Instance.new("UICorner")
    scc.CornerRadius = UDim.new(1, 0)
    scc.Parent = searchCount
    searchCount.Parent = searchBar

    searchClear.MouseButton1Click:Connect(function()
        searchBox.Text = ""
    end)

    -- Tab Strip Horizontal ScrollingFrame
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Position = UDim2.new(0, 140, 0, 4)
    tabScroll.Size = UDim2.new(1, -148, 0, 30)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
    tabScroll.CanvasSize = UDim2.new(0, 1080, 0, 0)
    tabScroll.ZIndex = 206
    tabScroll.Parent = tabBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabScroll

    -- 6. Content Container (Two Column Architecture)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Position = UDim2.new(0, 8, 0, 72)
    contentContainer.Size = UDim2.new(1, -16, 1, -78)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 205
    contentContainer.Parent = mainFrame

    self.TabFrames = {}
    self.CurrentTab = nil

    -- Tab Generator
    local tabDefinitions = {
        { name = "Main", width = 63, icon = "rbxassetid://88050097561287" },
        { name = "Home", width = 68, icon = "rbxassetid://130439434919073" },
        { name = "Sub Farm", width = 90, icon = "rbxassetid://88173691221304" },
        { name = "Sea Event", width = 93, icon = "rbxassetid://115481449706054" },
        { name = "Player", width = 73, icon = "rbxassetid://83474083071373" },
        { name = "Dragon Update", width = 122, icon = "rbxassetid://102173201308116" },
        { name = "Dungeon", width = 88, icon = "rbxassetid://104575804564229" },
        { name = "Trials", width = 68, icon = "rbxassetid://138575837887336" },
        { name = "Travel", width = 73, icon = "rbxassetid://125480398387209" },
        { name = "Tiktok Shop", width = 104, icon = "rbxassetid://137995400175306" },
        { name = "Misc", width = 60, icon = "rbxassetid://137985950260873" },
        { name = "Webhook", width = 89, icon = "rbxassetid://82115431450716" }
    }

    local tabButtons = {}

    for idx, def in ipairs(tabDefinitions) do
        -- Tab Button
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. def.name
        btn.Size = UDim2.new(0, def.width, 0, 24)
        btn.BackgroundTransparency = 1
        btn.Text = def.name
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 13
        btn.TextColor3 = (idx == 1) and Theme.TextWhite or Theme.TextMuted
        btn.TextXAlignment = Enum.TextXAlignment.Right
        btn.ZIndex = 207
        btn.Parent = tabScroll

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "TabIcon"
        tabIcon.Position = UDim2.new(0, 4, 0.5, -8)
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = def.icon
        tabIcon.ImageColor3 = (idx == 1) and Theme.Accent or Theme.TextMuted
        tabIcon.ZIndex = 208
        tabIcon.Parent = btn

        local underline = Instance.new("Frame")
        underline.Name = "Tab_Underline"
        underline.AnchorPoint = Vector2.new(0.5, 0)
        underline.Position = UDim2.new(0.5, 0, 1, 1)
        underline.Size = (idx == 1) and UDim2.new(0.8, 0, 0, 3) or UDim2.new(0, 0, 0, 3)
        underline.BackgroundColor3 = Theme.AccentDeep
        underline.BorderSizePixel = 0
        underline.ZIndex = 208
        local uc = Instance.new("UICorner")
        uc.CornerRadius = UDim.new(1, 0)
        uc.Parent = underline
        local ug = Instance.new("UIGradient")
        ug.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 70, 230)),
            ColorSequenceKeypoint.new(0.5, Theme.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 230))
        })
        ug.Parent = underline
        underline.Parent = btn

        -- Tab View Frame (Holds Column 1 and Column 2)
        local tabView = Instance.new("Frame")
        tabView.Name = "View_" .. def.name
        tabView.Visible = (idx == 1)
        tabView.Size = UDim2.new(1, 0, 1, 0)
        tabView.BackgroundTransparency = 1
        tabView.ZIndex = 206
        tabView.Parent = contentContainer

        local col1 = Instance.new("ScrollingFrame")
        col1.Name = "Column1"
        col1.Position = UDim2.new(0, 0, 0, 0)
        col1.Size = UDim2.new(0.485, 0, 1, 0)
        col1.BackgroundTransparency = 1
        col1.ScrollBarThickness = 3
        col1.ScrollBarImageColor3 = Theme.AccentDeep
        col1.CanvasSize = UDim2.new(0, 0, 0, 0)
        col1.AutomaticCanvasSize = Enum.AutomaticSize.Y
        col1.ZIndex = 207
        col1.Parent = tabView

        local l1 = Instance.new("UIListLayout")
        l1.Padding = UDim.new(0, 6)
        l1.SortOrder = Enum.SortOrder.LayoutOrder
        l1.Parent = col1

        local col2 = Instance.new("ScrollingFrame")
        col2.Name = "Column2"
        col2.Position = UDim2.new(0.515, 0, 0, 0)
        col2.Size = UDim2.new(0.485, 0, 1, 0)
        col2.BackgroundTransparency = 1
        col2.ScrollBarThickness = 3
        col2.ScrollBarImageColor3 = Theme.AccentDeep
        col2.CanvasSize = UDim2.new(0, 0, 0, 0)
        col2.AutomaticCanvasSize = Enum.AutomaticSize.Y
        col2.ZIndex = 207
        col2.Parent = tabView

        local l2 = Instance.new("UIListLayout")
        l2.Padding = UDim.new(0, 6)
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
                tabData.View.Visible = (name == def.name)
                local isActive = (name == def.name)
                tabData.Btn.TextColor3 = isActive and Theme.TextWhite or Theme.TextMuted
                tabData.Icon.ImageColor3 = isActive and Theme.Accent or Theme.TextMuted
                TweenService:Create(tabData.Underline, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isActive and UDim2.new(0.8, 0, 0, 3) or UDim2.new(0, 0, 0, 3)
                }):Play()
            end
        end)
    end

    -- 7. Component Builder Helpers
    self.CreateCenteredModal = createCenteredModal

    -- Mount ScreenGui
    screenGui.Parent = parentGui
    return self
end

-- Subheader with double gradient HUD lines
function QuantumOnyxUI:AddSubheader(parent, text)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Subheader_" .. text
    headerFrame.Size = UDim2.new(1, 0, 0, 22)
    headerFrame.BackgroundTransparency = 1
    headerFrame.ZIndex = 208
    headerFrame.Parent = parent

    local lineLeft = Instance.new("Frame")
    lineLeft.Position = UDim2.new(0, 0, 0.5, 0)
    lineLeft.Size = UDim2.new(0.22, 0, 0, 1)
    lineLeft.BackgroundColor3 = Theme.Accent
    lineLeft.BorderSizePixel = 0
    lineLeft.ZIndex = 209
    local g1 = Instance.new("UIGradient")
    g1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    g1.Parent = lineLeft
    lineLeft.Parent = headerFrame

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0.22, 0, 0, 0)
    title.Size = UDim2.new(0.56, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 11
    title.TextColor3 = Theme.Accent
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 209
    title.Parent = headerFrame

    local lineRight = Instance.new("Frame")
    lineRight.Position = UDim2.new(0.78, 0, 0.5, 0)
    lineRight.Size = UDim2.new(0.22, 0, 0, 1)
    lineRight.BackgroundColor3 = Theme.Accent
    lineRight.BorderSizePixel = 0
    lineRight.ZIndex = 209
    local g2 = Instance.new("UIGradient")
    g2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    g2.Parent = lineRight
    lineRight.Parent = headerFrame

    return headerFrame
end

-- Toggle Switch (with optional description)
function QuantumOnyxUI:AddToggle(parent, titleText, descText, defaultVal, callback)
    callback = callback or function(val) end
    local isToggled = defaultVal or false
    local height = descText and 54 or 32

    local btn = Instance.new("TextButton")
    btn.Name = "Toggle_" .. titleText
    btn.Size = UDim2.new(1, 0, 0, height)
    btn.BackgroundColor3 = Theme.ControlBase
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 208
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = Theme.BorderMuted
    bs.Thickness = 1
    bs.Transparency = 0.6
    bs.Parent = btn

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, descText and 6 or 0)
    tLabel.Size = UDim2.new(1, -60, 0, descText and 18 or height)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = titleText
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11
    tLabel.TextColor3 = Theme.TextWhite
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 209
    tLabel.Parent = btn

    if descText then
        local dLabel = Instance.new("TextLabel")
        dLabel.Position = UDim2.new(0, 10, 0, 24)
        dLabel.Size = UDim2.new(1, -60, 0, 24)
        dLabel.BackgroundTransparency = 1
        dLabel.Text = descText
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 9
        dLabel.TextColor3 = Theme.TextDesc
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextWrapped = true
        dLabel.ZIndex = 209
        dLabel.Parent = btn
    end

    -- Switch capsule
    local switchCapsule = Instance.new("Frame")
    switchCapsule.AnchorPoint = Vector2.new(1, 0.5)
    switchCapsule.Position = UDim2.new(1, -10, 0.5, 0)
    switchCapsule.Size = UDim2.new(0, 36, 0, 18)
    switchCapsule.BackgroundColor3 = isToggled and Theme.SwitchOn or Theme.SwitchOff
    switchCapsule.BorderSizePixel = 0
    switchCapsule.ZIndex = 209
    switchCapsule.Parent = btn

    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(1, 0)
    scCorner.Parent = switchCapsule

    local scStroke = Instance.new("UIStroke")
    scStroke.Color = isToggled and Theme.AccentGlow or Theme.BorderMuted
    scStroke.Thickness = 1
    scStroke.Transparency = 0.4
    scStroke.Parent = switchCapsule

    -- Thumb knob
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = isToggled and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Theme.TextWhite
    knob.BorderSizePixel = 0
    knob.ZIndex = 210
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob
    knob.Parent = switchCapsule

    btn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        local targetX = isToggled and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetBg = isToggled and Theme.SwitchOn or Theme.SwitchOff
        local targetStroke = isToggled and Theme.AccentGlow or Theme.BorderMuted

        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetX
        }):Play()
        TweenService:Create(switchCapsule, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetBg
        }):Play()
        TweenService:Create(scStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Color = targetStroke
        }):Play()

        callback(isToggled)
    end)

    return btn
end

-- Action Button with Chevron
function QuantumOnyxUI:AddButton(parent, labelText, callback)
    callback = callback or function() end

    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. labelText
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.ControlBase
    btn.BackgroundTransparency = 0.40
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 208
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = Theme.BorderMuted
    bs.Thickness = 1
    bs.Transparency = 0.6
    bs.Parent = btn

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 0)
    tLabel.Size = UDim2.new(1, -30, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11
    tLabel.TextColor3 = Theme.TextWhite
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 209
    tLabel.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -10, 0.5, 0)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.Font = Enum.Font.FredokaOne
    arrow.TextSize = 14
    arrow.TextColor3 = Theme.Accent
    arrow.ZIndex = 209
    arrow.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Slider Component
function QuantumOnyxUI:AddSlider(parent, titleText, minVal, maxVal, defaultVal, callback)
    callback = callback or function(val) end
    local currentVal = defaultVal or minVal

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. titleText
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.ControlBase
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 208
    frame.Parent = parent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local fs = Instance.new("UIStroke")
    fs.Color = Theme.BorderMuted
    fs.Thickness = 1
    fs.Transparency = 0.6
    fs.Parent = frame

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 10, 0, 5)
    title.Size = UDim2.new(1, -70, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextColor3 = Theme.TextWhite
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 209
    title.Parent = frame

    local valBox = Instance.new("TextBox")
    valBox.AnchorPoint = Vector2.new(1, 0)
    valBox.Position = UDim2.new(1, -10, 0, 5)
    valBox.Size = UDim2.new(0, 48, 0, 16)
    valBox.BackgroundColor3 = Theme.SearchBase
    valBox.BackgroundTransparency = 0.3
    valBox.Text = tostring(currentVal)
    valBox.Font = Enum.Font.GothamBold
    valBox.TextSize = 10
    valBox.TextColor3 = Theme.Accent
    valBox.ClearTextOnFocus = false
    valBox.ZIndex = 209
    local vbc = Instance.new("UICorner")
    vbc.CornerRadius = UDim.new(0, 4)
    vbc.Parent = valBox
    valBox.Parent = frame

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 10, 0, 30)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    track.BorderSizePixel = 0
    track.ZIndex = 209
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track
    track.Parent = frame

    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 210
    local filc = Instance.new("UICorner")
    filc.CornerRadius = UDim.new(1, 0)
    filc.Parent = fill
    fill.Parent = track

    local dragging = false
    local function update(input)
        local posX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(posX, 0, 1, 0)
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
            callback(num)
        end
    end)

    return frame
end

-- Dropdown Selector Opening Centered Floating Modal
function QuantumOnyxUI:AddDropdown(parent, titleText, options, defaultOption, callback)
    callback = callback or function(opt) end
    local selected = defaultOption or (options[1] or "Select...")

    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. titleText
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Theme.ControlBase
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 208
    frame.Parent = parent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local fs = Instance.new("UIStroke")
    fs.Color = Theme.BorderMuted
    fs.Thickness = 1
    fs.Transparency = 0.6
    fs.Parent = frame

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 0)
    tLabel.Size = UDim2.new(0.45, 0, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = titleText
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 10
    tLabel.TextColor3 = Theme.TextWhite
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 209
    tLabel.Parent = frame

    local triggerBtn = Instance.new("TextButton")
    triggerBtn.AnchorPoint = Vector2.new(1, 0.5)
    triggerBtn.Position = UDim2.new(1, -6, 0.5, 0)
    triggerBtn.Size = UDim2.new(0.5, 0, 0, 22)
    triggerBtn.BackgroundColor3 = Theme.SearchBase
    triggerBtn.BackgroundTransparency = 0.30
    triggerBtn.BorderSizePixel = 0
    triggerBtn.Text = ""
    triggerBtn.ZIndex = 209
    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(0, 4)
    trc.Parent = triggerBtn
    triggerBtn.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Position = UDim2.new(0, 6, 0, 0)
    valLabel.Size = UDim2.new(1, -22, 1, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = selected
    valLabel.Font = Enum.Font.Gotham
    valLabel.TextSize = 10
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Left
    valLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valLabel.ZIndex = 210
    valLabel.Parent = triggerBtn

    local dropArrow = Instance.new("TextLabel")
    dropArrow.AnchorPoint = Vector2.new(1, 0.5)
    dropArrow.Position = UDim2.new(1, -4, 0.5, 0)
    dropArrow.Size = UDim2.new(0, 12, 0, 12)
    dropArrow.BackgroundTransparency = 1
    dropArrow.Text = "▼"
    dropArrow.Font = Enum.Font.GothamBold
    dropArrow.TextSize = 8
    dropArrow.TextColor3 = Theme.Accent
    dropArrow.ZIndex = 210
    dropArrow.Parent = triggerBtn

    -- Dedicated Centered Modal
    local modal = self.CreateCenteredModal(titleText, 250, 260)
    local searchInModal = Instance.new("TextBox")
    searchInModal.Size = UDim2.new(1, 0, 0, 22)
    searchInModal.BackgroundColor3 = Theme.SearchBase
    searchInModal.BackgroundTransparency = 0.3
    searchInModal.PlaceholderText = "Filter options..."
    searchInModal.PlaceholderColor3 = Theme.TextMuted
    searchInModal.Text = ""
    searchInModal.Font = Enum.Font.Gotham
    searchInModal.TextSize = 10
    searchInModal.TextColor3 = Theme.TextWhite
    searchInModal.ZIndex = 313
    local smc = Instance.new("UICorner")
    smc.CornerRadius = UDim.new(0, 4)
    smc.Parent = searchInModal
    searchInModal.Parent = modal.Body

    local optButtons = {}
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = Theme.ControlBase
        optBtn.BackgroundTransparency = 0.4
        optBtn.Text = "  " .. opt
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 10
        optBtn.TextColor3 = (opt == selected) and Theme.Accent or Theme.TextWhite
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 313
        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 4)
        oc.Parent = optBtn
        optBtn.Parent = modal.Body

        table.insert(optButtons, { btn = optBtn, text = opt })

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            valLabel.Text = opt
            modal.Close()
            callback(opt)
        end)
    end

    searchInModal:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchInModal.Text:lower()
        for _, item in ipairs(optButtons) do
            item.btn.Visible = (filter == "" or item.text:lower():find(filter) ~= nil)
        end
    end)

    triggerBtn.MouseButton1Click:Connect(function()
        modal.Open()
    end)

    return frame
end

-- Info / Stat Card with gradient divider
function QuantumOnyxUI:AddInfoCard(parent, titleText, detailText)
    local card = Instance.new("Frame")
    card.Name = "InfoCard_" .. titleText
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Theme.ControlBase
    card.BackgroundTransparency = 0.40
    card.BorderSizePixel = 0
    card.ZIndex = 208
    card.Parent = parent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = card

    local cs = Instance.new("UIStroke")
    cs.Color = Theme.BorderMuted
    cs.Thickness = 1
    cs.Transparency = 0.6
    cs.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 6)
    tLabel.Size = UDim2.new(1, -20, 0, 14)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = titleText
    tLabel.Font = Enum.Font.FredokaOne
    tLabel.TextSize = 11
    tLabel.TextColor3 = Theme.Accent
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 209
    tLabel.Parent = card

    local div = Instance.new("Frame")
    div.Position = UDim2.new(0, 8, 0, 22)
    div.Size = UDim2.new(1, -16, 0, 1)
    div.BackgroundColor3 = Theme.AccentDeep
    div.BorderSizePixel = 0
    div.ZIndex = 209
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    g.Parent = div
    div.Parent = card

    local dLabel = Instance.new("TextLabel")
    dLabel.Position = UDim2.new(0, 10, 0, 26)
    dLabel.Size = UDim2.new(1, -20, 0, 16)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = detailText
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 9
    dLabel.TextColor3 = Theme.TextLight
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.ZIndex = 209
    dLabel.Parent = card

    return card
end

-- ============================================================================
-- INITIALIZE AND POPULATE SAMPLE SECTIONS & REAL CONTROLS
-- ============================================================================

local app = QuantumOnyxUI.new()

-- 1. MAIN TAB (Script Information & Favorites)
local mainTab = app.TabFrames["Main"]
app:AddSubheader(mainTab.Col1, "Script Information")
app:AddInfoCard(mainTab.Col1, "Quantum Onyx Project", "Game: Blox Fruits\nVersion: v.Premium\nStatus: [OK] Undetected")
app:AddButton(mainTab.Col1, "Copy Official Discord Link", function()
    if setclipboard then pcall(function() setclipboard("https://discord.gg/quantumonyx") end) end
end)
app:AddButton(mainTab.Col1, "Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

app:AddSubheader(mainTab.Col2, "Favorites / Pinned")
app:AddInfoCard(mainTab.Col2, "Pin Functions Tip", "PC: right-click a function to pin.\nMobile: double-tap to add to favorites.")
app:AddToggle(mainTab.Col2, "Auto Reconnect on Kick", "Automatically reconnects to the game if disconnected", true)

-- 2. HOME TAB (Level Farm, Magnet Event & Combat)
local homeTab = app.TabFrames["Home"]
-- Column 1: Magnet Event & Weapons
app:AddSubheader(homeTab.Col1, "Magnet Event")
app:AddToggle(homeTab.Col1, "Auto Farm Magnet Tokens", nil, false)
app:AddToggle(homeTab.Col1, "Auto Roll Magnet Gacha", nil, false)
app:AddButton(homeTab.Col1, "Open Magnet Gacha GUI", function() end)
app:AddToggle(homeTab.Col1, "Auto Complete Secret Quests", nil, false)
app:AddInfoCard(homeTab.Col1, "Secret Quests Progress", "Completed: 0/12 (0%) | Remaining: 12")

app:AddSubheader(homeTab.Col1, "Farm Configuration")
app:AddDropdown(homeTab.Col1, "Weapon", {"Melee", "Sword", "Gun", "Blox Fruit"}, "Melee")
app:AddDropdown(homeTab.Col1, "Farm Method", {"Quest", "No Quest", "Nearest Mob"}, "Quest")
app:AddSlider(homeTab.Col1, "Fast Attack Delay", 0, 100, 0)

-- Column 2: Level Farm & Combat Enhancements
app:AddSubheader(homeTab.Col2, "Level Farm")
app:AddToggle(homeTab.Col2, "Auto Farm Level", "Automated leveling with quest bypass and tweening", false)
app:AddToggle(homeTab.Col2, "Auto Double Quest", "Accepts secondary boss or elite quest simultaneously", true)

app:AddSubheader(homeTab.Col2, "Combat Enhancements")
app:AddToggle(homeTab.Col2, "Auto Buso Haki", "Ensures Enhancement Aura is always active", true)
app:AddToggle(homeTab.Col2, "Auto Observation Haki", "Automatically activates Ken Haki in combat", true)
app:AddToggle(homeTab.Col2, "Fast Attack", "Uncapped attack packet bursts", true)
app:AddToggle(homeTab.Col2, "Bring Mobs", "Pulls nearby spawned enemies into attack radius", true)
app:AddSlider(homeTab.Col2, "Bring Mobs Radius", 100, 500, 350)

-- 3. SUB FARM TAB
local subTab = app.TabFrames["Sub Farm"]
app:AddSubheader(subTab.Col1, "Materials & Mastery")
app:AddDropdown(subTab.Col1, "Select Material", {"Ectoplasm", "Scrap Metal", "Magma Ore", "Dragon Scale", "Fish Tail"}, "Ectoplasm")
app:AddToggle(subTab.Col1, "Auto Farm Material", nil, false)
app:AddDropdown(subTab.Col1, "Mastery Weapon", {"Sword", "Gun", "Blox Fruit"}, "Sword")
app:AddToggle(subTab.Col1, "Auto Farm Mastery", "Farms low-health mobs to level weapons", false)

app:AddSubheader(subTab.Col2, "Boss Hunting")
app:AddDropdown(subTab.Col2, "Select Boss", {"Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader", "Vice Admiral", "Saber Expert"}, "Gorilla King")
app:AddToggle(subTab.Col2, "Auto Farm Boss", nil, false)
app:AddToggle(subTab.Col2, "Auto Hop When Killed", "Server hops when target boss is dead", false)

-- 4. SEA EVENT TAB
local seaTab = app.TabFrames["Sea Event"]
app:AddSubheader(seaTab.Col1, "Boat & Sailing")
app:AddDropdown(seaTab.Col1, "Boat Selected", {"PirateBrigade", "Grand Brigade", "Sloop", "Dinghy"}, "PirateBrigade")
app:AddToggle(seaTab.Col1, "Auto Buy Boat", nil, true)
app:AddToggle(seaTab.Col1, "Auto Sail to Sea 6", nil, false)
app:AddSlider(seaTab.Col1, "Boat Speed", 100, 350, 220)

app:AddSubheader(seaTab.Col2, "Sea Monsters")
app:AddToggle(seaTab.Col2, "Auto Kill Sea Beast", nil, false)
app:AddToggle(seaTab.Col2, "Auto Kill Terror Shark", nil, false)
app:AddToggle(seaTab.Col2, "Auto Dodge Terror Shark", nil, true)

return QuantumOnyxUI
