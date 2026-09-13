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

local function ensurePrivileges()
    if setidentity then pcall(setidentity, 8) end
    if setthreadidentity then pcall(setthreadidentity, 8) end
end
ensurePrivileges()

-- ============================================================================
-- THEME DEFINITIONS & RESILIENT ARCHITECTURE
-- ============================================================================
-- 1. Default Authentic Onyx Purple Theme (Preserved 1:1, DO NOT ALTER)
local DefaultTheme = {
    Name         = "Polar Onyx",
    DisplayName  = "Polar Onyx [Purple]",
    LogoFile     = "polar_logo_purple.png",
    
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
    TextTabOff   = Color3.fromRGB(130, 120, 155),   -- #82789B

    CyberGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(60, 20, 90)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90, 40, 130)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(60, 60, 160)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(40, 100, 190)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 140, 200))
    }),
    LavenderGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(139, 92, 246)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(216, 180, 254))
    }),
    UnderlineGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(160, 100, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 40, 180))
    })
}

-- 2. New Authentic Polar Blue (Arctic Ice) Theme
local BlueTheme = setmetatable({
    Name         = "Polar Blue",
    DisplayName  = "Polar Blue [Arctic]",
    LogoFile     = "polar_logo_blue.png",
    
    WindowBase   = Color3.fromRGB(10, 10, 12),
    InnerCard    = Color3.fromRGB(18, 24, 34),
    ControlRow   = Color3.fromRGB(6, 10, 16),
    PillBadge    = Color3.fromRGB(10, 16, 26),
    SearchBase   = Color3.fromRGB(14, 22, 38),
    ModalBase    = Color3.fromRGB(10, 14, 24),
    
    Accent       = Color3.fromRGB(0, 229, 255),     -- #00E5FF (Electric Cyan)
    AccentGlow   = Color3.fromRGB(56, 189, 248),    -- #38BDF8 (Sky Ice)
    AccentDeep   = Color3.fromRGB(2, 132, 199),     -- #0284C7 (Ocean Blue)
    AccentStroke = Color3.fromRGB(14, 165, 233),    -- #0EA5E9 (Neon Blue Outline)
    BadgeStroke  = Color3.fromRGB(0, 229, 255),
    TrackStroke  = Color3.fromRGB(2, 132, 199),
    
    SwitchOff    = Color3.fromRGB(15, 15, 15),
    SwitchOn     = Color3.fromRGB(15, 15, 15),
    
    TextWhite    = Color3.fromRGB(255, 255, 255),
    TextLight    = Color3.fromRGB(220, 235, 245),
    TextDim      = Color3.fromRGB(195, 215, 235),
    TextMuted    = Color3.fromRGB(120, 135, 150),
    TextDesc     = Color3.fromRGB(130, 150, 175),
    TextTabOff   = Color3.fromRGB(115, 140, 170),

    CyberGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(10, 35, 75)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(14, 65, 130)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(18, 110, 180)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(2, 160, 220)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 229, 255))
    }),
    LavenderGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(2, 132, 199)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(56, 189, 248))
    }),
    UnderlineGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 229, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(120, 220, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(2, 132, 199))
    })
}, { __index = DefaultTheme })

-- Active working Theme table (starts with DefaultTheme values)
local Theme = {}
for k, v in pairs(DefaultTheme) do
    Theme[k] = v
end
setmetatable(Theme, { __index = DefaultTheme })

-- Built-in Theme Registry Map with full backwards-compatibility aliases
PolarUI.Themes = {
    ["Polar Onyx"] = DefaultTheme,
    ["Polar Blue"] = BlueTheme,
    
    ["Purple"] = DefaultTheme,
    ["Default"] = DefaultTheme,
    ["Blue"] = BlueTheme,
    ["Arctic"] = BlueTheme,
    ["Polar Ice"] = DefaultTheme,
    ["Liquid Glass"] = DefaultTheme,
    ["Blizzard"] = DefaultTheme,
    ["Arctic Aurora"] = DefaultTheme,
    ["Cyberpunk Neon"] = DefaultTheme,
    ["Midnight Violet"] = DefaultTheme,
    ["Darker"] = DefaultTheme,
    ["Dark"] = DefaultTheme
}

PolarUI.CurrentTheme = DefaultTheme
PolarUI.CurrentThemeName = "Polar Onyx"
PolarUI.ThemeRegistry = {}
PolarUI.ThemedElements = {}
PolarUI.ThemeCallbacks = {}

function PolarUI:RegisterThemedObject(instance, propertyName, themeKey)
    if not instance then return end
    table.insert(PolarUI.ThemedElements, {
        Instance = instance,
        Property = propertyName,
        Key = themeKey
    })
end

-- Dynamic Gradient references for inline container assignments
local CyberGradient = Theme.CyberGradient
local LavenderGradient = Theme.LavenderGradient
local UnderlineGradient = Theme.UnderlineGradient

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
PolarUI.Language = "EN"
PolarUI.Translatables = {}

