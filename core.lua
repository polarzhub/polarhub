-- Polar HUB | loadstring ready
-- Subir a GitHub como archivo raw y usar este comando en tu ejecutor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/main.lua"))()

-- Esperar a que el juego cargue completamente antes de inyectar
repeat task.wait() until game:IsLoaded()

-- ==================== REDZ UI LIBRARY ====================
local success, redzlib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/main/redzlibV5.lua"))()
end)

if not success or not redzlib then
    warn("Error: No se pudo cargar RedzLib V5.")
    return
end

local Window = redzlib:MakeWindow({
    Name = "❄️ POLAR HUB",
    SubTitle = "by polar",
    SaveFolder = "PolarHubConfig.json"
})
pcall(function()
    redzlib:SetScale(650) -- Escala por defecto "Grande" optimizada
end)
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
            print("[Polar Hub] 🔍 Scanner: " .. #NPCsFolder:GetChildren() .. " NPCs mapeados desde workspace.NPCs")
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
            print("[Polar Hub] ⚔️ Scanner: Tipos de enemigos activos -> " .. table.concat(typeList, ", "))
        end
    end)
    
    -- SCANNER 3: Escanear CommF_ para verificar que el remoto de misiones existe
    pcall(function()
        local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if Remotes then
            local CommF = Remotes:FindFirstChild("CommF_")
            if CommF then
                print("[Polar Hub] ✅ Scanner: CommF_ detectado y operativo")
            else
                warn("[Polar Hub] ⚠️ Scanner: CommF_ NO encontrado! Las misiones remotas no funcionarán.")
            end
        end
    end)
    
    -- SCANNER 4: Auto-detectar los quest strings correctos escaneando los datos del jugador
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            print("[Polar Hub] 📊 Scanner: Nivel del jugador = " .. tostring(data:FindFirstChild("Level") and data.Level.Value or "?"))
            
            -- Escanear si hay una misión activa en el PlayerGui
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
                if pgui.Main.Quest.Visible then
                    local title = pgui.Main.Quest:FindFirstChild("Container") and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
                    if title and title.Text then
                        print("[Polar Hub] 📋 Scanner: Misión activa detectada -> " .. title.Text)
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
            print("[Polar Hub] 👁️ Scanner: Vigilancia de NPCs en tiempo real ACTIVADA")
        end
    end)
end)

-- ==================== BLOX FRUITS REMOTES ====================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)
local Net = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit = Net and pcall(function() return Net["RE/RegisterHit"] end) and Net["RE/RegisterHit"]
local RegisterAttack = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]
local enemiesFolder = workspace:FindFirstChild("Enemies")

