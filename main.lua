-- Polar HUB | loadstring ready
-- Subir a GitHub como archivo raw y usar este comando en tu ejecutor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/polarzhub/polarhub/refs/heads/main/main.lua"))()

-- Esperar a que el juego cargue completamente antes de inyectar
repeat task.wait() until game:IsLoaded()

-- ==================== WIND UI LIBRARY ====================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Error: No se pudo cargar WindUI.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "❄️ POLAR HUB | Modo Dios",
    Icon = "snowflake",
    Folder = "PolarHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    OpenButton = {
		Title = "❄️ POLAR HUB",
		CornerRadius = UDim.new(0, 8),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		Scale = 1,
        OnlyMobile = false
	}
})

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

-- ==================== BLOX FRUITS REMOTES ====================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 5)
local Net = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit = Net and pcall(function() return Net["RE/RegisterHit"] end) and Net["RE/RegisterHit"]
local RegisterAttack = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]
local enemiesFolder = workspace:FindFirstChild("Enemies")

-- ==================== BASE DE DATOS DE MISIONES (SEA 1 INTELIGENTE) ====================
local LevelQuests = {
    {lvl = 1, q = "BanditQuest1", ql = 1, name = "Bandit", giver = "Bandit Quest Giver", island = "Town"},
    {lvl = 10, q = "JungleQuest", ql = 1, name = "Monkey", giver = "Adventurer", island = "Jungle"},
    {lvl = 15, q = "JungleQuest", ql = 2, name = "Gorilla", giver = "Adventurer", island = "Jungle"},
    {lvl = 20, q = "JungleQuest", ql = 3, name = "Gorilla King", giver = "Adventurer", island = "Jungle", isBoss = true},
    {lvl = 30, q = "BuggyQuest1", ql = 1, name = "Pirate", giver = "Pirate Adventurer", island = "Pirate"},
    {lvl = 40, q = "BuggyQuest1", ql = 2, name = "Brute", giver = "Pirate Adventurer", island = "Pirate"},
    {lvl = 55, q = "BuggyQuest1", ql = 3, name = "Bobby", giver = "Pirate Adventurer", island = "Pirate", isBoss = true},
    {lvl = 60, q = "DesertQuest", ql = 1, name = "Desert Bandit", giver = "Desert Adventurer", island = "Desert"},
    {lvl = 75, q = "DesertQuest", ql = 2, name = "Desert Officer", giver = "Desert Adventurer", island = "Desert"},
    {lvl = 90, q = "SnowQuest", ql = 1, name = "Snow Bandit", giver = "Villager", island = "Snow"},
    {lvl = 100, q = "SnowQuest", ql = 2, name = "Snowman", giver = "Villager", island = "Snow"},
    {lvl = 105, q = "SnowQuest", ql = 3, name = "Yeti", giver = "Villager", island = "Snow", isBoss = true},
    {lvl = 120, q = "MarineQuest2", ql = 1, name = "Chief Petty Officer", giver = "Marine", island = "Marine"},
    {lvl = 130, q = "MarineQuest2", ql = 2, name = "Vice Admiral", giver = "Marine", island = "Marine", isBoss = true},
    {lvl = 150, q = "SkyQuest", ql = 1, name = "Sky Bandit", giver = "Sky Adventurer", island = "Sky"},
    {lvl = 175, q = "SkyQuest", ql = 2, name = "Dark Master", giver = "Sky Adventurer", island = "Sky"},
    {lvl = 190, q = "PrisonerQuest", ql = 1, name = "Prisoner", giver = "Jail Keeper", island = "Prison"},
    {lvl = 210, q = "PrisonerQuest", ql = 2, name = "Dangerous Prisoner", giver = "Jail Keeper", island = "Prison"},
    {lvl = 220, q = "ImpelQuest", ql = 1, name = "Warden", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 230, q = "ImpelQuest", ql = 2, name = "Chief Warden", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 240, q = "ImpelQuest", ql = 3, name = "Swan", giver = "Head Jailer", island = "Prison", isBoss = true},
    {lvl = 250, q = "ColosseumQuest", ql = 1, name = "Toga Warrior", giver = "Colosseum Quest Giver", island = "Colosseum"},
    {lvl = 275, q = "ColosseumQuest", ql = 2, name = "Gladiator", giver = "Colosseum Quest Giver", island = "Colosseum"},
    {lvl = 300, q = "MagmaQuest", ql = 1, name = "Military Soldier", giver = "The Mayor", island = "Magma"},
    {lvl = 325, q = "MagmaQuest", ql = 2, name = "Military Spy", giver = "The Mayor", island = "Magma"},
    {lvl = 375, q = "FishmanQuest", ql = 1, name = "Fishman Warrior", giver = "Neptune", island = "Fishman"},
    {lvl = 400, q = "FishmanQuest", ql = 2, name = "Fishman Commando", giver = "Neptune", island = "Fishman"},
    {lvl = 425, q = "FishmanQuest", ql = 3, name = "Fishman Lord", giver = "Neptune", island = "Fishman", isBoss = true},
    {lvl = 450, q = "SkyExp1Quest", ql = 1, name = "God's Guard", giver = "Mole", island = "Sky"},
    {lvl = 475, q = "SkyExp1Quest", ql = 2, name = "Shanda", giver = "Mole", island = "Sky"},
    {lvl = 500, q = "SkyExp1Quest", ql = 3, name = "Wysper", giver = "Mole", island = "Sky", isBoss = true},
    {lvl = 525, q = "SkyExp2Quest", ql = 1, name = "Royal Squad", giver = "Sky Quest Giver 2", island = "Upper Sky"},
    {lvl = 550, q = "SkyExp2Quest", ql = 2, name = "Royal Soldier", giver = "Sky Quest Giver 2", island = "Upper Sky"},
    {lvl = 575, q = "SkyExp2Quest", ql = 3, name = "Thunder God", giver = "Sky Quest Giver 2", island = "Upper Sky", isBoss = true},
    {lvl = 625, q = "FountainQuest", ql = 1, name = "Galley Pirate", giver = "Freezeburg Quest Giver", island = "Fountain"},
    {lvl = 650, q = "FountainQuest", ql = 2, name = "Galley Captain", giver = "Freezeburg Quest Giver", island = "Fountain"},
    {lvl = 675, q = "FountainQuest", ql = 3, name = "Cyborg", giver = "Freezeburg Quest Giver", island = "Fountain", isBoss = true}
}

-- ==================== BASE DE DATOS DE JEFES (SEA 1) ====================
local Sea1Bosses = {
    {name = "Gorilla King", q = "JungleQuest", ql = 3, giver = "Adventurer", island = "Jungle", lvl = 20},
    {name = "Bobby", q = "BuggyQuest1", ql = 3, giver = "Pirate Adventurer", island = "Pirate", lvl = 55},
    {name = "Yeti", q = "SnowQuest", ql = 3, giver = "Villager", island = "Snow", lvl = 105},
    {name = "Mob Leader", q = nil, ql = nil, giver = nil, island = "Pirate", lvl = 120},
    {name = "Vice Admiral", q = "MarineQuest2", ql = 2, giver = "Marine", island = "Marine", lvl = 130},
    {name = "Warden", q = "ImpelQuest", ql = 1, giver = "Head Jailer", island = "Prison", lvl = 220},
    {name = "Chief Warden", q = "ImpelQuest", ql = 2, giver = "Head Jailer", island = "Prison", lvl = 230},
    {name = "Swan", q = "ImpelQuest", ql = 3, giver = "Head Jailer", island = "Prison", lvl = 240},
    {name = "Magma Admiral", q = "MagmaQuest", ql = 3, giver = "The Mayor", island = "Magma", lvl = 350},
    {name = "Fishman Lord", q = "FishmanQuest", ql = 3, giver = "Neptune", island = "Fishman", lvl = 425},
    {name = "Wysper", q = "SkyExp1Quest", ql = 3, giver = "Sky Adventurer", island = "Sky", lvl = 500},
    {name = "Thunder God", q = "SkyExp2Quest", ql = 3, giver = "Sky Adventurer", island = "Sky", lvl = 575},
    {name = "Cyborg", q = "FountainQuest", ql = 3, giver = "Fountain Quest Giver", island = "Fountain", lvl = 675},
    {name = "Saber Expert", q = nil, ql = nil, giver = nil, island = "Jungle", lvl = 200},
    {name = "The Saw", q = nil, ql = nil, giver = nil, island = "Town", lvl = 100},
    {name = "Greybeard", q = nil, ql = nil, giver = nil, island = "Marine", lvl = 750}
}

local SelectedBossToFarm = "Gorilla King"
local AutoFarmBossEnabled = false
local AutoFarmAllBossesEnabled = false
local BossWithQuest = false
local BotActiveQuest = nil
local lastBossCheckedIndex = 1
local QuestTryCount = 0

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

-- ==================== HYBRID SAFE TELEPORT ====================
local function BypassTeleport(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- === OPTIMIZACION: TP a Isla Submarina mediante Remolino ===
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
    -- ==========================================================
    
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    if dist < 50 then
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
        
        -- SISTEMA ANTI-ATASCO Y ANTI-AGUA (RUTA EN U / V)
        -- Si está en la ciudad fuente (Y muy altos o bajos) o la distancia es grande
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
        
        bp:Destroy()
        nclConn:Disconnect()
    end
end

-- ==================== ULTIMATE SHOP BYPASS (HOOKMETAMETHOD + GHOST TP) ====================
-- Utiliza funciones exclusivas de ejecutores nivel 8 para bypassear anti-cheats sin lag.
-- Cero lag: Solo corre al hacer clic.
local bypassHookInstalled = false
local function InstallShopBypass()
    if bypassHookInstalled then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and method == "DistanceFromCharacter" then
                return 0 -- Engañar al cliente diciendo que la distancia es 0
            end
            return oldNamecall(self, ...)
        end)
        bypassHookInstalled = true
    end)
end

local function BuyItem(action, arg1, arg2, npcName)
    InstallShopBypass()
    
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local oldCFrame = hrp.CFrame
        
        -- Indexar al máximo para conseguir las coordenadas reales del NPC
        local targetNPC = nil
        if npcName then
            -- Búsqueda exhaustiva sin causar lag
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.find(string.lower(v.Name), string.lower(npcName)) and v:FindFirstChild("HumanoidRootPart") then
                    targetNPC = v
                    break
                end
            end
        end
        
        -- Llegar más rápido a la ubicación usando el Tween Real del HUB
        if targetNPC then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Polar Hub | Viajando",
                    Text = "Bypass activo: Volando hacia " .. npcName .. "...",
                    Duration = 2
                })
            end)
            
            local targetCF = targetNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            -- Usar la potente función del ejecutor de antes para el TP seguro
            BypassTeleport(targetCF)
            task.wait(0.5) -- Pausa para estabilizar la posición y red
            
            -- Activar Proximity Prompts si existen (Funciones del ejecutor nivel 8)
            for _, v in ipairs(targetNPC:GetDescendants()) do
                if v:IsA("ProximityPrompt") and fireproximityprompt then
                    pcall(function() fireproximityprompt(v) end)
                end
            end
            task.wait(0.5)
        end
        
        -- Ejecutar la compra con spoof normal
        local success, result = pcall(function()
            if arg2 then
                return CommF:InvokeServer(action, arg1, arg2)
            elseif arg1 then
                return CommF:InvokeServer(action, arg1)
            else
                return CommF:InvokeServer(action)
            end
        end)
        
        -- Regresar a la posición original
        if targetNPC then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Polar Hub | Compra",
                    Text = success and "Compra inyectada. Volviendo..." or "Hubo un error. Volviendo...",
                    Duration = 2
                })
            end)
            
            task.wait(0.5)
            BypassTeleport(oldCFrame)
        else
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Polar Hub | Aviso",
                    Text = "NPC no encontrado, compra remota inyectada.",
                    Duration = 2
                })
            end)
        end
    end)