PolarUI.Dictionary = {
    ["ES"] = {
        -- Tabs
        ["Farm"] = "Farmear",
        ["Stats"] = "Estadísticas",
        ["Status"] = "Estado",
        ["Shop"] = "Tienda",
        ["Quest Farm"] = "Misiones",
        ["Teleport"] = "Teletransporte",
        ["Combat PvP"] = "Combate PvP",
        ["Server Hop"] = "Servidores",
        ["Misc"] = "Varios",

        -- Modals & General
        ["Close"] = "Cerrar",
        ["Cerrar"] = "Cerrar",
        ["UI Font"] = "Fuente de Interfaz",
        ["UI Theme"] = "Tema de Interfaz",
        ["BG Image Fade"] = "Opacidad de Fondo",
        ["Language: English [EN]"] = "Idioma: Español [ES]",
        ["Idioma: Español [ES]"] = "Language: English [EN]",

        -- Sections (Core)
        ["Combat Settings"] = "Configuración de Combate",
        ["Auto Farm"] = "Auto Farm Automático",
        ["Player Enhancements"] = "Mejoras de Jugador",
        ["Distribute Stats"] = "Auto Estadísticas",
        ["Server Telemetry"] = "Telemetría del Servidor",
        ["Abilities"] = "Habilidades",
        ["Fighting Styles"] = "Estilos de Pelea",
        ["Swords"] = "Espadas",
        ["Guns"] = "Armas de Fuego",
        ["Island Teleport"] = "Viajes a Islas",
        ["Combat Enhancements"] = "Mejoras de Combate",
        ["Bounty Hunter Tracker"] = "Rastreador de Recompensas",
        ["Combat Mode"] = "Modo Combate",
        ["Aimbot & Hitbox"] = "Aimbot y Hitbox",
        ["Extreme Combat"] = "Combate Extremo",
        ["UI Customization"] = "Personalización de Interfaz",
        ["Extra Utilities"] = "Utilidades Extra",
        ["Movement"] = "Movimiento",
        ["Server Management"] = "Gestión de Servidores",

        -- Controls (Core)
        ["Farm Tool"] = "Arma de Farmeo",
        ["Smart Mastery"] = "Maestría Inteligente",
        ["Finishes mob with secondary weapon"] = "Remata al enemigo con arma secundaria",
        ["Mastery Weapon"] = "Arma a Masterizar",
        ["Auto Skills"] = "Habilidades Auto",
        ["Cast skills while farming"] = "Usa habilidades al farmear",
        ["Auto Farm Level"] = "Auto Farm Nivel",
        ["Auto Chest"] = "Auto Cofres",
        ["Farm Nearest"] = "Farmear Cercano",
        ["Player & Mob ESP"] = "ESP Jugadores y Mobs",
        ["Auto Buso Haki"] = "Auto Haki Buso",
        ["Auto Ken Haki"] = "Auto Haki Ken",
        ["Melee"] = "Cuerpo a Cuerpo",
        ["Defense"] = "Defensa",
        ["Sword"] = "Espada",
        ["Gun"] = "Arma",
        ["Demon Fruit"] = "Fruta",
        ["Auto Assign Stats"] = "Asignar Puntos",
        ["Server Uptime"] = "Tiempo del Servidor",
        ["Session Time"] = "Tiempo en Sesión",
        ["Select Target"] = "Seleccionar Objetivo",
        ["Refresh Player List"] = "Actualizar Jugadores",
        ["Target Information"] = "Información del Objetivo",
        ["Teleport to Target"] = "Teleport al Objetivo",
        ["Enable Combat Mode"] = "Activar Modo Combate",
        ["Enables hitbox & silent aim"] = "Activa hitbox y silent aim",
        ["Hitbox Expander"] = "Expansor de Hitbox",
        ["Expands enemy collision box"] = "Aumenta la caja de colisión",
        ["Hitbox Size"] = "Tamaño de Hitbox",
        ["Silent Aim"] = "Silent Aim (Aimbot)",
        ["Redirects attacks to target"] = "Redirige ataques al objetivo",
        ["Bring Target"] = "Atraer Objetivo",
        ["Brings enemy player to you"] = "Teletransporta enemigo frente a ti",
        ["Kill Aura"] = "Kill Aura",
        ["Attacks all nearby enemies"] = "Daña a todos los enemigos cercanos",
        ["Visual Theme"] = "Tema Visual",
        ["Reset Floating Button"] = "Recentrar Botón Flotante",
        ["Interface Scale"] = "Escala de Interfaz",
        ["Fruit Finder"] = "Buscador de Frutas",
        ["Fly Mode"] = "Modo Vuelo",
        ["Auto Rejoin"] = "Reconexión Automática",
        ["Walk Speed"] = "Nivel de Velocidad",
        ["Speed Boost"] = "Aumento de Velocidad",
        ["Infinite Jump"] = "Salto Infinito",
        ["NoClip"] = "Atravesar Paredes",
        ["Walk on Water"] = "Caminar sobre el Agua",
        ["Job ID"] = "Pegar Job ID",
        ["Join Job ID"] = "Unirse por Job ID",
        ["Copy Current Job ID"] = "Copiar Job ID Actual",
        ["Hop Low Players"] = "Servidor con Menos Gente",
        ["Hop Best Ping"] = "Servidor con Mejor Ping",
        ["Auto Join Bounty"] = "Auto-Unirse a Caza",

        -- Sections (Sea 1)
        ["Boss Status & Timers"] = "Tabla de Jefes y Respawn",
        ["Raid Boss Radar"] = "Radar de Jefes de Raid",
        ["Sea 1 Boss Hunter"] = "Cazador de Jefes (Sea 1)",
        ["Saber Puzzle"] = "Puzzle de Saber",
        ["Secrets Master"] = "Maestro de Secretos (Sea 1)",
        ["Island Secrets Explorer"] = "Explorador de Secretos",
        ["Second Sea Journey"] = "Viaje al Second Sea",
        ["Haki Trainers"] = "Entrenadores de Haki",
        ["Sea 1 Fighting Styles"] = "Estilos de Pelea (Sea 1)",

        -- Controls (Sea 1)
        ["Select Boss to Inspect"] = "Seleccionar Jefe para Inspeccionar",
        ["Refresh Boss Status"] = "Actualizar Estado del Jefe",
        ["Teleport to Boss"] = "Teleport a Ubicación del Jefe",
        ["Select Boss"] = "Seleccionar Jefe",
        ["Farm Selected Boss"] = "Farmear Jefe Seleccionado",
        ["Farm All Bosses"] = "Farmear Todos los Jefes",
        ["Take Boss Quest"] = "Tomar Misión del Jefe",
        ["Start Auto Saber"] = "Iniciar Auto Saber",
        ["Stop Auto Saber"] = "Detener Auto Saber",
        ["Teleport to Secrets Master"] = "Teleport a Secrets Master",
        ["Auto Read Stories"] = "Auto Leer Historias",
        ["Equip Combat Style"] = "Equipar Estilo Combat",
        ["Equip Advanced Combat"] = "Equipar Advanced Combat",
        ["Select Secret Zone"] = "Seleccionar Zona Secreta",
        ["Teleport to Secret Zone"] = "Teleport a Zona Secreta",
        ["Start Second Sea Journey"] = "Iniciar Viaje al Second Sea",
        ["Stop Journey"] = "Detener Viaje",
        ["Buy Geppo - $10k"] = "Comprar Geppo - $10k",
        ["Buy Buso - $25k"] = "Comprar Buso - $25k",
        ["Buy Soru - $100k"] = "Comprar Soru - $100k",
        ["Buy Ken Haki - $750k"] = "Comprar Ken Haki - $750k",
        ["Check Ken Haki"] = "Consultar Estado Ken Haki",
        ["Buy Dark Step - $150k"] = "Comprar Dark Step - $150k",
        ["Buy Electro - $500k"] = "Comprar Electro - $500k",
        ["Buy Water Kung Fu - $750k"] = "Comprar Water Kung Fu - $750k",
        ["Select Island"] = "Elegir Isla",
        ["Teleport to Island"] = "Volar Hacia Isla"
    }
}

function PolarUI:RegisterTranslatable(labelObj, enText, esText)
    if not labelObj then return end
    local es = esText or (PolarUI.Dictionary["ES"] and PolarUI.Dictionary["ES"][enText]) or enText
    table.insert(PolarUI.Translatables, {
        Label = labelObj,
        EN = enText,
        ES = es
    })
    if PolarUI.Language == "ES" then
        labelObj.Text = es
    else
        labelObj.Text = enText
    end
end

function PolarUI:SetLanguage(lang)
    PolarUI.Language = lang
    for _, item in ipairs(PolarUI.Translatables) do
        if item.Label and item.Label.Parent then
            item.Label.Text = (lang == "ES") and item.ES or item.EN
        end
    end
end

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

