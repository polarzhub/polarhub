-- POLAR EXTREME V2 (MAX EXECUTOR POWER)
-- Script diseñado para romper los límites del juego
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Obtener función HTTP compatible con el executor
local request_func = (syn and syn.request) or request or http_request or (http and http.request)

-- ==================== POLAR IA HELPER API ====================
local TweenService = game:GetService("TweenService")
shared.PolarAPI = {
    GetSkybasePos = function()
        return Vector3.new(0, 100000, 0)
    end,
    
    Notify = function(title, content, duration)
        pcall(function()
            if WindUI then
                WindUI:Notify({Title = title, Content = content, Duration = duration or 3})
            end
        end)
    end,
    
    FindObjects = function(searchTerm, maxCount)
        local found = {}
        maxCount = maxCount or 5
        searchTerm = searchTerm:lower()
        
        local function search(object)
            if #found >= maxCount then return end
            if object:IsA("Model") or object:IsA("BasePart") then
                -- Ignorar lo creado por la IA, el Skybase y el personaje local
                if object.Name == "PolarIslaIA" or object.Name == "PolarSkybase" or object:IsDescendantOf(LocalPlayer.Character) then
                    return
                end
                
                if object.Name:lower():find(searchTerm) then
                    table.insert(found, object)
                    return -- Detenerse para no buscar dentro del modelo encontrado
                end
            end
            for _, child in ipairs(object:GetChildren()) do
                search(child)
            end
        end
        
        search(workspace)
        return found
    end,
    
    CreateLaser = function(startPos, endPos, color, duration)
        color = color or Color3.fromRGB(0, 255, 255)
        duration = duration or 0.5
        
        local laser = Instance.new("Part")
        laser.Name = "PolarLaser"
        laser.Anchored = true
        laser.CanCollide = false
        laser.CastShadow = false
        laser.Material = Enum.Material.Neon
        laser.Color = color
        
        local distance = (startPos - endPos).Magnitude
        laser.Size = Vector3.new(0.4, 0.4, distance)
        laser.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
        
        local folder = workspace:FindFirstChild("PolarIslaIA") or workspace
        laser.Parent = folder
        
        task.spawn(function()
            local tween = TweenService:Create(laser, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0, 0, distance),
                Transparency = 1
            })
            tween:Play()
            tween.Completed:Wait()
            laser:Destroy()
        end)
    end,
    
    AnimateHologramTravel = function(model, startPos, endPos, duration, shootLasers)
        duration = duration or 3
        local clone = model:Clone()
        
        local folder = workspace:FindFirstChild("PolarIslaIA")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "PolarIslaIA"
            folder.Parent = workspace
        end
        clone.Parent = folder
        clone:PivotTo(CFrame.new(startPos))
        
        -- Respaldar propiedades y aplicar holograma
        local originalProps = {}
        local function applyHologram(obj)
            if obj:IsA("BasePart") then
                originalProps[obj] = {
                    Color = obj.Color,
                    Material = obj.Material,
                    Transparency = obj.Transparency,
                    CanCollide = obj.CanCollide
                }
                obj.CanCollide = false
                obj.Material = Enum.Material.ForceField
                obj.Color = Color3.fromRGB(0, 255, 255)
                obj.Transparency = 0.4
            end
            for _, child in ipairs(obj:GetChildren()) do
                applyHologram(child)
            end
        end
        applyHologram(clone)
        
        -- Animar movimiento
        local value = Instance.new("NumberValue")
        value.Value = 0
        local tween = TweenService:Create(value, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = 1 })
        
        local laserTimer = 0
        local connection
        connection = value.Changed:Connect(function(progress)
            local currentPos = startPos:Lerp(endPos, progress)
            clone:PivotTo(CFrame.new(currentPos))
            
            if shootLasers then
                laserTimer = laserTimer + 1
                if laserTimer % 5 == 0 then
                    local origin = currentPos - Vector3.new(0, 80, 0)
                    shared.PolarAPI.CreateLaser(origin, currentPos, Color3.fromRGB(0, 255, 255), 0.2)
                end
            end
        end)
        
        tween:Play()
        tween.Completed:Wait()
        connection:Disconnect()
        value:Destroy()
        
        -- Restaurar propiedades originales
        local function restoreProps(obj)
            if obj:IsA("BasePart") then
                local props = originalProps[obj]
                if props then
                    obj.Color = props.Color
                    obj.Material = props.Material
                    obj.Transparency = props.Transparency
                    obj.CanCollide = props.CanCollide
                end
                obj.Anchored = true
            end
            for _, child in ipairs(obj:GetChildren()) do
                restoreProps(child)
            end
        end
        restoreProps(clone)
        
        return clone
    end
}