-- ==================== CORE PLATFORM FRAMEWORK (POLAR ENGINE) ====================
getgenv().Polar = {
    Data = {
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
}

-- Módulo de Jugador
Polar.Player = {}

function Polar.Player:GetLevel()
    local data = LocalPlayer:FindFirstChild("Data")
    return data and data:FindFirstChild("Level") and data.Level.Value or 1
end

-- Módulo de Teletransporte
Polar.Teleport = {}

local function MoveDirectly(targetCFrame)
    if typeof(targetCFrame) == "Vector3" then
        targetCFrame = CFrame.new(targetCFrame)
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    if dist < 95 then
        char:PivotTo(targetCFrame)
    else
        local bp = Instance.new("BodyVelocity", hrp)
        bp.Velocity = Vector3.new(0, 0, 0)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        local nclConn = RunService.Stepped:Connect(function()
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
        
        local tweenSpeed = 350
        
        local function DoTween(cframeTarget)
            local tDist = (hrp.Position - cframeTarget.Position).Magnitude
            if tDist < 5 then return end
            local tInfo = TweenInfo.new(tDist / tweenSpeed, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tInfo, {CFrame = cframeTarget})
            
            local startPos = hrp.Position
            local tpCheckConn = RunService.Stepped:Connect(function()
                if (hrp.Position - startPos).Magnitude > 3000 then
                    tween:Cancel()
                end
            end)
            
            tween:Play()
            tween.Completed:Wait()
            if tpCheckConn then tpCheckConn:Disconnect() end
        end
        
        if game.PlaceId == 4442272183 or (hrp.Position.Z > 25000 and targetCFrame.Position.Z > 25000) then
            -- En el Barco Maldito, volar recto (noclip atravesando paredes), nunca elevarse al techo porque hace daño
            DoTween(targetCFrame)
        else
            if dist > 200 or math.abs(hrp.Position.Y - targetCFrame.Y) > 100 then
                local safeY = math.max(hrp.Position.Y, targetCFrame.Y) + 300
                local p1 = CFrame.new(hrp.Position.X, safeY, hrp.Position.Z)
                local p2 = CFrame.new(targetCFrame.X, safeY, targetCFrame.Z)
                
                DoTween(p1)
                DoTween(p2)
                DoTween(targetCFrame)
            else
                DoTween(targetCFrame)
            end
        end
        
        bp:Destroy()
        nclConn:Disconnect()
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
            ["ice castle"] = Vector3.new(785, 142, 608),
            ["forgotten island"] = Vector3.new(-2544, 256, -429)
        }
        pos = fallbacks[string.lower(islandName)]
    end
    
    if pos then
        print("[Polar Hub] 🚀 Volando hacia isla: " .. islandName)
        Polar.Teleport:To(CFrame.new(pos.X, pos.Y + 250, pos.Z))
        task.wait(1.5) -- Pausa para que carguen los assets (streaming enabled bypass)
    end
end

-- Módulo del Mundo
Polar.World = {}

function Polar.World:FindNPC(npcName)
    if not npcName or npcName == "" then return nil end
    local cached = Polar.Data.NPCCache[npcName]
    if cached then
        if typeof(cached) == "table" or type(cached) == "table" then
            return cached[1]
        end
        return cached
    end
    
    -- Buscar en NPCs folder
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        local npc = npcs:FindFirstChild(npcName)
        if npc then
            local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
            if part then
                Polar.Data.NPCCache[npcName] = part.CFrame
                return part.CFrame
            end
        end
    end
    
    -- Buscar globalmente
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(string.lower(v.Name), string.lower(npcName)) then
            local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")
            if part then
                Polar.Data.NPCCache[npcName] = part.CFrame
                return part.CFrame
            end
        end
    end
    return nil
end

local FallbackPositions = {
    ["Rear Crew Quest Giver"] = Vector3.new(923, 126, 32852),
    ["Front Crew Quest Giver"] = Vector3.new(920, 125, 33000),
    ["Ship Deckhand"] = Vector3.new(920, 125, 32900),
    ["Ship Engineer"] = Vector3.new(920, 125, 32900),
    ["Ship Steward"] = Vector3.new(920, 125, 33000),
    ["Ship Officer"] = Vector3.new(920, 125, 33100),
    ["Cursed Captain"] = Vector3.new(920, 125, 33200),
}

function Polar.World:GetEnemySpawnPosition(enemyName)
    if not enemyName then return nil end
    if Polar.Data.SpawnCache[enemyName] then return Polar.Data.SpawnCache[enemyName] end
    
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local enemySpawns = worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
    
    if enemySpawns then
        local bestSpawn = nil
        local bestLenDiff = math.huge
        for _, spawnPart in ipairs(enemySpawns:GetChildren()) do
            if string.find(string.lower(spawnPart.Name), string.lower(enemyName)) then
                local diff = math.abs(#spawnPart.Name - #enemyName)
                if diff < bestLenDiff then
                    bestLenDiff = diff
                    bestSpawn = spawnPart.Position
                end
            end
        end
        if bestSpawn then
            Polar.Data.SpawnCache[enemyName] = bestSpawn
            return bestSpawn
        end
    end
    
    -- Usar posición hardcodeada de respaldo si no se encuentra en el mapa (útil bajo StreamingEnabled)
    local fallbackPos = FallbackPositions[enemyName]
    if fallbackPos then
        Polar.Data.SpawnCache[enemyName] = fallbackPos
        return fallbackPos
    end
    
    return nil
end

function Polar.World:IsEnemyAlive(enemyName)
    if enemiesFolder then
        for _, npc in ipairs(enemiesFolder:GetChildren()) do
            if string.find(string.lower(npc.Name), string.lower(enemyName)) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

-- Módulo de Misiones
Polar.Quest = {}

local QuestsTable = nil
function Polar.Quest:GetQuestsModule()
    if QuestsTable then return QuestsTable end
    local success, result = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Quests"))
    end)
    if success and result then
        QuestsTable = result
        return QuestsTable
    end
    return nil
end

function Polar.Quest:GetBestQuest()
    local level = Polar.Player:GetLevel()
    local quests = Polar.Quest:GetQuestsModule()
    local allowed = Polar.Data.AllowedQuests
    
    if not allowed or #allowed == 0 then return nil end
    
    local bestQuestName = nil
    local bestQuestIndex = 1
    local bestQuestData = nil
    local maxLevel = -1
    
    if quests then
        for _, qName in ipairs(allowed) do
            local qDataList = quests[qName]
            if qDataList then
                for index, qData in ipairs(qDataList) do
                    if qData.LevelReq and level >= qData.LevelReq and qData.LevelReq > maxLevel then
                        maxLevel = qData.LevelReq
                        bestQuestName = qName
                        bestQuestIndex = index
                        bestQuestData = qData
                    end
                end
            end
        end
    end
    
    -- Fallback si falla el modulo del juego
    if not bestQuestName then
        for _, qData in ipairs(Polar.Data.QuestInfo) do
            if level >= qData.lvl and qData.lvl > maxLevel then
                maxLevel = qData.lvl
                bestQuestName = qData.q
                bestQuestIndex = qData.ql
                bestQuestData = { Name = qData.name, LevelReq = qData.lvl }
            end
        end
    end
    
    if bestQuestName then
        return {
            qName = bestQuestName,
            index = bestQuestIndex,
            enemyName = bestQuestData and bestQuestData.Name or (Polar.Data.QuestInfo[1] and Polar.Data.QuestInfo[1].name),
            island = Polar.Data.QuestToIsland[bestQuestName] or ""
        }
    end
    return nil
end

function Polar.Quest:HasQuest()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
        if pgui.Main.Quest.Visible then
            local title = pgui.Main.Quest:FindFirstChild("Container") 
                and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") 
                and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
            if title and title.Text then
                if string.find(string.lower(title.Text), "completed") or string.find(string.lower(title.Text), "completada") then
                    return false
                end
                return true
            end
        end
    end
    return false
end

function Polar.Quest:GetTargetEnemyNameFromQuest()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
        if pgui.Main.Quest.Visible then
            local title = pgui.Main.Quest:FindFirstChild("Container") 
                and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") 
                and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
            if title and title.Text then
                local questText = title.Text
                local bestMatch = nil
                local bestLen = 0
                
                -- Buscar la coincidencia en nuestra base
                for _, qData in ipairs(Polar.Data.QuestInfo) do
                    if string.find(string.lower(questText), string.lower(qData.name)) then
                        if #qData.name > bestLen then
                            bestLen = #qData.name
                            bestMatch = qData.name
                        end
                    end
                end
                
                for _, bData in ipairs(Polar.Data.Bosses) do
                    if string.find(string.lower(questText), string.lower(bData.name)) then
                        if #bData.name > bestLen then
                            bestLen = #bData.name
                            bestMatch = bData.name
                        end
                    end
                end
                
                return bestMatch
            end
        end
    end
    return nil
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
    
    if not giverName then return nil end
    
    local cf = Polar.World:FindNPC(giverName)
    if cf then return cf end
    
    -- Usar posición de respaldo si el NPC aún no ha sido cargado/renderizado a lo lejos
    local fallbackPos = FallbackPositions[giverName]
    if fallbackPos then
        return CFrame.new(fallbackPos)
    end
    
    local islandName = Polar.Data.QuestToIsland[questName]
    if islandName then
        Polar.Teleport:ToIsland(islandName)
        cf = Polar.World:FindNPC(giverName)
        if cf then return cf end
    end
    return nil
end

-- Bypass Global de Distancia
local bypassHookInstalled = false
local function InstallGlobalBypass()
    if bypassHookInstalled then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and method == "DistanceFromCharacter" then
                return 0
            end
            return oldNamecall(self, ...)
        end)
        bypassHookInstalled = true
        print("[Polar Hub] ✅ Bypass Global de Distancia activo.")
    end)