end

-- ==================== INTELIGENCIA ARTIFICIAL DE MISIONES ====================
local function HasQuest()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
        if pgui.Main.Quest.Visible then
            local title = pgui.Main.Quest:FindFirstChild("Container") and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
            if title and title.Text then
                -- FIX: Blox Fruits deja el UI de la quest visible varios segundos diciendo "Quest Completed!".
                -- Si no tiene un contador válido como (0/9), significa que la misión ya no está activa.
                if string.find(string.lower(title.Text), "completed") or string.find(string.lower(title.Text), "completada") then
                    return false
                end
                
                -- Si no encontramos ningún nombre de enemigo en el texto, asumimos que no hay misión activa.
                local bestMatch = nil
                for _, qData in ipairs(LevelQuests) do
                    if string.find(string.lower(title.Text), string.lower(qData.name)) then
                        bestMatch = qData.name
                        break
                    end
                end
                
                if bestMatch then
                    return true
                end
            end
            return true
        end
    end
    return false
end

local function GetTargetEnemyNameFromQuest()
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
                
                -- FIX: Buscar la coincidencia de mayor longitud. 
                -- Evita que "Desert Bandit" se confunda con "Bandit".
                for _, qData in ipairs(LevelQuests) do
                    if string.find(string.lower(questText), string.lower(qData.name)) then
                        if #qData.name > bestLen then
                            bestLen = #qData.name
                            bestMatch = qData.name
                        end
                    end
                end
                
                for _, bData in ipairs(Sea1Bosses) do
                    if string.find(string.lower(questText), string.lower(bData.name)) then
                        if #bData.name > bestLen then
                            bestLen = #bData.name
                            bestMatch = bData.name
                        end
                    end
                end
                
                if enemiesFolder then
                    for _, npc in ipairs(enemiesFolder:GetChildren()) do
                        if string.find(string.lower(questText), string.lower(npc.Name)) then
                            if #npc.Name > bestLen then
                                bestLen = #npc.Name
                                bestMatch = npc.Name
                            end
                        end
                    end
                end
                
                return bestMatch
            end
        end
    end
    return nil
end

local function IsEnemyAlive(enemyName)
    if enemiesFolder then
        for _, npc in ipairs(enemiesFolder:GetChildren()) do
            if string.find(string.lower(npc.Name), string.lower(enemyName)) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function GetBestQuestData()
    local data = LocalPlayer:FindFirstChild("Data")
    local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
    local best = LevelQuests[1]
    
    for i = 1, #LevelQuests do
        local q = LevelQuests[i]
        if lvl >= q.lvl then
            if q.isBoss then
                if IsEnemyAlive(q.name) then
                    best = q
                end
            else
                best = q
            end
        else
            break
        end
    end
    return best
end

local function GetIslandPosition(islandKeyword)
    if string.lower(islandKeyword) == "fishman" then
        islandKeyword = "Underwater City"
    end
    local origin = workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if locs then
        for _, v in ipairs(locs:GetChildren()) do
            if string.find(string.lower(v.Name), string.lower(islandKeyword)) then
                return v.Position
            end
        end
    end
    
    if string.lower(islandKeyword) == "upper sky" then
        return Vector3.new(-7904, 5634, -1640)
    end
    
    return nil
end

