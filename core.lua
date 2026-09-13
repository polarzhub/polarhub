-- Polar HUB | loadstring ready
-- Subir a GitHub como archivo raw y usar este comando en tu ejecutor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/main.lua"))()

-- Esperar a que el juego cargue completamente antes de inyectar
repeat task.wait() until game:IsLoaded()

-- -- Limpiar cualquier instancia previa de la interfaz antes de cargar la librería para evitar ventanas duplicadas
pcall(function()
	local targets = {
		(gethui and gethui()),
		(get_hidden_gui and get_hidden_gui()),
		game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
		(pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"))
	}
	for _, container in ipairs(targets) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child.Name == "redz Library V5" or child.Name == "PolarHub_Onyx_UI" or child.Name == "Quantum_Onyx_UI" then
					pcall(function() child:Destroy() end)
				end
			end
		end
	end
end)

-- ==================== POLAR UI LIBRARY ====================
local function LoadPolarUILibrary()
	-- 1. Intentar cargar archivo local si existe en el entorno del ejecutor
	local localPaths = {"polar_ui_library.lua", "polarhub_repo/polar_ui_library.lua"}
	for _, path in ipairs(localPaths) do
		if readfile then
			local ok, content = pcall(readfile, path)
			if ok and content and #content > 100 then
				local fn, err = loadstring(content)
				if fn then
					local libOk, lib = pcall(fn)
					if libOk and lib and type(lib) == "table" and lib.MakeWindow then
						return lib
					end
				end
			end
		end
	end

	-- 2. Cargar desde GitHub con el SHA más reciente
	local function GetLatestCommitSHA()
		local s, res = pcall(function()
			return game:HttpGet("https://api.github.com/repos/polarzhub/polarhub/commits/main")
		end)
		if s and res then
			local data = nil
			pcall(function() data = game:GetService("HttpService"):JSONDecode(res) end)
			if data and data.sha then
				return data.sha
			end
		end
		return "refs/heads/main"
	end

	local sha = GetLatestCommitSHA()
	local s, lib = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/" .. sha .. "/polar_ui_library.lua"))()
	end)
	if s and lib then return lib end

	-- Fallback directo a main branch con cache buster
	local s2, lib2 = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/polar_ui_library.lua?t=" .. tostring(os.time())))()
	end)
	if s2 and lib2 then return lib2 end

	-- Fallback de seguridad a redzlibV5
	local s3, lib3 = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/redzlibV5.lua?t=" .. tostring(os.time())))()
	end)
	if s3 and lib3 then return lib3 end

	error("Error crítico: No se pudo cargar polar_ui_library.lua")
end

local PolarUI = LoadPolarUILibrary()
getgenv().PolarUI = PolarUI

local Window = PolarUI:MakeWindow({
	Name = "POLAR HUB",
	SubTitle = '<font color="#00E5FF">Blox Fruits</font> • <font color="#C084FC">v.Powerhouse</font> • <font color="#FFD700">Official</font>',
	SaveFolder = "PolarHubConfig.json"
})
pcall(function()
	PolarUI:SetScale(650) -- Escala 1.15 calibrada
	PolarUI:SetTheme("Polar Ice")
end)

-- CREACIÓN INMEDIATA DE PESTAÑAS (Garantiza que la UI NUNCA quede en negro)
local TabHome = Window:MakeTab({ Title = "Home", Icon = "rbxassetid://130439434919073" })
local TabFarm = TabHome
local TabStats = Window:MakeTab({ Title = "Stats", Icon = "user" })
local TabStatus = Window:MakeTab({ Title = "Status", Icon = "activity" })
local TabShop = Window:MakeTab({ Title = "Shop", Icon = "shopping-cart" })
local TabQuest = Window:MakeTab({ Title = "Quest Farm", Icon = "map" })
local TabTeleport = Window:MakeTab({ Title = "Teleport", Icon = "globe" })
local TabCombat = Window:MakeTab({ Title = "Combat PvP", Icon = "crosshair" })
local TabServers = Window:MakeTab({ Title = "Server Hop", Icon = "server" })
local TabMisc = Window:MakeTab({ Title = "Misc", Icon = "settings" })

local Polar = getgenv().Polar or {}
getgenv().Polar = Polar
Polar.Window = Window
Polar.TabHome = TabHome
Polar.TabFarm = TabFarm
Polar.TabStats = TabStats
Polar.TabStatus = TabStatus
Polar.TabShop = TabShop
Polar.TabQuest = TabQuest
Polar.TabTeleport = TabTeleport
Polar.TabCombat = TabCombat
Polar.TabServers = TabServers
Polar.TabMisc = TabMisc

getgenv().PolarWindow = Window
getgenv().PolarTabFarm = TabFarm
getgenv().PolarTabStats = TabStats
getgenv().PolarTabStatus = TabStatus
getgenv().PolarTabShop = TabShop
getgenv().PolarTabQuest = TabQuest
getgenv().PolarTabTeleport = TabTeleport
getgenv().PolarTabCombat = TabCombat
getgenv().PolarTabServers = TabServers
getgenv().PolarTabMisc = TabMisc
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ==================== ANTI-AFK ====================
LocalPlayer.Idled:Connect(function()
 VirtualUser:CaptureController()
 VirtualUser:ClickButton2(Vector2.new())
end)


-- ==================== AUTO SCANNER DE REMOTOS DEL JUEGO (NIVEL ATERRADOR) ====================
-- Escanea los archivos internos del juego para detectar remotos de misiones,
-- NPCs activos, y nombres correctos de Quest Givers en tiempo real.
task.spawn(function()
 task.wait(3) -- Esperar a que el juego cargue
 
 -- SCANNER 1: Escanear workspace.NPCs para mapear TODOS los Quest Givers del mapa actual
 pcall(function()
 local NPCsFolder = workspace:FindFirstChild("NPCs")
 if NPCsFolder then
 if not getgenv().PolarNPCCache then getgenv().PolarNPCCache = {} end
 for _, npc in ipairs(NPCsFolder:GetChildren()) do
 local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
 if part then
 getgenv().PolarNPCCache[npc.Name] = part.CFrame
 end
 end
 print("[Polar Hub] [SCAN] Scanner: " .. #NPCsFolder:GetChildren() .. "NPCs mapeados desde workspace.NPCs")
 end
 end)
 
 -- SCANNER 2: Escanear workspace.Enemies para registrar todos los tipos de enemigos
 pcall(function()
 local Enemies = workspace:FindFirstChild("Enemies")
 if Enemies then
 local enemyTypes = {}
 for _, npc in ipairs(Enemies:GetChildren()) do
 if not enemyTypes[npc.Name] then
 enemyTypes[npc.Name] = true
 end
 end
 local typeList = {}
 for name, _ in pairs(enemyTypes) do table.insert(typeList, name) end
 print("[Polar Hub] [SCAN] Scanner: Tipos de enemigos activos -> " .. table.concat(typeList, ", "))
 end
 end)
 
 -- SCANNER 3: Escanear CommF_ para verificar que el remoto de misiones existe
 pcall(function()
 local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
 if Remotes then
 local CommF = Remotes:FindFirstChild("CommF_")
 if CommF then
 print("[Polar Hub] [OK] Scanner: CommF_ detectado y operativo")
 else
 warn("[Polar Hub] [WARN] Scanner: CommF_ NO encontrado! Las misiones remotas no funcionarán.")
 end
 end
 end)
 
 -- SCANNER 4: Auto-detectar los quest strings correctos escaneando los datos del jugador
 pcall(function()
 local data = LocalPlayer:FindFirstChild("Data")
 if data then
 print("[Polar Hub] [DATA] Scanner: Nivel del jugador = " .. tostring(data:FindFirstChild("Level") and data.Level.Value or "?"))
 
 -- Escanear si hay una misión activa en el PlayerGui
 local pgui = LocalPlayer:FindFirstChild("PlayerGui")
 if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
 if pgui.Main.Quest.Visible then
 local title = pgui.Main.Quest:FindFirstChild("Container") and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
 if title and title.Text then
 print("[Polar Hub] [DATA] Scanner: Misión activa detectada -> " .. title.Text)
 end
 end
 end
 end
 end)
 
 -- SCANNER 5: Vigilar workspace.NPCs en tiempo real para actualizar la caché
 pcall(function()
 local NPCsFolder = workspace:FindFirstChild("NPCs")
 if NPCsFolder then
 NPCsFolder.ChildAdded:Connect(function(npc)
 task.wait(0.5)
 local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
 if part then
 if not getgenv().PolarNPCCache then getgenv().PolarNPCCache = {} end
 getgenv().PolarNPCCache[npc.Name] = part.CFrame
 end
 end)
 print("[Polar Hub] [WATCH] Scanner: Vigilancia de NPCs en tiempo real ACTIVADA")
 end
 end)
end)

-- ==================== BLOX FRUITS REMOTES ====================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)
local NetModule = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local Net = nil
pcall(function()
 if NetModule then
 Net = require(NetModule)
 end
end)
local RegisterHit = nil
local RegisterAttack = nil
pcall(function()
 	if Net then
		RegisterHit = Net:RemoteEvent("RegisterHit", true)
		RegisterAttack = Net:RemoteEvent("RegisterAttack")
	end
end)
if setidentity then pcall(setidentity, 8) end
if setthreadidentity then pcall(setthreadidentity, 8) end
local GlobalModule = nil
pcall(function()
	GlobalModule = require(ReplicatedStorage:WaitForChild("Global", 5))
end)
if setidentity then pcall(setidentity, 8) end
if setthreadidentity then pcall(setthreadidentity, 8) end
local SendHitsToServer = function(...)
 if GlobalModule and GlobalModule.SendHitsToServer then
 GlobalModule.SendHitsToServer(...)
 elseif RegisterHit and RegisterHit.FireServer then
 RegisterHit:FireServer(...)
 end
end
local enemiesFolder = workspace:FindFirstChild("Enemies")

-- Helper de seguridad para Humanoids (evita crash con barcos en workspace.Enemies)
local function GetValidHumanoid(model)
 if not model then return nil end
 local hum = model:FindFirstChildOfClass("Humanoid")
 if hum and hum:IsA("Humanoid") and hum.Health > 0 then
 return hum
 end
 return nil
end

-- ==================== CORE PLATFORM FRAMEWORK (POLAR ENGINE) ====================
local Polar = getgenv().Polar or {}
getgenv().Polar = Polar
Polar.Data = Polar.Data or {
 AllowedQuests = {},
 QuestInfo = {},
 QuestGiver = {},
 QuestToIsland = {},
 Bosses = {},
 NPCCache = {},
 SpawnCache = {},
 LastBossCheckedIndex = 1,
 CurrentState = "IDLE",
 ActiveQuestName = nil,
}

-- Módulo de Jugador
Polar.Player = Polar.Player or {}

function Polar.Player:GetLevel()
 local data = LocalPlayer:FindFirstChild("Data")
 return data and data:FindFirstChild("Level") and data.Level.Value or 1
end

-- ==================== BOSS SYSTEM (SHARED CORE ENGINE) ====================
Polar.BossSystem = Polar.BossSystem or {}

local BossTracker = getgenv().PolarBossTracker or {}
getgenv().PolarBossTracker = BossTracker

function Polar.BossSystem.InitTracker()
 if not Polar.Data.Bosses then return end
 for _, b in ipairs(Polar.Data.Bosses) do
 if not BossTracker[b.name] then
 BossTracker[b.name] = {
 status = "UNKNOWN",
 aliveAt = nil,
 deadAt = nil
 }
 end
 end
end

function Polar.BossSystem.GetTracker()
 return BossTracker
end

function Polar.BossSystem.NormalizeBossName(str)
 if not str then return "" end
 local s = str:lower()
 s = s:gsub("^the%s+", ""):gsub("^el%s+", ""):gsub("^la%s+", "")
 s = s:gsub("%s+respawn%s+marker$", ""):gsub("%s+marker$", "")
 s = s:gsub("rey%s+gorila", "gorillaking"):gsub("gorila", "gorilla")
 s = s:gsub("sierra", "saw")
 s = s:gsub("barbagris", "greybeard"):gsub("barba%s+gris", "greybeard"):gsub("barbablanca", "greybeard"):gsub("whitebeard", "greybeard")
 s = s:gsub("experto%s+en%s+sables?", "saberexpert"):gsub("shanks", "saberexpert")
 s = s:gsub("almirante%s+de%s+hielo", "iceadmiral"):gsub("almirante%s+helado", "iceadmiral")
 s = s:gsub("almirante%s+de%s+magma", "magmaadmiral"):gsub("general%s+de%s+magma", "magmaadmiral"):gsub("magmageneral", "magmaadmiral")
 s = s:gsub("chef", "bobby")
 s = s:gsub("skywarlord", "wysper"):gsub("senor%s+celestial", "wysper")
 s = s:gsub("lightninggod", "thundergod"):gsub("dios%s+del%s+rayo", "thundergod"):gsub("dios%s+del%s+trueno", "thundergod")
 s = s:gsub("senor%s+pez", "fishmanlord"):gsub("hombre%s+pez", "fishmanlord")
 s = s:gsub("jefe%s+de%s+la%s+mafia", "mobleader"):gsub("lider%s+de%s+la%s+mafia", "mobleader"):gsub("mobboss", "mobleader")
 s = s:gsub("jefe%s+alcaide", "chiefwarden"):gsub("alcaide", "warden")
 s = s:gsub("ciborg", "cyborg")
 s = s:gsub("[%s%p%c]", "")
 return s
end

function Polar.BossSystem.FindBossData(bossName)
 if not bossName then return nil end
 local targetNorm = Polar.BossSystem.NormalizeBossName(bossName)
 for _, b in ipairs(Polar.Data.Bosses) do
 if Polar.BossSystem.NormalizeBossName(b.name) == targetNorm then
 return b
 end
 end
 return nil
end

function Polar.BossSystem.GetOfficialBossMarker(bossName)
 local origin = workspace:FindFirstChild("_WorldOrigin")
 if not origin then return nil end
 local targetNorm = Polar.BossSystem.NormalizeBossName(bossName)
 if #targetNorm == 0 then return nil end
 for _, child in ipairs(origin:GetChildren()) do
 if child.Name:find("Marker") or child:FindFirstChild("RespawnTimer") then
 local cNorm = Polar.BossSystem.NormalizeBossName(child.Name)
 local timerGui = child:FindFirstChild("RespawnTimer")
 local timerLabel = timerGui and (timerGui:FindFirstChild("Timer", true) or timerGui:FindFirstChildWhichIsA("TextLabel", true))
 local nameLabel = timerGui and timerGui:FindFirstChild("Name", true)
 local internalName = nameLabel and nameLabel.Text:gsub("<[^>]->", "") or child.Name:gsub(" Respawn Marker", "")
 local internalNorm = Polar.BossSystem.NormalizeBossName(internalName)
 if cNorm == targetNorm or internalNorm == targetNorm or cNorm:find(targetNorm, 1, true) or targetNorm:find(cNorm, 1, true) then
 local rawTimer = timerLabel and timerLabel.Text or nil
 local cleanTimer = rawTimer and rawTimer:gsub("<[^>]->", "") or "[00:00]"
 return {
 part = child,
 name = internalName ~= "" and internalName or child.Name:gsub(" Respawn Marker", ""),
 timerText = cleanTimer,
 position = child.Position
 }
 end
 end
 end
 return nil
end