end
InstallGlobalBypass()

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

local function ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and result and result.data then
        for _, v in ipairs(result.data) do
            if type(v) == "table" and v.playing and v.maxPlayers and v.playing < v.maxPlayers - 1 and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
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
                    local nHum = npc:FindFirstChild("Humanoid")
                    if nHrp and nHum and nHum.Health > 0 and nHrp.Position.Y > 0 then
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
                        getgenv().PolarCurrentBotState = "GETTING_QUEST"
                        QuestTryCount = 0
                        task.wait(0.4)
                        continue
                    end
                else
                    Polar.Data.CurrentState = "GETTING_QUEST"
                    getgenv().PolarCurrentBotState = "GETTING_QUEST"
                    QuestTryCount = 0
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
                        local nHum = npc:FindFirstChild("Humanoid")
                        if nHrp and nHum and nHum.Health > 0 and nHrp.Position.Y > 0 then
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
                targetCF = CFrame.new(targetCF.Position) -- Mantener estable
                
                plat.CFrame = targetCF
                if (hrp.Position - plat.Position).Magnitude > 15 then
                    Polar.Teleport:To(plat.CFrame * CFrame.new(0, 3.5, 0))
                end
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                -- Congelar enemigo principal
                local oHum = firstNPC:FindFirstChild("Humanoid")
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
                            local tHum = npc:FindFirstChild("Humanoid")
                            if tHrp and tHum and tHum.Health > 0 then
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
                        local nHum = npc:FindFirstChild("Humanoid")
                        if nHrp and nHum and nHum.Health > 0 and nHrp.Position.Y > 0 then
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



-- ==================== AUTO-CLICK COMBAT ENGINE (NIVEL ATERRADOR) ====================
-- Este motor GARANTIZA que el personaje ataque SIEMPRE cuando está en modo FARMING.
-- Funciona INDEPENDIENTE del Fast Attack. Simula clicks de ratón reales usando
-- VirtualInputManager (ejecutor lvl 8) para activar el combo de ataque del arma equipada.
-- También activa automáticamente el Fast Attack cuando el farm está encendido.
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    while true do
        task.wait(0.15)
        local anyFarmActive = AutoFarmEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled
        if anyFarmActive and getgenv().PolarCurrentBotState == "FARMING" then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if char and hrp and hum and hum.Health > 0 then
                -- Verificar que tiene un arma equipada (no fishing rod)
                local tool = char:FindFirstChildOfClass("Tool")
                local validWeapons = {["Melee"]=true, ["Sword"]=true, ["Blox Fruit"]=true, ["Gun"]=true}
                if tool and validWeapons[tool.ToolTip] and tool.Name ~= "Fishing Rod" then
                    -- MÉTODO 1: VirtualInputManager Mouse Click (simula click real del ratón)
                    pcall(function()
                        VIM:SendMouseButtonEvent(400, 400, 0, true, game, 1)
                        task.wait(0.05)
                        VIM:SendMouseButtonEvent(400, 400, 0, false, game, 1)
                    end)
                else
                    -- Si no tiene arma válida, equipar automáticamente
                    EquipWeapon(100)
                end
            end
        end
    end
end)