local cachedSpawns = {}
local function GetEnemySpawnPosition(enemyName)
    if cachedSpawns[enemyName] and cachedSpawns[enemyName].Y > 0 then 
        return cachedSpawns[enemyName] 
    end
    
    if string.lower(enemyName) == "mob leader" then
        local rs = game:GetService("ReplicatedStorage")
        local wp = workspace:FindFirstChild("_WorldOrigin")
        local es = wp and wp:FindFirstChild("EnemySpawns")
        
        local targets = {
            es and es:FindFirstChild("Mob Leader [Lv. 120] [Boss]"),
            rs:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder") and rs.FortBuilderReplicatedSpawnPositionsFolder:FindFirstChild("Mob Leader"),
            rs:FindFirstChild("Mob Leader"),
            workspace.Map:FindFirstChild("MobBoss")
        }
        
        for _, t in ipairs(targets) do
            if t then
                if t:IsA("BasePart") then
                    cachedSpawns[enemyName] = t.Position
                    return t.Position
                else
                    local bp = t:FindFirstChildWhichIsA("BasePart", true)
                    if bp then
                        cachedSpawns[enemyName] = bp.Position
                        return bp.Position
                    end
                end
            end
        end
        return Vector3.new(-2880.71, 6.44, 5430.85) -- Fallback absoluto exacto (V9 Scanner)
    elseif string.lower(enemyName) == "saber expert" then
        local rs = game:GetService("ReplicatedStorage")
        local wp = workspace:FindFirstChild("_WorldOrigin")
        local es = wp and wp:FindFirstChild("EnemySpawns")
        
        local targets = {
            es and es:FindFirstChild("Saber Expert [Lv. 200] [Boss]"),
            rs:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder") and rs.FortBuilderReplicatedSpawnPositionsFolder:FindFirstChild("Saber Expert"),
            rs:FindFirstChild("Saber Expert")
        }
        
        for _, t in ipairs(targets) do
            if t then
                if t:IsA("BasePart") then
                    cachedSpawns[enemyName] = t.Position
                    return t.Position
                else
                    local bp = t:FindFirstChildWhichIsA("BasePart", true)
                    if bp then
                        cachedSpawns[enemyName] = bp.Position
                        return bp.Position
                    end
                end
            end
        end
        return Vector3.new(-1461, 30, -51) -- Fallback absoluto (Jungle)
    end

    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local enemySpawns = worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
    
    if enemySpawns then
        local bestSpawn = nil
        local bestLenDiff = math.huge
        for _, spawnPart in ipairs(enemySpawns:GetChildren()) do
            if string.find(string.lower(spawnPart.Name), string.lower(enemyName)) then
                if spawnPart.Position.Y > 0 then
                    local diff = math.abs(#spawnPart.Name - #enemyName)
                    if diff < bestLenDiff then
                        bestLenDiff = diff
                        bestSpawn = spawnPart.Position
                    end
                end
            end
        end
        if bestSpawn then
            cachedSpawns[enemyName] = bestSpawn
            return bestSpawn
        end
    end
    
    if enemiesFolder then
        local bestSpawn = nil
        local bestLenDiff = math.huge
        for _, npc in ipairs(enemiesFolder:GetChildren()) do
            if string.find(string.lower(npc.Name), string.lower(enemyName)) and npc:FindFirstChild("HumanoidRootPart") then
                local pos = npc.HumanoidRootPart.Position
                if pos.Y > 0 then
                    local diff = math.abs(#npc.Name - #enemyName)
                    if diff < bestLenDiff then
                        bestLenDiff = diff
                        bestSpawn = pos
                    end
                end
            end
        end
        if bestSpawn then
            cachedSpawns[enemyName] = bestSpawn
            return bestSpawn
        end
    end
    return nil
end

local HardcodedGivers = {
    ["Freezeburg Quest Giver"] = CFrame.new(5259.771, 37.713, 4050.025)
}

local function GetQuestGiverPosition(qData)
    if not qData or not qData.giver then return nil end
    
    -- Si tenemos las coordenadas exactas, ir directo (evita problemas de NPCs no renderizados a lo lejos)
    if HardcodedGivers[qData.giver] then
        return HardcodedGivers[qData.giver]
    end
    
    local targetNPC = nil
    local minDist = math.huge
    local spawnPos = GetEnemySpawnPosition(qData.name) or GetIslandPosition(qData.island)
    
    local function GetValidPart(npc)
        return npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc:FindFirstChild("Torso")
    end
    
    if workspace:FindFirstChild("NPCs") then
        for _, npc in ipairs(workspace.NPCs:GetChildren()) do
            local validPart = GetValidPart(npc)
            if string.find(string.lower(npc.Name), string.lower(qData.giver)) and validPart then
                local dist = spawnPos and (validPart.Position - spawnPos).Magnitude or 0
                if dist < minDist then
                    minDist = dist
                    targetNPC = npc
                end
            end
        end
        
        if not targetNPC and spawnPos then
            local fallbackDist = math.huge
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                local validPart = GetValidPart(npc)
                if string.find(string.lower(npc.Name), "quest") and validPart then
                    local dist = (validPart.Position - spawnPos).Magnitude
                    if dist < fallbackDist then
                        fallbackDist = dist
                        targetNPC = npc
                    end
                end
            end
        end
    end
    
    if targetNPC then
        local validPart = GetValidPart(targetNPC)
        if validPart then return validPart.CFrame end
    end
    return nil
end

-- ==================== ESP OPTIMIZADO ====================
local ESPEnabled = false
local function CreateESP(target, name)
    if not target:FindFirstChild("Head") or target.Head:FindFirstChild("Polar_ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Polar_ESP"
    billboard.Adornee = target:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target.Head
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name or target.Name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(0, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard
end
local function ClearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local e = p.Character.Head:FindFirstChild("Polar_ESP")
            if e then e:Destroy() end
        end
    end
    if enemiesFolder then
        for _, n in ipairs(enemiesFolder:GetChildren()) do
            if n:FindFirstChild("Head") then
                local e = n.Head:FindFirstChild("Polar_ESP")
                if e then e:Destroy() end
            end
        end
    end
end
local function UpdateESPState()
    if not ESPEnabled then return ClearESP() end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then CreateESP(p.Character, p.Name) end
    end
    if enemiesFolder then
        for _, n in ipairs(enemiesFolder:GetChildren()) do CreateESP(n, n.Name) end
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) if ESPEnabled then task.wait(1) CreateESP(c, p.Name) end end) end)
for _, p in ipairs(Players:GetPlayers()) do p.CharacterAdded:Connect(function(c) if ESPEnabled then task.wait(1) CreateESP(c, p.Name) end end) end
if enemiesFolder then enemiesFolder.ChildAdded:Connect(function(c) if ESPEnabled then task.wait(0.5) CreateESP(c, c.Name) end end) end


-- ==================== AUTO EQUIPAR ====================
local SelectedWeaponType = "Melee" 
local AutoMasteryEnabled = false
local AutoMasteryItem = "Sword"
local AutoSkillsEnabled = false

local function EquipWeapon(targetHealthPercent)
    local char = LocalPlayer.Character
    if not char then return end
    
    local weaponToEquip = SelectedWeaponType
    if AutoMasteryEnabled and targetHealthPercent and targetHealthPercent < 20 then
        weaponToEquip = AutoMasteryItem
    end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.ToolTip == weaponToEquip then return end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == weaponToEquip then
                char.Humanoid:EquipTool(tool)
                task.wait(0.1) -- FIX ANTI-CHEAT: Esperar a que el arma se equipe antes de atacar
                break
            end
        end
    end
end

-- ==================== MÁQUINA DE ESTADOS (STATE MACHINE) ====================
local STATE_IDLE = "IDLE"
local STATE_GETTING_QUEST = "GETTING_QUEST"
local STATE_FARMING = "FARMING"
local STATE_WAITING = "WAITING"
local CurrentBotState = STATE_IDLE

local FarmAnchorCF = nil
local FarmAnchorNPC = nil

-- ==================== CEREBRO AUTO FARM ====================
local AutoFarmEnabled = false
local FastAttackEnabled = false
local AutoFarmNearestEnabled = false
local AutoMobLeaderEnabled = false
local AutoSaberExpertEnabled = false

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
    if AutoSaberExpertEnabled then return "Saber Expert" end
    if AutoMobLeaderEnabled then return "Mob Leader" end
    if AutoFarmNearestEnabled then return "NearestNPC" end
    if AutoFarmAllBossesEnabled then
        for _, b in ipairs(Sea1Bosses) do
            if IsEnemyAlive(b.name) then return b.name end
        end
        if lastBossCheckedIndex > #Sea1Bosses then
            ServerHop()
            return "Buscando Jefes..."
        end
        return Sea1Bosses[lastBossCheckedIndex].name
    end
    if AutoFarmBossEnabled then return SelectedBossToFarm end
    return GetTargetEnemyNameFromQuest() or GetBestQuestData().name
end

task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp then continue end
        
        local anyFarmActive = AutoFarmEnabled or AutoFarmBossEnabled or AutoFarmAllBossesEnabled or AutoSaberExpertEnabled or AutoMobLeaderEnabled or AutoFarmNearestEnabled
        
        if not anyFarmActive then
            CurrentBotState = STATE_IDLE
            local plat = workspace:FindFirstChild("PolarFarmPlat")
            if plat then plat:Destroy() end
            task.wait(1)
            continue
        end

        if anyFarmActive and char and hrp and hum and hum.Health > 0 then
            
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

            -- 2. Determinar Objetivo Principal
            local targetEnemyName = GetCurrentTargetEnemyName()
            local bestQuestData = GetBestQuestData()
            local activeBossQuestData = nil
            local isHuntingBoss = AutoFarmAllBossesEnabled or AutoFarmBossEnabled or AutoSaberExpertEnabled or AutoMobLeaderEnabled
            
            -- Manejo de AutoFarmNearest
            if AutoFarmNearestEnabled then
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
            end
            
            -- Manejo de Jefes
            if AutoFarmAllBossesEnabled or AutoFarmBossEnabled or AutoMobLeaderEnabled or AutoSaberExpertEnabled then
                for _, b in ipairs(Sea1Bosses) do
                    if b.name == targetEnemyName then
                        activeBossQuestData = b
                        break
                    end
                end
            end
            
            local needsQuest = not (AutoSaberExpertEnabled or AutoMobLeaderEnabled or AutoFarmNearestEnabled)
            if (AutoFarmAllBossesEnabled or AutoFarmBossEnabled) then
                if not BossWithQuest then
                    needsQuest = false
                elseif activeBossQuestData and not activeBossQuestData.q then
                    needsQuest = false
                end
            end
            
            if targetEnemyName == "Buscando Jefes..." then
                CurrentBotState = STATE_IDLE
                task.wait(1)
                continue
            end

            -- ==================== INICIO MÁQUINA DE ESTADOS ====================
            if CurrentBotState == STATE_IDLE then
                QuestTryCount = 0
                if needsQuest and not HasQuest() then
                    CurrentBotState = STATE_GETTING_QUEST
                else
                    CurrentBotState = STATE_FARMING
                end
            end
            
            if CurrentBotState == STATE_GETTING_QUEST then
                if HasQuest() then
                    CurrentBotState = STATE_FARMING
                    continue
                end
                
                local qData = activeBossQuestData or bestQuestData
                local playerLvl = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") and LocalPlayer.Data.Level.Value or 1
                if AutoFarmAllBossesEnabled or AutoFarmBossEnabled then
                    if not BossWithQuest or not qData.q or (qData.lvl and playerLvl < qData.lvl) then
                        CurrentBotState = STATE_FARMING
                        continue
                    end
                end
                
                BotActiveQuest = qData.name
                local giverCF = GetQuestGiverPosition(qData)
                if giverCF then
                    if (hrp.Position - giverCF.Position).Magnitude > 15 then
                        BypassTeleport(giverCF)
                    else
                        hrp.CFrame = giverCF
                        task.wait(0.2)
                        pcall(function() CommF:InvokeServer("StartQuest", qData.q, qData.ql) end)
                        QuestTryCount = QuestTryCount + 1
                        if QuestTryCount > 10 then CurrentBotState = STATE_FARMING end
                        task.wait(0.5)
                    end
                else
                    -- FIX EXTREMO: Si el NPC no ha cargado, volar al spawn principal de la isla (Safe Zone) para forzar su renderizado.
                    local loadPos = GetIslandPosition(qData.island) or GetEnemySpawnPosition(qData.name)
                    if loadPos then
                        local targetCF = CFrame.new(loadPos) * CFrame.new(0, 30, 0)
                        if (hrp.Position - targetCF.Position).Magnitude > 50 then
                            BypassTeleport(targetCF)
                        else
                            hrp.CFrame = targetCF
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            task.wait(1) -- FIX: Previene el bug de flotar en el aire congelado
                        end
                    else
                        CurrentBotState = STATE_FARMING
                    end
                end
                continue
            end
            
            if CurrentBotState == STATE_FARMING then
                -- Validación Continua de Misión
                if needsQuest and HasQuest() then
                    local currentQuestTarget = GetTargetEnemyNameFromQuest()
                    local expectedTarget = activeBossQuestData and activeBossQuestData.name or bestQuestData.name
                    
                    if currentQuestTarget and currentQuestTarget ~= expectedTarget and not MatchEnemyName(currentQuestTarget, expectedTarget) and not MatchEnemyName(expectedTarget, currentQuestTarget) then
                        
                        warn("==================================================")
                        warn("[Polar DEBUG EXTREMO] ⚠️ ABANDONANDO MISIÓN ⚠️")
                        warn("-> Misión que deberíamos tener (expectedTarget):", tostring(expectedTarget))
                        warn("-> Misión detectada en pantalla (currentQuestTarget):", tostring(currentQuestTarget))
                        warn("-> MatchEnemyName devolvió FALSE para ambos casos.")
                        
                        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                        if pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Quest") then
                            local title = pgui.Main.Quest:FindFirstChild("Container") and pgui.Main.Quest.Container:FindFirstChild("QuestTitle") and pgui.Main.Quest.Container.QuestTitle:FindFirstChild("Title")
                            if title and title.Text then
                                warn("-> TEXTO REAL EN LA UI DE ROBLOX:", tostring(title.Text))
                            end
                        end
                        warn("==================================================")
                        
                        pcall(function() CommF:InvokeServer("AbandonQuest") end)
                        BotActiveQuest = nil
                        CurrentBotState = STATE_GETTING_QUEST
                        QuestTryCount = 0
                        task.wait(1)
                        continue
                    end
                elseif needsQuest and not HasQuest() then
                    if BotActiveQuest ~= nil then
                        warn("[Polar DEBUG EXTREMO] ❓ HasQuest() se volvió FALSE de repente! (La UI de la misión desapareció)")
                    end
                    CurrentBotState = STATE_GETTING_QUEST
                    QuestTryCount = 0
                    continue
                end

                local targetRealName = BotActiveQuest or targetEnemyName
                if targetEnemyName == "NearestNPC" or AutoFarmNearestEnabled then targetRealName = targetEnemyName end
                
                local firstNPC = nil
                local minDist = math.huge
                
                if enemiesFolder then
                    for _, npc in ipairs(enemiesFolder:GetChildren()) do
                        if MatchEnemyName(npc.Name, targetRealName) or (AutoFarmNearestEnabled and targetRealName == npc.Name) then
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
                    local targetCF
                    
                    -- AUTO FARM SEGURO Y ESTABLE (Cero Bans / Cero Bugs Físicos):
                    -- En lugar de arrastrar NPCs al aire (lo que causa bugs de Anti-Cheat y colisiones en casas),
                    -- el jugador VA directo hacia el NPC y se coloca de manera estable arriba de él.
                    if isHuntingBoss then
                        targetCF = nHrp.CFrame * CFrame.new(0, 18, 0)
                    else
                        targetCF = nHrp.CFrame * CFrame.new(0, 12, 0)
                    end
                    
                    -- Limpiar la rotación para que la plataforma no se incline si el NPC se cae, manteniendo la cámara estable.
                    targetCF = CFrame.new(targetCF.Position)
                    
                    plat.CFrame = targetCF
                    
                    if (hrp.Position - plat.Position).Magnitude > 15 then
                        BypassTeleport(plat.CFrame * CFrame.new(0, 3.5, 0))
                    end
                    -- Mantener la velocidad en cero para que no resbale de la plataforma
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    
                    -- Congelar al NPC principal en su lugar original y ANULAR sus físicas
                    local oHum = firstNPC:FindFirstChild("Humanoid")
                    if oHum then 
                        oHum.WalkSpeed = 0 
                        oHum.JumpPower = 0 
                    end
                    
                    -- Restaurando BodyVelocity (El método que el usuario amó)
                    -- Congelar al NPC principal en su lugar original
                    local primaryBv = nHrp:FindFirstChild("Polar_AntiGlitch")
                    if not primaryBv then
                        primaryBv = Instance.new("BodyVelocity")
                        primaryBv.Name = "Polar_AntiGlitch"
                        primaryBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        primaryBv.Velocity = Vector3.new(0, 0, 0)
                        primaryBv.Parent = nHrp
                    end
                    
                    if not isHuntingBoss then
                        local broughtCount = 1 -- Ya tenemos el principal
                        for _, npc in ipairs(enemiesFolder:GetChildren()) do
                            if npc ~= firstNPC and (MatchEnemyName(npc.Name, targetRealName) or (AutoFarmNearestEnabled and targetRealName == npc.Name)) then
                                local targetHrp = npc:FindFirstChild("HumanoidRootPart")
                                local targetHum = npc:FindFirstChild("Humanoid")
                                if targetHrp and targetHum and targetHum.Health > 0 then
                                    
                                    -- EXECUTOR LEVEL 7-8: Network Ownership Bypass
                                    -- Fuerza al servidor a darnos control de los NPCs lejanos
                                    pcall(function()
                                        if setsimulationradius then
                                            setsimulationradius(math.huge, math.huge)
                                        elseif sethiddenproperty then
                                            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                                        end
                                    end)
                                    
                                    -- Rango masivo (350 studs) para limpiar la isla rapidísimo
                                    if (targetHrp.Position - nHrp.Position).Magnitude <= 350 then
                                        if broughtCount < 6 then -- Jalar hasta 6 NPCs al mismo tiempo
                                            broughtCount = broughtCount + 1
                                            
                                            local secBv = targetHrp:FindFirstChild("Polar_AntiGlitch")
                                            if not secBv then
                                                secBv = Instance.new("BodyVelocity")
                                                secBv.Name = "Polar_AntiGlitch"
                                                secBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                secBv.Velocity = Vector3.new(0, 0, 0)
                                                secBv.Parent = targetHrp
                                            end
                                            
                                            -- Executor Hack: Stacking Perfecto
                                            -- Amontonarlos en el EXACTO MISMO PIXEL sin empujarse
                                            for _, part in ipairs(npc:GetDescendants()) do
                                                if part:IsA("BasePart") then
                                                    part.CanCollide = false
                                                end
                                            end
                                            
                                            targetHrp.CFrame = nHrp.CFrame
                                            targetHrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                            
                                            targetHum.WalkSpeed = 0
                                            targetHum.JumpPower = 0
                                            -- Deshabilitar Inteligencia Artificial del enemigo
                                            targetHum.PlatformStand = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    CurrentBotState = STATE_WAITING
                end
            end
            
            if CurrentBotState == STATE_WAITING then
                local targetRealName = BotActiveQuest or targetEnemyName
                if targetEnemyName == "NearestNPC" or AutoFarmNearestEnabled then targetRealName = targetEnemyName end
                
                -- Verificar reaparición
                local enemySpawned = false
                if enemiesFolder then
                    for _, npc in ipairs(enemiesFolder:GetChildren()) do
                        if MatchEnemyName(npc.Name, targetRealName) or (AutoFarmNearestEnabled and targetRealName == npc.Name) then
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
                    CurrentBotState = STATE_FARMING
                else
                    local spawnPos = GetEnemySpawnPosition(targetRealName)
                    if spawnPos then
                        local targetCF = CFrame.new(spawnPos) * CFrame.new(0, 30, 0)
                        plat.CFrame = targetCF
                        if (hrp.Position - targetCF.Position).Magnitude > 20 then
                            BypassTeleport(targetCF * CFrame.new(0, 3.5, 0))
                        else
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            task.wait(1) -- FIX: Previene que el loop sin espera te deje flotando congelado en el aire
                            if AutoFarmAllBossesEnabled then
                                if not IsEnemyAlive(targetRealName) then
                                    lastBossCheckedIndex = lastBossCheckedIndex + 1
                                    CurrentBotState = STATE_IDLE
                                end
                            end
                        end
                    else
                        local targetCF = nil
                        if AutoFarmNearestEnabled then
                            local closestDist = math.huge
                            local islandPos = nil
                            for _, quest in ipairs(LevelQuests) do
                                local p = GetIslandPosition(quest.island)
                                if p then
                                    local d = (hrp.Position - p).Magnitude
                                    if d < closestDist then
                                        closestDist = d
                                        islandPos = p
                                    end
                                end
                            end
                            if islandPos then targetCF = CFrame.new(islandPos) end
                        else
                            local qData = activeBossQuestData or bestQuestData
                            
                            -- Fix: Esperar cerca del spawn o del Quest Giver. 
                            -- Si vamos al centro de la isla en Magma, caemos justo en el Magma Admiral (Boss).
                            local spawnP = GetEnemySpawnPosition(qData.name)
                            local giverP = GetQuestGiverPosition(qData)
                            local islP = GetIslandPosition(qData.island)
                            
                            if spawnP then
                                targetCF = CFrame.new(spawnP)
                            elseif giverP then
                                targetCF = giverP
                            elseif islP then
                                targetCF = CFrame.new(islP)
                            end
                        end
                        
                        if targetCF then
                            targetCF = targetCF * CFrame.new(0, 30, 0)
                            plat.CFrame = targetCF
                            if (hrp.Position - targetCF.Position).Magnitude > 50 then
                                BypassTeleport(targetCF * CFrame.new(0, 3.5, 0))
                            else
                                hrp.CFrame = targetCF * CFrame.new(0, 3.5, 0)
                                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                if AutoFarmAllBossesEnabled then
                                    task.wait(1)
                                    if not IsEnemyAlive(targetRealName) then
                                        lastBossCheckedIndex = lastBossCheckedIndex + 1
                                        CurrentBotState = STATE_IDLE
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
        else
            CurrentBotState = STATE_IDLE
            local plat = workspace:FindFirstChild("PolarFarmPlat")
            if plat then plat:Destroy() end
        end
    end
end)