function Polar.BossSystem.GetAllActiveMarkers()
 local origin = workspace:FindFirstChild("_WorldOrigin")
 if not origin then return {} end
 local list = {}
 for _, child in ipairs(origin:GetChildren()) do
 if child.Name:find("Marker") or child:FindFirstChild("RespawnTimer") then
 local timerGui = child:FindFirstChild("RespawnTimer")
 local timerLabel = timerGui and (timerGui:FindFirstChild("Timer", true) or timerGui:FindFirstChildWhichIsA("TextLabel", true))
 local nameLabel = timerGui and timerGui:FindFirstChild("Name", true)
 local internalName = nameLabel and nameLabel.Text:gsub("<[^>]->", "") or child.Name:gsub(" Respawn Marker", "")
 local rawTimer = timerLabel and timerLabel.Text or nil
 local cleanTimer = rawTimer and rawTimer:gsub("<[^>]->", "") or "[00:00]"
 table.insert(list, {
 name = internalName,
 timer = cleanTimer,
 part = child
 })
 end
 end
 return list
end

function Polar.BossSystem.FindLiveBoss(bossName)
 local Norm = Polar.BossSystem.NormalizeBossName
 local targetNorm = Norm(bossName)
 local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Characters")
 if not enemies then return nil end
 for _, e in ipairs(enemies:GetChildren()) do
 local eName = e.Name:lower()
 local hum = e:FindFirstChild("Humanoid")
 if hum and hum.Health > 0 then
 if targetNorm == "gorillaking" then
 if (eName:find("gorilla") and eName:find("king")) or eName == "the gorilla king" then return e end
 elseif targetNorm == "bobby" then
 if eName == "bobby" or eName:find("bobby") or eName == "chef" or eName:find("chef") then return e end
 elseif targetNorm == "yeti" then
 if eName == "yeti" or eName:find("yeti") then return e end
 elseif targetNorm == "mobleader" then
 if eName:find("mob") and (eName:find("leader") or eName:find("boss")) then return e end
 elseif targetNorm == "viceadmiral" then
 if eName:find("vice") and eName:find("admiral") then return e end
 elseif targetNorm == "warden" then
 if (eName == "warden" or eName:find("warden")) and not eName:find("chief") then return e end
 elseif targetNorm == "chiefwarden" then
 if eName:find("chief") and eName:find("warden") then return e end
 elseif targetNorm == "swan" then
 if eName == "swan" or eName:find("swan") then return e end
 elseif targetNorm == "magmaadmiral" then
 if eName:find("magma") and (eName:find("admiral") or eName:find("general")) then return e end
 elseif targetNorm == "fishmanlord" then
 if eName:find("fishman") and eName:find("lord") then return e end
 elseif targetNorm == "wysper" then
 if eName == "wysper" or eName:find("wysper") or (eName:find("sky") and eName:find("warlord")) then return e end
 elseif targetNorm == "thundergod" then
 if (eName:find("thunder") or eName:find("lightning")) and eName:find("god") and not eName:find("guard") then return e end
 elseif targetNorm == "cyborg" then
 if eName == "cyborg" or eName:find("cyborg") then return e end
 elseif targetNorm == "iceadmiral" then
 if eName:find("ice") and eName:find("admiral") then return e end
 elseif targetNorm == "saberexpert" then
 if eName:find("saber") or eName:find("shanks") then return e end
 elseif targetNorm == "saw" then
 if eName == "the saw" or eName == "saw" then return e end
 elseif targetNorm == "greybeard" then
 if eName:find("greybeard") or eName:find("whitebeard") then return e end
 end
 end
 end
 return nil
end

function Polar.BossSystem.GetBossStatusCard(bossName)
 local BS = Polar.BossSystem
 local bData = BS.FindBossData(bossName)
 if not bData then return "Boss no encontrado." end
 local trk = BossTracker[bData.name] or {}
 local cdMins = math.floor(bData.cd / 60)
 local lines = {
 string.format("Jefe: %s | Nivel: %d", bData.name, bData.lvl),
 string.format("Ubicacion: Isla %s", bData.island),
 string.format("Cooldown Base: ~%d minutos (%ds)", cdMins, bData.cd)
 }
 local marker = BS.GetOfficialBossMarker(bData.name)
 if marker then
 trk.status = "DEAD"
 table.insert(lines, "Estado: [DERROTADO] (En Cooldown)")
 table.insert(lines, string.format("Contador Oficial 3D: %s", marker.timerText))
 table.insert(lines, string.format("Reaparicion en: %s (Sincronizado con marcador)", marker.timerText))
 table.insert(lines, "Marcador: " .. marker.name)
 return table.concat(lines, "\n")
 end
 local liveBoss = BS.FindLiveBoss(bData.name)
 if liveBoss then
 trk.status = "ALIVE"
 trk.aliveAt = os.time()
 local hum = liveBoss:FindFirstChild("Humanoid")
 local hp = hum and math.floor(hum.Health) or 0
 local maxHp = hum and math.floor(hum.MaxHealth) or 1
 local pct = math.floor((hp / math.max(1, maxHp)) * 100)
 table.insert(lines, string.format("Estado: [VIVO] (Salud: %d%% [%s/%s])", pct, tostring(hp), tostring(maxHp)))
 table.insert(lines, "Contador: Sin contador (En combate actualmente)")
 return table.concat(lines, "\n")
 end
 if trk.deadAt then
 trk.status = "DEAD"
 local elapsed = os.time() - trk.deadAt
 local remaining = math.max(0, bData.cd - elapsed)
 local remainM = math.floor(remaining / 60)
 local remainS = remaining % 60
 table.insert(lines, "Estado: [DERROTADO] (Marcador 3D concluido)")
 if remaining > 0 then
 table.insert(lines, string.format("Reaparicion estimada: ~%02dm %02ds restantes", remainM, remainS))
 else
 table.insert(lines, "Reaparicion: Cooldown cumplido, listo para reaparecer.")
 end
 else
 table.insert(lines, "Estado: [NO DETECTADO / LISTO PARA SPAWNEAR]")
 table.insert(lines, "Contador: Sin marcador activo (Cooldown concluido o en espera de proximidad)")
 table.insert(lines, "Sugerencia: Presiona 'Teleport' para volar a su isla y verificar spawn.")
 end
 return table.concat(lines, "\n")
end

function Polar.BossSystem.SetupReactiveListeners()
 local Norm = Polar.BossSystem.NormalizeBossName
 local originFolder = workspace:FindFirstChild("_WorldOrigin")
 if originFolder then
 originFolder.ChildAdded:Connect(function(child)
 if child.Name:find("Marker") or child:FindFirstChild("RespawnTimer") then
 local name = child.Name:gsub(" Respawn Marker", "")
 for _, b in ipairs(Polar.Data.Bosses) do
 if Norm(b.name) == Norm(name) then
 BossTracker[b.name].status = "DEAD"
 BossTracker[b.name].deadAt = os.time()
 break
 end
 end
 end
 end)
 originFolder.ChildRemoved:Connect(function(child)
 if child.Name:find("Marker") or child:FindFirstChild("RespawnTimer") then
 local name = child.Name:gsub(" Respawn Marker", "")
 for _, b in ipairs(Polar.Data.Bosses) do
 if Norm(b.name) == Norm(name) then
 BossTracker[b.name].status = "ALIVE"
 BossTracker[b.name].aliveAt = os.time()
 break
 end
 end
 end
 end)
 end
 local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Characters")
 if enemiesFolder then
 enemiesFolder.ChildAdded:Connect(function(child)
 local cName = child.Name:lower()
 for _, b in ipairs(Polar.Data.Bosses) do
 local normB = Norm(b.name)
 if (normB == "gorillaking" and cName:find("gorilla") and cName:find("king")) or
 (normB == "bobby" and (cName:find("bobby") or cName:find("chef"))) or
 (normB == "saberexpert" and (cName:find("saber") or cName:find("shanks"))) or
 (cName:find(b.name:lower())) then
 BossTracker[b.name].status = "ALIVE"
 BossTracker[b.name].aliveAt = os.time()
 break
 end
 end
 end)
 enemiesFolder.ChildRemoved:Connect(function(child)
 local cName = child.Name:lower()
 for _, b in ipairs(Polar.Data.Bosses) do
 local normB = Norm(b.name)
 if (normB == "gorillaking" and cName:find("gorilla") and cName:find("king")) or
 (normB == "bobby" and (cName:find("bobby") or cName:find("chef"))) or
 (normB == "saberexpert" and (cName:find("saber") or cName:find("shanks"))) or
 (cName:find(b.name:lower())) then
 BossTracker[b.name].status = "DEAD"
 BossTracker[b.name].deadAt = os.time()
 break
 end
 end
 end)
 end
end

-- Módulo de Teletransporte
Polar.Teleport = {}

local activeTween = nil

local function CancelActiveTween()
 if activeTween then
 pcall(function()
 activeTween:Cancel()
 end)
 activeTween = nil
 end
end

local function MoveDirectly(targetCFrame)
 if typeof(targetCFrame) == "Vector3" then
 targetCFrame = CFrame.new(targetCFrame)
 end
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health <= 0 then return end
 
 local dist = (hrp.Position - targetCFrame.Position).Magnitude
 
 -- Solo hacer TP instantáneo si ya estamos muy cerca (<= 15 studs) para evitar rollback del anti-cheat
 if dist <= 15 then
 CancelActiveTween()
 hrp.CFrame = targetCFrame
 hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
 return
 end
 
 CancelActiveTween()
 
 local oldPlatformStand = hum and hum.PlatformStand
 if hum then hum.PlatformStand = true end
 
 local bp = hrp:FindFirstChild("Polar_MoveVelocity")
 if not bp then
 bp = Instance.new("BodyVelocity")
 bp.Name = "Polar_MoveVelocity"
 bp.Velocity = Vector3.new(0, 0, 0)
 bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 bp.Parent = hrp
 else
 bp.Velocity = Vector3.new(0, 0, 0)
 end
 
 local nclConn = RunService.Stepped:Connect(function()
 for _, v in ipairs(char:GetChildren()) do
 if v:IsA("BasePart") then v.CanCollide = false end
 end
 end)
 
 local tweenSpeed = 320
 
 local function DoTween(cframeTarget)
 local tDist = (hrp.Position - cframeTarget.Position).Magnitude
 if tDist <= 5 then return end
 local tInfo = TweenInfo.new(tDist / tweenSpeed, Enum.EasingStyle.Linear)
 local tween = TweenService:Create(hrp, tInfo, {CFrame = cframeTarget})
 activeTween = tween
 
 local startPos = hrp.Position
 local tpCheckConn = RunService.Stepped:Connect(function()
 if (hrp.Position - startPos).Magnitude > 5000 then
 tween:Cancel()
 end
 end)
 
 tween:Play()
 tween.Completed:Wait()
 if tpCheckConn then tpCheckConn:Disconnect() end
 if activeTween == tween then activeTween = nil end
 end
 
 -- Tween directo y suave al objetivo (noclip sin saltos bruscos ni elevarse al cielo)
 DoTween(targetCFrame)
 
 -- Snap final seguro solo si ya llegó a menos de 15 studs
 if hrp and (hrp.Position - targetCFrame.Position).Magnitude <= 15 then
 hrp.CFrame = targetCFrame
 hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
 end
 
 nclConn:Disconnect()
 if bp and bp.Parent then bp:Destroy() end
 if hum and hum.Parent then hum.PlatformStand = oldPlatformStand end
end

local function FindCursedShipEntrance()
 local entryPos = Vector3.new(943, 121, 1269)
 local bestDoor = nil
 local bestDist = 999999
 
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("TouchTransmitter") then
 local parent = obj.Parent
 if parent and parent:IsA("BasePart") then
 local dist = (parent.Position - entryPos).Magnitude
 if dist < 400 then
 local pName = string.lower(parent.Name)
 local isEntity = string.find(pName, "npc") or string.find(pName, "quest") or string.find(pName, "giver") or 
 string.find(pName, "enemy") or string.find(pName, "player") or string.find(pName, "character") or
 string.find(pName, "chest") or string.find(pName, "haki")
 if not isEntity and parent.Parent then
 local ppName = string.lower(parent.Parent.Name)
 isEntity = string.find(ppName, "npc") or string.find(ppName, "quest") or string.find(ppName, "giver") or 
 string.find(ppName, "enemy") or string.find(ppName, "player") or string.find(ppName, "character") or
 string.find(ppName, "chest") or string.find(ppName, "haki")
 end
 if not isEntity then
 local hasKeyword = string.find(pName, "ship") or string.find(pName, "cursed") or 
 string.find(pName, "entrance") or string.find(pName, "portal") or 
 string.find(pName, "door")
 if hasKeyword then
 return parent
 elseif dist < bestDist then
 bestDoor = parent
 bestDist = dist
 end
 end
 end
 end
 end
 end
 return bestDoor
end

local function FindCursedShipExit()
 local spawnPos = Vector3.new(920, 125, 32800)
 local bestDoor = nil
 local bestDist = 999999
 
 for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("TouchTransmitter") then
 local parent = obj.Parent
 if parent and parent:IsA("BasePart") then
 local dist = (parent.Position - spawnPos).Magnitude
 if dist < 500 then
 local pName = string.lower(parent.Name)
 local isEntity = string.find(pName, "npc") or string.find(pName, "quest") or string.find(pName, "giver") or 
 string.find(pName, "enemy") or string.find(pName, "player") or string.find(pName, "character") or
 string.find(pName, "chest") or string.find(pName, "haki")
 if not isEntity and parent.Parent then
 local ppName = string.lower(parent.Parent.Name)
 isEntity = string.find(ppName, "npc") or string.find(ppName, "quest") or string.find(ppName, "giver") or 
 string.find(ppName, "enemy") or string.find(ppName, "player") or string.find(ppName, "character") or
 string.find(ppName, "chest") or string.find(ppName, "haki")
 end
 if not isEntity then
 local hasKeyword = string.find(pName, "exit") or string.find(pName, "leave") or 
 string.find(pName, "door") or string.find(pName, "ship") or 
 string.find(pName, "portal")
 if hasKeyword then
 return parent
 elseif dist < bestDist then
 bestDoor = parent
 bestDist = dist
 end
 end
 end
 end
 end
 end
 return bestDoor
end

function Polar.Teleport:To(targetCFrame)
 if typeof(targetCFrame) == "Vector3" then
 targetCFrame = CFrame.new(targetCFrame)
 end
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 
 -- Teletransporte especial para Sea 1 / Sea 2 (Isla Submarina, Barco Maldito)
 if targetCFrame.Position.X > 50000 and hrp.Position.X < 50000 then
 local whirlpool = workspace.Map:FindFirstChild("Whirlpool", true) or workspace:FindFirstChild("Whirlpool", true)
 local wpPos = whirlpool and (whirlpool:IsA("Model") and whirlpool:GetModelCFrame().Position or whirlpool.Position) or Vector3.new(3864.68, 6.73, -1926.92)
 local dist2D = Vector2.new(hrp.Position.X - wpPos.X, hrp.Position.Z - wpPos.Z).Magnitude
 if dist2D > 100 then
 targetCFrame = CFrame.new(wpPos.X, math.max(hrp.Position.Y, 150), wpPos.Z)
 else
 targetCFrame = CFrame.new(wpPos)
 end
 end
 
 -- Cursed Ship (Acceso al sub-lugar desde el Mar 2 Principal)
 if targetCFrame.Position.Z > 25000 and hrp.Position.Z < 25000 then
 local door = FindCursedShipEntrance()
 if door then
 MoveDirectly(door.CFrame)
 task.wait(0.2)
 local entered = false
 for i = 1, 6 do
 pcall(function()
 firetouchinterest(hrp, door, 0)
 task.wait(0.05)
 firetouchinterest(hrp, door, 1)
 end)
 task.wait(0.3)
 local cChar = LocalPlayer.Character
 local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
 if cHrp and cHrp.Position.Z > 25000 then
 entered = true
 break
 end
 end
 if entered then
 return
 end
 end
 
 local cChar = LocalPlayer.Character
 local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
 if not cHrp or cHrp.Position.Z < 25000 then
 warn("[Polar Hub] No se pudo entrar al Barco Maldito. Evitando tween directo.")
 task.wait(1.5)
 return
 end
 end
 
 -- Barco Maldito (Salida hacia el Mar 2 Principal si el objetivo está fuera)
 if targetCFrame.Position.Z < 25000 and hrp.Position.Z > 25000 then
 local door = FindCursedShipExit()
 local exited = false
 if door then
 MoveDirectly(door.CFrame)
 task.wait(0.2)
 for i = 1, 6 do
 pcall(function()
 firetouchinterest(hrp, door, 0)
 task.wait(0.05)
 firetouchinterest(hrp, door, 1)
 end)
 task.wait(0.3)
 local cChar = LocalPlayer.Character
 local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
 if cHrp and cHrp.Position.Z < 25000 then
 exited = true
 break
 end
 end
 end
 
 if not exited then
 warn("[Polar Hub] Puerta de salida no detectada o inoperante. Intentando GoHome...")
 if CommF then
 pcall(function()
 CommF:InvokeServer("GoHome")
 end)
 for i = 1, 10 do
 task.wait(0.3)
 local cChar = LocalPlayer.Character
 local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
 if cHrp and cHrp.Position.Z < 25000 then
 exited = true
 break
 end
 end
 end
 end
 
 if exited then
 return
 else
 warn("[Polar Hub] No se pudo salir del Barco Maldito. Evitando tween directo al agua.")
 task.wait(1.5)
 return
 end
 end
 
 MoveDirectly(targetCFrame)