-- Helper to load authentic theme logo dynamically with full fallback resilience
local function getThemeLogo(targetTheme)
    targetTheme = targetTheme or DefaultTheme
    local targetFile = targetTheme.LogoFile or DefaultTheme.LogoFile or "polar_logo_purple.png"
    
    -- Priority 1: Local file check for target theme logo
    if getcustomasset and isfile then
        local okCheck, exists = pcall(isfile, targetFile)
        if okCheck and exists then
            local okAsset, asset = pcall(getcustomasset, targetFile)
            if okAsset and asset then return asset end
        end
    end
    
    -- Priority 2: Download target theme logo from GitHub repository
    if writefile and getcustomasset and game and game.HttpGet then
        local okFetch, content = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/" .. targetFile)
        end)
        if okFetch and content and #content > 500 then
            pcall(writefile, targetFile, content)
            local okAsset, asset = pcall(getcustomasset, targetFile)
            if okAsset and asset then return asset end
        end
    end
    
    -- Priority 3: Fallback to DefaultTheme (Purple Logo) if target was not DefaultTheme
    if targetFile ~= (DefaultTheme.LogoFile or "polar_logo_purple.png") then
        local defaultFile = DefaultTheme.LogoFile or "polar_logo_purple.png"
        if getcustomasset and isfile then
            local okCheck, exists = pcall(isfile, defaultFile)
            if okCheck and exists then
                local okAsset, asset = pcall(getcustomasset, defaultFile)
                if okAsset and asset then return asset end
            end
        end
        if writefile and getcustomasset and game and game.HttpGet then
            local okFetch, content = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/" .. defaultFile)
            end)
            if okFetch and content and #content > 500 then
                pcall(writefile, defaultFile, content)
                local okAsset, asset = pcall(getcustomasset, defaultFile)
                if okAsset and asset then return asset end
            end
        end
    end
    
    -- Priority 4: Legacy polar_logo.png fallback
    if getcustomasset and isfile then
        local okCheck, exists = pcall(isfile, "polar_logo.png")
        if okCheck and exists then
            local okAsset, asset = pcall(getcustomasset, "polar_logo.png")
            if okAsset and asset then return asset end
        end
    end
    
    -- Priority 5: Fallback to authentic in-engine rbxassetid
    return "rbxassetid://87383580130479"
end

local function getPolarLogo()
    return getThemeLogo(PolarUI.CurrentTheme or DefaultTheme)
end

function PolarUI:SetTheme(themeName)
    local target = PolarUI.Themes[themeName]
    if not target then
        target = DefaultTheme
    end
    
    PolarUI.CurrentTheme = target
    PolarUI.CurrentThemeName = target.Name or "Polar Onyx"
    
    -- Update working Theme table
    for k, v in pairs(DefaultTheme) do
        Theme[k] = target[k] or v
    end
    
    -- Update dynamic gradient pointers
    CyberGradient = Theme.CyberGradient or DefaultTheme.CyberGradient
    LavenderGradient = Theme.LavenderGradient or DefaultTheme.LavenderGradient
    UnderlineGradient = Theme.UnderlineGradient or DefaultTheme.UnderlineGradient
    
    -- Resolve theme logo
    local themeLogo = getThemeLogo(target)
    
    -- Update all active windows
    for _, win in ipairs(PolarUI.ActiveWindows) do
        pcall(function()
            if win.FloatBtn then
                win.FloatBtn.Image = themeLogo
            end
            if win.FloatStroke then
                win.FloatStroke.Color = target.AccentStroke or DefaultTheme.AccentStroke
            end
        end)
    end
    
    -- Update registered themed instances
    for i = #PolarUI.ThemedElements, 1, -1 do
        local item = PolarUI.ThemedElements[i]
        if item.Instance and item.Instance.Parent then
            local val = target[item.Key]
            if val == nil then val = DefaultTheme[item.Key] end
            if val ~= nil then
                pcall(function()
                    item.Instance[item.Property] = val
                end)
            end
        else
            table.remove(PolarUI.ThemedElements, i)
        end
    end
    
    -- Execute registered theme callbacks
    for _, cb in ipairs(PolarUI.ThemeCallbacks or {}) do
        pcall(cb, target)
    end
end

-- ============================================================================
-- GLOBAL EXPOSURE & SEARCH REGISTRY
-- ============================================================================
_G.PolarUI = PolarUI
if getgenv then getgenv().PolarUI = PolarUI end

PolarUI.SearchRegistry = {}

function PolarUI:RegisterSearchItem(name, instance)
    if not instance then return end
    table.insert(PolarUI.SearchRegistry, {
        Name = tostring(name or ""),
        Instance = instance
    })
end

-- ============================================================================
-- TOAST NOTIFICATION SYSTEM (Exact Quantum Onyx Native Architecture)
-- Extracted directly from live memory of Onyx via Real MCP inspection
-- ============================================================================
local notifGui = nil
local function getNotificationHolder()
    local parentGui = nil
    if gethui then pcall(function() parentGui = gethui() end) end
    if not parentGui then
        parentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui") or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
    end

    if not notifGui or not notifGui.Parent then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "PolarHub_Notifications"
        notifGui.ResetOnSpawn = false
        notifGui.DisplayOrder = 999999
        notifGui.IgnoreGuiInset = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        if syn and syn.protect_gui then pcall(syn.protect_gui, notifGui) end
        notifGui.Parent = parentGui
    end

    local holder = notifGui:FindFirstChild("STX_Notification")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "STX_Notification"
        holder.AnchorPoint = Vector2.new(1, 0)
        holder.Position = UDim2.new(1, -10, 0, 10)
        holder.Size = UDim2.new(1, -20, 1, -52)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.ZIndex = 999
        holder.Parent = notifGui

        local layout = Instance.new("UIListLayout")
        layout.Name = "STX_NotificationUIListLayout"
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 6)
        layout.Parent = holder
    end
    return holder
end