-- ==================== FAST ATTACK ANTI-KICK ====================
local FastAttackRange = 60
task.spawn(function()
    while true do
        local active = FastAttackEnabled and (AutoFarmEnabled or AutoFarmBossEnabled or AutoFarmAllBossesEnabled or AutoSaberExpertEnabled or AutoMobLeaderEnabled or AutoFarmNearestEnabled)
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
            
            if currentTool and validWeapons[currentTool.ToolTip] and #targets > 0 and mainTargetPart and mainTargetPart.Parent then
                pcall(function()
                    -- EXECUTOR LEVEL 8 BARRAGE: Enviar Múltiples Paquetes en un solo tick
                    -- Esto clona tu daño y derrite a los enemigos al instante
                    for _ = 1, 3 do
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

-- FIX #1: AutoMobLeaderEnabled y AutoSaberExpertEnabled ya están declaradas arriba (línea ~498)
local AutoSaberRunning = false

local GlobalPhase1Solved = false
local MaxSaberPhaseReached = 1

local function FullAutoSaber()
    if AutoSaberRunning then return end
    AutoSaberRunning = true

    task.spawn(function()
        local playerData = LocalPlayer:FindFirstChild("Data")
        local playerLevel = playerData and playerData:FindFirstChild("Level")
        if not playerLevel or playerLevel.Value < 200 then
            warn("❌ Polar Hub [Error Inicial]: Necesitas Nivel 200+ para el Saber Puzzle o Datos no cargados.")
            AutoSaberRunning = false
            return
        end

        -- Desactivar interferencias globales
        AutoFarmEnabled = false
        AutoFarmBossEnabled = false
        AutoFarmAllBossesEnabled = false
        AutoFarmNearestEnabled = false
        print("✅ Polar Hub: Iniciando Auto Saber Puzzle (V7.2 Extreme)...")

        local function Notify(text)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "👑 Polar Hub", Text = text, Duration = 5})
            end)
            print("Polar Hub: " .. text)
        end

        -- ==================== V7.2 SAFE ACCESS UTILS ====================
        local function SafeGetMapFolder(folderName)
            local map = workspace:FindFirstChild("Map")
            if not map then return nil end
            return map:FindFirstChild(folderName)
        end

        local function GetHRP()
            local char = LocalPlayer.Character
            return char and char:FindFirstChild("HumanoidRootPart")
        end

        local function HasItem(toolName)
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp and bp:FindFirstChild(toolName) then return true end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(toolName) then return true end
            return false
        end

        local function EquipToolByName(toolName)
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            if not bp or not char then return false end
            local tool = bp:FindFirstChild(toolName) or char:FindFirstChild(toolName)
            if tool and tool.Parent == bp then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:EquipTool(tool) return true end
            end
            return (tool and tool.Parent == char)
        end

        local function ResolvePart(obj)
            if typeof(obj) == "CFrame" then return obj end
            if not obj then return nil end
            if obj:IsA("BasePart") then return obj.CFrame end
            if obj:IsA("Model") then
                return (obj.PrimaryPart and obj.PrimaryPart.CFrame)
                    or (obj:FindFirstChild("Handle", true) and obj:FindFirstChild("Handle", true).CFrame)
                    or (obj:FindFirstChildWhichIsA("BasePart", true) and obj:FindFirstChildWhichIsA("BasePart", true).CFrame)
            end
            return nil
        end

        local function SafeFly(targetCF, forceTweenMode)
            if not targetCF then return end
            local hrp = GetHRP()
            if not hrp then return end
            local dist = (hrp.Position - targetCF.Position).Magnitude
            
            local function RawTween(cf)
                local tHrp = GetHRP()
                if not tHrp then return end
                local tDist = (tHrp.Position - cf.Position).Magnitude
                local tInfo = TweenInfo.new(tDist / 300, Enum.EasingStyle.Linear)
                local tween = game:GetService("TweenService"):Create(tHrp, tInfo, {CFrame = cf})
                
                local bp = Instance.new("BodyVelocity", tHrp)
                bp.Velocity = Vector3.new(0, 0, 0)
                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                local nclConn = game:GetService("RunService").Stepped:Connect(function()
                    local lchar = LocalPlayer.Character
                    if lchar then
                        for _, v in ipairs(lchar:GetChildren()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end)
                
                tween:Play()
                tween.Completed:Wait()
                bp:Destroy()
                nclConn:Disconnect()
            end

            local pos = hrp.Position
            if pos.Y < 15 and pos.X > 1000 and pos.Z > 4000 then 
                RawTween(CFrame.new(1113, 5, 4350)) 
                RawTween(CFrame.new(1094, 20, 4344)) 
            elseif pos.Y < 50 and pos.X > 1300 and pos.Z < -1200 then 
                RawTween(CFrame.new(1370, 87, -1320)) 
                RawTween(CFrame.new(1384, 90, -1300)) 
            end

            hrp = GetHRP()
            if not hrp then return end
            dist = (hrp.Position - targetCF.Position).Magnitude

            if dist < 50 and not forceTweenMode then
                local char = LocalPlayer.Character
                if char then char:PivotTo(targetCF) end
            else
                if dist > 500 then
                    local upCF = CFrame.new(hrp.Position.X, 500, hrp.Position.Z)
                    RawTween(upCF)
                    local acrossCF = CFrame.new(targetCF.Position.X, 500, targetCF.Position.Z)
                    RawTween(acrossCF)
                end
                RawTween(targetCF)
            end
        end

        local function ForceTouchV7(obj, fallbackCF)
            local targetCF = ResolvePart(obj) or fallbackCF
            if not targetCF then return false end
            
            SafeFly(targetCF, false)
            
            local timeout = 0
            while AutoSaberRunning and GetHRP() and timeout < 50 do
                local hrp = GetHRP()
                local d = (hrp.Position - targetCF.Position).Magnitude
                if d < 15 then break end
                if timeout > 0 and timeout % 10 == 0 then
                    local char = LocalPlayer.Character
                    if char then char:PivotTo(targetCF) end
                end
                task.wait(0.2)
                timeout = timeout + 1
            end

            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = targetCF
                local isPart = (typeof(obj) ~= "CFrame" and obj and obj:IsA("BasePart"))
                if isPart and firetouchinterest then
                    task.wait(0.2)
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, obj, 1)
                end
                return true
            end
            return false
        end

        local function TalkToNPCV7(npcName, fallbackCF, remoteId)
            -- FIX #8: Buscar NPCs en workspace:GetDescendants() para encontrarlos incluso fuera de NPCs folder
            local function FindNPCByName(name)
                local npcs = workspace:FindFirstChild("NPCs")
                if npcs then
                    local found = npcs:FindFirstChild(name)
                    if found and found:FindFirstChild("HumanoidRootPart") then return found end
                end
                -- Fallback: buscar en todos los descendientes del workspace
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == name and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        return obj
                    end
                end
                return nil
            end
            
            local npc = FindNPCByName(npcName)
            if not npc then
                ForceTouchV7(nil, fallbackCF)
                task.wait(2) -- Esperar a que el NPC cargue
                npc = FindNPCByName(npcName)
                if not npc then
                    warn("Polar Hub [Error TalkToNPCV7]: NPC '" .. npcName .. "' no se encontró en workspace")
                    return false
                end
            end
            
            ForceTouchV7(npc.HumanoidRootPart, fallbackCF)
            task.wait(1)
            for i = 1, 3 do
                task.spawn(function() pcall(function() CommF:InvokeServer("ProQuestProgress", remoteId) end) end)
                if npc then
                    for _, v in ipairs(npc:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            task.spawn(function() pcall(function() fireproximityprompt(v) end) end)
                        end
                    end
                end
                task.wait(0.5)
            end
            return true
        end

        local function DetectPhase()
            -- PRIORIDAD ABSOLUTA: Si la memoria dice que superamos la fase 5+,
            -- confiar en ella. Después de entregar la copa al Sick Man, los ítems
            -- desaparecen del inventario y el desierto no renderiza a distancia.
            -- Sin esta barrera, el bot regresa infinitamente a la Fase 3.
            if HasItem("Saber") then MaxSaberPhaseReached = 9; return 9 end
            if MaxSaberPhaseReached >= 5 then return MaxSaberPhaseReached end
            
            local function calculateRawPhase()
                if HasItem("Saber") then return 9 end
                
                local s, progress = pcall(function() return CommF:InvokeServer("ProQuestProgress", "RichMan") end)
                if not s or (type(progress) == "string" and progress == "Unknown") then 
                    return -1 -- Remote failure/timeout
                end
                
                local hasRelic = HasItem("Relic") or progress == "Relic" or (type(progress) == "table" and progress.Relic)
                if hasRelic then return 7 end
                
                -- El remoto de RichMan indica si ya matamos al Mob Leader
                if type(progress) == "table" and progress.RichMan then return 6 end
                -- NOTA: progress.SickMan NO existe en Blox Fruits.
                -- La transición Fase 4→5 se fuerza manualmente al hablar con Sick Man.
                
                if HasItem("Cup") or HasItem("FilledCup") then return 4 end
                if HasItem("Torch") then return 3 end
                
                -- Chequeo de la puerta del desierto:
                -- SOLO verificar si estamos en fases bajas (< 5).
                -- Si la puerta Burn ya NO existe y no tenemos copa,
                -- significa que la quemamos y perdimos la copa.
                local desert = SafeGetMapFolder("Desert")
                local desertDoor = desert and desert:FindFirstChild("Burn")
                if desert and not desertDoor then return 3 end
                
                local jungle = SafeGetMapFolder("Jungle")
                local jungleDoor = jungle and jungle:FindFirstChild("QuestDoor")
                if jungleDoor and jungleDoor.Transparency > 0.5 then return 2 end
                
                if GlobalPhase1Solved then return 2 end
                
                return 1
            end
            
            local rawPhase = calculateRawPhase()
            
            -- Si el remoto falló, usar ítems físicos como override, luego memoria
            if rawPhase == -1 then
                if HasItem("Relic") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 7); return MaxSaberPhaseReached end
                if HasItem("Cup") or HasItem("FilledCup") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 4); return MaxSaberPhaseReached end
                if HasItem("Torch") then MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 3); return MaxSaberPhaseReached end
                warn("Polar Hub [DetectPhase]: Remoto sin respuesta. Forzando memoria Anti-Regresión: Fase " .. MaxSaberPhaseReached)
                return MaxSaberPhaseReached
            end
            
            -- Cuando la detección es exitosa, actualizar si avanzamos naturalmente.
            if rawPhase > MaxSaberPhaseReached then
                MaxSaberPhaseReached = rawPhase
            end
            
            -- ✅ DEBE DEVOLVER LA MEMORIA, NUNCA EL RAWPHASE
            return MaxSaberPhaseReached
        end

        local function WaitForItem(itemName, timeoutSecs)
            local t = 0
            while t < timeoutSecs and AutoSaberRunning do
                if HasItem(itemName) then return true end
                task.wait(1)
                t = t + 1
            end
            return false
        end

        local function ExclusiveTargetLock(targetCF, enemyName, timeoutSecs)
            -- Equipar arma al entrar en combate
            EquipWeapon()
            
            -- Guardar estado previo de todas las banderas
            local prevFastAttack = FastAttackEnabled
            local prevSaberFlag = AutoSaberExpertEnabled
            local prevMobFlag = AutoMobLeaderEnabled
            
            -- Activar FastAttack Y la bandera correcta para que el bucle global de ataque
            -- también dispare (su condición requiere al menos un Auto*Enabled = true)
            FastAttackEnabled = true
            if string.find(string.lower(enemyName), "saber") then AutoSaberExpertEnabled = true end
            if string.find(string.lower(enemyName), "mob") then AutoMobLeaderEnabled = true end
            
            local timeout = 0
            local aliveCheckFails = 0
            local lastHP = math.huge
            local hpStuckCount = 0
            while AutoSaberRunning and timeout < timeoutSecs do
                if not IsEnemyAlive(enemyName) then
                    aliveCheckFails = aliveCheckFails + 1
                    if aliveCheckFails > 5 then break end
                else
                    aliveCheckFails = 0
                end
                
                task.wait(0.5)
                local hrp = GetHRP()
                local enemies = workspace:FindFirstChild("Enemies")
                
                -- Usar MatchEnemyName en lugar de FindFirstChild
                local target = nil
                if enemies then
                    for _, npc in ipairs(enemies:GetChildren()) do
                        if MatchEnemyName(npc.Name, enemyName) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            target = npc
                            break
                        end
                    end
                end
                
                if target and target:FindFirstChild("HumanoidRootPart") and hrp then
                    -- Incrementar contador si el HP del boss no baja
                    local currentHP = target:FindFirstChild("Humanoid") and target.Humanoid.Health or 0
                    if currentHP >= lastHP then
                        hpStuckCount = hpStuckCount + 1
                        if hpStuckCount > 20 then
                            warn("Polar Hub [ExclusiveTargetLock]: HP de '" .. enemyName .. "' no baja. Re-equipando arma...")
                            EquipWeapon()
                            hpStuckCount = 0
                        end
                    else
                        hpStuckCount = 0
                    end
                    lastHP = currentHP
                    
                    if (hrp.Position - target.HumanoidRootPart.Position).Magnitude > 300 then
                        SafeFly(target.HumanoidRootPart.CFrame, true)
                    else
                        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    end
                    
                    -- Atacar con remotes directamente
                    if RegisterHit and RegisterAttack then
                        local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                        if targetPart then
                            pcall(function()
                                RegisterAttack:FireServer(0)
                                RegisterHit:FireServer(targetPart, {{target, targetPart}})
                            end)
                        end
                    end
                elseif hrp and (hrp.Position - targetCF.Position).Magnitude > 300 then
                    SafeFly(targetCF, true)
                end
                timeout = timeout + 1
            end
            
            -- Restaurar TODAS las banderas a su estado previo
            FastAttackEnabled = prevFastAttack
            AutoSaberExpertEnabled = prevSaberFlag
            AutoMobLeaderEnabled = prevMobFlag
        end

        -- ==================== BUCLE MAESTRO V7.2 ====================
        local phaseAttempts = { [1]=0, [2]=0, [3]=0, [4]=0, [5]=0, [6]=0, [7]=0, [8]=0 }

        local function HandleCriticalFailure(phaseNum)
            warn("Polar Hub [Error Crítico]: Atascado en Fase " .. phaseNum .. " tras múltiples intentos.")
            Notify("⚠️ Atascado en Fase " .. phaseNum .. ". Retrocediendo para re-validar...")
            
            -- LÓGICA DE ESCAPE (Rollback): Si fallamos repetidamente,
            -- retrocedemos la memoria 1 fase para obligar al bot a re-verificar.
            if MaxSaberPhaseReached > 1 then
                MaxSaberPhaseReached = MaxSaberPhaseReached - 1
            else
                MaxSaberPhaseReached = 1
                GlobalPhase1Solved = false
            end
            
            -- Reiniciar contadores para el nuevo intento
            for i=1, 8 do phaseAttempts[i] = 0 end
            task.wait(3) -- Pausa táctica antes de reintentar
        end

        while AutoSaberRunning do
            task.wait(1)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then continue end

            local currentPhase = DetectPhase()
            
            -- Fase 1: Placas (MODO EXTREMO: 5 INTENTOS Y FUERZA AVANCE)
            if currentPhase == 1 then
                local s, err = pcall(function()
                    if not GlobalPhase1Solved then
                        phaseAttempts[1] = phaseAttempts[1] + 1
                        
                        -- LÍMITE EXTREMO: Si ya lo intentó 5 veces, ¡PASA A LA FASE 2 A LA FUERZA!
                        if phaseAttempts[1] > 5 then 
                            Notify("⚠️ 5 intentos alcanzados. ¡Forzando avance a Fase 2 (Antorcha)!")
                            GlobalPhase1Solved = true
                            MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 2)
                            phaseAttempts[1] = 0
                            return 
                        end
                        
                        Notify("Fase 1: Activando Placas (Intento " .. phaseAttempts[1] .. "/5)")
                        
                        local hrp = GetHRP()
                        local jungleCenterCF = CFrame.new(-1610, 22, 162)
                        if hrp and (hrp.Position - jungleCenterCF.Position).Magnitude > 300 then
                            Notify("✈️ Volando a la Jungla para cargar el mapa...")
                            SafeFly(jungleCenterCF, false)
                            task.wait(2)
                        end
                        
                        local jungle = SafeGetMapFolder("Jungle")
                        local questPlates = jungle and jungle:FindFirstChild("QuestPlates")
                        if questPlates then
                            for _, v in ipairs(questPlates:GetDescendants()) do
                                if not AutoSaberRunning then break end
                                if v:IsA("BasePart") and (string.find(string.lower(v.Name), "button") or string.find(string.lower(v.Name), "plate")) then
                                    ForceTouchV7(v, v.CFrame)
                                    task.wait(0.5)
                                end
                            end
                        else
                            warn("Polar Hub [Error Fase 1]: Carpeta 'QuestPlates' no renderizada aún.")
                        end
                        
                        task.wait(2)
                        local door = jungle and jungle:FindFirstChild("QuestDoor")
                        if door and door.Transparency > 0.5 then
                            Notify("✅ ¡Placas activadas! Puerta abierta de forma natural.")
                            GlobalPhase1Solved = true
                            MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 2)
                            phaseAttempts[1] = 0
                        else
                            if phaseAttempts[1] >= 3 then
                                Notify("⚠️ Las placas resisten. Cooldown táctico (3s)...")
                                task.wait(3)
                            end
                        end
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 1]: " .. tostring(err)) end
                continue
            end

            -- Fase 2: Recoger Antorcha (MODO EXTREMO)
            if currentPhase == 2 then
                local s, err = pcall(function()
                    phaseAttempts[2] = phaseAttempts[2] + 1
                    
                    if phaseAttempts[2] > 5 then
                        Notify("⚠️ 5 intentos en Antorcha. ¡Forzando avance a Fase 3 (Desierto)!")
                        MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 3)
                        phaseAttempts[2] = 0
                        return
                    end
                    
                    Notify("Fase 2: Recogiendo Antorcha (Intento " .. phaseAttempts[2] .. "/5)...")
                    local torchCF = CFrame.new(-1610.15, 12.18, 162.72)
                    local jungle = SafeGetMapFolder("Jungle")
                    local torch = jungle and jungle:FindFirstChild("Torch")
                    
                    if not torch then warn("Polar Hub [Error Fase 2]: Objeto 'Torch' no renderizado en Map/Jungle.") end
                    ForceTouchV7(torch, torchCF)
                    
                    if WaitForItem("Torch", 5) then -- Reducido a 5s de espera por agilidad
                        Notify("✅ ¡Antorcha obtenida!")
                        phaseAttempts[2] = 0
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 2]: " .. tostring(err)) end
                continue
            end

            -- Fase 3: Desierto (Quemar Puerta y Recoger Copa) (MODO EXTREMO)
            if currentPhase == 3 then
                local s, err = pcall(function()
                    phaseAttempts[3] = phaseAttempts[3] + 1
                    
                    if phaseAttempts[3] > 5 then
                        Notify("⚠️ 5 intentos en Desierto. ¡Forzando avance a Fase 4 (Nieve)!")
                        MaxSaberPhaseReached = math.max(MaxSaberPhaseReached, 4)
                        phaseAttempts[3] = 0
                        return
                    end
                    
                    Notify("Fase 3: Desierto (Puerta y Copa) - Intento " .. phaseAttempts[3] .. "/5")
                    local desert = SafeGetMapFolder("Desert")
                    local doorBurn = desert and desert:FindFirstChild("Burn")
                    
                    if doorBurn then
                        if HasItem("Torch") then
                            EquipToolByName("Torch")
                            ForceTouchV7(doorBurn, doorBurn.CFrame)
                            task.wait(3)
                        else
                            -- Ya no retrocede. Gasta el intento advirtiendo.
                            warn("Polar Hub [Fase 3]: Intentando avanzar sin Antorcha física...")
                        end
                    else
                        Notify("Fase 3: Puerta ya quemada o no existe.")
                    end

                    local cupCF = CFrame.new(1114.26, 4.17, 4366.15)
                    local cup = desert and desert:FindFirstChild("Cup")
                    ForceTouchV7(cup, cupCF)

                    if WaitForItem("Cup", 5) then
                        Notify("✅ ¡Copa obtenida exitosamente!")
                        phaseAttempts[3] = 0
                    else
                        warn("Polar Hub [Fase 3]: Fallo al obtener Copa. Se forzará en próximos intentos.")
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 3]: " .. tostring(err)) end
                continue
            end

            -- Fase 4: Llenar Copa y dársela al Sick Man
            if currentPhase == 4 then
                local s, err = pcall(function()
                    phaseAttempts[4] = phaseAttempts[4] + 1
                    if phaseAttempts[4] > 5 then
                        Notify("⚠️ 5 intentos en Sick Man. ¡Forzando avance a Fase 5!")
                        MaxSaberPhaseReached = 5
                        phaseAttempts[4] = 0
                        return
                    end
                    
                    Notify("Fase 4: Llenando Copa en la Nieve (Intento " .. phaseAttempts[4] .. "/5)")
                    local fillCF = CFrame.new(1394.12, 37.38, -1320.83)
                    
                    if HasItem("FilledCup") then
                        EquipToolByName("FilledCup")
                    elseif HasItem("Cup") then
                        EquipToolByName("Cup")
                    end
                    
                    ForceTouchV7(nil, fillCF)
                    task.wait(4)
                    
                    if HasItem("FilledCup") then
                        Notify("Fase 4: Copa llena. Entregando a Sick Man...")
                        TalkToNPCV7("Sick Man", CFrame.new(1395.4, 37.3, -1322.5), nil)
                        task.wait(2)
                        
                        -- VERIFICACIÓN FÍSICA: Si ya no tenemos la copa, el NPC la aceptó.
                        if not HasItem("FilledCup") and not HasItem("Cup") then
                            Notify("✅ ¡Sick Man ayudado! Avanzando a Fase 5...")
                            MaxSaberPhaseReached = 5
                            phaseAttempts[4] = 0
                        else
                            warn("Polar Hub [Error Fase 4]: Sick Man no tomó la copa. Reintentando...")
                        end
                    else
                        warn("Polar Hub [Error Fase 4]: La copa no se llenó con agua.")
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 4]: " .. tostring(err)) end
                continue
            end

            -- Fase 5: Ir a Rich Man (Primer Encuentro)
            if currentPhase == 5 then
                local s, err = pcall(function()
                    phaseAttempts[5] = phaseAttempts[5] + 1
                    if phaseAttempts[5] > 5 then
                        Notify("⚠️ 5 intentos en Rich Man. ¡Forzando avance a Fase 6!")
                        MaxSaberPhaseReached = 6
                        phaseAttempts[5] = 0
                        return
                    end
                    
                    Notify("Fase 5: Volando hacia Rich Man (Intento " .. phaseAttempts[5] .. "/5)...")
                    TalkToNPCV7("Rich Man", CFrame.new(-1145, 4.7, 3828.6), "RichMan")
                    task.wait(3)
                    
                    Notify("✅ ¡Hablamos con Rich Man! Avanzando a cazar al Mob Leader...")
                    MaxSaberPhaseReached = 6
                    phaseAttempts[5] = 0
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 5]: " .. tostring(err)) end
                continue
            end

            -- Fase 6: Matar Mob Leader y Reclamar Reliquia
            if currentPhase == 6 then
                local s, err = pcall(function()
                    phaseAttempts[6] = phaseAttempts[6] + 1
                    if phaseAttempts[6] > 40 then
                        HandleCriticalFailure(6)
                        return
                    end
                    
                    local mobLeaderCF = CFrame.new(-2880.71, 15, 5430.85)
                    local richManCF = CFrame.new(-1145, 4.7, 3828.6)
                    
                    -- 1. Intentar cobrar recompensa ANTES de cazar (Por si ya lo matamos antes)
                    if phaseAttempts[6] == 1 or phaseAttempts[6] % 4 == 0 then
                        Notify("Fase 6: Verificando estado con Rich Man...")
                        TalkToNPCV7("Rich Man", richManCF, "RichMan")
                        task.wait(3)
                        if HasItem("Relic") then
                            Notify("✅ ¡Reliquia obtenida! Avanzando a Fase 7...")
                            MaxSaberPhaseReached = 7
                            phaseAttempts[6] = 0
                            return
                        end
                    end
                    
                    -- 2. Si no tenemos la reliquia, buscamos al Mob Leader
                    if IsEnemyAlive("Mob Leader") then
                        Notify("🎯 ¡Mob Leader encontrado! Entrando en combate...")
                        ExclusiveTargetLock(mobLeaderCF, "Mob Leader", 600)
                        Notify("✅ ¡Mob Leader derrotado! Yendo a reclamar recompensa...")
                        task.wait(3)
                        
                        -- Reclamar insistentemente
                        for i = 1, 3 do
                            TalkToNPCV7("Rich Man", richManCF, "RichMan")
                            task.wait(3)
                            if HasItem("Relic") then
                                Notify("✅ ¡Reliquia obtenida! Avanzando a Fase 7...")
                                MaxSaberPhaseReached = 7
                                phaseAttempts[6] = 0
                                return
                            end
                        end
                        Notify("⚠️ No se recibió la reliquia. Se reintentará en el próximo ciclo...")
                    else
                        Notify("⏳ Mob Leader no spawneado. Esperando en isla (Intento " .. phaseAttempts[6] .. "/40)...")
                        local hrp = GetHRP()
                        if hrp and (hrp.Position - mobLeaderCF.Position).Magnitude > 100 then
                            SafeFly(mobLeaderCF, false)
                        end
                        task.wait(5)
                    end
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 6]: " .. tostring(err)) end
                continue
            end

            -- Fase 7: Usar Relic
            if currentPhase == 7 then
                local s, err = pcall(function()
                    phaseAttempts[7] = phaseAttempts[7] + 1
                    
                    if phaseAttempts[7] > 5 then
                        Notify("⚠️ 5 intentos con Relic. ¡Forzando avance a Fase 8 (Saber Expert)!")
                        MaxSaberPhaseReached = 8
                        phaseAttempts[7] = 0
                        return
                    end
                    
                    Notify("Fase 7: Abriendo bóveda con Relic (Intento " .. phaseAttempts[7] .. "/5)...")
                    EquipToolByName("Relic")
                    local relicCF = CFrame.new(-1406.8, 29.8, 3.8)
                    local jungle = SafeGetMapFolder("Jungle")
                    local relicDoor = jungle and jungle:FindFirstChild("Relic", true)
                    
                    if not relicDoor then warn("Polar Hub [Error Fase 7]: Puerta 'Relic' no encontrada en Map/Jungle.") end
                    ForceTouchV7(relicDoor, relicCF)
                    task.wait(3)
                    
                    Notify("✅ ¡Reliquia colocada! Avanzando a Fase 8...")
                    MaxSaberPhaseReached = 8
                    phaseAttempts[7] = 0
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 7]: " .. tostring(err)) end
                continue
            end

            -- Fase 8: Saber Expert
            if currentPhase == 8 or currentPhase == 9 then
                local s, err = pcall(function()
                    if HasItem("Saber") or currentPhase == 9 then
                        Notify("🎉 ¡ÉXITO TOTAL! Ya tienes la espada Saber.")
                        AutoSaberRunning = false
                        CurrentBotState = STATE_IDLE
                        return
                    end
                    
                    Notify("Fase 8: Validando Saber Expert...")
                    local shanksCF = CFrame.new(-1461, 30, -51)
                    ForceTouchV7(nil, shanksCF)
                    task.wait(1)
                    
                    if not IsEnemyAlive("Saber Expert") then
                        phaseAttempts[8] = phaseAttempts[8] + 1
                        -- Los bosses tardan hasta 30 min en reaparecer.
                        -- 120 intentos x 10s = 20 minutos de espera paciente.
                        if phaseAttempts[8] > 120 then
                            Notify("⚠️ Saber Expert no ha spawneado en 20 min. Reiniciando contador...")
                            phaseAttempts[8] = 0
                            return
                        end
                        -- Mostrar progreso sin alarmar al usuario
                        if phaseAttempts[8] % 6 == 1 then -- Solo notificar cada ~60s
                            local minutesWaited = math.floor(phaseAttempts[8] * 10 / 60)
                            Notify("⏳ Esperando spawn de Saber Expert... (" .. minutesWaited .. " min)")
                        end
                        -- Mantenerse en la zona de spawn
                        local hrp = GetHRP()
                        if hrp and (hrp.Position - shanksCF.Position).Magnitude > 100 then
                            SafeFly(shanksCF, false)
                        end
                        task.wait(10)
                        return
                    end

                    -- Boss está vivo, entrar en combate
                    EquipWeapon()
                    phaseAttempts[8] = 0
                    Notify("⚔️ ¡Matando a Shanks (Saber Expert)!")
                    ExclusiveTargetLock(shanksCF, "Saber Expert", 600)
                    WaitForItem("Saber", 10)
                end)
                if not s then warn("Polar Hub [Error Crítico Fase 8]: " .. tostring(err)) end
                if not AutoSaberRunning then break end
                continue
            end
            
            -- FIX #9: Else con warn al final del loop si ninguna fase coincidió
            warn("Polar Hub [Loop Principal]: Fase " .. tostring(currentPhase) .. " no tiene handler definido. MaxPhase=" .. tostring(MaxSaberPhaseReached))
        end
        
        -- Limpieza Final
        AutoSaberRunning = false
        -- FIX #15: Restaurar CurrentBotState al terminar FullAutoSaber
        CurrentBotState = STATE_IDLE
    end)