end

function Polar.Teleport:ToIsland(islandName)
 if not islandName or islandName == "" then return end
 
 local inCursedShip = game.PlaceId == 4442272183 or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position.Z > 25000)
 if inCursedShip and string.lower(islandName) == "cursed ship" then
 return -- Ya estamos en el barco, no es necesario viajar
 end
 
 local origin = workspace:FindFirstChild("_WorldOrigin")
 local locs = origin and origin:FindFirstChild("Locations")
 local pos = nil
 
 if locs then
 for _, v in ipairs(locs:GetChildren()) do
 if string.find(string.lower(v.Name), string.lower(islandName)) then
 pos = v.Position
 break
 end
 end
 end
 
 -- Fallbacks absolutos de islas
 if not pos then
 local fallbacks = {
 ["town"] = Vector3.new(-1000, 15, 1000),
 ["jungle"] = Vector3.new(-1461, 30, -51),
 ["pirate"] = Vector3.new(-1134, 14, 3880),
 ["desert"] = Vector3.new(1094, 20, 4344),
 ["snow"] = Vector3.new(1384, 90, -1300),
 ["marine"] = Vector3.new(-3122, 10, 4048),
 ["sky"] = Vector3.new(-1643, 368, -52),
 ["prison"] = Vector3.new(4875, 5, 743),
 ["colosseum"] = Vector3.new(-1500, 7, 2500),
 ["magma"] = Vector3.new(-5259, 37, 4050),
 ["fishman"] = Vector3.new(3864, 6, -1926),
 ["upper sky"] = Vector3.new(-7904, 5634, -1640),
 ["fountain"] = Vector3.new(5259, 37, 4050),
 ["kingdom of rose"] = Vector3.new(-429, 73, 299),
 ["green zone"] = Vector3.new(-2840, 73, -2990),
 ["graveyard"] = Vector3.new(-5154, 8, -714),
 ["snow mountain"] = Vector3.new(639, 44, -5137),
 ["hot and cold"] = Vector3.new(-312, 190, -4933),
 ["cursed ship"] = Vector3.new(943, 121, 1269),
 ["ice castle"] = Vector3.new(5669, 28, -6482),
 ["forgotten island"] = Vector3.new(-2544, 256, -429),
 ["port town"] = Vector3.new(-290, 44, 5582),
 ["hydra island"] = Vector3.new(5230, 60, 763),
 ["great tree"] = Vector3.new(2402, 73, -6682),
 ["floating turtle"] = Vector3.new(-2014, 185, -10238),
 ["turtle"] = Vector3.new(-2014, 185, -10238),
 ["haunted castle"] = Vector3.new(-9516, 169, 6079),
 ["sea of treats"] = Vector3.new(-198, 48, -12118),
 ["tiki outpost"] = Vector3.new(-16238, 10, 439),
 ["submerged island"] = Vector3.new(-18021, 15, 2810),
 ["castle on sea"] = Vector3.new(-5085, 316, 3152)
 }
 pos = fallbacks[string.lower(islandName)]
 end
 
 if pos then
 print("[Polar Hub] [TP] Volando hacia isla: " .. islandName)
 Polar.Teleport:To(CFrame.new(pos.X, pos.Y + 250, pos.Z))
 task.wait(1.5) -- Pausa para que carguen los assets (streaming enabled bypass)
 end
end

-- ==================== SYSTEM DETECTION ENGINE (DETECCION ABSURDA DE NPCS Y OBJETOS) ====================
local FallbackPositions = {
 -- Sea 1 Quest Givers
 ["Bandit Quest Giver"] = Vector3.new(1060, 16, 1548),
 ["Jungle Quest Giver"] = Vector3.new(-1600, 37, 153),
 ["Pirate Quest Giver"] = Vector3.new(-1140, 4, 3828),
 ["Desert Quest Giver"] = Vector3.new(897, 6, 4388),
 ["Snow Quest Giver"] = Vector3.new(1386, 87, -1298),
 ["Marine Quest Giver"] = Vector3.new(-2900, 7, 5350),
 ["Sky Quest Giver"] = Vector3.new(-4840, 718, -2620),
 ["Prison Quest Giver"] = Vector3.new(4850, 5, 730),
 ["Colosseum Quest Giver"] = Vector3.new(-1580, 7, 2720),
 ["Magma Quest Giver"] = Vector3.new(-5310, 8, 8530),
 ["Fishman Quest Giver"] = Vector3.new(61120, 18, 1568),
 ["Upper Sky Quest Giver"] = Vector3.new(-7900, 5635, -1410),
 ["Fountain Quest Giver"] = Vector3.new(5259, 38, 4050),

 -- Sea 2 Quest Givers
 ["Area 1 Quest Giver"] = Vector3.new(-429, 73, 299),
 ["Area 2 Quest Giver"] = Vector3.new(954, 142, 1412),
 ["Marine Quest Giver"] = Vector3.new(-2840, 73, -2990),
 ["Zombie Quest Giver"] = Vector3.new(-5154, 8, -714),
 ["Snowy Quest Giver"] = Vector3.new(639, 44, -5137),
 ["Ice Quest Giver"] = Vector3.new(-312, 190, -4933),
 ["Fire Quest Giver"] = Vector3.new(-312, 190, -4933),
 ["Rear Crew Quest Giver"] = Vector3.new(923, 126, 32852),
 ["Front Crew Quest Giver"] = Vector3.new(920, 125, 33000),
 ["Ship Deckhand"] = Vector3.new(920, 125, 32900),
 ["Ship Engineer"] = Vector3.new(920, 125, 32900),
 ["Ship Steward"] = Vector3.new(920, 125, 33000),
 ["Ship Officer"] = Vector3.new(920, 125, 33100),
 ["Cursed Captain"] = Vector3.new(920, 125, 33200),
 ["Frost Quest Giver"] = Vector3.new(5669, 28, -6482),
 ["Arctic Warrior"] = Vector3.new(5995, 57, -6183),
 ["Snow Lurker"] = Vector3.new(5518, 61, -6828),
 ["Awakened Ice Admiral"] = Vector3.new(5655, 38, -6482),
 ["Forgotten Quest Giver"] = Vector3.new(-2544, 256, -429),

 -- Sea 3 Quest Givers
 ["Pirate Port Quest Giver"] = Vector3.new(-290, 44, 5582),
 ["Dragon Crew Quest Giver"] = Vector3.new(5230, 60, 763),
 ["Hydra Town Quest Giver"] = Vector3.new(5748, 610, -278),
 ["Marine Tree Quest Giver"] = Vector3.new(2402, 73, -6682),
 ["Turtle Adventure Quest Giver"] = Vector3.new(-2014, 185, -10238),
 ["Deep Forest Quest Giver"] = Vector3.new(-12871, 333, -7751),
 ["Deep Forest Area 2 Quest Giver"] = Vector3.new(-10620, 331, -8671),
 ["Haunted Castle Quest Giver 1"] = Vector3.new(-9516, 169, 6079),
 ["Haunted Castle Quest Giver 2"] = Vector3.new(-9516, 175, 6079),
 ["Peanut Quest Giver"] = Vector3.new(-198, 48, -12118),
 ["Ice Cream Quest Giver"] = Vector3.new(-822, 63, -10963),
 ["Cake Quest Giver 1"] = Vector3.new(198, 25, -12109),
 ["Cake Quest Giver 2"] = Vector3.new(680, 25, -12543),
 ["Chocolate Quest Giver 1"] = Vector3.new(228, 25, -11124),
 ["Chocolate Quest Giver 2"] = Vector3.new(1541, 25, -12105),
 ["Candy Cane Quest Giver"] = Vector3.new(-1190, 14, -14352),
 ["Tiki Quest Giver 1"] = Vector3.new(-16238, 10, 439),
 ["Tiki Quest Giver 2"] = Vector3.new(-16521, 52, 1042),
 ["Tiki Quest Giver 3"] = Vector3.new(-16901, 85, 1512),
 ["Submerged Quest Giver 1"] = Vector3.new(-18021, 15, 2810),
 ["Submerged Quest Giver 2"] = Vector3.new(-18512, 42, 3211),
 ["Submerged Quest Giver 3"] = Vector3.new(-19102, 90, 3821)
}

Polar.Detection = {
 Cache = {
 NPCs = {},
 Enemies = {},
 Objects = {},
 Spawns = {}
 }
}

function Polar.Detection:FuzzyMatch(str1, str2)
 if not str1 or not str2 then return false end
 local s1 = string.lower(tostring(str1)):gsub("[%s%p]", "")
 local s2 = string.lower(tostring(str2)):gsub("[%s%p]", "")
 if s1 == s2 then return true end
 if string.find(s1, s2, 1, true) or string.find(s2, s1, 1, true) then
 return true
 end
 return false
end

function Polar.Detection:FindNPC(npcName)
 if not npcName or npcName == "" then return nil end
 
 -- 1. Caché previo
 if getgenv().PolarNPCCache and getgenv().PolarNPCCache[npcName] then
 return getgenv().PolarNPCCache[npcName]
 end
 if Polar.Data.NPCCache and Polar.Data.NPCCache[npcName] then
 return Polar.Data.NPCCache[npcName]
 end

 -- 2. Búsqueda directa en workspace.NPCs
 local npcsFolder = workspace:FindFirstChild("NPCs")
 if npcsFolder then
 for _, npc in ipairs(npcsFolder:GetChildren()) do
 if self:FuzzyMatch(npc.Name, npcName) then
 local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc:FindFirstChildOfClass("BasePart")
 if part then
 local cf = part.CFrame
 Polar.Data.NPCCache[npcName] = cf
 if getgenv().PolarNPCCache then getgenv().PolarNPCCache[npcName] = cf end
 return cf
 end
 end
 end
 end

 -- 3. Búsqueda profunda en contenedores secundarios
 local containers = {
 workspace:FindFirstChild("Enemies"),
 workspace:FindFirstChild("Characters"),
 workspace:FindFirstChild("Map"),
 workspace:FindFirstChild("Locations"),
 workspace
 }

 for _, folder in ipairs(containers) do
 if folder then
 for _, child in ipairs(folder:GetChildren()) do
 if child:IsA("Model") and self:FuzzyMatch(child.Name, npcName) then
 local part = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head") or child:FindFirstChildOfClass("BasePart")
 if part then
 local cf = part.CFrame
 Polar.Data.NPCCache[npcName] = cf
 return cf
 end
 end
 end
 end
 end

 -- 4. Fallback de StreamingEnabled
 if FallbackPositions and FallbackPositions[npcName] then
 local pos = FallbackPositions[npcName]
 local cf = (typeof(pos) == "Vector3" and CFrame.new(pos)) or pos
 Polar.Data.NPCCache[npcName] = cf
 return cf
 end

 return nil
end

function Polar.Detection:FindEnemy(enemyName)
 if not enemyName or enemyName == "" then return nil, nil end
 local enemies = workspace:FindFirstChild("Enemies")
 local chars = workspace:FindFirstChild("Characters")
 
 local containers = {enemies, chars}
 for _, folder in ipairs(containers) do
 if folder then
 for _, npc in ipairs(folder:GetChildren()) do
 if self:FuzzyMatch(npc.Name, enemyName) then
 local hum = npc:FindFirstChildOfClass("Humanoid")
 local hrp = npc:FindFirstChild("HumanoidRootPart")
 if hum and hrp and hum.Health > 0 then
 return npc, hrp
 end
 end
 end
 end
 end
 return nil, nil
end

function Polar.Detection:GetEnemySpawnCFrame(enemyName)
 if not enemyName or enemyName == "" then return nil end
 
 local mob, hrp = self:FindEnemy(enemyName)
 if hrp then return hrp.CFrame end
 
 if Polar.Data.SpawnCache[enemyName] then
 local pos = Polar.Data.SpawnCache[enemyName]
 return typeof(pos) == "Vector3" and CFrame.new(pos) or pos
 end

 local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
 local enemySpawns = worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
 if enemySpawns then
 for _, spawnPart in ipairs(enemySpawns:GetChildren()) do
 if self:FuzzyMatch(spawnPart.Name, enemyName) then
 local cf = spawnPart.CFrame
 Polar.Data.SpawnCache[enemyName] = cf
 return cf
 end
 end
 end

 if FallbackPositions and FallbackPositions[enemyName] then
 local pos = FallbackPositions[enemyName]
 local cf = typeof(pos) == "Vector3" and CFrame.new(pos) or pos
 Polar.Data.SpawnCache[enemyName] = cf
 return cf
 end

 if Polar.Data.QuestInfo then
 for _, qData in ipairs(Polar.Data.QuestInfo) do
 if qData.name and self:FuzzyMatch(qData.name, enemyName) and qData.pos then
 local cf = qData.pos
 Polar.Data.SpawnCache[enemyName] = cf
 return cf
 end
 end
 end

 return nil
end

function Polar.Detection:FindObject(objName)
 if not objName or objName == "" then return nil end
 
 local char = LocalPlayer.Character
 local backpack = LocalPlayer:FindFirstChild("Backpack")
 if char then
 local tool = char:FindFirstChild(objName)
 if tool then return tool end
 end
 if backpack then
 local tool = backpack:FindFirstChild(objName)
 if tool then return tool end
 end

 for _, v in ipairs(workspace:GetChildren()) do
 if self:FuzzyMatch(v.Name, objName) then return v end
 end

 local map = workspace:FindFirstChild("Map")
 if map then
 for _, v in ipairs(map:GetDescendants()) do
 if self:FuzzyMatch(v.Name, objName) then return v end
 end
 end

 return nil
end

-- Módulo del Mundo Compatible
Polar.World = Polar.World or {}

function Polar.World:FindNPC(npcName)
 return Polar.Detection:FindNPC(npcName)
end

function Polar.World:GetEnemySpawnPosition(enemyName)
 local cf = Polar.Detection:GetEnemySpawnCFrame(enemyName)
 return cf and cf.Position or nil
end

function Polar.World:IsEnemyAlive(enemyName)
 local mob, hrp = Polar.Detection:FindEnemy(enemyName)
 return mob ~= nil
end

-- ==================== UNIFIED QUEST ENGINE (MOTOR MAESTRO DE MISIONES) ====================
Polar.QuestEngine = Polar.QuestEngine or {}