function PolarUI:Notify(cfg)
    ensurePrivileges()
    local title = type(cfg) == "table" and (cfg.Title or "Polar Hub") or tostring(cfg)
    local desc = type(cfg) == "table" and (cfg.Content or cfg.Text or cfg.Description or "") or ""
    local dur = type(cfg) == "table" and (cfg.Duration or 4) or 4
    if dur < 1 then dur = 3 end

    task.spawn(function()
        ensurePrivileges()
        local holder = getNotificationHolder()
        if not holder then return end

        -- Dynamic text height calculation matching Onyx
        local textService = game:GetService("TextService")
        local textHeight = 16
        if desc and #desc > 0 then
            local bounds = textService:GetTextSize(desc, 12, Enum.Font.Gotham, Vector2.new(184, 1000))
            textHeight = bounds.Y
        else
            textHeight = 0
        end

        local cardHeight = 22 + textHeight + 18
        if cardHeight < 46 then cardHeight = 46 end

        -- Outer Frame: exact 206px width, anchor (1, 0)
        local card = Instance.new("Frame")
        card.Name = "Frame"
        card.AnchorPoint = Vector2.new(1, 0)
        card.Position = UDim2.new(1, -10, 0, 10)
        card.Size = UDim2.new(0, 206, 0, cardHeight)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ZIndex = 1000

        -- Inner Frame: dark matte background Color3.fromRGB(25, 25, 25), ClipsDescendants = true
        local inner = Instance.new("Frame")
        inner.Name = "Frame"
        inner.AnchorPoint = Vector2.new(0, 0)
        inner.Position = UDim2.new(0, 0, 0, 0)
        inner.Size = UDim2.new(1, 0, 1, 0)
        inner.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        inner.BackgroundTransparency = 0
        inner.BorderSizePixel = 0
        inner.ClipsDescendants = true
        inner.ZIndex = 1001
        inner.Parent = card

        local innerCorner = Instance.new("UICorner")
        innerCorner.CornerRadius = UDim.new(0, 13)
        innerCorner.Parent = inner

        -- Title Label: exact Enum.Font.FredokaOne 12px Color3.fromRGB(220, 220, 220)
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "TextLabel"
        titleLbl.Position = UDim2.new(0, 8, 0, 2)
        titleLbl.Size = UDim2.new(1, -16, 0, 18)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.Font = Enum.Font.FredokaOne
        titleLbl.TextSize = 12
        titleLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextYAlignment = Enum.TextYAlignment.Center
        titleLbl.ZIndex = 1002
        titleLbl.Parent = inner

        -- Time Remaining Label: Gotham 11px Color3.fromRGB(180, 180, 180) on top right
        local timeLbl = Instance.new("TextLabel")
        timeLbl.Name = "TextLabel"
        timeLbl.AnchorPoint = Vector2.new(1, 0)
        timeLbl.Position = UDim2.new(1, -8, 0, 2)
        timeLbl.Size = UDim2.new(0, 40, 0, 18)
        timeLbl.BackgroundTransparency = 1
        timeLbl.Text = "(" .. tostring(math.floor(dur)) .. "s)"
        timeLbl.Font = Enum.Font.Gotham
        timeLbl.TextSize = 11
        timeLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        timeLbl.TextXAlignment = Enum.TextXAlignment.Right
        timeLbl.TextYAlignment = Enum.TextYAlignment.Center
        timeLbl.ZIndex = 1002
        timeLbl.Parent = inner

        -- Description Label: Gotham 12px Color3.fromRGB(180, 180, 180) wrapped
        local descLbl = Instance.new("TextLabel")
        descLbl.Name = "TextLabel"
        descLbl.Position = UDim2.new(0, 8, 0, 22)
        descLbl.Size = UDim2.new(0, 184, 0, textHeight)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 12
        descLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        descLbl.TextWrapped = true
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.TextYAlignment = Enum.TextYAlignment.Top
        descLbl.ZIndex = 1002
        descLbl.Parent = inner

        -- ProgressBarBackground: Color3.fromRGB(40, 40, 40), height 4px, position {0, 8}, {1, -10}
        local pTrack = Instance.new("Frame")
        pTrack.Name = "ProgressBarBackground"
        pTrack.Position = UDim2.new(0, 8, 1, -10)
        pTrack.Size = UDim2.new(1, -16, 0, 4)
        pTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pTrack.BorderSizePixel = 0
        pTrack.ZIndex = 1002
        pTrack.Parent = inner

        local ptc = Instance.new("UICorner")
        ptc.CornerRadius = UDim.new(1, 0)
        ptc.Parent = pTrack

        -- ProgressBarFill with exact 5-point gradient extracted from live memory
        local pFill = Instance.new("Frame")
        pFill.Name = "ProgressBarFill"
        pFill.Position = UDim2.new(0, 0, 0, 0)
        pFill.Size = UDim2.new(1, 0, 1, 0)
        pFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        pFill.BorderSizePixel = 0
        pFill.ZIndex = 1003
        pFill.Parent = pTrack

        local pfc = Instance.new("UICorner")
        pfc.CornerRadius = UDim.new(1, 0)
        pfc.Parent = pFill

        local pfg = Instance.new("UIGradient")
        pfg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(60, 20, 90)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90, 40, 130)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(60, 60, 160)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(40, 100, 190)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 140, 200))
        })
        pfg.Parent = pFill

        card.Parent = holder

        -- Slide-in animation from right
        card.Position = UDim2.new(1, 50, 0, 10)
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -10, 0, 10)
        }):Play()

        -- Progress bar shrinking animation matching duration
        local shrinkTween = TweenService:Create(pFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        shrinkTween:Play()

        -- Timer countdown loop updating every second
        local remaining = dur
        task.spawn(function()
            while remaining > 0 and card and card.Parent do
                timeLbl.Text = "(" .. tostring(math.ceil(remaining)) .. "s)"
                task.wait(1)
                remaining = remaining - 1
            end
        end)

        task.wait(dur)

        -- Exit animation: slide back to the right and fade out smoothly
        local fadeOut = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0, 10)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            card:Destroy()
        end)
    end)
end

-- Note: Theme logo resolution is handled dynamically via getThemeLogo and getPolarLogo