end
local AutoHakiEnabled = true
task.spawn(function()
    while true do
        if not AutoHakiEnabled then
            task.wait(1)
            continue
        end
        task.wait(0.5)
        -- FIX: Activar Haki automáticamente si está encendido
        if AutoHakiEnabled and CommF then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild("HasBuso") then 
                pcall(function() CommF:InvokeServer("Buso") end) 
            end
        end
    end
end)


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

local TabFarm = Window:Tab({ Title = "Farm", Icon = "swords" })
local TabStats = Window:Tab({ Title = "Stats", Icon = "user" })
local TabStatus = Window:Tab({ Title = "Status", Icon = "activity" })
local TabShop = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local TabQuest = Window:Tab({ Title = "Quest Farm", Icon = "map" })
local TabTeleport = Window:Tab({ Title = "Teleport", Icon = "globe" })
local TabCombat = Window:Tab({ Title = "Combat PvP", Icon = "crosshair" })
local TabMisc = Window:Tab({ Title = "Misc", Icon = "settings" })


-- ===== TAB FARM =====
TabFarm:Section({ Title = "Configuración de Combate" })

TabFarm:Dropdown({
    Title = "Farm Tool (Arma)",
    Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Value = "Melee",
    Callback = function(Value)
        SelectedWeaponType = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Mastery Inteligente",
    Desc = "Baja la vida con tu Farm Tool, y remata (cuando le quede < 20%) con el arma que elijas abajo.",
    Callback = function(Value)
        AutoMasteryEnabled = Value
    end
})