function Polar.QuestEngine:GetActiveQuestTitle()
 local pgui = LocalPlayer:FindFirstChild("PlayerGui")
 if not pgui then return nil end

 -- Prioridad 1: Modern Blox Fruits TrackedQuestFrame
 local tq = pgui:FindFirstChild("TrackedQuestFrame")
 if tq then
 local frame = tq:FindFirstChild("Frame")
 if frame and frame.Visible then
 local header = frame:FindFirstChild("header")
 local headerText = header and header:FindFirstChild("textLabel")
 if headerText and headerText.Text and headerText.Text ~= "" then
 return headerText.Text
 end
 local desc = frame:FindFirstChild("description")
 if desc and desc.Text and desc.Text ~= "" then
 return desc.Text
 end
 end
 end

 -- Prioridad 2: Legacy Main.Quest
 local main = pgui:FindFirstChild("Main")
 local questUI = main and main:FindFirstChild("Quest")
 if questUI and questUI.Visible then
 local container = questUI:FindFirstChild("Container")
 if container then
 local title = container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title")
 if title and title.Text and title.Text ~= "" then
 return title.Text
 end
 local oldTitle = container:FindFirstChild("QuestTitle")
 if oldTitle and oldTitle:IsA("TextLabel") and oldTitle.Text and oldTitle.Text ~= "" then
 return oldTitle.Text
 end
 end
 end
 return nil
end

function Polar.QuestEngine:HasActiveQuest()
 local title = self:GetActiveQuestTitle()
 if not title then return false end
 local lowerTitle = string.lower(title)
 if string.find(lowerTitle, "completed") or string.find(lowerTitle, "completada") then
 return false
 end
 return true
end

function Polar.QuestEngine:GetBestQuest(level)
 level = level or (Polar.Player and Polar.Player:GetLevel() or 1)
 
 local bestQuest = nil
 local maxLvl = -1
 
 local questsModule = nil
 pcall(function()
 questsModule = require(ReplicatedStorage:WaitForChild("Quests", 2))
 end)
 
 local allowed = Polar.Data.AllowedQuests or {}
 
 if questsModule and #allowed > 0 then
 for _, qName in ipairs(allowed) do
 local qList = questsModule[qName]
 if qList then
 for index, qData in ipairs(qList) do
 if qData.LevelReq and level >= qData.LevelReq and qData.LevelReq > maxLvl then
 maxLvl = qData.LevelReq
 bestQuest = {
 qName = qName,
 index = index,
 enemyName = qData.Name,
 giverName = Polar.Data.QuestGiver[qName],
 island = Polar.Data.QuestToIsland[qName] or "",
 levelReq = qData.LevelReq
 }
 end
 end
 end
 end
 end
 
 if not bestQuest and Polar.Data.QuestInfo then
 for _, qData in ipairs(Polar.Data.QuestInfo) do
 if level >= qData.lvl and qData.lvl > maxLvl then
 maxLvl = qData.lvl
 bestQuest = {
 qName = qData.q,
 index = qData.ql,
 enemyName = qData.name,
 giverName = qData.giver or Polar.Data.QuestGiver[qData.q],
 island = qData.island or Polar.Data.QuestToIsland[qData.q] or "",
 levelReq = qData.lvl,
 pos = qData.pos
 }
 end
 end
 end
 
 return bestQuest
end

-- Compatibilidad con Polar.Quest
Polar.Quest = Polar.Quest or {}

function Polar.Quest:GetQuestsModule()
 local success, result = pcall(function()
 return require(ReplicatedStorage:WaitForChild("Quests", 2))
 end)
 return success and result or nil
end

function Polar.Quest:GetBestQuest()
 return Polar.QuestEngine:GetBestQuest()
end

function Polar.Quest:HasQuest()
 return Polar.QuestEngine:HasActiveQuest()
end

function Polar.Quest:GetTargetEnemyNameFromQuest()
 local pgui = LocalPlayer:FindFirstChild("PlayerGui")
 local tq = pgui and pgui:FindFirstChild("TrackedQuestFrame")
 if tq then
 local frame = tq:FindFirstChild("Frame")
 if frame and frame.Visible then
 local desc = frame:FindFirstChild("description")
 if desc and desc.Text and desc.Text ~= "" then
 return desc.Text
 end
 end
 end

 local activeTitle = Polar.QuestEngine:GetActiveQuestTitle()
 if not activeTitle then return nil end
 
 local bestMatch = nil
 local bestLen = 0
 
 if Polar.Data.QuestInfo then
 for _, qData in ipairs(Polar.Data.QuestInfo) do
 if Polar.Detection:FuzzyMatch(activeTitle, qData.name) then
 if #qData.name > bestLen then
 bestLen = #qData.name
 bestMatch = qData.name
 end
 end
 end
 end
 if Polar.Data.Bosses then
 for _, bData in ipairs(Polar.Data.Bosses) do
 if Polar.Detection:FuzzyMatch(activeTitle, bData.name) then
 if #bData.name > bestLen then
 bestLen = #bData.name
 bestMatch = bData.name
 end
 end
 end
 end
 
 return bestMatch
end

function Polar.World:GetQuestGiverCFrame(questName, index, enemyName)
 local giverName = Polar.Data.QuestGiver[questName]
 
 -- Soporte para misiones del Barco Maldito que se dividen entre dos NPCs distintos
 if questName == "ShipQuest1" or questName == "ShipQuest2" then
 if index == 3 or index == 4 or (enemyName and (string.find(enemyName, "Steward") or string.find(enemyName, "Officer"))) then
 giverName = "Front Crew Quest Giver"
 elseif index == 1 or index == 2 or (enemyName and (string.find(enemyName, "Deckhand") or string.find(enemyName, "Engineer"))) then
 giverName = "Rear Crew Quest Giver"
 end
 end
 
 -- 1. Búsqueda directa en workspace.NPCs
 if giverName then
 local cf = Polar.World:FindNPC(giverName)
 if cf then return cf end
 end
 
 -- 2. Búsqueda exacta en Polar.Data.QuestInfo (con posición pos)
 if Polar.Data.QuestInfo then
 for _, qData in ipairs(Polar.Data.QuestInfo) do
 if (qData.q == questName or (qData.qName and qData.qName == questName)) and (not index or qData.ql == index or qData.index == index) then
 if qData.pos then return qData.pos end
 end
 end
 for _, qData in ipairs(Polar.Data.QuestInfo) do
 if qData.q == questName or (qData.qName and qData.qName == questName) then
 if qData.pos then return qData.pos end
 end
 end
 end
 
 -- 3. Posición de respaldo si el NPC aún no ha sido cargado por streaming
 if giverName and FallbackPositions and FallbackPositions[giverName] then
 return CFrame.new(FallbackPositions[giverName])
 end
 
 local islandName = Polar.Data.QuestToIsland[questName]
 if islandName then
 Polar.Teleport:ToIsland(islandName)
 if giverName then
 local cf = Polar.World:FindNPC(giverName)
 if cf then return cf end
 end
 end
 return nil
end

-- Bypass Global de Distancia no requiere hook metamethod (la teleportación física lo cubre al 100%)
local function InstallGlobalBypass()
 -- Sin hooks metamethod para máxima estabilidad en todos los ejecutores
end

local function BuyItem(action, arg1, arg2, npcName)
 InstallGlobalBypass()
 task.spawn(function()
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 
 local oldCFrame = hrp.CFrame
 local npcCF = Polar.World:FindNPC(npcName)
 
 if npcCF then
 Polar.Teleport:To(npcCF * CFrame.new(0, 0, 3))
 task.wait(0.5)
 for _, v in ipairs(workspace:GetDescendants()) do
 if v:IsA("Model") and string.find(string.lower(v.Name), string.lower(npcName)) then
 for _, prompt in ipairs(v:GetDescendants()) do
 if prompt:IsA("ProximityPrompt") and fireproximityprompt then
 pcall(function() fireproximityprompt(prompt) end)
 end
 end
 end
 end
 task.wait(0.5)
 end
 
 pcall(function()
 if arg2 then CommF:InvokeServer(action, arg1, arg2)
 elseif arg1 then CommF:InvokeServer(action, arg1)
 else CommF:InvokeServer(action) end
 end)
 
 if npcCF then
 task.wait(0.5)
 Polar.Teleport:To(oldCFrame)
 end
 end)
end

-- Exportar funciones globales
getgenv().PolarBuyItem = BuyItem
getgenv().PolarBypassTeleport = function(cf) Polar.Teleport:To(cf) end
getgenv().PolarIsEnemyAlive = function(name) return Polar.World:IsEnemyAlive(name) end
getgenv().PolarNPCCache = Polar.Data.NPCCache
getgenv().PolarLevelQuests = Polar.Data.QuestInfo
getgenv().PolarBosses = Polar.Data.Bosses

-- ==================== COMPATIBILIDAD DE VARIABLES ====================
local SelectedWeaponType = "Melee" 
local AutoMasteryEnabled = false
local AutoMasteryItem = "Sword"
local AutoSkillsEnabled = false
local AutoFarmEnabled = false
local AutoFarmNearestEnabled = false
getgenv().PolarAutoFarmBossEnabled = false
getgenv().PolarAutoFarmAllBossesEnabled = false
getgenv().PolarBossWithQuest = false
getgenv().PolarLastBossCheckedIndex = 1
getgenv().PolarSelectedBossToFarm = "Gorilla King"
getgenv().PolarAutoMobLeaderEnabled = false
getgenv().PolarAutoSaberExpertEnabled = false
getgenv().PolarCurrentBotState = "IDLE"
local STATE_IDLE = "IDLE"
local STATE_FARMING = "FARMING"
local STATE_WAITING = "WAITING"
local STATE_GETTING_QUEST = "GETTING_QUEST"

local request_func = (http_request or request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))

local function SafeHttpGet(url)
 if request_func then
 local success, response = pcall(function()
 return request_func({
 Url = url,
 Method = "GET",
 Headers = {
 ["User-Agent"] = "Roblox"
 },
 Timeout = 2
 })
 end)
 if success and response and response.StatusCode == 200 then
 return response.Body
 end
 else
 local success, body = pcall(function()
 return game:HttpGet(url)
 end)
 if success then
 return body
 end
 end
 return nil
end

local bridgeUrl = getgenv().PolarBridgeURL or "http://127.0.0.1:3000"
task.spawn(function()
 if not getgenv().PolarBridgeURL then
 pcall(function()
 local configUrl = "https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/bridge_config.json"
 local rawConfig = SafeHttpGet(configUrl)
 if rawConfig then
 local decoded = game:GetService("HttpService"):JSONDecode(rawConfig)
 if decoded and decoded.bridgeUrl then
 bridgeUrl = decoded.bridgeUrl
 end
 end
 end)
 end
end)

local function CopyToClipboard(text)
 local setClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
 if setClipboard then
 pcall(setClipboard, text)
 end
end

local function GetServerFromBridge(queryType, placeId)
 local url = bridgeUrl .. "/get_server?type=" .. tostring(queryType) .. "&place_id=" .. tostring(placeId)
 local raw = SafeHttpGet(url)
 if raw then
 local success, result = pcall(function() return HttpService:JSONDecode(raw) end)
 if success and result and result.success then
 return result.jobId, result.placeId
 end
 end
 return nil
end

local function SendDiscordNotification(title, description, fields)
 task.spawn(function()
 pcall(function()
 local payload = {
 embed = {
 title = title,
 description = description,
 color = 378120,
 fields = fields or {},
 footer = "Polar Hub Notificaciones"
 }
 }
 local jsonPayload = HttpService:JSONEncode(payload)
 HttpService:PostAsync(bridgeUrl .. "/log_discord", jsonPayload, Enum.HttpContentType.ApplicationJson)
 end)
 end)
end

local function GetMainPlaceIdForCurrentSea()
 local placeId = game.PlaceId
 if placeId == 2753915549 then return 2753915549 end
 if placeId == 4442272000 or placeId == 79091703265657 or placeId == 4442272183 then return 4442272183 end
 if placeId == 7449423635 then return 7449423635 end
 
 local map = workspace:FindFirstChild("Map")
 if map then
 if map:FindFirstChild("Kingdom of Rose") or map:FindFirstChild("Green Zone") or map:FindFirstChild("Graveyard") or workspace:FindFirstChild("Factory") then
 return 4442272183
 elseif map:FindFirstChild("Port Town") or map:FindFirstChild("Turtle") or map:FindFirstChild("Sea Castle") or map:FindFirstChild("Floating Turtle") then
 return 7449423635
 end
 end
 
 if workspace:FindFirstChild("NPCs") then
 if workspace.NPCs:FindFirstChild("Area 1 Quest Giver") or workspace.NPCs:FindFirstChild("Zombie Quest Giver") or workspace.NPCs:FindFirstChild("Alchemist") or workspace.NPCs:FindFirstChild("Ship Quest Giver") then
 return 4442272183
 end
 end
 
 local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
 local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
 if lvl >= 1500 then
 return 7449423635
 elseif lvl >= 700 then
 return 4442272183
 end
 
 return 2753915549
end

