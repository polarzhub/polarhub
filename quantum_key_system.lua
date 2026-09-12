--[[
    ========================================================================
    [POLAR HUB / REVERSE-ENGINEERED ARTIFACT]
    Quantum Onyx — Key System GUI (1:1 Exact Extraction & Recreation)
    ========================================================================
    Extracted via Real MCP Memory & Render Tree Dump
    Target Resolution / Geometry: 450x310 px, Centered (AnchorPoint 0.5, 0.5)
    Theme: Obsidian Deep Violet (#0F0C18), Neon Glow Stroke (#783CDC)
    Typography: FredokaOne (Titles & Actions), GothamBold, Gotham
    Features:
      - 1:1 Color, Stroke, Corner & Hierarchy Recreation
      - Dual Ambient Glow Orbs (Soft Nebula lighting at corners)
      - Dynamic User Avatar Headshot + DisplayName / Username
      - Information Card (Discord, Game, Version)
      - Interactive Freemium Instruction Banner with Accent Pill
      - Input Box with Lock Icon and Text Entry
      - "Get Key" Dropdown Modal (Lootlabs / Linkvertise) with Clipboard copy
      - "Free Version" Native Response Handler
      - Smooth Header Drag & Drop System
    ========================================================================
]]--

local QuantumKeySystem = {}

function QuantumKeySystem.Create(config)
    config = config or {}
    local TitleText = config.Title or "Quantum Onyx — Key System"
    local BadgeText = config.Badge or "Freemium"
    local DiscordText = config.Discord or "discord.gg/quantumonyx"
    local GameText = config.Game or "Blox Frutas"
    local VersionText = config.Version or "v.Freemium"
    local LootlabsUrl = config.LootlabsUrl or "https://ads.luarmor.net/get_key?for=Quantum_Onyx_Keysytem-NdUqNPMGBobv"
    local LinkvertiseUrl = config.LinkvertiseUrl or "https://ads.luarmor.net/get_key?for=Quantum_Onyx_Keysytem-KCyPvypRNlEm"
    local OnKeySubmitted = config.OnKeySubmitted or function(key) end

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Target Parent
    local parentGui = nil
    if gethui then
        pcall(function() parentGui = gethui() end)
    end
    if not parentGui then
        parentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Clean old instance if already running
    local oldGui = parentGui:FindFirstChild("QuantumOnyx_KeySystem")
    if oldGui then oldGui:Destroy() end

    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QuantumOnyx_KeySystem"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999

    -- 2. Dim Backdrop Overlay (45% Black)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.Position = UDim2.new(0, 0, 0, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.45
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 200
    backdrop.Parent = screenGui

    -- 3. Main Window Card (450x310)
    local mainCard = Instance.new("Frame")
    mainCard.Name = "MainCard"
    mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainCard.Size = UDim2.new(0, 450, 0, 310)
    mainCard.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    mainCard.BackgroundTransparency = 0
    mainCard.BorderSizePixel = 0
    mainCard.ClipsDescendants = true
    mainCard.ZIndex = 201
    mainCard.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainCard

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(120, 60, 220)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.30
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainCard

    -- Ambient Glow Orbs (Soft Nebula Lighting)
    local glowTopLeft = Instance.new("Frame")
    glowTopLeft.Name = "GlowOrbTopLeft"
    glowTopLeft.Position = UDim2.new(0, -60, 0, -60)
    glowTopLeft.Size = UDim2.new(0, 220, 0, 220)
    glowTopLeft.BackgroundColor3 = Color3.fromRGB(80, 20, 160)
    glowTopLeft.BackgroundTransparency = 0.85
    glowTopLeft.BorderSizePixel = 0
    glowTopLeft.ZIndex = 201
    local glowCorner1 = Instance.new("UICorner")
    glowCorner1.CornerRadius = UDim.new(1, 0)
    glowCorner1.Parent = glowTopLeft
    glowTopLeft.Parent = mainCard

    local glowBottomRight = Instance.new("Frame")
    glowBottomRight.Name = "GlowOrbBottomRight"
    glowBottomRight.Position = UDim2.new(1, -100, 1, -100)
    glowBottomRight.Size = UDim2.new(0, 180, 0, 180)
    glowBottomRight.BackgroundColor3 = Color3.fromRGB(40, 10, 110)
    glowBottomRight.BackgroundTransparency = 0.85
    glowBottomRight.BorderSizePixel = 0
    glowBottomRight.ZIndex = 201
    local glowCorner2 = Instance.new("UICorner")
    glowCorner2.CornerRadius = UDim.new(1, 0)
    glowCorner2.Parent = glowBottomRight
    glowBottomRight.Parent = mainCard

    -- 4. Header Bar (Height: 44px)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    header.BorderSizePixel = 0
    header.ZIndex = 202
    header.Parent = mainCard

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header

    -- Square filler to keep bottom corners of header crisp
    local headerSquareFiller = Instance.new("Frame")
    headerSquareFiller.Name = "SquareFiller"
    headerSquareFiller.Position = UDim2.new(0, 0, 0.5, 0)
    headerSquareFiller.Size = UDim2.new(1, 0, 0.5, 0)
    headerSquareFiller.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    headerSquareFiller.BorderSizePixel = 0
    headerSquareFiller.ZIndex = 202
    headerSquareFiller.Parent = header

    -- App Icon
    local appIcon = Instance.new("ImageLabel")
    appIcon.Name = "AppIcon"
    appIcon.Position = UDim2.new(0, 13, 0.5, -8)
    appIcon.Size = UDim2.new(0, 16, 0, 16)
    appIcon.BackgroundTransparency = 1
    appIcon.Image = "rbxassetid://7733992528"
    appIcon.ImageColor3 = Color3.fromRGB(155, 90, 255)
    appIcon.ZIndex = 203
    appIcon.Parent = header

    -- Title Label
    local appTitle = Instance.new("TextLabel")
    appTitle.Name = "AppTitle"
    appTitle.Position = UDim2.new(0, 35, 0, 0)
    appTitle.Size = UDim2.new(1, -130, 1, 0)
    appTitle.BackgroundTransparency = 1
    appTitle.Text = TitleText
    appTitle.Font = Enum.Font.FredokaOne
    appTitle.TextSize = 14
    appTitle.TextColor3 = Color3.fromRGB(220, 200, 255)
    appTitle.TextXAlignment = Enum.TextXAlignment.Left
    appTitle.ZIndex = 203
    appTitle.Parent = header

    -- Freemium Status Badge
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.AnchorPoint = Vector2.new(1, 0.5)
    badge.Position = UDim2.new(1, -40, 0.5, 0)
    badge.Size = UDim2.new(0, 72, 0, 20)
    badge.BackgroundColor3 = Color3.fromRGB(30, 60, 20)
    badge.BorderSizePixel = 0
    badge.ZIndex = 203
    badge.Parent = header

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 5)
    badgeCorner.Parent = badge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Color3.fromRGB(80, 200, 110)
    badgeStroke.Thickness = 1
    badgeStroke.Transparency = 0.30
    badgeStroke.Parent = badge

    local badgeText = Instance.new("TextLabel")
    badgeText.Name = "BadgeText"
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = BadgeText
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 10
    badgeText.TextColor3 = Color3.fromRGB(130, 235, 160)
    badgeText.TextXAlignment = Enum.TextXAlignment.Center
    badgeText.ZIndex = 204
    badgeText.Parent = badge

    -- Close Button (X)
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://79324227570635"
    closeBtn.ImageColor3 = Color3.fromRGB(200, 80, 80)
    closeBtn.ZIndex = 203
    closeBtn.Parent = header

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Header Divider Line
    local headerDivider = Instance.new("Frame")
    headerDivider.Name = "HeaderDivider"
    headerDivider.Position = UDim2.new(0, 0, 0, 44)
    headerDivider.Size = UDim2.new(1, 0, 0, 1)
    headerDivider.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    headerDivider.BackgroundTransparency = 0.30
    headerDivider.BorderSizePixel = 0
    headerDivider.ZIndex = 202
    headerDivider.Parent = mainCard

    -- Central Divider Line (Vertical)
    local centerDivider = Instance.new("Frame")
    centerDivider.Name = "CenterDivider"
    centerDivider.Position = UDim2.new(0, 188, 0, 52)
    centerDivider.Size = UDim2.new(0, 1, 0, 250)
    centerDivider.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    centerDivider.BackgroundTransparency = 0.50
    centerDivider.BorderSizePixel = 0
    centerDivider.ZIndex = 202
    centerDivider.Parent = mainCard

    -- 5. Left Panel: Card 1 (Information)
    local cardInfo = Instance.new("Frame")
    cardInfo.Name = "CardInformation"
    cardInfo.Position = UDim2.new(0, 8, 0, 52)
    cardInfo.Size = UDim2.new(0, 180, 0, 112)
    cardInfo.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    cardInfo.BorderSizePixel = 0
    cardInfo.ZIndex = 202
    cardInfo.Parent = mainCard

    local cardInfoCorner = Instance.new("UICorner")
    cardInfoCorner.CornerRadius = UDim.new(0, 8)
    cardInfoCorner.Parent = cardInfo

    local cardInfoStroke = Instance.new("UIStroke")
    cardInfoStroke.Color = Color3.fromRGB(100, 50, 190)
    cardInfoStroke.Thickness = 1
    cardInfoStroke.Transparency = 0.40
    cardInfoStroke.Parent = cardInfo

    local infoTitle = Instance.new("TextLabel")
    infoTitle.Name = "Title"
    infoTitle.Position = UDim2.new(0, 9, 0, 5)
    infoTitle.Size = UDim2.new(1, -14, 0, 13)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "Information"
    infoTitle.Font = Enum.Font.GothamBold
    infoTitle.TextSize = 9
    infoTitle.TextColor3 = Color3.fromRGB(160, 110, 240)
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.ZIndex = 203
    infoTitle.Parent = cardInfo

    local infoSubDivider = Instance.new("Frame")
    infoSubDivider.Name = "SubDivider"
    infoSubDivider.Position = UDim2.new(0, 7, 0, 20)
    infoSubDivider.Size = UDim2.new(1, -14, 0, 1)
    infoSubDivider.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
    infoSubDivider.BackgroundTransparency = 0.60
    infoSubDivider.BorderSizePixel = 0
    infoSubDivider.ZIndex = 203
    infoSubDivider.Parent = cardInfo

    local function createInfoRow(yOffset, labelText, valText)
        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 9, 0, yOffset)
        lbl.Size = UDim2.new(0, 55, 0, 12)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextColor3 = Color3.fromRGB(140, 110, 190)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 203
        lbl.Parent = cardInfo

        local val = Instance.new("TextLabel")
        val.Position = UDim2.new(0, 64, 0, yOffset)
        val.Size = UDim2.new(1, -70, 0, 12)
        val.BackgroundTransparency = 1
        val.Text = valText
        val.Font = Enum.Font.Gotham
        val.TextSize = 9
        val.TextColor3 = Color3.fromRGB(200, 180, 240)
        val.TextXAlignment = Enum.TextXAlignment.Left
        val.ZIndex = 203
        val.Parent = cardInfo
    end

    createInfoRow(26, "Discord:", DiscordText)
    createInfoRow(42, "Game:", GameText)
    createInfoRow(58, "Version:", VersionText)

    -- 6. Left Panel: Card 2 (User Profile)
    local cardProfile = Instance.new("Frame")
    cardProfile.Name = "CardUserProfile"
    cardProfile.Position = UDim2.new(0, 8, 0, 170)
    cardProfile.Size = UDim2.new(0, 180, 0, 128)
    cardProfile.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    cardProfile.BorderSizePixel = 0
    cardProfile.ZIndex = 202
    cardProfile.Parent = mainCard

    local cardProfCorner = Instance.new("UICorner")
    cardProfCorner.CornerRadius = UDim.new(0, 8)
    cardProfCorner.Parent = cardProfile

    local cardProfStroke = Instance.new("UIStroke")
    cardProfStroke.Color = Color3.fromRGB(100, 50, 190)
    cardProfStroke.Thickness = 1
    cardProfStroke.Transparency = 0.40
    cardProfStroke.Parent = cardProfile

    local profTitle = Instance.new("TextLabel")
    profTitle.Name = "Title"
    profTitle.Position = UDim2.new(0, 9, 0, 5)
    profTitle.Size = UDim2.new(1, -14, 0, 13)
    profTitle.BackgroundTransparency = 1
    profTitle.Text = "User Profile"
    profTitle.Font = Enum.Font.GothamBold
    profTitle.TextSize = 9
    profTitle.TextColor3 = Color3.fromRGB(160, 110, 240)
    profTitle.TextXAlignment = Enum.TextXAlignment.Left
    profTitle.ZIndex = 203
    profTitle.Parent = cardProfile

    local profSubDivider = Instance.new("Frame")
    profSubDivider.Name = "SubDivider"
    profSubDivider.Position = UDim2.new(0, 7, 0, 20)
    profSubDivider.Size = UDim2.new(1, -14, 0, 1)
    profSubDivider.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
    profSubDivider.BackgroundTransparency = 0.60
    profSubDivider.BorderSizePixel = 0
    profSubDivider.ZIndex = 203
    profSubDivider.Parent = cardProfile

    local avatarOuter = Instance.new("Frame")
    avatarOuter.Name = "AvatarBorder"
    avatarOuter.AnchorPoint = Vector2.new(0.5, 0)
    avatarOuter.Position = UDim2.new(0.5, 0, 0, 28)
    avatarOuter.Size = UDim2.new(0, 52, 0, 52)
    avatarOuter.BackgroundColor3 = Color3.fromRGB(110, 55, 210)
    avatarOuter.BackgroundTransparency = 0.30
    avatarOuter.BorderSizePixel = 0
    avatarOuter.ZIndex = 203
    local avOuterCorner = Instance.new("UICorner")
    avOuterCorner.CornerRadius = UDim.new(1, 0)
    avOuterCorner.Parent = avatarOuter
    avatarOuter.Parent = cardProfile

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarHeadshot"
    avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImg.Size = UDim2.new(0, 46, 0, 46)
    avatarImg.BackgroundColor3 = Color3.fromRGB(30, 15, 55)
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=100&h=100"
    avatarImg.BorderSizePixel = 0
    avatarImg.ZIndex = 204
    local avImgCorner = Instance.new("UICorner")
    avImgCorner.CornerRadius = UDim.new(1, 0)
    avImgCorner.Parent = avatarImg
    avatarImg.Parent = avatarOuter

    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Name = "DisplayName"
    displayNameLabel.AnchorPoint = Vector2.new(0.5, 0)
    displayNameLabel.Position = UDim2.new(0.5, 0, 0, 86)
    displayNameLabel.Size = UDim2.new(1, -12, 0, 14)
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Text = LocalPlayer.DisplayName
    displayNameLabel.Font = Enum.Font.GothamBold
    displayNameLabel.TextSize = 11
    displayNameLabel.TextColor3 = Color3.fromRGB(220, 205, 255)
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    displayNameLabel.ZIndex = 203
    displayNameLabel.Parent = cardProfile

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "Username"
    usernameLabel.AnchorPoint = Vector2.new(0.5, 0)
    usernameLabel.Position = UDim2.new(0.5, 0, 0, 102)
    usernameLabel.Size = UDim2.new(1, -12, 0, 12)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. LocalPlayer.Name
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 9
    usernameLabel.TextColor3 = Color3.fromRGB(145, 125, 185)
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Center
    usernameLabel.ZIndex = 203
    usernameLabel.Parent = cardProfile

    -- 7. Right Panel: Card 1 (Instruction Banner)
    local banner = Instance.new("Frame")
    banner.Name = "InstructionBanner"
    banner.Position = UDim2.new(0, 198, 0, 52)
    banner.Size = UDim2.new(0, 242, 0, 50)
    banner.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    banner.BorderSizePixel = 0
    banner.ZIndex = 202
    banner.Parent = mainCard

    local bannerCorner = Instance.new("UICorner")
    bannerCorner.CornerRadius = UDim.new(0, 7)
    bannerCorner.Parent = banner

    local bannerStroke = Instance.new("UIStroke")
    bannerStroke.Color = Color3.fromRGB(80, 200, 110)
    bannerStroke.Thickness = 1
    bannerStroke.Transparency = 0.40
    bannerStroke.Parent = banner

    local bannerPill = Instance.new("Frame")
    bannerPill.Name = "AccentPill"
    bannerPill.Position = UDim2.new(0, 0, 0.5, -10)
    bannerPill.Size = UDim2.new(0, 3, 0, 20)
    bannerPill.BackgroundColor3 = Color3.fromRGB(80, 200, 110)
    bannerPill.BorderSizePixel = 0
    bannerPill.ZIndex = 203
    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = bannerPill
    bannerPill.Parent = banner

    local bannerText = Instance.new("TextLabel")
    bannerText.Name = "BannerText"
    bannerText.Position = UDim2.new(0, 12, 0, 0)
    bannerText.Size = UDim2.new(1, -16, 1, 0)
    bannerText.BackgroundTransparency = 1
    bannerText.Text = "Freemium — key is optional.\nEnter a key to unlock premium features."
    bannerText.Font = Enum.Font.Gotham
    bannerText.TextSize = 10
    bannerText.TextColor3 = Color3.fromRGB(140, 230, 170)
    bannerText.TextXAlignment = Enum.TextXAlignment.Left
    bannerText.ZIndex = 203
    bannerText.Parent = banner

    -- 8. Right Panel: Card 2 (State Bar)
    local stateBar = Instance.new("Frame")
    stateBar.Name = "StateBar"
    stateBar.Position = UDim2.new(0, 198, 0, 110)
    stateBar.Size = UDim2.new(0, 242, 0, 28)
    stateBar.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
    stateBar.BorderSizePixel = 0
    stateBar.ZIndex = 202
    stateBar.Parent = mainCard

    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(0, 6)
    stateCorner.Parent = stateBar

    local stateStroke = Instance.new("UIStroke")
    stateStroke.Color = Color3.fromRGB(100, 50, 190)
    stateStroke.Thickness = 1
    stateStroke.Transparency = 0.40
    stateStroke.Parent = stateBar

    local stateIcon = Instance.new("ImageLabel")
    stateIcon.Name = "StateIcon"
    stateIcon.Position = UDim2.new(0, 8, 0.5, -6)
    stateIcon.Size = UDim2.new(0, 12, 0, 12)
    stateIcon.BackgroundTransparency = 1
    stateIcon.Image = "rbxassetid://7733992528"
    stateIcon.ImageColor3 = Color3.fromRGB(150, 95, 225)
    stateIcon.ZIndex = 203
    stateIcon.Parent = stateBar

    local stateText = Instance.new("TextLabel")
    stateText.Name = "StateText"
    stateText.Position = UDim2.new(0, 25, 0, 0)
    stateText.Size = UDim2.new(1, -30, 1, 0)
    stateText.BackgroundTransparency = 1
    stateText.Text = "Ready for Authentication"
    stateText.Font = Enum.Font.GothamBold
    stateText.TextSize = 10
    stateText.TextColor3 = Color3.fromRGB(180, 160, 225)
    stateText.TextXAlignment = Enum.TextXAlignment.Left
    stateText.ZIndex = 203
    stateText.Parent = stateBar

    -- 9. Right Panel: Card 3 (Key Input Field)
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.Position = UDim2.new(0, 198, 0, 146)
    inputContainer.Size = UDim2.new(0, 242, 0, 34)
    inputContainer.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 202
    inputContainer.Parent = mainCard

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 7)
    inputCorner.Parent = inputContainer

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(120, 60, 220)
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.30
    inputStroke.Parent = inputContainer

    local lockIcon = Instance.new("ImageLabel")
    lockIcon.Name = "LockIcon"
    lockIcon.Position = UDim2.new(0, 10, 0.5, -7)
    lockIcon.Size = UDim2.new(0, 14, 0, 14)
    lockIcon.BackgroundTransparency = 1
    lockIcon.Image = "rbxassetid://7733992528"
    lockIcon.ImageColor3 = Color3.fromRGB(140, 90, 215)
    lockIcon.ZIndex = 203
    lockIcon.Parent = inputContainer

    local textBox = Instance.new("TextBox")
    textBox.Name = "KeyTextBox"
    textBox.Position = UDim2.new(0, 30, 0, 0)
    textBox.Size = UDim2.new(1, -38, 1, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = "Enter premium key..."
    textBox.PlaceholderColor3 = Color3.fromRGB(115, 95, 155)
    textBox.Font = Enum.Font.GothamBold
    textBox.TextSize = 11
    textBox.TextColor3 = Color3.fromRGB(225, 205, 255)
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 203
    textBox.Parent = inputContainer

    -- 10. Status / Feedback Label
    local statusFeedback = Instance.new("TextLabel")
    statusFeedback.Name = "StatusFeedback"
    statusFeedback.Position = UDim2.new(0, 198, 0, 185)
    statusFeedback.Size = UDim2.new(0, 242, 0, 13)
    statusFeedback.BackgroundTransparency = 1
    statusFeedback.Text = ""
    statusFeedback.Font = Enum.Font.GothamBold
    statusFeedback.TextSize = 9
    statusFeedback.TextColor3 = Color3.fromRGB(105, 195, 255)
    statusFeedback.TextXAlignment = Enum.TextXAlignment.Center
    statusFeedback.ZIndex = 202
    statusFeedback.Parent = mainCard

    -- 11. Dropdown Modal for Get Key
    local dropdownModal = Instance.new("Frame")
    dropdownModal.Name = "DropdownModal"
    dropdownModal.Visible = false
    dropdownModal.Position = UDim2.new(0, 280, 0, 124)
    dropdownModal.Size = UDim2.new(0, 76, 0, 72)
    dropdownModal.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    dropdownModal.BorderSizePixel = 0
    dropdownModal.ZIndex = 215
    dropdownModal.Parent = mainCard

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 7)
    dropCorner.Parent = dropdownModal

    local dropStroke = Instance.new("UIStroke")
    dropStroke.Color = Color3.fromRGB(120, 60, 220)
    dropStroke.Thickness = 1
    dropStroke.Transparency = 0.30
    dropStroke.Parent = dropdownModal

    local function createDropOption(yOffset, nameText, url)
        local optBtn = Instance.new("TextButton")
        optBtn.Position = UDim2.new(0, 4, 0, yOffset)
        optBtn.Size = UDim2.new(1, -8, 0, 30)
        optBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 80)
        optBtn.Text = nameText
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 11
        optBtn.TextColor3 = Color3.fromRGB(210, 185, 255)
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 216
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 5)
        optCorner.Parent = optBtn
        optBtn.Parent = dropdownModal

        optBtn.MouseButton1Click:Connect(function()
            dropdownModal.Visible = false
            if setclipboard then
                pcall(function() setclipboard(url) end)
            end
            statusFeedback.Text = "Copied link!"
            task.delay(3, function()
                if statusFeedback.Text == "Copied link!" then
                    statusFeedback.Text = ""
                end
            end)
        end)
    end

    createDropOption(4, "Lootlabs", LootlabsUrl)
    createDropOption(38, "Linkvertise", LinkvertiseUrl)

    -- 12. Bottom Action Buttons Row
    local function createActionButton(xOffset, bgColor, labelText, textColor)
        local btn = Instance.new("TextButton")
        btn.Position = UDim2.new(0, xOffset, 0, 202)
        btn.Size = UDim2.new(0, 76, 0, 30)
        btn.BackgroundColor3 = bgColor
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = 202
        btn.Parent = mainCard

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.FredokaOne
        lbl.TextSize = 13
        lbl.TextColor3 = textColor
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.ZIndex = 203
        lbl.Parent = btn

        return btn
    end

    local freeBtn = createActionButton(198, Color3.fromRGB(45, 19, 85), "Free Version", Color3.fromRGB(200, 165, 255))
    local getKeyBtn = createActionButton(280, Color3.fromRGB(20, 45, 90), "Get Key", Color3.fromRGB(130, 195, 255))
    local enterKeyBtn = createActionButton(362, Color3.fromRGB(65, 25, 130), "Enter Key", Color3.fromRGB(225, 180, 255))

    freeBtn.MouseButton1Click:Connect(function()
        statusFeedback.Text = "No free version for this game."
        task.delay(3, function()
            if statusFeedback.Text == "No free version for this game." then
                statusFeedback.Text = ""
            end
        end)
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        dropdownModal.Visible = not dropdownModal.Visible
    end)

    enterKeyBtn.MouseButton1Click:Connect(function()
        local entered = textBox.Text
        if #entered > 0 then
            statusFeedback.TextColor3 = Color3.fromRGB(80, 200, 110)
            statusFeedback.Text = "Validating key..."
            OnKeySubmitted(entered)
        else
            statusFeedback.TextColor3 = Color3.fromRGB(255, 100, 100)
            statusFeedback.Text = "Please enter a key!"
        end
        task.delay(3, function()
            statusFeedback.TextColor3 = Color3.fromRGB(105, 195, 255)
            statusFeedback.Text = ""
        end)
    end)

    -- Window Dragging Mechanism
    local dragging = false
    local dragInput, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainCard.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainCard.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Mount
    screenGui.Parent = parentGui

    return {
        ScreenGui = screenGui,
        MainCard = mainCard,
        Close = function() screenGui:Destroy() end
    }
end

-- If executed directly, run default creation
if not ... or type(...) ~= "table" then
    QuantumKeySystem.Create()
end

return QuantumKeySystem