TabFarm:Dropdown({
    Title = "Arma a Masterizar (Auto Mastery)",
    Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Value = "Sword",
    Callback = function(Value)
        AutoMasteryItem = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Skills",
    Desc = "Usa las habilidades Z, X, C, V, F automáticamente mientras farmeas.",
    Callback = function(Value)
        AutoSkillsEnabled = Value
    end
})

TabFarm:Section({ Title = "Auto Farm Automático" })

TabFarm:Toggle({
    Title = "Auto Farm Nivel (100% Automático)",
    Desc = "Detecta nivel, vuela a la isla, toma misión y ataca.",
    Callback = function(Value)
        AutoFarmEnabled = Value
        FastAttackEnabled = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Chest (Farm Beli)",
    Callback = function(Value)
        AutoChestEnabled = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm Nearest (Masacre Total)",
    Desc = "Ignora misiones y niveles. Aniquila al NPC más cercano en la isla actual. Exterminio masivo.",
    Callback = function(Value)
        AutoFarmNearestEnabled = Value
        FastAttackEnabled = Value
    end
})

-- ==================== TAB FARM (BOSS SECTION) ====================
TabFarm:Section({ Title = "Cazador de Jefes (Bosses)" })

local BossNamesList = {}
for _, b in ipairs(Sea1Bosses) do table.insert(BossNamesList, b.name) end