-- ==================== ANTI-CHEAT BYPASS (NIVEL EXECUTOR) ====================
-- Usamos hookmetamethod para ocultarle al servidor nuestros verdaderos stats
-- FIX: Caché del humanoide para evitar C Stack Overflow (recursión infinita)
local myHumanoid = nil
task.spawn(function()
    while task.wait(1) do
        if LocalPlayer.Character then
            myHumanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
end)

local oldIndex, oldNewIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == myHumanoid then
        if key == "WalkSpeed" then return 16 end
        if key == "JumpPower" then return 50 end
    end
    return oldIndex(self, key)
end)
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if not checkcaller() and self == myHumanoid then
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

RunService.Heartbeat:Connect(function()
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
        if not skybase or not skybase.Parent then
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

TabWorld:Section({ Title = "Construcción Inteligente (IA)" })

local promptText = ""
TabWorld:Input({
    Title = "Prompt de la Isla",
    Placeholder = "Ej: Un mini castillo de ladrillos rojos y fuego...",
    Callback = function(text)
        promptText = text
    end
})

TabWorld:Button({
    Title = "Construir con Gemini 3.1 Flash-Lite",
    Callback = function()
        if not request_func then
            WindUI:Notify({Title = "Error de Executor", Content = "Tu executor no soporta peticiones HTTP (request).", Duration = 5})
            return
        end
        if promptText == "" then
            WindUI:Notify({Title = "Error", Content = "Escribe un prompt para la isla.", Duration = 3})
            return
        end

        WindUI:Notify({Title = "Generando con IA...", Content = "Gemini está escribiendo el código de construcción...", Duration = 6})

        task.spawn(function()
            local apiKey = "AIzaSyAcd0v4QHUIjp_SwHrXatFhzyTLAkpH5ss" -- Hardcoded (Seguridad ignorada a peticion del usuario)
            local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=" .. apiKey

            -- Instrucción estricta para que la IA actúe como un programador ejecutor de Roblox con acceso a PolarAPI
            local systemInstruction = [[
            Eres un programador experto en Luau para Roblox. Tu tarea es escribir código Luau ejecutable para construir o manipular el mapa según lo que pida el usuario.
            
            Para crear animaciones de alta fidelidad, efectos y teletransporte de objetos de forma estable, cuentas con la librería global pre-importada 'PolarAPI'.
            
            MÉTODOS DE PolarAPI DISPONIBLES:
            - PolarAPI.GetSkybasePos() -> Devuelve un Vector3 con el centro de la isla Skybase (0, 100000, 0).
            - PolarAPI.Notify(title, content, duration) -> Muestra un Toast (notificación) en la UI del juego.
            - PolarAPI.FindObjects(searchTerm, maxCount) -> Busca objetos o modelos en el workspace cuyo nombre contenga el término (ej. "tree", "palmera"). Devuelve una tabla/arreglo de instancias.
            - PolarAPI.CreateLaser(startPos, endPos, color, duration) -> Dibuja un rayo láser neon físico temporal entre startPos y endPos.
            - PolarAPI.AnimateHologramTravel(model, startPos, endPos, duration, shootLasers) -> Clona un modelo en startPos, lo convierte temporalmente en un holograma (material ForceField, semi-transparente celeste neon) y lo desplaza suavemente hacia endPos. Al llegar, restaura sus materiales y colores originales, lo ancla y lo guarda dentro de "PolarIslaIA". Si shootLasers es true, dispara láseres desde el suelo apuntando al holograma en el aire mientras viaja.
            
            EJEMPLO DE USO DE PolarAPI:
            Si el usuario pide extraer árboles/palmeras y traerlos a la isla flotante con efectos:
            ```lua
            local skybase = PolarAPI.GetSkybasePos()
            local arboles = PolarAPI.FindObjects("tree", 4)
            if #arboles == 0 then
                PolarAPI.Notify("IA Info", "No se encontraron árboles en el mapa.", 3)
            else
                for i, arbol in ipairs(arboles) do
                    local startPos = arbol:GetPivot().Position
                    local endPos = skybase + Vector3.new(i * 15 - 30, 5, i * 15 - 30)
                    PolarAPI.AnimateHologramTravel(arbol, startPos, endPos, 4, true)
                end
                PolarAPI.Notify("IA Éxito", "Extrayendo y transportando árboles con hologramas y láseres!", 4)
            end
            ```
            
            REGLAS DE DISEÑO PREMIUM (MODO POLAR EXTREME):
            1. ¡NADA DE APARECER DE GOLPE DE FORMA ABURRIDA! Siempre que manipules objetos, crees estructuras, o hagas teletransporte, hazlo de forma proactiva utilizando efectos extremos y cinemáticos sin que el usuario te lo pida explícitamente en el prompt.
            2. Si el usuario te pide traer elementos existentes del mapa (ej. árboles, estructuras, NPCs, etc.), usa SIEMPRE la animación holográfica 'PolarAPI.AnimateHologramTravel' con 'shootLasers = true' para crear un show de láseres de abajo hacia arriba y un aura neón en el aire.
            3. Si vas a construir estructuras nuevas desde cero (ej. un castillo, una casa, etc.), no crees todos los bloques al instante. Escribe bucles Luau que vayan construyendo la estructura fila por fila o parte por parte con un pequeño retardo (ej. task.wait(0.04)), y dispara un rayo láser neon con 'PolarAPI.CreateLaser' conectando un punto alto (ej. la parte superior de la Skybase) hacia el bloque en el momento en que se genera para dar el efecto de que el bloque está siendo "tallado" o "impreso" con láseres en tiempo real.
            4. Utiliza colores vibrantes (Neon, Fuerza de campo, Neón parpadeante) y materiales dinámicos (Glass, ForceField, Neon, SmoothPlastic). Dales a tus construcciones un aspecto tecnológico, futurista o de hacker potente ("Polar Extreme").
            5. Sé extremadamente creativo y dramático. Si construyes un trono, añade antorchas de fuego neón parpadeante a los lados. Si construyes un puente, ponle luces neón por debajo y un arco con láseres cruzados. ¡Todo debe verse espectacular y vivo!
            
            REGLAS DE GENERACIÓN DE CÓDIGO:
            1. Toda creación física debe parentarse a la carpeta workspace:FindFirstChild("PolarIslaIA") (si no existe, debes crearla).
            2. Todas las partes creadas manualmente deben estar ancladas (Anchored = true) y no colisionar para evitar lag físico.
            3. Escribe código seguro, validando que los objetos encontrados existan antes de leer su posición o manipularlos.
            4. Devuelve ÚNICAMENTE el código Luau ejecutable puro. No incluyas comentarios iniciales, no uses formato Markdown (NO rodees tu respuesta con ```lua o ```). Devuelve solo el código directo para ser compilado con loadstring.
            ]]

            local payload = {
                contents = {
                    {
                        parts = {
                            { text = "Petición del usuario: " .. promptText }
                        }
                    }
                },
                systemInstruction = {
                    parts = {
                        { text = systemInstruction }
                    }
                },
                generationConfig = {
                    temperature = 0.3,
                    maxOutputTokens = 8192
                }
            }

            local jsonPayload = HttpService:JSONEncode(payload)
            local success, response = pcall(function()
                return request_func({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonPayload
                })
            end)

            if success and response and response.StatusCode == 200 then
                local decodeSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)

                if decodeSuccess and data.candidates and data.candidates[1] then
                    local partsText = data.candidates[1].content.parts[1].text
                    
                    -- Limpieza preventiva de Markdown en la respuesta
                    partsText = partsText:gsub("```lua", ""):gsub("```", ""):gsub("^%s*(.-)%s*$", "%1")

                    -- Cargar el código generado inyectando el header de acceso a la API
                    local apiHeader = "local PolarAPI = shared.PolarAPI\n"
                    local func, loadError = loadstring(apiHeader .. partsText)
                    
                    if func then
                        local runSuccess, runError = pcall(func)
                        if runSuccess then
                            WindUI:Notify({Title = "Construcción Finalizada", Content = "El script de Gemini 3.1 se ejecutó con éxito.", Duration = 4})
                        else
                            warn("Error al ejecutar código de la IA: " .. tostring(runError))
                            WindUI:Notify({Title = "Error de Ejecución", Content = "Error al ejecutar el código de construcción.", Duration = 5})
                        end
                    else
                        warn("Error al compilar código de la IA: " .. tostring(loadError))
                        WindUI:Notify({Title = "Error de Compilación", Content = "El código generado tiene un error de sintaxis.", Duration = 5})
                    end
                else
                    WindUI:Notify({Title = "Error", Content = "Gemini devolvió una respuesta vacía.", Duration = 5})
                end
            else
                local errMsg = response and response.Body or "Error de red"
                warn("Error en la API de Gemini: " .. errMsg)
                WindUI:Notify({Title = "Error de Conexión", Content = "No se pudo contactar a la API de Gemini 3.1.", Duration = 5})
            end
        end)
    end
})

TabWorld:Button({
    Title = "Limpiar Creaciones IA",
    Callback = function()
        local folder = workspace:FindFirstChild("PolarIslaIA")
        if folder then
            folder:Destroy()
            WindUI:Notify({Title = "Limpieza Exitosa", Content = "Isla IA eliminada.", Duration = 3})
        else
            WindUI:Notify({Title = "Info", Content = "No hay creaciones de IA en el juego.", Duration = 3})
        end
    end
})

Window:SelectTab(1)