-- ============================================================================
-- MAIN WINDOW CREATION (Window Object)
-- ============================================================================
function PolarUI:MakeWindow(config)
    ensurePrivileges()
    config = config or {}
    local customTitle = config.Name or config.Title or "POLAR HUB"
    local customSub = config.SubTitle or '<font color="#00E5FF">Blox Fruits</font> • <font color="#C084FC">v.Powerhouse</font> • <font color="#FFD700">Official</font>'
    
    local selfWindow = setmetatable({}, { __index = PolarUI })
    selfWindow.RegisteredControls = {}
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

    -- 2. Floating Toggle Button (60x60 Circle at {0.016, 0}, {0.219, 0}, Smooth Draggable)
    local floatFrame = Instance.new("Frame")
    floatFrame.Name = "FloatToggle"
    floatFrame.Position = UDim2.new(0.016, 0, 0.219, 0)
    floatFrame.Size = UDim2.new(0, 60, 0, 60)
    floatFrame.BackgroundTransparency = 1
    floatFrame.BorderSizePixel = 0
    floatFrame.Active = true
    floatFrame.ZIndex = 500
    floatFrame.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatFrame

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Theme.AccentStroke
    floatStroke.Thickness = 1.5
    floatStroke.Transparency = 0.25
    floatStroke.Parent = floatFrame
    PolarUI:RegisterThemedObject(floatStroke, "Color", "AccentStroke")

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "ToggleLogo"
    floatBtn.Size = UDim2.new(1, 0, 1, 0)
    floatBtn.BackgroundTransparency = 1
    floatBtn.BorderSizePixel = 0
    floatBtn.Image = getThemeLogo(PolarUI.CurrentTheme or DefaultTheme)
    floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.ZIndex = 501
    floatBtn.Active = true
    floatBtn.Parent = floatFrame

    local floatBtnCorner = Instance.new("UICorner")
    floatBtnCorner.CornerRadius = UDim.new(1, 0)
    floatBtnCorner.Parent = floatBtn

    selfWindow.FloatFrame = floatFrame
    selfWindow.FloatBtn = floatBtn
    selfWindow.FloatStroke = floatStroke

    -- Draggable Floating Toggle Logic
    local floatDragging = false
    local floatDragStart, floatStartPos, floatDragInput
    local floatMoved = false

    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
            floatMoved = false
            floatDragStart = input.Position
            floatStartPos = floatFrame.Position

            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    floatDragging = false
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)

    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            floatDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == floatDragInput and floatDragging and floatDragStart and floatStartPos then
            local delta = input.Position - floatDragStart
            if delta.Magnitude > 4 then
                floatMoved = true
            end
            floatFrame.Position = UDim2.new(
                floatStartPos.X.Scale,
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale,
                floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = false
        end
    end)

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

    -- Toggle visibility animation (fires on click, not drag)
    local isVisible = true
    floatBtn.MouseButton1Click:Connect(function()
        if floatMoved then
            floatMoved = false
            return
        end
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

    -- 4. Top Bar (Header at {0, 0}, {0, 0}, Size {1, 0}, {0, 32})
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 205
    topBar.Active = true
    topBar.Parent = mainFrame

    -- Window Dragging Logic (Anchored to TopBar header ONLY - sliders/controls will NEVER drag the window)
    local draggingWindow = false
    local dragInput, dragStart, startPos
    local function updateWindow(input)
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingWindow = true
            dragStart = input.Position
            startPos = mainFrame.Position

            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingWindow = false
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and draggingWindow then
            updateWindow(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingWindow = false
        end
    end)

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
    titleLabel.Active = false
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
    subtitleLabel.Active = false
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
        modal.BackgroundTransparency = 0
        modal.BorderSizePixel = 0
        modal.ZIndex = 2000
        modal.Parent = mainFrame

        local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = modal

        local ms = Instance.new("UIStroke")
        ms.Color = Theme.AccentStroke
        ms.Thickness = 1.0
        ms.Transparency = 0.35
        ms.LineJoinMode = Enum.LineJoinMode.Round
        ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ms.Parent = modal
        PolarUI:RegisterThemedObject(ms, "Color", "AccentStroke")

        -- Top gradient background header
        local mTop = Instance.new("Frame")
        mTop.Size = UDim2.new(1, 0, 0.45, 0)
        mTop.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
        mTop.BackgroundTransparency = 0.92
        mTop.BorderSizePixel = 0
        mTop.ZIndex = 2001
        mTop.Parent = modal
        local mtc = Instance.new("UICorner"); mtc.CornerRadius = UDim.new(0, 12); mtc.Parent = mTop
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
        mIcon.ImageColor3 = Theme.Accent
        mIcon.ZIndex = 2002
        mIcon.Parent = modal
        PolarUI:RegisterThemedObject(mIcon, "ImageColor3", "Accent")

        -- Title (15px GothamBold at {0.5, 0}, {0, 38})
        local mTitle = Instance.new("TextLabel")
        mTitle.AnchorPoint = Vector2.new(0.5, 0)
        mTitle.Position = UDim2.new(0.5, 0, 0, 38)
        mTitle.Size = UDim2.new(1, -24, 0, 16)
        mTitle.BackgroundTransparency = 1
        mTitle.BorderSizePixel = 0
        mTitle.Text = titleText
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 15
        mTitle.TextColor3 = Theme.Accent
        mTitle.TextXAlignment = Enum.TextXAlignment.Center
        mTitle.ZIndex = 2002
        mTitle.Parent = modal
        PolarUI:RegisterThemedObject(mTitle, "TextColor3", "Accent")

        -- Gradient divider line ({0.65, 0}, {0, 1} at {0.5, 0}, {0, 57})
        local mDiv = Instance.new("Frame")
        mDiv.AnchorPoint = Vector2.new(0.5, 0)
        mDiv.Position = UDim2.new(0.5, 0, 0, 57)
        mDiv.Size = UDim2.new(0.65, 0, 0, 1)
        mDiv.BackgroundColor3 = Theme.AccentStroke
        mDiv.BackgroundTransparency = 0.72
        mDiv.BorderSizePixel = 0
        mDiv.ZIndex = 2002
        mDiv.Parent = modal
        PolarUI:RegisterThemedObject(mDiv, "BackgroundColor3", "AccentStroke")
        local mdg = Instance.new("UIGradient")
        mdg.Color = UnderlineGradient
        mdg.Parent = mDiv
        PolarUI:RegisterThemedObject(mdg, "Color", "UnderlineGradient")

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
        mClose.Name = "CloseBtn"
        mClose.AnchorPoint = Vector2.new(0.5, 1)
        mClose.Position = UDim2.new(0.5, 0, 1, -9)
        mClose.Size = UDim2.new(0.52, 0, 0, 24)
        mClose.BackgroundColor3 = Color3.fromRGB(30, 18, 52)
        mClose.BorderSizePixel = 0
        mClose.Text = "Close"
        mClose.Font = Enum.Font.GothamBold
        mClose.TextSize = 11
        mClose.TextColor3 = Theme.Accent
        mClose.ZIndex = 2003
        mClose.Parent = modal
        PolarUI:RegisterTranslatable(mClose, "Close", "Cerrar")
        PolarUI:RegisterThemedObject(mClose, "TextColor3", "Accent")

        local mcc = Instance.new("UICorner"); mcc.CornerRadius = UDim.new(0, 6); mcc.Parent = mClose
        local mcs = Instance.new("UIStroke")
        mcs.Color = Theme.AccentStroke
        mcs.Thickness = 1.0
        mcs.Transparency = 0.35
        mcs.LineJoinMode = Enum.LineJoinMode.Round
        mcs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        mcs.Parent = mClose
        PolarUI:RegisterThemedObject(mcs, "Color", "AccentStroke")

        local function open()
            modalOverlay.Visible = true
            modal.Visible = true
            modal.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(modal, TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
        return { Modal = modal, Scroll = mScroll, Open = open, Close = close }
    end

    -- Construct Config. Modal (exact replica matching user image)
    local configModal = createAuthenticModal("Config", "Config.", "rbxassetid://81151604784579")
    do
        -- 1. Language Translator Box
        local langBox = Instance.new("TextButton")
        langBox.Size = UDim2.new(1, 0, 0, 28)
        langBox.BackgroundColor3 = Color3.fromRGB(18, 13, 30)
        langBox.BackgroundTransparency = 0.20
        langBox.BorderSizePixel = 0
        langBox.Text = "Language: English [EN]"
        langBox.Font = Enum.Font.GothamBold
        langBox.TextSize = 10
        langBox.TextColor3 = Color3.fromRGB(215, 185, 255)
        langBox.ZIndex = 2004
        langBox.Parent = configModal.Scroll
        local lbc = Instance.new("UICorner"); lbc.CornerRadius = UDim.new(0, 6); lbc.Parent = langBox
        local lbs = Instance.new("UIStroke")
        lbs.Color = Theme.AccentStroke
        lbs.Thickness = 1
        lbs.Transparency = 0.35
        lbs.LineJoinMode = Enum.LineJoinMode.Round
        lbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        lbs.Parent = langBox

        -- 2. BG Image Fade Slider Box
        local fadeBox = Instance.new("Frame")
        fadeBox.Size = UDim2.new(1, 0, 0, 48)
        fadeBox.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
        fadeBox.BackgroundTransparency = 0.20
        fadeBox.BorderSizePixel = 0
        fadeBox.ZIndex = 2004
        fadeBox.Parent = configModal.Scroll
        local fbc = Instance.new("UICorner"); fbc.CornerRadius = UDim.new(0, 8); fbc.Parent = fadeBox
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
        local ftc = Instance.new("UICorner"); ftc.CornerRadius = UDim.new(1, 0); ftc.Parent = fTrack
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
        fFill.Active = false
        fFill.Parent = fTrack
        local ffc = Instance.new("UICorner"); ffc.CornerRadius = UDim.new(1, 0); ffc.Parent = fFill
        local ffg = Instance.new("UIGradient"); ffg.Color = LavenderGradient; ffg.Parent = fFill

        local fThumb = Instance.new("Frame")
        fThumb.AnchorPoint = Vector2.new(0.5, 0.5)
        fThumb.Position = UDim2.new(0.88, 0, 0.5, 0)
        fThumb.Size = UDim2.new(0, 12, 0, 12)
        fThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fThumb.BorderSizePixel = 0
        fThumb.ZIndex = 2007
        fThumb.Active = false
        fThumb.Parent = fTrack
        local ftcc = Instance.new("UICorner"); ftcc.CornerRadius = UDim.new(1, 0); ftcc.Parent = fThumb

        -- Interactive sliding for fadeBox
        local fSliding = false
        local function updateFade(input)
            local p = math.clamp((input.Position.X - fTrack.AbsolutePosition.X) / math.max(1, fTrack.AbsoluteSize.X), 0, 1)
            fFill.Size = UDim2.new(p, 0, 1, 0)
            fThumb.Position = UDim2.new(p, 0, 0.5, 0)
            local pctNum = math.floor(p * 100 + 0.5)
            fVal.Text = tostring(pctNum) .. "%"
        end

        local fadeHitbox = Instance.new("TextButton")
        fadeHitbox.Name = "FadeHitbox"
        fadeHitbox.Position = UDim2.new(0, 0, 0, 20)
        fadeHitbox.Size = UDim2.new(1, 0, 0, 26)
        fadeHitbox.BackgroundTransparency = 1
        fadeHitbox.BorderSizePixel = 0
        fadeHitbox.Text = ""
        fadeHitbox.ZIndex = 2008
        fadeHitbox.Parent = fadeBox

        fadeHitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fSliding = true
                updateFade(input)
            end
        end)
        fTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fSliding = true
                updateFade(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if fSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFade(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fSliding = false
            end
        end)

        PolarUI:RegisterTranslatable(flbl, "BG Image Fade", "Opacidad de Fondo")

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
        fontHdr.Parent = configModal.Scroll
        PolarUI:RegisterTranslatable(fontHdr, "UI Font", "Fuente de Interfaz")

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
        gothamBtn.Parent = configModal.Scroll
        local gbc = Instance.new("UICorner"); gbc.CornerRadius = UDim.new(0, 5); gbc.Parent = gothamBtn
        local gbs = Instance.new("UIStroke")
        gbs.Color = Theme.AccentStroke
        gbs.Thickness = 1
        gbs.Transparency = 0.35
        gbs.LineJoinMode = Enum.LineJoinMode.Round
        gbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        gbs.Parent = gothamBtn
        PolarUI:RegisterThemedObject(gbs, "Color", "AccentStroke")

        -- 5. UI Theme Section Header
        local themeHdr = Instance.new("TextLabel")
        themeHdr.Size = UDim2.new(1, 0, 0, 16)
        themeHdr.BackgroundTransparency = 1
        themeHdr.Text = "UI Theme"
        themeHdr.Font = Enum.Font.GothamBold
        themeHdr.TextSize = 10
        themeHdr.TextColor3 = Theme.AccentGlow
        themeHdr.TextXAlignment = Enum.TextXAlignment.Center
        themeHdr.ZIndex = 2004
        themeHdr.Parent = configModal.Scroll
        PolarUI:RegisterTranslatable(themeHdr, "UI Theme", "Tema de Interfaz")
        PolarUI:RegisterThemedObject(themeHdr, "TextColor3", "AccentGlow")

        -- Dynamic Theme Selectors (extensible architecture)
        local themeEntries = {
            { Key = "Polar Onyx", Display = "Polar Onyx [Purple]", Bg = Color3.fromRGB(30, 18, 52), Text = Color3.fromRGB(215, 185, 255), Stroke = Color3.fromRGB(160, 100, 240) },
            { Key = "Polar Blue", Display = "Polar Blue [Arctic]", Bg = Color3.fromRGB(12, 28, 48), Text = Color3.fromRGB(0, 229, 255), Stroke = Color3.fromRGB(14, 165, 233) }
        }

        local themeBtnMap = {}
        local function refreshThemeUI()
            for _, entry in ipairs(themeEntries) do
                local uiItem = themeBtnMap[entry.Key]
                if uiItem then
                    local isActive = (PolarUI.CurrentThemeName == entry.Key)
                    if isActive then
                        uiItem.Btn.Text = "✓ " .. entry.Display
                        uiItem.Btn.TextColor3 = entry.Text
                        uiItem.Btn.BackgroundColor3 = entry.Bg
                        uiItem.Btn.BackgroundTransparency = 0.20
                        uiItem.Stroke.Color = entry.Stroke
                        uiItem.Stroke.Transparency = 0.35
                    else
                        uiItem.Btn.Text = entry.Display
                        uiItem.Btn.TextColor3 = Color3.fromRGB(130, 130, 150)
                        uiItem.Btn.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
                        uiItem.Btn.BackgroundTransparency = 0.45
                        uiItem.Stroke.Color = Color3.fromRGB(60, 50, 80)
                        uiItem.Stroke.Transparency = 0.65
                    end
                end
            end
        end

        for _, entry in ipairs(themeEntries) do
            local tBtn = Instance.new("TextButton")
            tBtn.Name = "ThemeBtn_" .. entry.Key
            tBtn.Size = UDim2.new(1, 0, 0, 26)
            tBtn.BorderSizePixel = 0
            tBtn.Font = Enum.Font.GothamBold
            tBtn.TextSize = 11
            tBtn.ZIndex = 2004
            tBtn.Parent = configModal.Scroll

            local tbc = Instance.new("UICorner")
            tbc.CornerRadius = UDim.new(0, 5)
            tbc.Parent = tBtn

            local tbs = Instance.new("UIStroke")
            tbs.Thickness = 1
            tbs.LineJoinMode = Enum.LineJoinMode.Round
            tbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            tbs.Parent = tBtn

            themeBtnMap[entry.Key] = { Btn = tBtn, Stroke = tbs, Entry = entry }

            tBtn.MouseButton1Click:Connect(function()
                PolarUI:SetTheme(entry.Key)
            end)
        end

        table.insert(PolarUI.ThemeCallbacks, refreshThemeUI)
        refreshThemeUI()

        -- Language translator toggle
        local isEnglish = (PolarUI.Language == "EN")
        langBox.MouseButton1Click:Connect(function()
            isEnglish = not isEnglish
            local targetLang = isEnglish and "EN" or "ES"
            langBox.Text = isEnglish and "Language: English [EN]" or "Idioma: Español [ES]"
            PolarUI:SetLanguage(targetLang)
        end)
    end

    -- Construct Credits Modal (exact replica matching user image)
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
        teamHdr.Parent = creditsModal.Scroll

        local team = {
            { letter = "V", name = "Vin", role = "ServerOwner", color = Color3.fromRGB(255, 200, 80) },
            { letter = "F", name = "Flazhy", role = "MainDeveloper", color = Color3.fromRGB(175, 115, 255) },
            { letter = "K", name = "Kiel", role = "WebDesigner", color = Color3.fromRGB(100, 200, 255) },
            { letter = "P", name = "Polar", role = "LeadDeveloper", color = Color3.fromRGB(0, 229, 255) },
            { letter = "A", name = "Ans", role = "CoreEngine", color = Color3.fromRGB(175, 115, 255) }
        }

        for _, member in ipairs(team) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 50)
            card.BackgroundColor3 = Color3.fromRGB(10, 7, 18)
            card.BorderSizePixel = 0
            card.ZIndex = 2004
            card.Parent = creditsModal.Scroll
            local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = card
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
            local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(1, 0); avc.Parent = av
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
            rb.Size = UDim2.new(0, 76, 0, 20)
            rb.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
            rb.BorderSizePixel = 0
            rb.ZIndex = 2005
            rb.Parent = card
            local rbc = Instance.new("UICorner"); rbc.CornerRadius = UDim.new(0, 5); rbc.Parent = rb
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

    -- Header Button Builder (Config. & Credits matching user screenshot 5)
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

        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn

        local bs = Instance.new("UIStroke")
        bs.Color = Theme.AccentStroke
        bs.Thickness = 1.0
        bs.Transparency = 0.32
        bs.LineJoinMode = Enum.LineJoinMode.Round
        bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bs.Parent = btn
        PolarUI:RegisterThemedObject(bs, "Color", "AccentStroke")

        -- Left Vertical Neon Gradient Strip
        local strip = Instance.new("Frame")
        strip.Position = UDim2.new(0, 0, 0.5, -7)
        strip.Size = UDim2.new(0, 2, 0, 14)
        strip.BackgroundColor3 = Theme.AccentStroke
        strip.BorderSizePixel = 0
        strip.ZIndex = 207
        strip.Parent = btn
        PolarUI:RegisterThemedObject(strip, "BackgroundColor3", "AccentStroke")
        local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = strip
        local sg = Instance.new("UIGradient")
        sg.Rotation = 90
        sg.Color = LavenderGradient
        sg.Parent = strip
        PolarUI:RegisterThemedObject(sg, "Color", "LavenderGradient")

        -- Icon
        local icon = Instance.new("ImageLabel")
        icon.Position = UDim2.new(0, 8, 0.5, -7)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Image = iconId
        icon.ImageColor3 = Theme.Accent
        icon.ZIndex = 207
        icon.Parent = btn
        PolarUI:RegisterThemedObject(icon, "ImageColor3", "Accent")

        -- Label
        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 27, 0, 0)
        lbl.Size = UDim2.new(1, -30, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = Theme.Accent
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 207
        lbl.Parent = btn
        PolarUI:RegisterThemedObject(lbl, "TextColor3", "Accent")

        if onClick then
            btn.MouseButton1Click:Connect(onClick)
        end

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

    -- SearchBarFrame at {0, 8}, {0, 1}, Size {0, 126}, {0, 22} (Exact extracted Onyx specification)
    local searchBar = Instance.new("Frame")
    searchBar.Name = "SearchBarFrame"
    searchBar.Position = UDim2.new(0, 8, 0, 1)
    searchBar.Size = UDim2.new(0, 126, 0, 22)
    searchBar.BackgroundColor3 = Color3.fromRGB(22, 17, 34)
    searchBar.BackgroundTransparency = 0.40
    searchBar.BorderSizePixel = 0
    searchBar.ZIndex = 206
    searchBar.Parent = tabBar

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = searchBar

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
    searchBox.Name = "SearchBox"
    searchBox.Position = UDim2.new(0, 21, 0, 0)
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(135, 120, 165)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.TextColor3 = Color3.fromRGB(235, 230, 250)
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.TextYAlignment = Enum.TextYAlignment.Center
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 207
    searchBox.Parent = searchBar

    -- Clear button (hidden by default, only visible when query text exists)
    local searchClear = Instance.new("TextButton")
    searchClear.Name = "SearchClear"
    searchClear.Position = UDim2.new(1, -3, 0.5, 0)
    searchClear.AnchorPoint = Vector2.new(1, 0.5)
    searchClear.Size = UDim2.new(0, 14, 0, 14)
    searchClear.BackgroundTransparency = 1
    searchClear.BorderSizePixel = 0
    searchClear.Text = "×"
    searchClear.Font = Enum.Font.GothamBold
    searchClear.TextSize = 12
    searchClear.TextColor3 = Color3.fromRGB(175, 145, 215)
    searchClear.Visible = false
    searchClear.ZIndex = 207
    searchClear.Parent = searchBar

    -- Floating counter badge (hidden by default, only appears to show matching results count, disappears when search is cleared)
    local searchCount = Instance.new("TextLabel")
    searchCount.Name = "SearchCount"
    searchCount.AnchorPoint = Vector2.new(1, 0)
    searchCount.Position = UDim2.new(1, -2, 0, -6)
    searchCount.Size = UDim2.new(0, 22, 0, 13)
    searchCount.BackgroundColor3 = Color3.fromRGB(110, 60, 190)
    searchCount.BackgroundTransparency = 0.20
    searchCount.BorderSizePixel = 0
    searchCount.Text = "0"
    searchCount.Font = Enum.Font.GothamBold
    searchCount.TextSize = 9
    searchCount.TextColor3 = Color3.fromRGB(240, 225, 255)
    searchCount.Visible = false
    searchCount.ZIndex = 208
    searchCount.Parent = searchBar
    local scc = Instance.new("UICorner"); scc.CornerRadius = UDim.new(1, 0); scc.Parent = searchCount

    -- Live Search Filtering
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local raw = searchBox.Text
        local query = raw:lower():gsub("^%s*(.-)%s*$", "%1")
        if query == "" then
            searchClear.Visible = false
            searchCount.Visible = false
            searchCount.Text = "0"
            searchCount.Size = UDim2.new(0, 22, 0, 13)
            for _, item in ipairs(PolarUI.SearchRegistry) do
                if item.Instance and item.Instance.Parent then
                    item.Instance.Visible = true
                end
            end
        else
            searchClear.Visible = true
            local matches = 0
            for _, item in ipairs(PolarUI.SearchRegistry) do
                if item.Instance and item.Instance.Parent then
                    local found = item.Name:lower():find(query, 1, true) ~= nil
                    item.Instance.Visible = found
                    if found then
                        matches = matches + 1
                    end
                end
            end
            if matches > 0 then
                searchCount.Text = tostring(matches)
                local w = 22
                if matches >= 100 then
                    w = 34
                elseif matches >= 10 then
                    w = 28
                end
                searchCount.Size = UDim2.new(0, w, 0, 13)
                searchCount.Visible = true
            else
                searchCount.Visible = false
                searchCount.Text = "0"
            end
        end
    end)

    searchClear.MouseButton1Click:Connect(function()
        searchBox.Text = ""
    end)

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
    ensurePrivileges()
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
    PolarUI:RegisterTranslatable(btn, tabTitle)

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
    PolarUI:RegisterThemedObject(underline, "BackgroundColor3", "AccentDeep")
    PolarUI:RegisterThemedObject(ug, "Color", "UnderlineGradient")

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
    ensurePrivileges()
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
    PolarUI:RegisterTranslatable(title, titleText)

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
        PolarUI:RegisterThemedObject(f, "BackgroundColor3", "Accent")
        PolarUI:RegisterThemedObject(g, "Color", "CyberGradient")
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
    ensurePrivileges()
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
    local isLongDesc = desc and #desc > 60
    local hasLongTitle = #name > 26
    local height = isLongDesc and 72 or (isMultiLine and 56 or (desc and 42 or 32))
    if hasLongTitle and desc then height = height + 10 end
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
    tLabel.Size = UDim2.new(1, -66, 0, desc and (hasLongTitle and 26 or 16) or height)
    tLabel.BackgroundTransparency = 1
    tLabel.BorderSizePixel = 0
    tLabel.Text = name
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 12
    tLabel.TextWrapped = true
    tLabel.TextColor3 = isToggled and Theme.TextWhite or Theme.TextMuted
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.TextYAlignment = desc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    tLabel.ZIndex = 211
    tLabel.Parent = btn
    PolarUI:RegisterTranslatable(tLabel, name, (type(cfg) == "table" and (cfg.ES or cfg.Spanish)))

    if desc then
        local dLabel = Instance.new("TextLabel")
        dLabel.Name = "DescLabel"
        dLabel.Position = UDim2.new(0, 10, 0, hasLongTitle and 30 or 20)
        dLabel.Size = UDim2.new(1, -60, 0, isLongDesc and 40 or (isMultiLine and 28 or 14))
        dLabel.BackgroundTransparency = 1
        dLabel.BorderSizePixel = 0
        dLabel.Text = desc
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 10
        dLabel.TextColor3 = Theme.TextDesc
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextYAlignment = Enum.TextYAlignment.Top
        dLabel.TextWrapped = true
        dLabel.ZIndex = 211
        dLabel.Parent = btn
        PolarUI:RegisterTranslatable(dLabel, desc, (type(cfg) == "table" and (cfg.DescES or cfg.SpanishDesc)))
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
    PolarUI:RegisterThemedObject(kg, "Color", "CyberGradient")

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
    PolarUI:RegisterSearchItem(name, btn)

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
    ensurePrivileges()
    local name, minVal, maxVal, defaultVal, callback
    if type(cfg) == "table" then
        name = cfg.Name or cfg.Title or cfg[1] or "Slider"
        if type(cfg.Default) == "table" then
            minVal = cfg.Default.Min or cfg.Default.MinValue or cfg.Default[1] or 0
            maxVal = cfg.Default.Max or cfg.Default.MaxValue or cfg.Default[2] or 100
            defaultVal = cfg.Default.Default or cfg.Default.Value or cfg.Default[3] or minVal
        elseif type(cfg.Value) == "table" then
            minVal = cfg.Value.Min or cfg.Value.MinValue or 0
            maxVal = cfg.Value.Max or cfg.Value.MaxValue or 100
            defaultVal = cfg.Value.Default or cfg.Value.Value or minVal
        else
            minVal = cfg.MinValue or cfg.Min or cfg[2] or 0
            maxVal = cfg.MaxValue or cfg.Max or cfg[3] or 100
            defaultVal = cfg.Default or cfg.Value or cfg[5] or minVal
        end
        callback = cfg.Callback or function() end
    else
        name = tostring(cfg)
        minVal = min or 0
        maxVal = max or 100
        defaultVal = def or minVal
        callback = cb or function() end
    end

    minVal = tonumber(minVal) or 0
    maxVal = tonumber(maxVal) or 100
    defaultVal = tonumber(defaultVal) or minVal

    local innerParent = resolveParent(self, overrideParent)
    local currentVal = defaultVal
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
    PolarUI:RegisterTranslatable(title, name, (type(cfg) == "table" and (cfg.ES or cfg.Spanish)))

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
    PolarUI:RegisterThemedObject(valBox, "TextColor3", "Accent")
    PolarUI:RegisterThemedObject(vbs, "Color", "BadgeStroke")

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
    PolarUI:RegisterThemedObject(ts, "Color", "TrackStroke")

    -- Lavender Gradient Fill
    local fill = Instance.new("Frame")
    local pct = math.clamp((currentVal - minVal) / math.max(1, maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 212
    fill.Active = false
    fill.Parent = track
    PolarUI:RegisterThemedObject(fill, "BackgroundColor3", "Accent")

    local filc = Instance.new("UICorner"); filc.CornerRadius = UDim.new(1, 0); filc.Parent = fill
    local filg = Instance.new("UIGradient"); filg.Color = LavenderGradient; filg.Parent = fill
    PolarUI:RegisterThemedObject(filg, "Color", "LavenderGradient")

    -- Thumb Knob (13x13 white circle with 5x5 violet inner dot)
    local thumb = Instance.new("Frame")
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, 13, 0, 13)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 213
    thumb.Active = false
    thumb.Parent = track

    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb
    local ths = Instance.new("UIStroke")
    ths.Color = Theme.AccentDeep
    ths.Thickness = 1.0
    ths.Transparency = 0.40
    ths.Parent = thumb
    PolarUI:RegisterThemedObject(ths, "Color", "AccentDeep")

    local innerDot = Instance.new("Frame")
    innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerDot.Size = UDim2.new(0, 5, 0, 5)
    innerDot.BackgroundColor3 = Theme.Accent
    innerDot.BorderSizePixel = 0
    innerDot.ZIndex = 214
    innerDot.Active = false
    innerDot.Parent = thumb
    local idc = Instance.new("UICorner"); idc.CornerRadius = UDim.new(1, 0); idc.Parent = innerDot

    -- Dedicated generous hit-box for smooth sliding on both PC and Mobile touch
    local sliderHitbox = Instance.new("TextButton")
    sliderHitbox.Name = "SliderHitbox"
    sliderHitbox.Position = UDim2.new(0, 0, 0, 24)
    sliderHitbox.Size = UDim2.new(1, 0, 0, 28)
    sliderHitbox.BackgroundTransparency = 1
    sliderHitbox.BorderSizePixel = 0
    sliderHitbox.Text = ""
    sliderHitbox.ZIndex = 220
    sliderHitbox.Parent = frame

    -- Drag & Click Math
    local sliding = false
    local function update(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * p + 0.5)
        currentVal = val
        valBox.Text = tostring(val)
        fill.Size = UDim2.new(p, 0, 1, 0)
        thumb.Position = UDim2.new(p, 0, 0.5, 0)
        callback(val)
    end

    local function startSliding(input)
        sliding = true
        update(input)
    end

    sliderHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startSliding(input)
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startSliding(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
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
    PolarUI:RegisterSearchItem(name, frame)

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
    ensurePrivileges()
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

    local isLongName = #name > 24
    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. name
    frame.LayoutOrder = ord
    frame.Size = UDim2.new(1, -25, 0, isLongName and 44 or 34)
    frame.BackgroundColor3 = Theme.ControlRow
    frame.BackgroundTransparency = 0.40
    frame.BorderSizePixel = 0
    frame.ZIndex = 210
    frame.Parent = innerParent

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.new(0, 10, 0, 0)
    tLabel.Size = UDim2.new(1, -92, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.BorderSizePixel = 0
    tLabel.Text = name
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11
    tLabel.TextWrapped = true
    tLabel.TextColor3 = Theme.TextWhite
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 211
    tLabel.Parent = frame
    PolarUI:RegisterTranslatable(tLabel, name, (type(cfg) == "table" and (cfg.ES or cfg.Spanish)))

    -- PillBadge Button with #C084FC border
    local pillBadge = Instance.new("Frame")
    pillBadge.AnchorPoint = Vector2.new(1, 0.5)
    pillBadge.Position = UDim2.new(1, -8, 0.5, 0)
    pillBadge.Size = UDim2.new(0, 76, 0, 22)
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
    PolarUI:RegisterThemedObject(pbs, "Color", "BadgeStroke")

    local valLabel = Instance.new("TextLabel")
    valLabel.Position = UDim2.new(0, 8, 0, 0)
    valLabel.Size = UDim2.new(1, -26, 1, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.BorderSizePixel = 0
    valLabel.Text = tostring(selectedVal)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextScaled = true
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Left
    valLabel.ZIndex = 212
    valLabel.Parent = pillBadge
    PolarUI:RegisterThemedObject(valLabel, "TextColor3", "Accent")

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
    PolarUI:RegisterSearchItem(name, frame)

    local dropdownObj = {
        Instance = frame,
        Name = name,
        Set = function(_, optVal)
            if type(optVal) == "table" then
                options = optVal
                rebuildOptions(optVal)
            else
                selectedVal = optVal
                valLabel.Text = tostring(optVal)
                callback(optVal)
            end
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
    ensurePrivileges()
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
    PolarUI:RegisterTranslatable(lbl, name, (type(cfg) == "table" and (cfg.ES or cfg.Spanish)))

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
    PolarUI:RegisterThemedObject(arrow, "TextColor3", "TrackStroke")

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
    PolarUI:RegisterSearchItem(name, btn)

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
    ensurePrivileges()
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
    PolarUI:RegisterTranslatable(titleLbl, titleText, (type(cfg) == "table" and (cfg.TitleES or cfg.ES)))

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
    PolarUI:RegisterSearchItem(titleText, card)

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
    ensurePrivileges()
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
    PolarUI:RegisterSearchItem(name, frame)

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