TabFarm:Dropdown({
    Title = "Seleccionar Jefe",
    Values = BossNamesList,
    Value = "Gorilla King",
    Callback = function(Value)
        SelectedBossToFarm = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm Boss Seleccionado",
    Desc = "Caza exclusivamente al jefe seleccionado arriba.",
    Callback = function(Value)
        AutoFarmBossEnabled = Value
        FastAttackEnabled = Value
    end
})

TabFarm:Toggle({
    Title = "Auto Farm ALL Bosses",
    Desc = "Modo Exterminio: Escanea el servidor y caza a TODOS los jefes vivos.",
    Callback = function(Value)
        AutoFarmAllBossesEnabled = Value
        FastAttackEnabled = Value
        lastBossCheckedIndex = 1
    end
})

TabFarm:Toggle({
    Title = "Tomar Misión del Jefe",
    Desc = "Si está desactivado, los cazará a sangre fría ignorando requisitos de nivel.",
    Callback = function(Value)
        BossWithQuest = Value
    end
})

-- ===== TAB STATS =====
TabStats:Section({ Title = "Mejoras de Jugador" })

TabStats:Toggle({
    Title = "Player & NPC ESP",
    Callback = function(Value)
        ESPEnabled = Value
        UpdateESPState()
    end
})

TabStats:Toggle({
    Title = "Auto Haki (Buso)",
    Default = true,
    Callback = function(Value)
        AutoHakiEnabled = Value
    end
})

TabStats:Section({ Title = "Auto Stats Equitativo" })

local function ToggleStat(statName, value)
    if value then
        if not table.find(activeStats, statName) then table.insert(activeStats, statName) end
    else
        local idx = table.find(activeStats, statName)
        if idx then table.remove(activeStats, idx) end
    end
end

TabStats:Toggle({ Title = "Melee", Callback = function(v) ToggleStat("Melee", v) end })
TabStats:Toggle({ Title = "Defense", Callback = function(v) ToggleStat("Defense", v) end })
TabStats:Toggle({ Title = "Sword", Callback = function(v) ToggleStat("Sword", v) end })
TabStats:Toggle({ Title = "Gun", Callback = function(v) ToggleStat("Gun", v) end })
TabStats:Toggle({ Title = "Demon Fruit", Callback = function(v) ToggleStat("Demon Fruit", v) end })

TabStats:Toggle({
    Title = "Activar Auto Stats",
    Desc = "Divide tus puntos equitativamente.",
    Callback = function(Value)
        AutoStatsEnabled = Value
    end
})


-- ===== TAB STATUS =====
TabStatus:Section({ Title = "Telemetría del Servidor" })

local LabelServerUptime = TabStatus:Paragraph({
    Title = "Tiempo de Vida del Servidor",
    Desc = "Calculando..."
})

local LabelPlayerTime = TabStatus:Paragraph({
    Title = "Tiempo en Sesión (Jugador)",
    Desc = "Calculando..."
})

TabStatus:Section({ Title = "Radar de Jefes Especiales (Sea 1)" })

local LabelTheSaw = TabStatus:Paragraph({
    Title = "The Saw (Nvl 100) - Middle Town",
    Desc = "Estado: Calculando..."
})

local LabelGreybeard = TabStatus:Paragraph({
    Title = "Greybeard (Nvl 750) - Marine Fortress",
    Desc = "Estado: Calculando..."
})

local scriptStartTime = os.time()

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function UpdatePara(para, newDesc)
    if not para then return end
    pcall(function()
        if para.SetDesc then para:SetDesc(newDesc)
        elseif para.Set then para:Set({Desc = newDesc}) end
    end)
end

local function GetExactBossTimer(bossName)
    local foundTimer = nil
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            local isTargetBoss = false
            local timerText = nil
            
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text then
                    local textLower = string.lower(child.Text)
                    if string.find(textLower, string.lower(bossName)) then
                        isTargetBoss = true
                    end
                    local matchTimer = string.match(child.Text, "%[(%d+:%d+:%d+)%]") or string.match(child.Text, "%[(%d+:%d+)%]")
                    if matchTimer then
                        timerText = matchTimer
                    end
                end
            end
            
            if isTargetBoss and timerText then
                foundTimer = timerText
            end
        end
    end
    return foundTimer
end

task.spawn(function()
    while true do
        task.wait(5) -- OPTIMIZADO: Espera aumentada para evitar lag extremo de búsqueda en workspace
        pcall(function()
            local serverUptime = workspace.DistributedGameTime
            UpdatePara(LabelServerUptime, FormatTime(serverUptime))
            
            local sessionTime = os.time() - scriptStartTime
            UpdatePara(LabelPlayerTime, FormatTime(sessionTime))
            
            local enemies = workspace:FindFirstChild("Enemies")
            
            -- THE SAW
            local sawAlive = false
            if enemies and enemies:FindFirstChild("The Saw") then sawAlive = true end
            
            if sawAlive then
                UpdatePara(LabelTheSaw, "🟢 SPAWNEADO! (¡Ve a matarlo!)")
            else
                local exactTimer = GetExactBossTimer("The Saw")
                if exactTimer then
                    UpdatePara(LabelTheSaw, "🔴 MUERTO\nPróximo Spawn (Holograma Oficial): " .. exactTimer)
                else
                    UpdatePara(LabelTheSaw, "🔴 MUERTO\nPróximo Spawn: Esperando sincronización...")
                end
            end
            
            -- GREYBEARD
            local greyAlive = false
            if enemies and enemies:FindFirstChild("Greybeard") then greyAlive = true end
            
            if greyAlive then
                UpdatePara(LabelGreybeard, "🟢 SPAWNEADO! (¡Ve a matarlo!)")
            else
                local exactTimer = GetExactBossTimer("Greybeard")
                if exactTimer then
                    UpdatePara(LabelGreybeard, "🔴 MUERTO\nPróximo Spawn (Holograma Oficial): " .. exactTimer)
                else
                    UpdatePara(LabelGreybeard, "🔴 MUERTO\nPróximo Spawn: Esperando sincronización...")
                end
            end
        end)
    end
end)