-- ==================== FAST ATTACK ANTI-KICK ====================
local FastAttackRange = 60
task.spawn(function()
    while true do
        -- AUTO-ACTIVACIÓN: Fast Attack se activa automáticamente cuando cualquier farm está encendido
        local anyFarmOn = AutoFarmEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or AutoFarmNearestEnabled
        local active = anyFarmOn -- Ya no depende de PolarFastAttackEnabled
        if not active then
            task.wait(1)
            continue
        end
        -- EXECUTOR HACK: Velocidad de Relámpago (0.05s)
        task.wait(0.05)
        if active and RegisterHit and RegisterAttack then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local targetEnemyName = GetCurrentTargetEnemyName()
            
            -- 1. Escanear salud para AutoMastery ANTES de hacer yield
            local minHealthPercent = nil
            if enemiesFolder and targetEnemyName then
                for _, npc in ipairs(enemiesFolder:GetChildren()) do
                    if not AutoFarmNearestEnabled and not MatchEnemyName(npc.Name, targetEnemyName) then continue end
                    local nHrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChild("Humanoid")
                    if nHrp and hum and hum.Health > 0 and (nHrp.Position - hrp.Position).Magnitude <= FastAttackRange then
                        local hPct = (hum.Health / hum.MaxHealth) * 100
                        if not minHealthPercent or hPct < minHealthPercent then minHealthPercent = hPct end
                    end
                end
            end
            
            -- 2. Equipar Arma (esto puede hacer un task.wait si necesita cambiar de arma)
            EquipWeapon(minHealthPercent)
            
            -- 3. Recopilar objetivos de forma SEGURA después del yield
            local targets = {}
            local mainTargetPart = nil
            
            if enemiesFolder and targetEnemyName then
                for _, npc in ipairs(enemiesFolder:GetChildren()) do
                    if not AutoFarmNearestEnabled and not MatchEnemyName(npc.Name, targetEnemyName) then continue end
                    
                    local nHrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChild("Humanoid")
                    local ff = npc:FindFirstChildOfClass("ForceField")
                    
                    -- Verificar firmemente que el objetivo existe y es válido
                    if nHrp and nHrp.Parent and hum and hum.Parent and hum.Health > 0 and not ff and (nHrp.Position - hrp.Position).Magnitude <= FastAttackRange then
                        local targetPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                        if targetPart and targetPart.Parent then
                            table.insert(targets, {npc, targetPart})
                            if not mainTargetPart then mainTargetPart = targetPart end
                            if #targets >= 8 then break end
                        end
                    end
                end
            end
            
            -- FIX ANTI-CHEAT: Jamás atacar con armas inválidas (como Fishing Rod) ni objetos destruidos
            local currentTool = char:FindFirstChildOfClass("Tool")
            local validWeapons = {["Melee"]=true, ["Sword"]=true, ["Blox Fruit"]=true, ["Gun"]=true}
            
            if currentTool and validWeapons[currentTool.ToolTip] and currentTool.Name ~= "Fishing Rod" and #targets > 0 and mainTargetPart and mainTargetPart.Parent then
                pcall(function()
                    -- EXECUTOR LEVEL 8 BARRAGE: Enviar Múltiples Paquetes en un solo tick
                    -- Esto clona tu daño y derrite a los enemigos al instante
                    for _ = 1, 5 do
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(mainTargetPart, targets)
                    end
                end)
            end
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
                                BypassTeleport(chestCF)
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
local AutoSaberRunning = false

local GlobalPhase1Solved = false
local MaxSaberPhaseReached = 1


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

local TabFarm = Window:MakeTab({ Title = "Farm", Icon = "swords" })
local TabStats = Window:MakeTab({ Title = "Stats", Icon = "user" })
local TabStatus = Window:MakeTab({ Title = "Status", Icon = "activity" })
local TabShop = Window:MakeTab({ Title = "Shop", Icon = "shopping-cart" })
local TabQuest = Window:MakeTab({ Title = "Quest Farm", Icon = "map" })
local TabTeleport = Window:MakeTab({ Title = "Teleport", Icon = "globe" })
local TabCombat = Window:MakeTab({ Title = "Combat PvP", Icon = "crosshair" })
local TabMisc = Window:MakeTab({ Title = "Misc", Icon = "settings" })

getgenv().PolarWindow = Window
getgenv().PolarTabFarm = TabFarm
getgenv().PolarTabStats = TabStats
getgenv().PolarTabStatus = TabStatus
getgenv().PolarTabShop = TabShop
getgenv().PolarTabQuest = TabQuest
getgenv().PolarTabTeleport = TabTeleport
getgenv().PolarTabCombat = TabCombat
getgenv().PolarTabMisc = TabMisc

-- Exportar funciones utilitarias de core.lua para sea.lua
getgenv().PolarBuyItem = BuyItem
getgenv().PolarBypassTeleport = BypassTeleport
getgenv().PolarIsEnemyAlive = IsEnemyAlive



-- ===== TAB FARM =====
TabFarm:AddSection("Configuración de Combate")

TabFarm:AddDropdown({
    Name = "Farm Tool (Arma)",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = "Melee",
    Callback = function(Value)
        SelectedWeaponType = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Mastery Inteligente",
    Desc = "Baja la vida con tu Farm Tool, y remata (cuando le quede < 20%) con el arma que elijas abajo.",
    Callback = function(Value)
        AutoMasteryEnabled = Value
    end
})

TabFarm:AddDropdown({
    Name = "Arma a Masterizar (Auto Mastery)",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = "Sword",
    Callback = function(Value)
        AutoMasteryItem = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Skills",
    Desc = "Usa las habilidades Z, X, C, V, F automáticamente mientras farmeas.",
    Callback = function(Value)
        AutoSkillsEnabled = Value
    end
})

TabFarm:AddSection("Auto Farm Automático")

TabFarm:AddToggle({
    Name = "Auto Farm Nivel (100% Automático)",
    Desc = "Detecta nivel, vuela a la isla, toma misión y ataca.",
    Callback = function(Value)
        AutoFarmEnabled = Value
        getgenv().PolarFastAttackEnabled = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Chest (Farm Beli)",
    Callback = function(Value)
        AutoChestEnabled = Value
    end
})

TabFarm:AddToggle({
    Name = "Auto Farm Nearest (Masacre Total)",
    Desc = "Ignora misiones y niveles. Aniquila al NPC más cercano en la isla actual. Exterminio masivo.",
    Callback = function(Value)
        AutoFarmNearestEnabled = Value
        getgenv().PolarFastAttackEnabled = Value
    end
})

-- ==================== TAB FARM (BOSS SECTION) ====================
-- ===== TAB STATS =====
TabStats:AddSection("Mejoras de Jugador")

TabStats:AddToggle({
    Name = "Player & NPC ESP",
    Callback = function(Value)
        ESPEnabled = Value
        UpdateESPState()
    end
})

TabStats:AddToggle({
    Name = "Auto Haki (Buso)",
    Default = true,
    Callback = function(Value)
        AutoHakiEnabled = Value
    end
})

TabStats:AddSection("Auto Stats Equitativo")

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
    Name = "Activar Auto Stats",
    Desc = "Divide tus puntos equitativamente.",
    Callback = function(Value)
        AutoStatsEnabled = Value
    end
})