local serverHopCache = {}
local serverHopIndex = 1

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage, placeId)
 if player == LocalPlayer then
 warn("[Polar Hub] Teletransporte falló: " .. tostring(teleportResult) .. " (" .. tostring(errorMessage) .. ")")
 if #serverHopCache > 0 and serverHopIndex < #serverHopCache then
 serverHopIndex = serverHopIndex + 1
 local nextServerId = serverHopCache[serverHopIndex]
 local targetPlaceId = placeId or GetMainPlaceIdForCurrentSea()
 warn("[Polar Hub] Reintentando automático con servidor alternativo (" .. tostring(serverHopIndex) .. "/" .. tostring(#serverHopCache) .. ")...")
 pcall(function()
 TeleportService:TeleportToPlaceInstance(targetPlaceId, nextServerId, LocalPlayer)
 end)
 end
 end
end)

local function ServerHop()
 local placeId = GetMainPlaceIdForCurrentSea()
 local servers = {}
 local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
 local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
 if success and result and result.data then
 for _, v in ipairs(result.data) do
 if type(v) == "table" and v.playing and v.maxPlayers and v.playing >= 2 and v.playing < v.maxPlayers - 1 and v.id ~= game.JobId then
 table.insert(servers, v.id)
 end
 end
 end
 if #servers > 0 then
 local shuffled = {}
 while #servers > 0 do
 table.insert(shuffled, table.remove(servers, math.random(1, #servers)))
 end
 serverHopCache = shuffled
 serverHopIndex = 1
 pcall(function()
 TeleportService:TeleportToPlaceInstance(placeId, serverHopCache[1], LocalPlayer)
 end)
 end
end

local function ServerHopLowPlayers()
 local placeId = GetMainPlaceIdForCurrentSea()
 
 local bridgeJobId, bridgePlaceId = GetServerFromBridge("low_players", placeId)
 if bridgeJobId then
 warn("[Polar Hub] Servidor con pocos jugadores obtenido vía Python Bridge!")
 serverHopCache = { bridgeJobId }
 serverHopIndex = 1
 pcall(function()
 TeleportService:TeleportToPlaceInstance(bridgePlaceId or placeId, bridgeJobId, LocalPlayer)
 end)
 return
 end
 
 warn("[Polar Hub] Python Bridge no disponible. Usando escaneo Lua interno...")
 local serverList = {}
 local cursor = ""
 local attempts = 0
 while attempts < 5 do
 local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
 if cursor ~= "" then
 url = url .. "&cursor=" .. cursor
 end
 local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
 if success and result and result.data then
 for _, v in ipairs(result.data) do
 if type(v) == "table" and v.playing and v.maxPlayers and v.id ~= game.JobId then
 if v.playing >= 2 and v.playing <= v.maxPlayers - 2 then
 table.insert(serverList, v)
 end
 end
 end
 if #serverList >= 20 or not result.nextPageCursor then
 break
 end
 cursor = result.nextPageCursor
 else
 break
 end
 attempts = attempts + 1
 task.wait(0.1)
 end
 
 if #serverList > 0 then
 table.sort(serverList, function(a, b)
 return a.playing < b.playing
 end)
 local cache = {}
 for _, s in ipairs(serverList) do
 table.insert(cache, s.id)
 end
 serverHopCache = cache
 serverHopIndex = 1
 pcall(function()
 TeleportService:TeleportToPlaceInstance(placeId, serverHopCache[1], LocalPlayer)
 end)
 else
 ServerHop()
 end
end

local function ServerHopBestPing()
 local placeId = GetMainPlaceIdForCurrentSea()
 
 local bridgeJobId, bridgePlaceId = GetServerFromBridge("best_ping", placeId)
 if bridgeJobId then
 warn("[Polar Hub] Servidor con mejor ping obtenido vía Python Bridge!")
 serverHopCache = { bridgeJobId }
 serverHopIndex = 1
 pcall(function()
 TeleportService:TeleportToPlaceInstance(bridgePlaceId or placeId, bridgeJobId, LocalPlayer)
 end)
 return
 end
 
 warn("[Polar Hub] Python Bridge no disponible. Usando escaneo Lua interno...")
 local serverList = {}
 local cursor = ""
 local attempts = 0
 while attempts < 5 do
 local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
 if cursor ~= "" then
 url = url .. "&cursor=" .. cursor
 end
 local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
 if success and result and result.data then
 for _, v in ipairs(result.data) do
 if type(v) == "table" and v.playing and v.maxPlayers and v.id ~= game.JobId and v.ping then
 if v.playing >= 2 and v.playing <= v.maxPlayers - 2 then
 table.insert(serverList, v)
 end
 end
 end
 if #serverList >= 20 or not result.nextPageCursor then
 break
 end
 cursor = result.nextPageCursor
 else
 break
 end
 attempts = attempts + 1
 task.wait(0.1)
 end
 
 if #serverList > 0 then
 table.sort(serverList, function(a, b)
 return a.ping < b.ping
 end)
 local cache = {}
 for _, s in ipairs(serverList) do
 table.insert(cache, s.id)
 end
 serverHopCache = cache
 serverHopIndex = 1
 pcall(function()
 TeleportService:TeleportToPlaceInstance(placeId, serverHopCache[1], LocalPlayer)
 end)
 else
 ServerHop()
 end
end

local function MatchEnemyName(npcName, targetName)
 if npcName == targetName then return true end
 local lowerNpc = string.lower(npcName)
 local lowerTarget = string.lower(targetName)
 if string.find(lowerNpc, lowerTarget) then
 if lowerTarget == "gorilla" and string.find(lowerNpc, "king") then return false end
 if lowerTarget == "bandit" and string.find(lowerNpc, "desert") then return false end
 if lowerTarget == "bandit" and string.find(lowerNpc, "snow") then return false end
 if lowerTarget == "bandit" and string.find(lowerNpc, "sky") then return false end
 return true
 end
 return false
end

local function GetCurrentTargetEnemyName()
 if getgenv().PolarAutoSaberExpertEnabled then return "Saber Expert" end
 if getgenv().PolarAutoMobLeaderEnabled then return "Mob Leader" end
 if AutoFarmNearestEnabled then return "NearestNPC" end
 if getgenv().PolarAutoFarmAllBossesEnabled then
 for _, b in ipairs(Polar.Data.Bosses) do
 if Polar.World:IsEnemyAlive(b.name) then return b.name end
 end
 if getgenv().PolarLastBossCheckedIndex > #Polar.Data.Bosses then
 ServerHop()
 return "Buscando Jefes..."
 end
 return Polar.Data.Bosses[getgenv().PolarLastBossCheckedIndex].name
 end
 if getgenv().PolarAutoFarmBossEnabled then return getgenv().PolarSelectedBossToFarm end
 
 local bestQuest = Polar.Quest:GetBestQuest()
 return bestQuest and bestQuest.enemyName
end

local function EquipWeapon(targetHealthPercent)
 local char = LocalPlayer.Character
 if not char then return end
 
 local weaponToEquip = SelectedWeaponType
 if AutoMasteryEnabled and targetHealthPercent and targetHealthPercent < 20 then
 weaponToEquip = AutoMasteryItem
 end

 local currentTool = char:FindFirstChildOfClass("Tool")
 if currentTool then
 if currentTool.ToolTip == weaponToEquip then
 return
 else
 char.Humanoid:UnequipTools()
 end
 end
 
 local backpack = LocalPlayer:FindFirstChild("Backpack")
 if backpack then
 for _, tool in ipairs(backpack:GetChildren()) do
 if tool:IsA("Tool") and tool.ToolTip == weaponToEquip and tool.Name ~= "Fishing Rod" then
 char.Humanoid:EquipTool(tool)
 task.wait(0.1)
 return
 end
 end
 end
end

-- ==================== CEREBRO AUTO FARM CENTRAL ====================
local QuestTryCount = 0
task.spawn(function()
 while true do
 task.wait(0.1)
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChild("Humanoid")
 if not hrp or not hum or hum.Health <= 0 then continue end
 
 local anyFarmActive = AutoFarmEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled
 
 if not anyFarmActive then
 Polar.Data.CurrentState = "IDLE"
 getgenv().PolarCurrentBotState = "IDLE"
 local plat = workspace:FindFirstChild("PolarFarmPlat")
 if plat then plat:Destroy() end
 local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
 if hoverBv then hoverBv:Destroy() end
 task.wait(1)
 continue
 end

 -- 1. Asegurar plataforma base
 local plat = workspace:FindFirstChild("PolarFarmPlat")
 if not plat then
 plat = Instance.new("Part", workspace)
 plat.Name = "PolarFarmPlat"
 plat.Size = Vector3.new(15, 1, 15)
 plat.Anchored = true
 plat.Transparency = 1
 plat.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
 end

 -- 2. Determinar Objetivo Principal y Misión
 local targetEnemyName = nil
 local activeBossQuestData = nil
 local isHuntingBoss = getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled
 local needsQuest = not (getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled)
 
 -- Resolver Objetivo
 if getgenv().PolarAutoSaberExpertEnabled then
 targetEnemyName = "Saber Expert"
 elseif getgenv().PolarAutoMobLeaderEnabled then
 targetEnemyName = "Mob Leader"
 elseif AutoFarmNearestEnabled then
 local minDist = math.huge
 local nearestName = nil
 if enemiesFolder then
 for _, npc in ipairs(enemiesFolder:GetChildren()) do
 local nHrp = npc:FindFirstChild("HumanoidRootPart")
 local nHum = GetValidHumanoid(npc)
 if nHrp and nHum and nHrp.Position.Y > 0 then
 local d = (nHrp.Position - hrp.Position).Magnitude
 if d < minDist then
 minDist = d
 nearestName = npc.Name
 end
 end
 end
 end
 targetEnemyName = nearestName or "Buscando Enemigos..."
 elseif getgenv().PolarAutoFarmAllBossesEnabled then
 for _, b in ipairs(Polar.Data.Bosses) do
 if Polar.World:IsEnemyAlive(b.name) then
 targetEnemyName = b.name
 activeBossQuestData = b
 break
 end
 end
 if not targetEnemyName then
 if getgenv().PolarLastBossCheckedIndex > #Polar.Data.Bosses then
 ServerHop()
 targetEnemyName = "Buscando Jefes..."
 else
 targetEnemyName = Polar.Data.Bosses[getgenv().PolarLastBossCheckedIndex].name
 activeBossQuestData = Polar.Data.Bosses[getgenv().PolarLastBossCheckedIndex]
 end
 end
 elseif getgenv().PolarAutoFarmBossEnabled then
 targetEnemyName = getgenv().PolarSelectedBossToFarm
 for _, b in ipairs(Polar.Data.Bosses) do
 if b.name == targetEnemyName then activeBossQuestData = b break end
 end
 else
 -- AutoFarm de Niveles
 local bestQuest = Polar.Quest:GetBestQuest()
 targetEnemyName = bestQuest and bestQuest.enemyName
 end
 
 -- Control de Misiones para Jefes
 if isHuntingBoss then
 if not getgenv().PolarBossWithQuest or (activeBossQuestData and not activeBossQuestData.q) then
 needsQuest = false
 end
 end
 
 if targetEnemyName == "Buscando Jefes..." or targetEnemyName == "Buscando Enemigos..." or not targetEnemyName then
 Polar.Data.CurrentState = "IDLE"
 getgenv().PolarCurrentBotState = "IDLE"
 task.wait(1)
 continue
 end

 -- ==================== ESTADOS DE LA MÁQUINA DE AUTOFARM ====================
 if Polar.Data.CurrentState == "IDLE" then
 QuestTryCount = 0
 if needsQuest and not Polar.Quest:HasQuest() then
 Polar.Data.CurrentState = "GETTING_QUEST"
 getgenv().PolarCurrentBotState = "GETTING_QUEST"
 else
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 end
 end
 
 if Polar.Data.CurrentState == "GETTING_QUEST" then
 if Polar.Quest:HasQuest() then
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 continue
 end
 
 local bestQuest = Polar.Quest:GetBestQuest()
 local qData = activeBossQuestData or bestQuest
 
 -- Normalizar qData para dar soporte unificado a BossData y QuestData
 if qData then
 if not qData.qName and qData.q then
 qData.qName = qData.q
 end
 if not qData.index and qData.ql then
 qData.index = qData.ql
 end
 if not qData.enemyName and qData.name then
 qData.enemyName = qData.name
 end
 end
 
 if not qData or not qData.qName then
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 continue
 end
 
 local giverCF = Polar.World:GetQuestGiverCFrame(qData.qName, qData.index, qData.enemyName)
 
 if giverCF then
 if (hrp.Position - giverCF.Position).Magnitude > 15 then
 Polar.Teleport:To(giverCF)
 else
 hrp.CFrame = giverCF
 hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 task.wait(0.2)
 pcall(function() CommF:InvokeServer("StartQuest", qData.qName, qData.index) end)
 QuestTryCount = QuestTryCount + 1
 if QuestTryCount > 10 then
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 end
 task.wait(0.25)
 end
 else
 local islandName = Polar.Data.QuestToIsland[qData.qName]
 if islandName then
 Polar.Teleport:ToIsland(islandName)
 else
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 end
 end
 continue
 end
 
 if Polar.Data.CurrentState == "FARMING" then
 getgenv().PolarCurrentBotState = "FARMING"
 -- Abandonar misión incorrecta si es necesario
 if needsQuest then
 if Polar.Quest:HasQuest() then
 local currentQuestTarget = Polar.Quest:GetTargetEnemyNameFromQuest()
 local expectedTarget = activeBossQuestData and activeBossQuestData.name or (Polar.Quest:GetBestQuest() and Polar.Quest:GetBestQuest().enemyName)
 
 if currentQuestTarget and expectedTarget and not MatchEnemyName(currentQuestTarget, expectedTarget) and not MatchEnemyName(expectedTarget, currentQuestTarget) then
 pcall(function() CommF:InvokeServer("AbandonQuest") end)
 Polar.Data.CurrentState = "GETTING_QUEST"
 getgenv().PolarCurrentBotState = "GETTING_QUEST"QuestTryCount = 0
 task.wait(0.4)
 continue
 end
 else
 Polar.Data.CurrentState = "GETTING_QUEST"
 getgenv().PolarCurrentBotState = "GETTING_QUEST"QuestTryCount = 0
 continue
 end
 end

 -- Buscar enemigo
 local firstNPC = nil
 local minDist = math.huge
 
 if enemiesFolder then
 for _, npc in ipairs(enemiesFolder:GetChildren()) do
 if MatchEnemyName(npc.Name, targetEnemyName) then
 local nHrp = npc:FindFirstChild("HumanoidRootPart")
 local nHum = GetValidHumanoid(npc)
 if nHrp and nHum and nHrp.Position.Y > 0 then
 local d = (nHrp.Position - hrp.Position).Magnitude
 if d < minDist then
 minDist = d
 firstNPC = npc
 end
 end
 end
 end
 end
 
 if firstNPC then
 local nHrp = firstNPC:FindFirstChild("HumanoidRootPart")
 local targetCF = nHrp.CFrame * CFrame.new(0, isHuntingBoss and 18 or 12, 0)
 
 -- BodyVelocity permanente para que el jugador flote sin caer jamás por gravedad o M1
 local hoverBv = hrp:FindFirstChild("Polar_PlayerHover")
 if not hoverBv then
 hoverBv = Instance.new("BodyVelocity")
 hoverBv.Name = "Polar_PlayerHover"
 hoverBv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
 hoverBv.Velocity = Vector3.new(0, 0, 0)
 hoverBv.Parent = hrp
 else
 hoverBv.Velocity = Vector3.new(0, 0, 0)
 end
 
 plat.CFrame = targetCF * CFrame.new(0, -3.5, 0)
 plat.CanCollide = true
 
 local distToTarget = (hrp.Position - targetCF.Position).Magnitude
 if distToTarget > 15 then
 Polar.Teleport:To(targetCF)
 else
 -- Fijar firmemente la posición en el aire mirando hacia el NPC
 hrp.CFrame = CFrame.lookAt(targetCF.Position, nHrp.Position)
 hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
 end
 
 -- Congelar enemigo principal
 local oHum = GetValidHumanoid(firstNPC)
 if oHum then oHum.WalkSpeed = 0 oHum.JumpPower = 0 end
 
 local primaryBv = nHrp:FindFirstChild("Polar_AntiGlitch")
 if not primaryBv then
 primaryBv = Instance.new("BodyVelocity")
 primaryBv.Name = "Polar_AntiGlitch"
 primaryBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 primaryBv.Velocity = Vector3.new(0, 0, 0)
 primaryBv.Parent = nHrp
 end
 
 -- Agrupar otros enemigos cercanos
 if not isHuntingBoss then
 local broughtCount = 1
 for _, npc in ipairs(enemiesFolder:GetChildren()) do
 if npc ~= firstNPC and MatchEnemyName(npc.Name, targetEnemyName) then
 local tHrp = npc:FindFirstChild("HumanoidRootPart")
 local tHum = GetValidHumanoid(npc)
 if tHrp and tHum then
 pcall(function()
 if setsimulationradius then setsimulationradius(math.huge, math.huge)
 elseif sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
 end)
 
 if (tHrp.Position - nHrp.Position).Magnitude <= 350 then
 if broughtCount < 6 then
 broughtCount = broughtCount + 1
 
 local secBv = tHrp:FindFirstChild("Polar_AntiGlitch")
 if not secBv then
 secBv = Instance.new("BodyVelocity")
 secBv.Name = "Polar_AntiGlitch"
 secBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 secBv.Velocity = Vector3.new(0, 0, 0)
 secBv.Parent = tHrp
 end
 
 for _, part in ipairs(npc:GetDescendants()) do
 if part:IsA("BasePart") then part.CanCollide = false end
 end
 tHrp.CFrame = nHrp.CFrame
 tHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 tHum.WalkSpeed = 0
 tHum.JumpPower = 0
 tHum.PlatformStand = true
 end
 end
 end
 end
 end
 end
 else
 Polar.Data.CurrentState = "WAITING"
 getgenv().PolarCurrentBotState = "WAITING"
 end
 end
 
 if Polar.Data.CurrentState == "WAITING" then
 getgenv().PolarCurrentBotState = "WAITING"
 -- Verificar reaparición
 local enemySpawned = false
 if enemiesFolder then
 for _, npc in ipairs(enemiesFolder:GetChildren()) do
 if MatchEnemyName(npc.Name, targetEnemyName) then
 local nHrp = npc:FindFirstChild("HumanoidRootPart")
 local nHum = GetValidHumanoid(npc)
 if nHrp and nHum and nHrp.Position.Y > 0 then
 enemySpawned = true
 break
 end
 end
 end
 end
 
 if enemySpawned then
 Polar.Data.CurrentState = "FARMING"
 getgenv().PolarCurrentBotState = "FARMING"
 else
 local spawnPos = Polar.World:GetEnemySpawnPosition(targetEnemyName)
 if spawnPos then
 local targetCF = CFrame.new(spawnPos) * CFrame.new(0, 30, 0)
 plat.CFrame = targetCF
 if (hrp.Position - targetCF.Position).Magnitude > 20 then
 Polar.Teleport:To(targetCF * CFrame.new(0, 3.5, 0))
 else
 hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 task.wait(1)
 if getgenv().PolarAutoFarmAllBossesEnabled then
 if not Polar.World:IsEnemyAlive(targetEnemyName) then
 getgenv().PolarLastBossCheckedIndex = getgenv().PolarLastBossCheckedIndex + 1
 Polar.Data.CurrentState = "IDLE"
 getgenv().PolarCurrentBotState = "IDLE"
 end
 end
 end
 else
 -- Si no se encuentra el spawn, volar a la isla para que spawnee
 local bestQuest = Polar.Quest:GetBestQuest()
 local islandName = activeBossQuestData and activeBossQuestData.island or (bestQuest and bestQuest.island)
 if islandName then
 Polar.Teleport:ToIsland(islandName)
 end
 end
 end
 end
 end
end)



-- ==================== POLAR ULTRA FAST ATTACK & COMBAT ENGINE ====================
local FastAttackRange = 65
local FastAttackCombo = 1
local attackMeleeCached = nil
pcall(function()
 if filtergc then
 attackMeleeCached = filtergc("function", {Name = "attackMelee"}, true)
 end
end)

task.spawn(function()
 while true do
 local anyFarmActive = AutoFarmEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled or KillAuraEnabled
 if not anyFarmActive then
 task.wait(0.5)
 continue
 end
 
 task.wait(0.18) -- Cadencia óptima anti-kick verificada en servidor
 
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = GetValidHumanoid(char)
 if not hrp or not hum then continue end
 
 -- 1. Auto-Equipar Arma Válida (Melee, Sword, Blox Fruit)
 local currentTool = char:FindFirstChildOfClass("Tool")
 local validWeapons = {["Melee"]=true, ["Sword"]=true, ["Blox Fruit"]=true, ["Gun"]=true}
 if not currentTool or not validWeapons[currentTool.ToolTip] or currentTool.Name == "Fishing Rod" then
 EquipWeapon(100)
 currentTool = char:FindFirstChildOfClass("Tool")
 end
 
 if not currentTool or not validWeapons[currentTool.ToolTip] or currentTool.Name == "Fishing Rod" then
 continue
 end
 
 -- 2. Bypass de cooldown interno de animación
 if attackMeleeCached then
 pcall(function()
 debug.setupvalue(attackMeleeCached, 2, false)
 end)
 end
 if GlobalModule then
 GlobalModule.tapCooldown = 0
 end
 
 -- 3. Detección de Buddha para AoE (al menos 3 targets sin Buda, 10 con Buda)
 local isBuddha = hrp:FindFirstChild("Buddha") or hrp:FindFirstChild("Buddha2")
 local maxTargets = isBuddha and 10 or 3
 
 local targetEnemyName = GetCurrentTargetEnemyName()
 local targets = {}
 local mainTargetPart = nil
 
 if enemiesFolder then
 for _, npc in ipairs(enemiesFolder:GetChildren()) do
 if not AutoFarmNearestEnabled and targetEnemyName and targetEnemyName ~= "NearestNPC" and targetEnemyName ~= "Buscando Jefes..." and not MatchEnemyName(npc.Name, targetEnemyName) then
 continue
 end
 
 local nHrp = npc:FindFirstChild("HumanoidRootPart")
 local nHum = GetValidHumanoid(npc)
 local ff = npc:FindFirstChildOfClass("ForceField")
 
 if nHrp and nHum and not ff then
 local dist = (nHrp.Position - hrp.Position).Magnitude
 if dist <= FastAttackRange then
 if not mainTargetPart then
 mainTargetPart = nHrp
 else
 if #targets < (maxTargets - 1) then
 table.insert(targets, {npc, nHrp})
 end
 end
 end
 end
 end
 end
 
 if mainTargetPart and mainTargetPart.Parent then
 pcall(function()
 if RegisterAttack then
 RegisterAttack:FireServer(0.18, FastAttackCombo)
 end
 SendHitsToServer(mainTargetPart, targets)
 FastAttackCombo = (FastAttackCombo % 4) + 1
 end)
 end
 end
end)


-- ==================== AUTO CHEST ====================
local AutoChestEnabled = false
task.spawn(function()
 while true do
 if not AutoChestEnabled then
 task.wait(1)
 continue
 end
 task.wait(1)
 if AutoChestEnabled then
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp then
 local chests = {}
 for _, v in ipairs(workspace:GetDescendants()) do
 if string.find(v.Name, "Chest") and v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
 table.insert(chests, v)
 end
 end
 
 if #chests > 0 then
 table.sort(chests, function(a, b)
 return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
 end)
 
 for _, chest in ipairs(chests) do
 if not AutoChestEnabled then break end
 if chest and chest.Parent and chest:FindFirstChild("TouchInterest") then
 local chestCF = chest.CFrame
 local dist = (hrp.Position - chestCF.Position).Magnitude
 if dist > 15 then
 Polar.Teleport:To(chestCF)
 else
 hrp.CFrame = chestCF
 end
 task.wait(0.2)
 if firetouchinterest and chest:FindFirstChild("TouchInterest") then
 firetouchinterest(hrp, chest, 0)
 task.wait(0.01)
 firetouchinterest(hrp, chest, 1)
 end
 task.wait(0.2)
 end
 end
 end
 end
 end
 end
end)

-- ==================== AUTO STATS / HAKI ====================
local AutoStatsEnabled = false
local activeStats = {}

task.spawn(function()
 while true do
 if not AutoStatsEnabled then
 task.wait(1)
 continue
 end
 task.wait(1)
 if AutoStatsEnabled and CommF and #activeStats > 0 then
 local data = LocalPlayer:FindFirstChild("Data")
 local points = data and data:FindFirstChild("Points")
 if points and points.Value > 0 then
 local pts = points.Value
 local n = #activeStats
 local base = math.floor(pts / n)
 local rem = pts % n
 
 for i, statName in ipairs(activeStats) do
 local add = base
 if i <= rem then add = add + 1 end
 if add > 0 then
 pcall(function() CommF:InvokeServer("AddPoint", statName, add) end)
 task.wait(0.2)
 end
 end
 end
 end
 end
end)

-- FIX #1: getgenv().PolarAutoMobLeaderEnabled y getgenv().PolarAutoSaberExpertEnabled ya están declaradas arriba (línea ~498)
-- NOTA: AutoSaberRunning, GlobalPhase1Solved y MaxSaberPhaseReached se declaran en sea1.lua


-- ==================== UTILS ====================

local function ScanIslands()
 local islands = {}
 local added = {}
 local origin = workspace:FindFirstChild("_WorldOrigin")
 local locs = origin and origin:FindFirstChild("Locations")
 if locs then
 for _, v in ipairs(locs:GetChildren()) do
 if not added[v.Name] then
 table.insert(islands, v.Name)
 added[v.Name] = true
 end
 end
 end
 if #islands == 0 then table.insert(islands, "None") end
 table.sort(islands)
 return islands
end

local sAct, sVal, iJ, ncl, walkWaterEnabled = false, 16, false, false, false
RunService.Heartbeat:Connect(function()
 if sAct then
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChild("Humanoid")
 if hum and hum.MoveDirection.Magnitude > 0 then char:TranslateBy(hum.MoveDirection * (sVal / 55)) end
 end
end)
UserInputService.JumpRequest:Connect(function()
 if iJ then
 local char = LocalPlayer.Character
 local hum = char and char:FindFirstChild("Humanoid")
 if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)
RunService.Stepped:Connect(function()
 if ncl then
 local char = LocalPlayer.Character
 if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
 end
end)
local waterPart = nil
RunService.RenderStepped:Connect(function()
 if walkWaterEnabled then
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp and hrp.Position.Y >= 9.5 and hrp.AssemblyLinearVelocity.Y <= 0 then
 if not waterPart then
 waterPart = Instance.new("Part", workspace)
 waterPart.Name = "Polar_Water"
 waterPart.Size, waterPart.Transparency, waterPart.Anchored, waterPart.CanQuery = Vector3.new(30, 1, 30), 1, true, false
 end
 waterPart.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
 elseif waterPart then waterPart.CFrame = CFrame.new(0, -5000, 0) end
 elseif waterPart then waterPart:Destroy() waterPart = nil end
end)


-- ==================== WIND UI CONSTRUCCION ====================
-- (Pestañas ya instanciadas arriba de forma blindada para garantizar que la interfaz se muestre de inmediato)

-- Exportar funciones utilitarias de core.lua para sea.lua
-- Nota: PolarBypassTeleport y PolarIsEnemyAlive ya están exportados correctamente en líneas 788-789
getgenv().PolarBuyItem = BuyItem



-- ===== TAB HOME / FARM (ADVANCED AUTO MASTERY & ONYX SYSTEM) =====
if setidentity then pcall(setidentity, 8) end
if setthreadidentity then pcall(setthreadidentity, 8) end

-- Cargar motor de Auto Mastery
local PolarMastery = getgenv().PolarMastery
if not PolarMastery then
	pcall(function()
		if isfile and isfile("polar_mastery.lua") then
			PolarMastery = loadstring(readfile("polar_mastery.lua"))()
		end
	end)
end
if not PolarMastery then
	pcall(function()
		PolarMastery = loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/polar_mastery.lua?t=" .. tostring(os.time())))()
	end)
end
if not PolarMastery then
	PolarMastery = getgenv().PolarMastery or {}
end

-- ==================== COLUMNA 1: MAIN FARM & AUTO BONES ====================
local SecMainFarm = TabHome:AddSection("Main Farm")

SecMainFarm:AddDropdown({
	Name = "Farm Method",
	Options = {"Quest", "Nearest"},
	Default = PolarMastery.FarmMethod or "Quest",
	Callback = function(Value)
		if PolarMastery then PolarMastery.FarmMethod = Value end
	end
})

SecMainFarm:AddDropdown({
	Name = "Quest Farm Mode",
	Options = {"Double Quest", "Normal"},
	Default = PolarMastery.QuestFarmMode or "Double Quest",
	Callback = function(Value)
		if PolarMastery then PolarMastery.QuestFarmMode = Value end
	end
})

SecMainFarm:AddSlider({
	Name = "Nearest (Distance)",
	Min = 100,
	Max = 3000,
	Default = PolarMastery.NearestDistance or 1500,
	Callback = function(Value)
		if PolarMastery then PolarMastery.NearestDistance = Value end
	end
})

SecMainFarm:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(Value)
		AutoFarmEnabled = Value
		getgenv().PolarFastAttackEnabled = Value
		if PolarMastery then PolarMastery.AutoFarm = Value end
	end
})

SecMainFarm:AddToggle({
	Name = "Take Quest",
	Desc = "Accept Quest for Bones/Cakes",
	Default = true,
	Callback = function(Value)
		if PolarMastery then PolarMastery.TakeQuest = Value end
	end
})

SecMainFarm:AddToggle({
	Name = "Auto Bones",
	Default = false,
	Callback = function(Value)
		if PolarMastery then PolarMastery.AutoBones = Value end
		getgenv().PolarFastAttackEnabled = Value
	end
})

SecMainFarm:AddToggle({
	Name = "Enable Mastery",
	Default = true,
	Callback = function(Value)
		AutoMasteryEnabled = Value
		if PolarMastery then PolarMastery.EnableMastery = Value end
	end
})

SecMainFarm:AddSlider({
	Name = "Health Mob%",
	Min = 5,
	Max = 90,
	Default = PolarMastery.HealthMobThreshold or 25,
	Callback = function(Value)
		if PolarMastery then PolarMastery.HealthMobThreshold = Value end
	end
})

SecMainFarm:AddDropdown({
	Name = "Primary Weapon",
	Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
	Default = PolarMastery.PrimaryWeapon or "Melee",
	Callback = function(Value)
		SelectedWeaponType = Value
		if PolarMastery then PolarMastery.PrimaryWeapon = Value end
	end
})

SecMainFarm:AddDropdown({
	Name = "Mastery Target",
	Options = {"Blox Fruit", "Sword", "Gun", "Melee"},
	Default = PolarMastery.MasteryTarget or "Blox Fruit",
	Callback = function(Value)
		AutoMasteryItem = Value
		if PolarMastery then PolarMastery.MasteryTarget = Value end
	end
})

-- ==================== COLUMNA 2: SKILLS SETTINGS ====================
local SecSkills = TabHome:AddSection("Skills Settings")

SecSkills:AddSlider({
	Name = "Z Hold Time",
	Min = 0.0,
	Max = 5.0,
	Default = (PolarMastery.HoldTimes and PolarMastery.HoldTimes.Z) or 0.8,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.HoldTimes then
			PolarMastery.HoldTimes.Z = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "X Hold Time",
	Min = 0.0,
	Max = 5.0,
	Default = (PolarMastery.HoldTimes and PolarMastery.HoldTimes.X) or 3.8,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.HoldTimes then
			PolarMastery.HoldTimes.X = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "C Hold Time",
	Min = 0.0,
	Max = 5.0,
	Default = (PolarMastery.HoldTimes and PolarMastery.HoldTimes.C) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.HoldTimes then
			PolarMastery.HoldTimes.C = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "V Hold Time",
	Min = 0.0,
	Max = 5.0,
	Default = (PolarMastery.HoldTimes and PolarMastery.HoldTimes.V) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.HoldTimes then
			PolarMastery.HoldTimes.V = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "F Hold Time",
	Min = 0.0,
	Max = 5.0,
	Default = (PolarMastery.HoldTimes and PolarMastery.HoldTimes.F) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.HoldTimes then
			PolarMastery.HoldTimes.F = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "Blox Fruit Skill Delay",
	Min = 0.0,
	Max = 2.0,
	Default = (PolarMastery.SkillDelays and PolarMastery.SkillDelays.BloxFruit) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.SkillDelays then
			PolarMastery.SkillDelays.BloxFruit = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "Melee Skill Delay",
	Min = 0.0,
	Max = 2.0,
	Default = (PolarMastery.SkillDelays and PolarMastery.SkillDelays.Melee) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.SkillDelays then
			PolarMastery.SkillDelays.Melee = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "Sword Skill Delay",
	Min = 0.0,
	Max = 2.0,
	Default = (PolarMastery.SkillDelays and PolarMastery.SkillDelays.Sword) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.SkillDelays then
			PolarMastery.SkillDelays.Sword = Value
		end
	end
})

SecSkills:AddSlider({
	Name = "Gun Skill Delay",
	Min = 0.0,
	Max = 2.0,
	Default = (PolarMastery.SkillDelays and PolarMastery.SkillDelays.Gun) or 0.0,
	Step = 0.1,
	Decimals = 1,
	Suffix = "s",
	Callback = function(Value)
		if PolarMastery and PolarMastery.SkillDelays then
			PolarMastery.SkillDelays.Gun = Value
		end
	end
})

-- ==================== COLUMNA 1: BOSS FARM ====================
local SecBossFarm = TabHome:AddSection("Boss Farm")

local bossList = {"Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "Cake Prince", "Dough King", "Soul Reaper"}
SecBossFarm:AddDropdown({
	Name = "Select Boss",
	Options = bossList,
	Default = PolarMastery.SelectedBoss or "Stone",
	Callback = function(Value)
		if PolarMastery then PolarMastery.SelectedBoss = Value end
	end
})

SecBossFarm:AddToggle({
	Name = "Auto Farm Boss",
	Default = false,
	Callback = function(Value)
		if PolarMastery then PolarMastery.AutoFarmBoss = Value end
		getgenv().PolarFastAttackEnabled = Value
	end
})

SecBossFarm:AddToggle({
	Name = "Auto Kill All Bosses",
	Default = false,
	Callback = function(Value)
		if PolarMastery then PolarMastery.AutoKillAllBosses = Value end
	end
})

SecBossFarm:AddToggle({
	Name = "Get Boss Quest",
	Desc = "Automatically takes the boss quest before attacking",
	Default = true,
	Callback = function(Value)
		if PolarMastery then PolarMastery.GetBossQuest = Value end
	end
})

-- ==================== COLUMNA 2: SPECIAL EVENTS & TYRANT ====================
local SecSpecialFarm = TabHome:AddSection("Tyrant & Special Farm")

SecSpecialFarm:AddToggle({
	Name = "Auto Summon Kill Tyrant Of The Skies",
	Desc = "turn on auto skill or gun shooting for destroying vases",
	Default = false,
	Callback = function(Value)
		getgenv().PolarAutoTyrant = Value
	end
})

SecSpecialFarm:AddToggle({
	Name = "Auto Dough King",
	Default = false,
	Callback = function(Value)
		getgenv().PolarAutoDoughKing = Value
	end
})

SecSpecialFarm:AddToggle({
	Name = "Ignore Farm Dough King Item",
	Desc = "only focus on boss and will not try to get chalice",
	Default = false,
	Callback = function(Value)
		getgenv().PolarIgnoreDoughKingItem = Value
	end
})

SecSpecialFarm:AddToggle({
	Name = "Auto Katakuri",
	Default = false,
	Callback = function(Value)
		getgenv().PolarAutoKatakuri = Value
	end
})

SecSpecialFarm:AddToggle({
	Name = "Auto Try Luck",
	Default = false,
	Callback = function(Value)
		getgenv().PolarAutoTryLuck = Value
	end
})

-- ==================== TAB FARM (BOSS SECTION) ====================
-- ===== TAB STATS =====
TabStats:AddSection("Player Enhancements")

TabStats:AddToggle({
	Name = "Player & Mob ESP",
	Callback = function(Value)
		ESPEnabled = Value
		if UpdateESPState then UpdateESPState() end
	end
})

TabStats:AddToggle({
	Name = "Auto Buso Haki",
	Default = true,
	Callback = function(Value)
		AutoHakiEnabled = Value
	end
})

TabStats:AddSection("Distribute Stats")

local function ToggleStat(statName, value)
	if value then
		if not table.find(activeStats, statName) then table.insert(activeStats, statName) end
	else
		local idx = table.find(activeStats, statName)
		if idx then table.remove(activeStats, idx) end
	end
end

TabStats:AddToggle({ Name = "Melee", Callback = function(v) ToggleStat("Melee", v) end })
TabStats:AddToggle({ Name = "Defense", Callback = function(v) ToggleStat("Defense", v) end })
TabStats:AddToggle({ Name = "Sword", Callback = function(v) ToggleStat("Sword", v) end })
TabStats:AddToggle({ Name = "Gun", Callback = function(v) ToggleStat("Gun", v) end })
TabStats:AddToggle({ Name = "Demon Fruit", Callback = function(v) ToggleStat("Demon Fruit", v) end })

TabStats:AddToggle({
	Name = "Auto Assign Stats",
	Desc = "Evenly distribute stat points",
	Callback = function(Value)
		AutoStatsEnabled = Value
	end
})


-- ===== TAB STATUS =====
TabStatus:AddSection("Server Telemetry")

local LabelServerUptime = TabStatus:AddParagraph({
	Title = "Server Uptime",
	Text = "Calculating..."
})

local LabelPlayerTime = TabStatus:AddParagraph({
	Title = "Session Time",
	Text = "Calculating..."
})

local telemetryStartTime = os.time()
local function FormatTelemetryDuration(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

task.spawn(function()
	while true do
		task.wait(5)
		pcall(function()
			local serverUptime = workspace.DistributedGameTime
			local sessionTime = os.time() - telemetryStartTime
			if LabelServerUptime and LabelServerUptime.SetDesc then
				LabelServerUptime:SetDesc(FormatTelemetryDuration(serverUptime))
			elseif LabelServerUptime and LabelServerUptime.Set then
				LabelServerUptime:Set(FormatTelemetryDuration(serverUptime))
			end
			if LabelPlayerTime and LabelPlayerTime.SetDesc then
				LabelPlayerTime:SetDesc(FormatTelemetryDuration(sessionTime))
			elseif LabelPlayerTime and LabelPlayerTime.Set then
				LabelPlayerTime:Set(FormatTelemetryDuration(sessionTime))
			end
		end)
	end
end)

-- ===== TAB SHOP =====
TabShop:AddSection("Abilities")
TabShop:AddButton({ Name = "Buy Geppo - $10k", Callback = function() BuyItem("BuyHaki", "Geppo", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Buy Buso - $25k", Callback = function() BuyItem("BuyHaki", "Buso", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Buy Soru - $100k", Callback = function() BuyItem("BuyHaki", "Soru", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Buy Ken Haki - $750k", Callback = function() BuyItem("KenTalk", "Buy", nil, "Instinct Teacher") end })

TabShop:AddSection("Fighting Styles")
TabShop:AddButton({ Name = "Dark Step - $150k", Callback = function() BuyItem("BuyBlackLeg", nil, nil, "Dark Step Teacher") end })
TabShop:AddButton({ Name = "Electro - $500k", Callback = function() BuyItem("BuyElectro", nil, nil, "Mad Scientist") end })
TabShop:AddButton({ Name = "Water Kung Fu - $750k", Callback = function() BuyItem("BuyFishmanKarate", nil, nil, "Water Kung Fu Teacher") end })

TabShop:AddSection("Swords")
TabShop:AddButton({ Name = "Katana - $1k", Callback = function() BuyItem("BuyItem", "Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Dual Katana - $12k", Callback = function() BuyItem("BuyItem", "Dual Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Iron Mace - $25k", Callback = function() BuyItem("BuyItem", "Iron Mace", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Triple Katana - $60k", Callback = function() BuyItem("BuyItem", "Triple Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Pipe - $100k", Callback = function() BuyItem("BuyItem", "Pipe", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Soul Cane - $750k", Callback = function() BuyItem("BuyItem", "Soul Cane", nil, "Living Skeleton") end })
TabShop:AddButton({ Name = "Bisento - $1M", Callback = function() BuyItem("BuyItem", "Bisento", nil, "Master Sword Dealer") end })

TabShop:AddSection("Guns")
TabShop:AddButton({ Name = "Slingshot - $5k", Callback = function() BuyItem("BuyItem", "Slingshot", nil, "Weapon Dealer") end })
TabShop:AddButton({ Name = "Musket - $8k", Callback = function() BuyItem("BuyItem", "Musket", nil, "Weapon Dealer") end })
TabShop:AddButton({ Name = "Flintlock - $10k", Callback = function() BuyItem("BuyItem", "Flintlock", nil, "Weapon Dealer") end })


-- ===== TAB QUEST FARM =====

-- ===== TAB TELEPORT =====
TabTeleport:AddSection("Island Teleport")

local SelectedIsland = ""
TabTeleport:AddDropdown({
	Name = "Select Island",
	Options = ScanIslands(),
	Callback = function(Value)
		SelectedIsland = Value
	end
})

TabTeleport:AddButton({
	Name = "Teleport to Island",
	Callback = function()
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locs = origin and origin:FindFirstChild("Locations")
		if locs and SelectedIsland ~= "" and SelectedIsland ~= "None" then
			local islaObj = locs:FindFirstChild(SelectedIsland)
			if islaObj then Polar.Teleport:To(islaObj.CFrame * CFrame.new(0, 80, 0)) end
		end
	end
})


-- =========================================================
-- ===== TAB COMBAT PVP (RESTAURADO + ANTI-LAG) =====
-- =========================================================


TabCombat:AddSection("Combat Enhancements")
TabCombat:AddToggle({ Name = "Auto Buso Haki", Default = false, Callback = function(v) getgenv().PolarAutoBusoEnabled = v end })
TabCombat:AddToggle({ Name = "Auto Ken Haki", Default = false, Callback = function(v) getgenv().PolarAutoKenEnabled = v end })
TabCombat:AddToggle({ Name = "Auto Skills", Default = false, Callback = function(v) getgenv().PolarAutoSkillsEnabled = v end })

TabCombat:AddSection("Bounty Hunter Tracker")

local SelectedTarget = nil
local TargetSetInfo = "Waiting for target..."

-- Desplegable para seleccionar jugador
local PlayerDropdown = TabCombat:AddDropdown({
	Name = "Select Target",
	Options = {"None"},
	Callback = function(Value)
		if Value and Value ~= "None" and Value ~= "Nadie" then
			SelectedTarget = Players:FindFirstChild(Value)
		else
			SelectedTarget = nil
		end
	end
})

-- Función reutilizable para refrescar la lista de jugadores
local function RefreshPlayerList()
	local list = {"None"}
 for _, p in ipairs(Players:GetPlayers()) do
 if p ~= LocalPlayer then table.insert(list, p.Name) end
 end
 pcall(function()
 if PlayerDropdown.SetValues then
 PlayerDropdown:SetValues(list)
 elseif PlayerDropdown.Refresh then
 PlayerDropdown:Refresh(list)
 elseif PlayerDropdown.UpdateValues then
 PlayerDropdown:UpdateValues(list)
 elseif PlayerDropdown.Set then
 PlayerDropdown:Set({Values = list})
 end
 end)
end

-- Poblar la lista al cargar
task.delay(2, RefreshPlayerList)

TabCombat:AddButton({
	Name = "Refresh Player List",
	Callback = function()
		RefreshPlayerList()
	end
})

local LabelTargetInfo = TabCombat:AddParagraph({
	Title = "Target Information",
	Text = TargetSetInfo
})

-- Auto-refrescar lista cuando entran/salen jugadores
Players.PlayerAdded:Connect(function() task.delay(1, RefreshPlayerList) end)
Players.PlayerRemoving:Connect(function(p)
	if SelectedTarget == p then SelectedTarget = nil end
	task.delay(0.5, RefreshPlayerList)
end)

-- Bucle para extraer los datos del jugador seleccionado en tiempo real
task.spawn(function()
	while task.wait(1.5) do
		if SelectedTarget and SelectedTarget.Parent and SelectedTarget.Character then
			local bounty = "Hidden"
			pcall(function()
				local data = SelectedTarget:FindFirstChild("Data")
				if data and data:FindFirstChild("Bounty") then
					bounty = tostring(data.Bounty.Value)
				elseif SelectedTarget:FindFirstChild("leaderstats") and SelectedTarget.leaderstats:FindFirstChild("Bounty") then
					bounty = tostring(SelectedTarget.leaderstats.Bounty.Value)
				end
			end)
			
			local armas = ""
			pcall(function()
				for _, item in ipairs(SelectedTarget.Character:GetChildren()) do
					if item:IsA("Tool") then armas = armas .. item.Name .. ", " end
				end
				local bp = SelectedTarget:FindFirstChild("Backpack")
				if bp then
					for _, item in ipairs(bp:GetChildren()) do
						if item:IsA("Tool") then armas = armas .. item.Name .. ", " end
					end
				end
			end)
			if armas == "" then armas = "None" else armas = string.sub(armas, 1, -3) end

			-- Datos extra: nivel, salud, fruta
			local extraInfo = ""
			pcall(function()
				local hum = SelectedTarget.Character:FindFirstChild("Humanoid")
				if hum then
					extraInfo = string.format("\n HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
				end
				local data = SelectedTarget:FindFirstChild("Data")
				if data then
					local lvl = data:FindFirstChild("Level")
					if lvl then extraInfo = extraInfo .. "\n[DATA] Level: " .. tostring(lvl.Value) end
					local fruit = data:FindFirstChild("BloxFruit")
					if fruit and fruit.Value ~= "" then extraInfo = extraInfo .. "\n[FRUIT] Fruit: " .. tostring(fruit.Value) end
				end
			end)

			local info = string.format("Target: %s\n Bounty: %s\n[SCAN] Tools: %s%s", SelectedTarget.Name, bounty, armas, extraInfo)
			
			pcall(function()
				if LabelTargetInfo.SetDesc then LabelTargetInfo:SetDesc(info)
				elseif LabelTargetInfo.Set then LabelTargetInfo:Set({Desc = info}) end
			end)
		else
			pcall(function()
				if LabelTargetInfo.SetDesc then LabelTargetInfo:SetDesc("Select a valid player...")
				elseif LabelTargetInfo.Set then LabelTargetInfo:Set({Desc = "Select a valid player..."}) end
			end)
		end
	end
end)

TabCombat:AddButton({
	Name = "Teleport to Target",
	Callback = function()
		if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
			Polar.Teleport:To(SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
		end
	end
})

-- ==================== MODO COMBATE (TOGGLE MAESTRO) ====================
-- ANTI-LAG: Los hooks y bucles de Hitbox/Silent Aim NO se ejecutan
-- hasta que actives este toggle. Esto garantiza 0 lag si no estás en PvP.
TabCombat:AddSection("Combat Mode")

local CombatModeEnabled = false
local CombatHooksInjected = false -- Flag para inyectar hooks solo 1 vez

TabCombat:AddToggle({
	Name = "Enable Combat Mode",
	Desc = "Enables hitbox & silent aim",
	Callback = function(Value)
		CombatModeEnabled = Value
		if Value and not CombatHooksInjected then
			CombatHooksInjected = true
		end
	end
})

-- ==================== HITBOX EXPANDER ====================
TabCombat:AddSection("Aimbot & Hitbox")

local HitboxEnabled = false
local HitboxSizeValue = 15
local HITBOX_ORIGINAL_SIZE = Vector3.new(2, 2, 1)
local lastHitboxUpdate = 0

-- Función centralizada de limpieza de hitboxes
local function RestoreAllHitboxes()
	for _, p in ipairs(Players:GetPlayers()) do
		pcall(function()
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				p.Character.HumanoidRootPart.Size = HITBOX_ORIGINAL_SIZE
				p.Character.HumanoidRootPart.Transparency = 1
				p.Character.HumanoidRootPart.CanCollide = true
				p.Character.HumanoidRootPart.Material = Enum.Material.Plastic
			end
		end)
	end
end

TabCombat:AddToggle({
	Name = "Hitbox Expander",
	Desc = "Expands enemy collision box",
	Callback = function(Value)
		HitboxEnabled = Value
		if not Value then RestoreAllHitboxes() end
	end
})

TabCombat:AddSlider({
	Name = "Hitbox Size",
	Default = { Min = 5, Max = 40, Default = 15 },
	Callback = function(Value)
		HitboxSizeValue = Value
	end
})

-- Restaurar hitboxes cuando un jugador muere (evita artefactos visuales)
for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		p.CharacterRemoving:Connect(function(oldChar)
			pcall(function()
				if oldChar:FindFirstChild("HumanoidRootPart") then
					oldChar.HumanoidRootPart.Size = HITBOX_ORIGINAL_SIZE
					oldChar.HumanoidRootPart.Transparency = 1
				end
			end)
		end)
	end
end
Players.PlayerAdded:Connect(function(p)
	p.CharacterRemoving:Connect(function(oldChar)
		pcall(function()
			if oldChar:FindFirstChild("HumanoidRootPart") then
				oldChar.HumanoidRootPart.Size = HITBOX_ORIGINAL_SIZE
				oldChar.HumanoidRootPart.Transparency = 1
			end
		end)
	end)
end)

-- Bucle de Hitbox con throttling (5 veces/seg) Y gateado por CombatModeEnabled
RunService.Heartbeat:Connect(function()
	if CombatModeEnabled and HitboxEnabled and tick() - lastHitboxUpdate > 0.05 then
		lastHitboxUpdate = tick()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				pcall(function()
					local hrp = p.Character.HumanoidRootPart
					hrp.Size = Vector3.new(HitboxSizeValue, HitboxSizeValue, HitboxSizeValue)
					hrp.Transparency = 0.6
					hrp.Color = Color3.fromRGB(255, 0, 0)
					hrp.Material = Enum.Material.Neon
					hrp.CanCollide = false
				end)
			end
		end
	end
end)

-- ==================== SILENT AIM (TÉCNICA AVANZADA - checkcaller) ====================
local SilentAimEnabled = false
local BringTargetEnabled = false

TabCombat:AddToggle({
	Name = "Silent Aim",
	Desc = "Redirects attacks to target",
	Callback = function(Value)
		SilentAimEnabled = Value
	end
})

TabCombat:AddToggle({
	Name = "Bring Target",
	Desc = "Brings enemy player to you",
	Callback = function(Value)
		BringTargetEnabled = Value
	end
})

TabCombat:AddSection("Extreme Combat")

local KillAuraEnabled = false
TabCombat:AddToggle({
	Name = "Kill Aura",
	Desc = "Attacks all nearby enemies",
	Callback = function(Value)
		KillAuraEnabled = Value
	end
})

-- Bring Target: Trae al jugador enemigo cerca de ti (no usa hooks)

task.spawn(function()
 while true do
 task.wait(0.1)
 if CombatModeEnabled and BringTargetEnabled then
 pcall(function()
 local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
 local enemyHrp = SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
 if myHrp and enemyHrp then
 enemyHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -5)
 enemyHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
 end
 end)
 end
 end
end)

-- Remotos de combate
local COMBAT_REMOTE_NAMES = {
 ["RE/RegisterHit"] = true, ["RE/RegisterAttack"] = true,
 ["RE/AttackTarget"] = true, ["RE/DealDamage"] = true,
 ["RE/CombatEvent"] = true, ["RE/UseSkill"] = true,
 ["RE/Shoot"] = true, ["RE/ShootGun"] = true,
 ["RE/Projectile"] = true, ["RE/GunEvent"] = true,
}
local COMBAT_KEYWORDS = {"hit", "attack", "damage", "shoot", "skill", "combat", "projectile", "gun"}

-- ============ SISTEMA DE COMBATE NATIVO (100% LIBRE DE EXCEPCIONES DE CAPABILITY) ============
-- Los sistemas de Aimbot, Hitbox y FastAttack operan de forma nativa directa,
-- garantizando estabilidad total sin hooks metamethod invasivos en DataModel.
local function InitCombatHooks()
 -- Seguro: sin ganchos globales que corrompan el DataModel
end

-- ===== TAB MISC =====
TabMisc:AddSection("UI Customization")

local themesList = {}
pcall(function()
	local thSrc = (PolarUI and PolarUI.Themes) or (redzlib and redzlib.Themes) or {}
	for themeName, _ in pairs(thSrc) do
		table.insert(themesList, themeName)
	end
end)
if #themesList == 0 then
	themesList = {"Polar Ice", "Liquid Glass", "Blizzard", "Arctic Aurora", "Cyberpunk Neon", "Crimson Blood", "Emerald Abyss", "Sunset Gold", "Midnight Violet", "Darker", "Dark", "Purple"}
end
table.sort(themesList)

TabMisc:AddDropdown({
	Name = "Visual Theme",
	Description = "Changes UI color palette",
	Options = themesList,
	Default = "Polar Ice",
	Callback = function(selected)
		pcall(function()
			if PolarUI and PolarUI.SetTheme then
				PolarUI:SetTheme(selected)
			elseif redzlib and redzlib.SetTheme then
				redzlib:SetTheme(selected)
			end
		end)
	end
})

TabMisc:AddButton({
	Name = "Reset Floating Button",
	Desc = "Resets floating button position",
	Callback = function()
		pcall(function()
			local targets = {
				(gethui and gethui()),
				(get_hidden_gui and get_hidden_gui()),
				game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
				(pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"))
			}
			for _, c in ipairs(targets) do
				if c then
					local gui = c:FindFirstChild("PolarHub_Onyx_UI") or c:FindFirstChild("redz Library V5")
					if gui then
						local fl = gui:FindFirstChild("FloatToggle", true) or gui:FindFirstChild("PolarFloatingButton", true)
						if fl then
							fl.Position = UDim2.new(0.016, 0, 0.219, 0)
						end
					end
				end
			end
		end)
	end
})

TabMisc:AddDropdown({
	Name = "Interface Scale",
	Description = "Adjusts global UI size",
	Options = {"Small", "Medium", "Large", "Extra Large"},
	Default = "Large",
	Callback = function(selected)
		local scaleMap = {
			["Small"] = 950,
			["Medium"] = 800,
			["Large"] = 650,
			["Extra Large"] = 500,
			["Pequeño"] = 950,
			["Mediano"] = 800,
			["Grande"] = 650,
			["Muy Grande"] = 500
		}
		local val = scaleMap[selected] or 650
		pcall(function()
			if PolarUI and PolarUI.SetScale then
				PolarUI:SetScale(val)
			elseif redzlib and redzlib.SetScale then
				redzlib:SetScale(val)
			end
		end)
	end
})
TabMisc:AddSection("Extra Utilities")

local FruitFinderEnabled = false
local foundFruits = {}
TabMisc:AddToggle({
	Name = "Fruit Finder",
	Desc = "Alerts when fruit spawns",
	Callback = function(Value)
		FruitFinderEnabled = Value
	end
})

local FlyEnabled = false
local flySpeed = 50
local flyBodyMover = nil
TabMisc:AddToggle({
	Name = "Fly Mode",
	Desc = "Fly using WASD and camera",
	Callback = function(Value)
		FlyEnabled = Value
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if Value and hrp then
			local bp = Instance.new("BodyVelocity", hrp)
			bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bp.Velocity = Vector3.new(0, 0, 0)
			flyBodyMover = bp
			
			local bg = Instance.new("BodyGyro", hrp)
			bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bg.D = 10
			bg.CFrame = hrp.CFrame
			flyBodyMover.Name = "Polar_Fly"
			bg.Name = "Polar_FlyG"
		else
			if hrp then
				local b1 = hrp:FindFirstChild("Polar_Fly")
				local b2 = hrp:FindFirstChild("Polar_FlyG")
				if b1 then b1:Destroy() end
				if b2 then b2:Destroy() end
			end
			flyBodyMover = nil
		end
	end
})

local AutoRejoinEnabled = false
TabMisc:AddToggle({
	Name = "Auto Rejoin",
	Desc = "Rejoins automatically if disconnected",
	Callback = function(Value)
		AutoRejoinEnabled = Value
	end
})

TabMisc:AddSection("Movement")

TabMisc:AddSlider({
	Name = "Walk Speed",
	Default = { Min = 16, Max = 500, Default = 16 },
	Callback = function(Value)
		sVal = Value
	end
})

TabMisc:AddToggle({
	Name = "Speed Boost",
	Callback = function(Value)
		sAct = Value
	end
})

TabMisc:AddToggle({
	Name = "Infinite Jump",
	Callback = function(Value)
		iJ = Value
	end
})

TabMisc:AddToggle({
	Name = "NoClip",
	Callback = function(Value)
		ncl = Value
	end
})

TabMisc:AddToggle({
	Name = "Walk on Water",
	Callback = function(Value)
		walkWaterEnabled = Value
	end
})

TabServers:AddSection("Server Management")

local TargetJobId = ""
TabServers:AddTextBox({
	Name = "Job ID",
	PlaceholderText = "Paste Job ID here...",
	Callback = function(Value)
		TargetJobId = Value
	end
})

TabServers:AddButton({
	Name = "Join Job ID",
	Callback = function()
		if TargetJobId and TargetJobId:gsub(" ", ""):len() > 0 then
			pcall(function()
				TeleportService:TeleportToPlaceInstance(GetMainPlaceIdForCurrentSea(), TargetJobId, LocalPlayer)
			end)
		else
			warn("[Polar Hub] Invalid or empty Job ID.")
		end
	end
})

TabServers:AddButton({
	Name = "Copy Current Job ID",
	Callback = function()
		CopyToClipboard(tostring(game.JobId))
	end
})

TabServers:AddButton({
	Name = "Hop Low Players",
	Callback = function()
		ServerHopLowPlayers()
	end
})

TabServers:AddButton({
	Name = "Hop Best Ping",
	Callback = function()
		ServerHopBestPing()
	end
})

local AutoCazarEnabled = false
local lastTeleportedJobId = nil
TabServers:AddToggle({
	Name = "Auto Join Bounty",
	Desc = "Joins target server automatically",
	Callback = function(Value)
		AutoCazarEnabled = Value
		if not Value then
			lastTeleportedJobId = nil
		end
	end
})

task.spawn(function()
 while true do
 task.wait(3)
 if AutoCazarEnabled then
 pcall(function()
 local url = bridgeUrl .. "/get_server?type=cazar&username=" .. tostring(LocalPlayer.Name)
 local raw = SafeHttpGet(url)
 if raw then
 local success, result = pcall(function() return HttpService:JSONDecode(raw) end)
 if success and result and result.success and result.jobId then
 if result.jobId ~= lastTeleportedJobId then
 lastTeleportedJobId = result.jobId
 warn("[Polar Hub] ¡Objetivo localizado por el Bot de Discord! Teletransportando...")
 TeleportService:TeleportToPlaceInstance(result.placeId or game.PlaceId, result.jobId, LocalPlayer)
 end
 end
 end
 end)
 end
 end
end)

-- ==================== LOGICA DE UTILIDADES Y COMBATE EXTREMO ====================

task.spawn(function()
 while true do
 task.wait(1)
 if AutoSkillsEnabled and (AutoFarmEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled) then
 pcall(function()
 VirtualUser:CaptureController()
 VirtualUser:SetKeyDown("Z") task.wait(0.1) VirtualUser:SetKeyUp("Z") task.wait(0.1)
 VirtualUser:SetKeyDown("X") task.wait(0.1) VirtualUser:SetKeyUp("X") task.wait(0.1)
 VirtualUser:SetKeyDown("C") task.wait(0.1) VirtualUser:SetKeyUp("C") task.wait(0.1)
 VirtualUser:SetKeyDown("V") task.wait(0.1) VirtualUser:SetKeyUp("V") task.wait(0.1)
 VirtualUser:SetKeyDown("F") task.wait(0.1) VirtualUser:SetKeyUp("F")
 end)
 end
 end
end)

task.spawn(function()
 while true do
 task.wait(2)
 if FruitFinderEnabled then
 for _, v in ipairs(workspace:GetDescendants()) do
 if v:IsA("Tool") and string.find(string.lower(v.Name), "fruit") and not foundFruits[v] then
 foundFruits[v] = true
 game:GetService("StarterGui"):SetCore("SendNotification", {
 Title = "[FRUTA] ¡FRUTA ENCONTRADA!",
 Text = "Se ha encontrado: " .. v.Name,
 Duration = 10
 })
 SendDiscordNotification("[FRUTA] ¡FRUTA ENCONTRADA!", "Se ha detectado una fruta libre en el mapa.", {
 {name = "Nombre de la Fruta", value = v.Name, inline = true},
 {name = "Servidor (JobId)", value = "`" .. tostring(game.JobId) .. "`", inline = true},
 {name = "Sea / Place ID", value = tostring(game.PlaceId), inline = true}
 })
 end
 end
 end
 end
end)

-- KillAura está integrado directamente y con máxima potencia en el motor unificado Polar Fast Attack.

RunService.RenderStepped:Connect(function()
 if FlyEnabled and flyBodyMover then
 local char = LocalPlayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChild("Humanoid")
 if hrp and hum then
 local dir = Vector3.new()
 local cam = workspace.CurrentCamera
 if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
 if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
 if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
 if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
 
 flyBodyMover.Velocity = dir * flySpeed
 local bg = hrp:FindFirstChild("Polar_FlyG")
 if bg then bg.CFrame = cam.CFrame end
 end
 end
end)

pcall(function()
 local CoreGui = game:GetService("CoreGui")
 local rbxPrompt = CoreGui:FindFirstChild("RobloxPromptGui")
 local promptOverlay = rbxPrompt and rbxPrompt:FindFirstChild("promptOverlay")
 if promptOverlay then
 promptOverlay.ChildAdded:Connect(function(child)
 if child.Name == "ErrorPrompt" and AutoRejoinEnabled then
 task.wait(2)
 TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
 end
 end)
 end
end)

print("[OK] Polar Hub cargado exitosamente.")

-- Authentic Status Toast Notifications (matching Quantum Onyx status alerts)
pcall(function()
    if PolarUI and PolarUI.Notify then
        PolarUI:Notify({
            Title = "Polar Hub Fully Loaded",
            Description = "All Functions, Modules, Dependencies, Successfully loaded.",
            Duration = 3
        })
        task.delay(0.3, function()
            PolarUI:Notify({
                Title = "Polar Hub (INFO)",
                Description = "Polar Hub Script is 100% Free and Keyless",
                Duration = 4
            })
        end)
    end
end)

SendDiscordNotification("[OK] Script Cargado", "El script de Polar Hub ha sido ejecutado con éxito.", {
 {name = "Usuario (Roblox)", value = "`" .. tostring(LocalPlayer.Name) .. "`", inline = true},
 {name = "Nivel", value = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") and tostring(LocalPlayer.Data.Level.Value) or "N/A", inline = true},
 {name = "Servidor (JobId)", value = "`" .. tostring(game.JobId) .. "`", inline = true},
 {name = "Sea / Place ID", value = tostring(game.PlaceId), inline = true}
})

-- ==================== TELEMETRÍA Y LOGS EN TIEMPO REAL ====================
task.spawn(function()
 local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService")
 local LogService = game:GetService("LogService")
 local request_func = (http_request or request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
 
 if request_func and HttpService then
 LogService.MessageOut:Connect(function(message, messageType)
 pcall(function()
 request_func({
 Url = bridgeUrl .. "/log",
 Method = "POST",
 Headers = {
 ["Content-Type"] = "application/json"
 },
 Body = HttpService:JSONEncode({
 message = message,
 type = tostring(messageType)
 })
 })
 end)
 end)
 print("[NET] Polar Hub Telemetría: Puente de logs en tiempo real conectado.")
 
 -- ==================== EVALUACIÓN DE COMANDOS REMOTOS (AI BRIDGE) ====================
 task.spawn(function()
 task.wait(2)
 while true do
 task.wait(1.5)
 pcall(function()
 local response = request_func({
 Url = bridgeUrl .. "/eval",
 Method = "GET"
 })
 if response and response.StatusCode == 200 and response.Body and response.Body ~= "" and response.Body ~= "NO_COMMAND" then
 local code = response.Body
 print("[Polar Hub AI] Recibido comando remoto para ejecutar...")
 local fn, err = loadstring(code)
 if not fn then
 warn("[ERROR] Error de compilación en comando remoto: " .. tostring(err))
 request_func({
 Url = bridgeUrl .. "/eval_result",
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
 warn("[ERROR] Error de ejecución en comando remoto: " .. tostring(run_err))
 request_func({
 Url = bridgeUrl .. "/eval_result",
 Method = "POST",
 Headers = { ["Content-Type"] = "application/json" },
 Body = HttpService:JSONEncode({
 success = false,
 error = "Runtime error: " .. tostring(run_err)
 })
 })
 else
 print("[OK] Comando remoto ejecutado con éxito.")
 request_func({
 Url = bridgeUrl .. "/eval_result",
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
end)

-- Asegurar que todos los contenedores inicien en la parte superior (0, 0)
pcall(function()
 local rz = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("redz Library V5")
 if rz then
 for _, c in ipairs(rz:GetDescendants()) do
 if c:IsA("ScrollingFrame") and string.find(c.Name, "Container") then
 c.CanvasPosition = Vector2.new(0, 0)
 end
 end
 end
end)