-- ===== TAB SHOP =====
TabShop:Section({ Title = "Habilidades (Bypass Distancia)" })
TabShop:Button({ Title = "Comprar Geppo (Skyjump) - $10k", Callback = function() BuyItem("BuyHaki", "Geppo", nil, "Ability Teacher") end })
TabShop:Button({ Title = "Comprar Buso (Aura) - $25k", Callback = function() BuyItem("BuyHaki", "Buso", nil, "Ability Teacher") end })
TabShop:Button({ Title = "Comprar Soru (Flash Step) - $100k", Callback = function() BuyItem("BuyHaki", "Soru", nil, "Ability Teacher") end })
TabShop:Button({ Title = "Comprar Ken Haki (Observation) - $750k", Callback = function() BuyItem("KenTalk", "Buy", nil, "Instinct Teacher") end })

TabShop:Section({ Title = "Estilos de Pelea (Ghost TP Bypass)" })
TabShop:Button({ Title = "Dark Step (Teacher) - $150k", Callback = function() BuyItem("BuyBlackLeg", nil, nil, "Dark Step Teacher") end })
TabShop:Button({ Title = "Electro (Mad Scientist) - $500k", Callback = function() BuyItem("BuyElectro", nil, nil, "Mad Scientist") end })
TabShop:Button({ Title = "Water Kung Fu (Teacher) - $750k", Callback = function() BuyItem("BuyFishmanKarate", nil, nil, "Water Kung Fu Teacher") end })

TabShop:Section({ Title = "Espadas Avanzadas (Sword Dealer)" })
TabShop:Button({ Title = "Katana Clásica - $1k", Callback = function() BuyItem("BuyItem", "Katana", nil, "Sword Dealer") end })
TabShop:Button({ Title = "Dual Katana - $12k", Callback = function() BuyItem("BuyItem", "Dual Katana", nil, "Sword Dealer") end })
TabShop:Button({ Title = "Iron Mace - $25k", Callback = function() BuyItem("BuyItem", "Iron Mace", nil, "Sword Dealer") end })
TabShop:Button({ Title = "Triple Katana - $60k", Callback = function() BuyItem("BuyItem", "Triple Katana", nil, "Sword Dealer") end })
TabShop:Button({ Title = "Pipe (Tubería) - $100k", Callback = function() BuyItem("BuyItem", "Pipe", nil, "Sword Dealer") end })
TabShop:Button({ Title = "Soul Cane (Bastón) - $750k", Callback = function() BuyItem("BuyItem", "Soul Cane", nil, "Living Skeleton") end })
TabShop:Button({ Title = "Bisento (Barbablanca) - $1M", Callback = function() BuyItem("BuyItem", "Bisento", nil, "Master Sword Dealer") end })

TabShop:Section({ Title = "Armas de Fuego (Weapon Dealer)" })
TabShop:Button({ Title = "Slingshot (Resortera) - $5k", Callback = function() BuyItem("BuyItem", "Slingshot", nil, "Weapon Dealer") end })
TabShop:Button({ Title = "Musket (Mosquete) - $8k", Callback = function() BuyItem("BuyItem", "Musket", nil, "Weapon Dealer") end })
TabShop:Button({ Title = "Flintlock (Pistola) - $10k", Callback = function() BuyItem("BuyItem", "Flintlock", nil, "Weapon Dealer") end })


-- ===== TAB QUEST FARM =====

TabQuest:Section({ Title = "Habilidades Especiales" })
TabQuest:Button({ 
    Title = "Auto Desbloquear Ken Haki (Visión) - $750k", 
    Callback = function() 
        local data = LocalPlayer:FindFirstChild("Data")
        local lvl = data and data:FindFirstChild("Level") and data.Level.Value or 1
        if lvl >= 300 then
            BuyItem("KenTalk", "Buy")
        else
            warn("❌ Error Polar Hub: Necesitas Nivel 300 para el Ken Haki.")
        end
    end 
})

TabQuest:Section({ Title = "Saber Puzzle (100% Automático)" })
TabQuest:Paragraph({
    Title = "Auto Saber Definitivo",
    Desc = "Presiona INICIAR y el bot viajará por 4 islas, presionará los botones secretos, tomará la antorcha, quemará paredes, y masacrará a los jefes de la mafia y a Shanks de forma autónoma."
})

TabQuest:Button({
    Title = "▶ Iniciar Auto Saber Puzzle",
    Callback = function()
        if not AutoSaberRunning then
            FullAutoSaber()
        end
    end
})

TabQuest:Button({
    Title = "⏹ Detener Auto Saber",
    Callback = function()
        AutoSaberRunning = false
        AutoMobLeaderEnabled = false
        AutoSaberExpertEnabled = false
    end
})

TabQuest:Section({ Title = "Caza de Jefes (Modo Manual)" })

TabQuest:Toggle({
    Title = "Auto Matar Mob Leader (Nvl 120)",
    Default = false,
    Callback = function(v)
        AutoMobLeaderEnabled = v
        FastAttackEnabled = v
    end
})

TabQuest:Toggle({
    Title = "Auto Matar Saber Expert / Shanks (Nvl 200)",
    Default = false,
    Callback = function(v)
        AutoSaberExpertEnabled = v
        FastAttackEnabled = v
    end
})

-- ===== TAB TELEPORT =====
TabTeleport:Section({ Title = "Viajes Dinámicos" })

local SelectedIsland = ""
TabTeleport:Dropdown({
    Title = "Isla a Volar",
    Values = ScanIslands(),
    Callback = function(Value)
        SelectedIsland = Value
    end
})

TabTeleport:Button({
    Title = "Volar Hacia Isla (Tween)",
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

TabCombat:Section({ Title = "Bounty Hunter Tracker" })

local SelectedTarget = nil
local TargetSetInfo = "Esperando objetivo..."

-- Desplegable para seleccionar jugador
local PlayerDropdown = TabCombat:Dropdown({
    Title = "Seleccionar Víctima",
    Values = {"Nadie"},
    Callback = function(Value)
        if Value ~= "Nadie" then
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

TabCombat:Button({
    Title = "🔄 Actualizar Lista del Servidor",
    Callback = function()
        RefreshPlayerList()
    end
})

local LabelTargetInfo = TabCombat:Paragraph({
    Title = "Inspección Táctica (Set & Stats)",
    Desc = TargetSetInfo
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

TabCombat:Button({
    Title = "🚀 Teletransportarse al Objetivo",
    Callback = function()
        if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            BypassTeleport(SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        end
    end
})

-- ==================== MODO COMBATE (TOGGLE MAESTRO) ====================
-- ANTI-LAG: Los hooks y bucles de Hitbox/Silent Aim NO se ejecutan
-- hasta que actives este toggle. Esto garantiza 0 lag si no estás en PvP.
TabCombat:Section({ Title = "⚡ Modo Combate (Anti-Lag)" })

local CombatModeEnabled = false
local CombatHooksInjected = false -- Flag para inyectar hooks solo 1 vez

TabCombat:Toggle({
    Title = "⚡ Activar Modo Combate",
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
TabCombat:Section({ Title = "Aimbot & Hitbox" })

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

TabCombat:Toggle({
    Title = "Activar Hitbox Expander",
    Desc = "Aumenta la caja de colisión de los enemigos. Requiere Modo Combate activado. (15-25 es óptimo)",
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then RestoreAllHitboxes() end
    end
})

TabCombat:Slider({
    Title = "Tamaño de Hitbox",
    Value = { Min = 5, Max = 40, Default = 15 },
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

TabCombat:Toggle({
    Title = "Silent Aim (Full Aimbot)",
    Desc = "Redirige Mouse.Hit, remotos y skills al objetivo. Armas como Tirachinas apuntan solas. Requiere Modo Combate.",
    Callback = function(Value)
        SilentAimEnabled = Value
    end
})

TabCombat:Toggle({
    Title = "Bring Target (Atraer Víctima)",
    Desc = "Teletransporta la víctima frente a ti. Combo letal con Silent Aim. Requiere Modo Combate.",
    Callback = function(Value)
        BringTargetEnabled = Value
    end
})

TabCombat:Section({ Title = "Combate Extremo" })

local KillAuraEnabled = false
TabCombat:Toggle({
    Title = "Kill Aura (Destrucción Total)",
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
TabMisc:Section({ Title = "Utilidades Extra" })

local FruitFinderEnabled = false
local foundFruits = {}
TabMisc:Toggle({
    Title = "Buscador de Frutas (Fruit Finder)",
    Desc = "Notifica si aparece una fruta en el mapa.",
    Callback = function(Value)
        FruitFinderEnabled = Value
    end
})

local FlyEnabled = false
local flySpeed = 50
local flyBodyMover = nil
TabMisc:Toggle({
    Title = "Modo Fly Libre",
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
TabMisc:Toggle({
    Title = "Auto Rejoin",
    Desc = "Te reconecta al instante si eres expulsado.",
    Callback = function(Value)
        AutoRejoinEnabled = Value
    end
})

TabMisc:Section({ Title = "Movimiento" })

TabMisc:Slider({
    Title = "Nivel de Velocidad",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(Value)
        sVal = Value
    end
})

TabMisc:Toggle({
    Title = "Control de Velocidad",
    Callback = function(Value)
        sAct = Value
    end
})

TabMisc:Toggle({
    Title = "Salto Infinito",
    Callback = function(Value)
        iJ = Value
    end
})

TabMisc:Toggle({
    Title = "Atravesar Paredes (NoClip)",
    Callback = function(Value)
        ncl = Value
    end
})

TabMisc:Toggle({
    Title = "Caminar sobre el Agua",
    Callback = function(Value)
        walkWaterEnabled = Value
    end
})

TabMisc:Section({ Title = "Sistema" })

TabMisc:Button({
    Title = "Server Hop (Saltar Servidor)",
    Callback = function()
        ServerHop()
    end
})

-- ==================== LOGICA DE UTILIDADES Y COMBATE EXTREMO ====================

task.spawn(function()
    while true do
        task.wait(1)
        if AutoSkillsEnabled and (AutoFarmEnabled or AutoFarmBossEnabled or AutoFarmAllBossesEnabled or AutoSaberExpertEnabled or AutoMobLeaderEnabled or AutoFarmNearestEnabled) then
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
                    local farmingActive = (AutoFarmNearestEnabled or AutoFarmBossEnabled or AutoFarmAllBossesEnabled or AutoSaberExpertEnabled or AutoMobLeaderEnabled or CurrentBotState ~= STATE_IDLE)
                    
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