-- ===== TAB STATUS =====
TabStatus:AddSection("Telemetría del Servidor")

local LabelServerUptime = TabStatus:AddParagraph({
    Title = "Tiempo de Vida del Servidor",
    Text = "Calculando..."
})

local LabelPlayerTime = TabStatus:AddParagraph({
    Title = "Tiempo en Sesión (Jugador)",
    Text = "Calculando..."
})

-- ===== TAB SHOP =====
TabShop:AddSection("Habilidades (Bypass Distancia)")
TabShop:AddButton({ Name = "Comprar Geppo (Skyjump) - $10k", Callback = function() BuyItem("BuyHaki", "Geppo", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Comprar Buso (Aura) - $25k", Callback = function() BuyItem("BuyHaki", "Buso", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Comprar Soru (Flash Step) - $100k", Callback = function() BuyItem("BuyHaki", "Soru", nil, "Ability Teacher") end })
TabShop:AddButton({ Name = "Comprar Ken Haki (Observation) - $750k", Callback = function() BuyItem("KenTalk", "Buy", nil, "Instinct Teacher") end })

TabShop:AddSection("Estilos de Pelea (Ghost TP Bypass)")
TabShop:AddButton({ Name = "Dark Step (Teacher) - $150k", Callback = function() BuyItem("BuyBlackLeg", nil, nil, "Dark Step Teacher") end })
TabShop:AddButton({ Name = "Electro (Mad Scientist) - $500k", Callback = function() BuyItem("BuyElectro", nil, nil, "Mad Scientist") end })
TabShop:AddButton({ Name = "Water Kung Fu (Teacher) - $750k", Callback = function() BuyItem("BuyFishmanKarate", nil, nil, "Water Kung Fu Teacher") end })

TabShop:AddSection("Espadas Avanzadas (Sword Dealer)")
TabShop:AddButton({ Name = "Katana Clásica - $1k", Callback = function() BuyItem("BuyItem", "Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Dual Katana - $12k", Callback = function() BuyItem("BuyItem", "Dual Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Iron Mace - $25k", Callback = function() BuyItem("BuyItem", "Iron Mace", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Triple Katana - $60k", Callback = function() BuyItem("BuyItem", "Triple Katana", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Pipe (Tubería) - $100k", Callback = function() BuyItem("BuyItem", "Pipe", nil, "Sword Dealer") end })
TabShop:AddButton({ Name = "Soul Cane (Bastón) - $750k", Callback = function() BuyItem("BuyItem", "Soul Cane", nil, "Living Skeleton") end })
TabShop:AddButton({ Name = "Bisento (Barbablanca) - $1M", Callback = function() BuyItem("BuyItem", "Bisento", nil, "Master Sword Dealer") end })

TabShop:AddSection("Armas de Fuego (Weapon Dealer)")
TabShop:AddButton({ Name = "Slingshot (Resortera) - $5k", Callback = function() BuyItem("BuyItem", "Slingshot", nil, "Weapon Dealer") end })
TabShop:AddButton({ Name = "Musket (Mosquete) - $8k", Callback = function() BuyItem("BuyItem", "Musket", nil, "Weapon Dealer") end })
TabShop:AddButton({ Name = "Flintlock (Pistola) - $10k", Callback = function() BuyItem("BuyItem", "Flintlock", nil, "Weapon Dealer") end })


-- ===== TAB QUEST FARM =====

-- ===== TAB TELEPORT =====
TabTeleport:AddSection("Viajes Dinámicos")

local SelectedIsland = ""
TabTeleport:AddDropdown({
    Name = "Isla a Volar",
    Options = ScanIslands(),
    Callback = function(Value)
        SelectedIsland = Value
    end
})

TabTeleport:AddButton({
    Name = "Volar Hacia Isla (Tween)",
    Callback = function()
        local origin = workspace:FindFirstChild("_WorldOrigin")
        local locs = origin and origin:FindFirstChild("Locations")
        if locs and SelectedIsland ~= "" and SelectedIsland ~= "None" then
            local islaObj = locs:FindFirstChild(SelectedIsland)
            if islaObj then BypassTeleport(islaObj.CFrame * CFrame.new(0, 80, 0)) end
        end
    end
})


-- =========================================================
-- ===== TAB COMBAT PVP (RESTAURADO + ANTI-LAG)         =====
-- =========================================================


TabCombat:AddSection("Mejoras de Combate")
TabCombat:AddToggle({ Name = "Auto Buso Haki (Aura)", Default = false, Callback = function(v) getgenv().PolarAutoBusoEnabled = v end })
TabCombat:AddToggle({ Name = "Auto Ken Haki (Observation)", Default = false, Callback = function(v) getgenv().PolarAutoKenEnabled = v end })
TabCombat:AddToggle({ Name = "Auto Skills (Z, X)", Default = false, Callback = function(v) getgenv().PolarAutoSkillsEnabled = v end })

TabCombat:AddSection("Bounty Hunter Tracker")

local SelectedTarget = nil
local TargetSetInfo = "Esperando objetivo..."

-- Desplegable para seleccionar jugador
local PlayerDropdown = TabCombat:AddDropdown({
    Name = "Seleccionar Víctima",
    Options = {"Nadie"},
    Callback = function(Value)
        if Value and Value ~= "Nadie" then
            SelectedTarget = Players:FindFirstChild(Value)
        else
            SelectedTarget = nil
        end
    end
})

-- Función reutilizable para refrescar la lista de jugadores
local function RefreshPlayerList()
    local list = {"Nadie"}
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
    Name = "🔄 Actualizar Lista del Servidor",
    Callback = function()
        RefreshPlayerList()
    end
})

local LabelTargetInfo = TabCombat:AddParagraph({
    Title = "Inspección Táctica (Set & Stats)",
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
            local bounty = "Oculto"
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
            if armas == "" then armas = "Manos vacías" else armas = string.sub(armas, 1, -3) end

            -- Datos extra: nivel, salud, fruta
            local extraInfo = ""
            pcall(function()
                local hum = SelectedTarget.Character:FindFirstChild("Humanoid")
                if hum then
                    extraInfo = string.format("\n❤️ HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                end
                local data = SelectedTarget:FindFirstChild("Data")
                if data then
                    local lvl = data:FindFirstChild("Level")
                    if lvl then extraInfo = extraInfo .. "\n📊 Nivel: " .. tostring(lvl.Value) end
                    local fruit = data:FindFirstChild("BloxFruit")
                    if fruit and fruit.Value ~= "" then extraInfo = extraInfo .. "\n🍎 Fruta: " .. tostring(fruit.Value) end
                end
            end)

            local info = string.format("🎯 Objetivo: %s\n💰 Bounty: %s\n⚔️ Inventario/Armas: %s%s", SelectedTarget.Name, bounty, armas, extraInfo)
            
            pcall(function()
                if LabelTargetInfo.SetDesc then LabelTargetInfo:SetDesc(info)
                elseif LabelTargetInfo.Set then LabelTargetInfo:Set({Desc = info}) end
            end)
        else
            pcall(function()
                if LabelTargetInfo.SetDesc then LabelTargetInfo:SetDesc("Selecciona un jugador válido...")
                elseif LabelTargetInfo.Set then LabelTargetInfo:Set({Desc = "Selecciona un jugador válido..."}) end
            end)
        end
    end
end)

TabCombat:AddButton({
    Name = "🚀 Teletransportarse al Objetivo",
    Callback = function()
        if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            BypassTeleport(SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        end
    end
})

-- ==================== MODO COMBATE (TOGGLE MAESTRO) ====================
-- ANTI-LAG: Los hooks y bucles de Hitbox/Silent Aim NO se ejecutan
-- hasta que actives este toggle. Esto garantiza 0 lag si no estás en PvP.
TabCombat:AddSection("⚡ Modo Combate (Anti-Lag)")

local CombatModeEnabled = false
local CombatHooksInjected = false -- Flag para inyectar hooks solo 1 vez

TabCombat:AddToggle({
    Name = "⚡ Activar Modo Combate",
    Desc = "ACTIVA ESTO PRIMERO. Sin esto, Hitbox y Silent Aim no funcionarán. Desactívalo cuando no hagas PvP para eliminar lag.",
    Callback = function(Value)
        CombatModeEnabled = Value
        if Value and not CombatHooksInjected then
            CombatHooksInjected = true
            -- Inyectar hooks SOLO la primera vez que se activa
            -- (ver abajo: se inyectan al final de esta sección)
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
    Name = "Activar Hitbox Expander",
    Desc = "Aumenta la caja de colisión de los enemigos. Requiere Modo Combate activado. (15-25 es óptimo)",
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then RestoreAllHitboxes() end
    end
})

TabCombat:AddSlider({
    Name = "Tamaño de Hitbox",
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
-- Usa checkcaller() para romper la recursión de __index:
-- Cuando NUESTRO HOOK lee propiedades (.Character, .Name) → checkcaller() = true → pasa directo
-- Cuando el JUEGO lee Mouse.Hit → checkcaller() = false → interceptamos y redirigimos
-- Esta es la técnica estándar de los script hubs profesionales.

local SilentAimEnabled = false
local BringTargetEnabled = false

TabCombat:AddToggle({
    Name = "Silent Aim (Full Aimbot)",
    Desc = "Redirige Mouse.Hit, remotos y skills al objetivo. Armas como Tirachinas apuntan solas. Requiere Modo Combate.",
    Callback = function(Value)
        SilentAimEnabled = Value
    end
})

TabCombat:AddToggle({
    Name = "Bring Target (Atraer Víctima)",
    Desc = "Teletransporta la víctima frente a ti. Combo letal con Silent Aim. Requiere Modo Combate.",
    Callback = function(Value)
        BringTargetEnabled = Value
    end
})

TabCombat:AddSection("Combate Extremo")

local KillAuraEnabled = false
TabCombat:AddToggle({
    Name = "Kill Aura (Destrucción Total)",
    Desc = "Daña a todos los enemigos o jugadores a tu alrededor automáticamente sin apuntar.",
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

-- ============ HOOKS DE PROTECCIÓN PROFUNDA (ANTI-CHEAT BYPASS) ============
-- Intercepta intentos del Anti-Cheat local de borrarnos la GUI o patearnos
pcall(function()
    local OldNewIndex
    OldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
        if not checkcaller() then
            if (self.Name == "PlayerGui" or self == LocalPlayer) and key == "Parent" and value == nil then
                return -- Anular el borrado silencioso
            end
        end
        return OldNewIndex(self, key, value)
    end))
end)

-- ============ HOOK __namecall (con checkcaller) ============
-- Intercepta FireServer para combate y bloquea Destroy/Kick del Anti-Cheat
pcall(function()
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- BLOQUEADOR DE CASTIGOS (Anti-Cheat Bypass):
        if not checkcaller() then
            if method == "Destroy" or method == "ClearAllChildren" or method == "Remove" then
                if self.Name == "PlayerGui" or self == LocalPlayer then
                    return -- Anular la ejecución (Bloqueado)
                end
            elseif method == "Kick" or method == "kick" then
                if self == LocalPlayer then
                    return -- Anular el Kick
                end
            end
        end

        -- Si no está activo el combate, pasar directo
        if not CombatModeEnabled or not SilentAimEnabled then
            return OldNamecall(self, ...)
        end
        
        -- checkcaller: si somos nosotros los que llamamos, no interceptar (anti-recursión)
        if checkcaller and checkcaller() then
            return OldNamecall(self, ...)
        end
        
        local method = getnamecallmethod()
        if method ~= "FireServer" and method ~= "InvokeServer" then
            return OldNamecall(self, ...)
        end
        
        if typeof(self) ~= "Instance" then
            return OldNamecall(self, ...)
        end
        
        -- Seguro: con checkcaller, podemos usar :IsA() sin recursión
        if not self:IsA("RemoteEvent") and not self:IsA("RemoteFunction") then
            return OldNamecall(self, ...)
        end
        
        -- Verificar si es remoto de combate (Optimizado Anti-Lag)
        local remoteName = self.Name
        local isCombat = COMBAT_REMOTE_NAMES[remoteName]
        if isCombat == nil then
            local lower = string.lower(remoteName)
            for _, kw in ipairs(COMBAT_KEYWORDS) do
                if string.find(lower, kw) then isCombat = true break end
            end
            if not isCombat and self.Parent then
                local pn = self.Parent.Name
                if pn == "Net" or pn == "Remotes" then isCombat = true end
            end
            COMBAT_REMOTE_NAMES[remoteName] = isCombat or false
        end
        
        if not isCombat then
            return OldNamecall(self, ...)
        end
        
        -- Redirigir al target
        if SelectedTarget and SelectedTarget.Parent and SelectedTarget.Character then
            local targetHrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local args = {...}
                for i, v in pairs(args) do
                    if typeof(v) == "CFrame" then args[i] = targetHrp.CFrame
                    elseif typeof(v) == "Vector3" then args[i] = targetHrp.Position end
                end
                return OldNamecall(self, unpack(args))
            end
        end
        
        return OldNamecall(self, ...)
    end))
end)

-- ============ HOOK __index (con checkcaller + newcclosure) ============
-- Intercepta Mouse.Hit / Mouse.Target para que armas apunten al objetivo
-- checkcaller() rompe la recursión: nuestro código pasa directo, el juego se intercepta
pcall(function()
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        -- ANTI-RECURSIÓN PRINCIPAL: Si nuestro propio script está leyendo propiedades, NO interceptar
        -- checkcaller() = true cuando NUESTRO código llama → pasa al original sin procesar
        -- checkcaller() = false cuando el JUEGO llama → aplicamos la redirección
        if not checkcaller or checkcaller() then
            return OldIndex(self, key)
        end
        
        -- Si no está activo, pasar directo (0 CPU)
        if not CombatModeEnabled or not SilentAimEnabled then
            return OldIndex(self, key)
        end
        
        -- Solo nos interesan Hit y Target del Mouse
        if key ~= "Hit" and key ~= "Target" then
            return OldIndex(self, key)
        end
        
        -- Verificar que tenemos un objetivo válido
        if not SelectedTarget or not SelectedTarget.Parent then
            return OldIndex(self, key)
        end
        
        -- Verificar que self es el Mouse del jugador (comparación segura)
        local isOurMouse = false
        pcall(function()
            isOurMouse = (self == LocalPlayer:GetMouse())
        end)
        if not isOurMouse then
            return OldIndex(self, key)
        end
        
        -- Obtener HRP del target
        local targetHrp = nil
        pcall(function()
            targetHrp = SelectedTarget.Character.HumanoidRootPart
        end)
        if not targetHrp then
            return OldIndex(self, key)
        end
        
        -- Redirigir Mouse.Hit y Mouse.Target
        if key == "Hit" then
            return targetHrp.CFrame
        elseif key == "Target" then
            return targetHrp
        end
        
        return OldIndex(self, key)
    end))
end)

-- ===== TAB MISC =====
TabMisc:AddSection("Personalización de la Interfaz")

local themesList = {}
pcall(function()
    for themeName, _ in pairs(redzlib.Themes) do
        table.insert(themesList, themeName)
    end
end)
if #themesList == 0 then
    themesList = {"Darker", "Dark", "Purple"}
end
table.sort(themesList)

TabMisc:AddDropdown({
    Name = "Tema Visual",
    Description = "Cambia el color de acento de la interfaz en tiempo real.",
    Options = themesList,
    Default = "Darker",
    Callback = function(selected)
        pcall(function() redzlib:SetTheme(selected) end)
    end
})

TabMisc:AddDropdown({
    Name = "Escala de la Interfaz (UI Scale)",
    Description = "Ajusta el tamaño global de la interfaz.",
    Options = {"Pequeño", "Mediano", "Grande", "Muy Grande"},
    Default = "Grande",
    Callback = function(selected)
        local scaleMap = {
            ["Pequeño"] = 950,
            ["Mediano"] = 800,
            ["Grande"] = 650,
            ["Muy Grande"] = 500
        }
        local val = scaleMap[selected] or 800
        pcall(function()
            redzlib:SetScale(val)
        end)
    end
})
TabMisc:AddSection("Utilidades Extra")

local FruitFinderEnabled = false
local foundFruits = {}
TabMisc:AddToggle({
    Name = "Buscador de Frutas (Fruit Finder)",
    Desc = "Notifica si aparece una fruta en el mapa.",
    Callback = function(Value)
        FruitFinderEnabled = Value
    end
})

local FlyEnabled = false
local flySpeed = 50
local flyBodyMover = nil
TabMisc:AddToggle({
    Name = "Modo Fly Libre",
    Desc = "Vuela usando W A S D y tu cámara.",
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
    Desc = "Te reconecta al instante si eres expulsado.",
    Callback = function(Value)
        AutoRejoinEnabled = Value
    end
})

TabMisc:AddSection("Movimiento")

TabMisc:AddSlider({
    Name = "Nivel de Velocidad",
    Default = { Min = 16, Max = 500, Default = 16 },
    Callback = function(Value)
        sVal = Value
    end
})

TabMisc:AddToggle({
    Name = "Control de Velocidad",
    Callback = function(Value)
        sAct = Value
    end
})

TabMisc:AddToggle({
    Name = "Salto Infinito",
    Callback = function(Value)
        iJ = Value
    end
})

TabMisc:AddToggle({
    Name = "Atravesar Paredes (NoClip)",
    Callback = function(Value)
        ncl = Value
    end
})

TabMisc:AddToggle({
    Name = "Caminar sobre el Agua",
    Callback = function(Value)
        walkWaterEnabled = Value
    end
})

TabMisc:AddSection("Sistema")

TabMisc:AddButton({
    Name = "Server Hop (Saltar Servidor)",
    Callback = function()
        ServerHop()
    end
})

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
                        Title = "🍎 ¡FRUTA ENCONTRADA!",
                        Text = "Se ha encontrado: " .. v.Name,
                        Duration = 10
                    })
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if KillAuraEnabled and RegisterHit and RegisterAttack then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local targets = {}
                local mainTargetPart = nil

                if enemiesFolder then
                    local targetEnemyName = GetCurrentTargetEnemyName()
                    local farmingActive = (AutoFarmNearestEnabled or getgenv().PolarAutoFarmBossEnabled or getgenv().PolarAutoFarmAllBossesEnabled or getgenv().PolarAutoSaberExpertEnabled or getgenv().PolarAutoMobLeaderEnabled or getgenv().PolarCurrentBotState ~= STATE_IDLE)
                    
                    for _, npc in ipairs(enemiesFolder:GetChildren()) do
                        if farmingActive and targetEnemyName and targetEnemyName ~= "NearestNPC" and targetEnemyName ~= "Buscando Jefes..." and not MatchEnemyName(npc.Name, targetEnemyName) then
                            continue
                        end
                        
                        local nHrp = npc:FindFirstChild("HumanoidRootPart")
                        local hum = npc:FindFirstChild("Humanoid")
                        local ff = npc:FindFirstChildOfClass("ForceField")
                        if nHrp and nHrp.Parent and hum and hum.Parent and hum.Health > 0 and not ff and (nHrp.Position - hrp.Position).Magnitude < 60 then
                            table.insert(targets, {npc, nHrp})
                            if not mainTargetPart then mainTargetPart = nHrp end
                            if #targets >= 8 then break end
                        end
                    end
                end
                
                -- FIX ANTI-CHEAT: Validar herramienta y objetivo
                local currentTool = char:FindFirstChildOfClass("Tool")
                local validWeapons = {["Melee"]=true, ["Sword"]=true, ["Blox Fruit"]=true, ["Gun"]=true}
                
                if currentTool and validWeapons[currentTool.ToolTip] and #targets > 0 and mainTargetPart and mainTargetPart.Parent then
                    pcall(function()
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(mainTargetPart, targets)
                    end)
                end
            end
        end
    end
end)

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

local CoreGui = game:GetService("CoreGui")
local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
if promptOverlay then
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" and AutoRejoinEnabled then
            task.wait(2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

print("✅ Polar Hub cargado exitosamente.")

-- ==================== TELEMETRÍA Y LOGS EN TIEMPO REAL ====================
task.spawn(function()
    local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService")
    local LogService = game:GetService("LogService")
    local request_func = (http_request or request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
    
    if request_func and HttpService then
        LogService.MessageOut:Connect(function(message, messageType)
            pcall(function()
                request_func({
                    Url = "http://127.0.0.1:3000/log",
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
        print("📡 Polar Hub Telemetría: Puente de logs en tiempo real conectado.")
        
        -- ==================== EVALUACIÓN DE COMANDOS REMOTOS (AI BRIDGE) ====================
        task.spawn(function()
            task.wait(2)
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
end)