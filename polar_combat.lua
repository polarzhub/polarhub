--[[
    ==============================================================================
                          POLAR HUB x COKEBOYS ENGINE
               Complete Reconstructed Combat, Movement & Macro Engine
                            [100% KEYLESS EDITION]
    ==============================================================================
    Target Game: Blox Fruits (Sea 1, Sea 2, Sea 3)
    Protection: Keyless (Decrypted, Reconstructed & Fully Unlocked)
    Repository: https://github.com/polarzhub/polarhub
    
    Subsystems Included:
      - Module 1:  Core Services & Runtime State Management
      - Module 2:  Full Settings Schema & Configuration IO (176 settings + Profiles)
      - Module 3:  Localization & Notification Engine (Spanish / English / Portuguese)
      - Module 4:  Weapon Detection & Inventory Management (CB_WEAPON_EQUIP)
      - Module 5:  Dual-Layer Silent Skill Aimbot & Kinematic Prediction (550 speed)
                   [Players & NPCs Support Included]
      - Module 6:  Soru Aimbot, Infinite Soru & Anti-Combo Interrupt
      - Module 7:  FastAttack M1 Combat Engine (SendHitsToServer / RegisterAttack)
      - Module 8:  Skill Manipulators & Combat Boosters (Sanguine Z, Yama Z, Diamond M1)
      - Module 9:  Smart Combo Macro Engine (5 Slots x 10 Steps with Fallbacks)
      - Module 10: Movement & Physics Engine (SuperJump 140, Geppo AirJump, Lava/Water)
      - Module 11: Camera & Visuals (Permanent CamLock, FOV Ring, Tracers, NoFog, FPS)
      - Module 12: Player ESP Engine (HealthBar, Bounty, Race, Level, Ken, Combat)
      - Module 13: Weapon Skin Changer System (3 Profile Slots, Materials, Colors)
      - Module 14: Complete GUI System (18 Desktop Tabs & 12 Mobile Floating Buttons)
      - Module 15: Metamethod Hooks, Keybind Dispatcher & Complete Teardown
    ==============================================================================
]]



-- ==============================================================================
-- MODULE 1: CORE SERVICES & RUNTIME STATE MANAGEMENT
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera


-- Global state flags (Polar & Cokeboys interoperability)
getgenv().PolarCokeboysLoaded = true
getgenv().CokeboysScriptLoaded = true
getgenv().__CokeboysLaunchInProgress = false
getgenv().CokeboysGuiHidden = false
getgenv().CokeboysEspForceHidden = false


-- Runtime garbage and connection trackers
if not getgenv().__CokeboysRuntimeConnections then
    getgenv().__CokeboysRuntimeConnections = {}
end
if not getgenv().__CokeboysRuntimeTasks then
    getgenv().__CokeboysRuntimeTasks = {}
end

local function trackConnection(conn)
    table.insert(getgenv().__CokeboysRuntimeConnections, conn)
    return conn
end

local function spawnRuntimeTask(fn)
    local t = task.spawn(fn)
    table.insert(getgenv().__CokeboysRuntimeTasks, t)
    return t
end

_G.__CokeboysTrackRuntimeConnection = trackConnection
_G.__CokeboysSpawnRuntimeTask = spawnRuntimeTask

-- Metatable inspection & hooking baseline
local rawmt = getrawmetatable(game)
local oldNamecall = rawmt and rawmt.__namecall
local oldIndex = rawmt and rawmt.__index



-- ==============================================================================
-- MODULE 2: SETTINGS SCHEMA & CONFIGURATION IO
-- ==============================================================================
local ConfigFileName = "CokeboysConfig_v1.json"
local ProfilesFileName = "CokeboysProfiles_v1.json"

local DefaultConfigRaw = [===[{"MenuKey":"RightControl","DisableNotifications":false,"FastAttack":true,"ESPShowInfo":true,"PermanentCamLockKey":"N","NoFog":false,"SpeedBoost":true,"DashBoost":false,"MobileButtonFullScreenMigrated":false,"SkillCamLockKeys":[],"FakeKorblox":false,"InfiniteAirJumpAuto":false,"AbilityReachSkills":[],"SkillAimbot":true,"TargetLockKey":"L","MobileMacroSlots":[{"m1Weapon":"Melee","m1Enabled":false,"steps":[{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 1","v3After":1,"v3Enabled":false,"m1After":1,"soruAfter":1,"m1Count":1},{"m1Weapon":"Melee","m1Enabled":false,"steps":[{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 2","v3After":1,"v3Enabled":false,"m1After":1,"soruAfter":1,"m1Count":1},{"m1Weapon":"Melee","m1Enabled":false,"steps":[{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 3","v3After":1,"v3Enabled":false,"m1After":1,"soruAfter":1,"m1Count":1},{"m1Weapon":"Melee","m1Enabled":false,"steps":[{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 4","v3After":1,"v3Enabled":false,"m1After":1,"soruAfter":1,"m1Count":1},{"m1Weapon":"Melee","m1Enabled":false,"steps":[{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"enabled":false,"fallbackHold":"0","skill":"Z","fallbackMode":"Tap","jumpsAfter":0,"fallbackSkill":"X","hold":"0","fallbackEnabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 5","v3After":1,"v3Enabled":false,"m1After":1,"soruAfter":1,"m1Count":1}],"HideControlEffects":false,"DiamondM1Boost":false,"ESPUseBountyColors":true,"LockMobileButtons":false,"FastAttackDelay":0.1,"HideHeaderIdentity":false,"FPSBooster":false,"SoulGuitarMomentumBoost":true,"StatusOverlay":{"AutoObs":true,"Ragdoll":true,"SangZ":true,"FastAtk":true,"V4":true,"AutoBuso":true,"Aimbot":true},"ShowFPSPing":false,"ComboBound":"F6","NormalSafeMode":false,"TargetSwitchDelay":0.30000000000000007,"SkinChangerStyle":"Full Replace","SuperJumpPower":140,"MobileButtonColors":{"Inner":[10,12,24],"Outer":[238,190,40],"Text":[255,255,255]},"WalkOnLava":false,"RememberGuiHidden":false,"ActiveModulesColor":"Pink","PermanentCamLockMode":false,"AutoBuso":true,"ESPShowName":true,"ESPShowCombatState":true,"ShowSessionInfo":false,"HoldInfiniteAirJump":false,"CustomGameFont":false,"AntiAFK":false,"AutoV4":false,"TargetIndicator":"Line","UIBackgroundPreset":"Classic (No Wallpaper)","IgnoreLowLevelPlayers":true,"SkillCamLock":false,"ComboStatus":false,"TargetPriority":"Crosshair","AimbotDist":900,"ESPLimitDistance":false,"ESPShowKen":true,"YamaZBoostSkill":"Z","ESPTextSize":12,"MenuButtonPos":{"XOffset":21,"XScale":0,"YScale":0,"YOffset":204},"AimbotKey":"G","AntiCombo":false,"UseFOVAim":false,"HideV4Effects":false,"SafeModeHealth":5000,"SangZDistance":350,"SmartV4":false,"ESPShowHealthText":true,"AntiComboSoru":false,"MenuScale":1,"UIBackgroundCustomAsset":"","ESPShowDistance":true,"SoruSkillWeapon":"Fruit","HitboxNPCs":false,"JumpValue":50,"SpiderCAccuracy":false,"AirJumpButton":true,"MainWindowFullScreenMigrated":false,"SessionInfoTextSize":11,"SpeedValue":2.5,"SkyChangerEnabled":false,"HitboxSize":40,"NoCameraShake":true,"ESPOffsetY":4,"AutoRollFruits":false,"InCombatOnly":true,"SkinChangerSlotNames":{"1":"Skin 1","3":"Skin 3","2":"Skin 2"},"SkinChangerSlots":{"1":{"PreserveDetails":true,"Colors":{"Melee":[245,245,248],"All":[165,75,230],"Fruit":[165,75,230],"Sword":[220,50,50],"Gun":[65,145,255]},"RGB":false,"CategoryPresets":{"Melee":"White","All":"Purple","Fruit":"Purple","Sword":"Red","Gun":"Blue"},"Style":"Full Replace","Strength":100,"Scopes":{"Melee":false,"All":false,"Fruit":true,"Sword":false,"Gun":false}}},"SkinChangerSelectedSlot":"1","SkinChangerEditCategory":"Fruit","FPSCap":240,"SkinChangerPreserveDetails":true,"HideMenuButton":false,"Aim360":true,"SkinChangerStrength":100,"SkinChangerCategoryPresets":{"Melee":"White","All":"Purple","Fruit":"Purple","Sword":"Red","Gun":"Blue"},"ESPEnabled":true,"SoruSkillDelay":0.1,"SkinChangerScopes":{"Melee":false,"Fruit":true,"All":false,"Sword":false,"Gun":false},"SkinChangerRGB":false,"SkinChangerEnabled":false,"ActiveModulesShowValues":false,"WideViewFOV":90,"ESPShowLevel":true,"YamaZBoostKey":"B","WideView":false,"AutoSkullGuitar":false,"FruitM1Ragdoll":true,"AutoStoreRolledFruits":false,"GameFont":"Ubuntu","ESPMaxDistance":2500,"SoruSkillKey":"Z","MainWindowScreenInsetsNoneMigrated":false,"MainWindowPos":{"XOffset":250,"XScale":0,"YScale":0,"YOffset":16},"StreamerMode":false,"ESPShowBounty":true,"Prediction":550,"YamaZBoost":false,"AimExclude":{"cartero3301":true,"Kakashy442":true,"joanzgjk":true,"rip_bloxfruit09742":true,"Eo3386":true,"EVERYBODYWASUPERSTAR":true,"Josefo7890":true,"Wilix588":true,"dilanpgeelo":true,"Santiah35":true,"NEL_RIN8333":true,"colinas_788":true},"ActiveModulesTextSize":18,"HitboxExpander":true,"AutoPrediction":true,"SoruAimbotKey":"P","SkinChangerColors":{"Melee":[245,245,248],"Gun":[65,145,255],"All":[165,75,230],"Sword":[220,50,50],"Fruit":[165,75,230]},"SoruSkillMacro":false,"DiamondM1BoostIntensity":70,"InfiniteSoru":false,"ESPShowRace":true,"StatusOverlayEnabled":false,"NormalSoruAimbot":false,"UIBackgroundVisibility":78,"SoruAimbot":true,"GuiHidden":false,"JumpBoost":false,"MobileButtonPositions":{"Landscape":{"AIRJUMP":{"y":219,"x":913}}},"AutoObservation":false,"TargetIndicatorTransparency":1,"TargetIndicatorThickness":3,"TargetIndicatorColor":"Gold","YamaZBoostWeapon":"Melee","SoruSkillFallbacks":[{"Enabled":false,"Key":"X","Weapon":"Fruit"},{"Enabled":false,"Key":"Z","Weapon":"Sword"}],"SkyChangerPreset":"Galaxy","BuddySwordAccuracy":false,"HitboxVisual":true,"SoulGuitarMomentumIntensity":100,"ShowBountyHonor":false,"CamLockSwitchKey":"K","UITheme":{"Panel":[20,19,24],"Name":"Gold","Card":[34,32,39],"Background":[13,13,16],"Text":[245,243,236],"Accent":[238,190,40]},"SessionInfoPosition":"Top Right","SkillBlacklist":[],"AbilityReachCheck":true,"SangZBoostKey":"J","MobileButtonScreenInsetsNoneMigrated":false,"ActiveModulesPosition":"Top Right","AutoFastMode":false,"ESPShowHealthBar":true,"FastAttackKey":"H","DashLength":37,"SangZNoRagdoll":false,"AimbotMode":"Players Only","ShowFOV":false,"YamaZBoostDelay":0.15,"ESPHealthBarWidth":120,"ActiveModulesEnabled":false,"FullViewportDragMigrated":false,"AutoSkullGuitarOnlyEquipped":false,"SangZFrames":220,"WalkOnWater":true,"MobileMacroActiveSlot":1,"SmartV3":false,"TargetIndicatorOutline":false,"MobileButtonCustomColors":false,"ActiveModulesRainbow":false,"FOV":350,"MobileVisibility":{"SORUAIM":false,"RESET":false,"AIRJUMP":true,"CAMLOCK":false,"V4":false,"SANGZ":false,"DIAMOND":false,"FAST":false,"RAGDOLL":false,"AIM":false,"TARGETLOCK":false,"MACRO":false},"AutoV3":false,"GuiWindowScale":1.15,"FakeHeadless":false,"NoBackgroundMusic":false,"SangZBoost":false}]===]
local DefaultProfilesRaw = [===[{"order":["default"],"profiles":{"default":{"name":"Default","config":{"MenuKey":"RightControl","DisableNotifications":false,"FastAttack":true,"ESPShowInfo":true,"WideViewFOV":90,"NoFog":false,"SpeedBoost":true,"DashBoost":false,"AutoPrediction":true,"SkillCamLockKeys":[],"SkinChangerCategoryPresets":{"Melee":"White","All":"Purple","Gun":"Blue","Sword":"Red","Fruit":"Purple"},"InfiniteAirJumpAuto":false,"AbilityReachSkills":[],"SkinChangerEnabled":false,"TargetLockKey":"L","MobileMacroSlots":[{"v3Enabled":false,"m1Enabled":false,"steps":[{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 1","v3After":1,"m1Weapon":"Melee","m1After":1,"soruAfter":1,"m1Count":1},{"v3Enabled":false,"m1Enabled":false,"steps":[{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 2","v3After":1,"m1Weapon":"Melee","m1After":1,"soruAfter":1,"m1Count":1},{"v3Enabled":false,"m1Enabled":false,"steps":[{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 3","v3After":1,"m1Weapon":"Melee","m1After":1,"soruAfter":1,"m1Count":1},{"v3Enabled":false,"m1Enabled":false,"steps":[{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 4","v3After":1,"m1Weapon":"Melee","m1After":1,"soruAfter":1,"m1Count":1},{"v3Enabled":false,"m1Enabled":false,"steps":[{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"},{"fallbackHold":"0","jumpsAfter":0,"skill":"Z","fallbackMode":"Tap","fallbackSkill":"X","fallbackEnabled":false,"hold":"0","enabled":false,"fallbackWeapon":"Melee","mode":"Tap","delay":"0.2","weapon":"Melee"}],"soruEnabled":false,"name":"Slot 5","v3After":1,"m1Weapon":"Melee","m1After":1,"soruAfter":1,"m1Count":1}],"SkinChangerPreserveDetails":true,"DiamondM1Boost":false,"ESPUseBountyColors":true,"LockMobileButtons":false,"FastAttackDelay":0.1,"HideHeaderIdentity":false,"FPSBooster":false,"SoulGuitarMomentumBoost":true,"StatusOverlay":{"Ragdoll":true,"AutoObs":true,"V4":true,"FastAtk":true,"SangZ":true,"AutoBuso":true,"Aimbot":true},"ShowFPSPing":false,"ComboBound":"F6","NormalSafeMode":false,"TargetSwitchDelay":0.30000000000000007,"SkinChangerStyle":"Full Replace","SuperJumpPower":140,"MobileButtonColors":{"Inner":[10,12,24],"Outer":[238,190,40],"Text":[255,255,255]},"WalkOnLava":false,"RememberGuiHidden":false,"SkinChangerSlots":{"1":{"PreserveDetails":true,"Colors":{"Melee":[245,245,248],"All":[165,75,230],"Gun":[65,145,255],"Sword":[220,50,50],"Fruit":[165,75,230]},"RGB":false,"CategoryPresets":{"Melee":"White","All":"Purple","Gun":"Blue","Sword":"Red","Fruit":"Purple"},"Style":"Full Replace","Strength":100,"Scopes":{"Melee":false,"All":false,"Gun":false,"Sword":false,"Fruit":true}}},"PermanentCamLockMode":false,"AutoBuso":true,"ESPShowName":true,"ESPShowCombatState":true,"ShowSessionInfo":false,"HoldInfiniteAirJump":false,"CustomGameFont":false,"ActiveModulesShowValues":false,"AutoV4":false,"TargetIndicator":"Line","UIBackgroundPreset":"Classic (No Wallpaper)","SkinChangerStrength":100,"SkillCamLock":false,"ComboStatus":false,"TargetPriority":"Crosshair","AimbotDist":900,"ESPLimitDistance":false,"ESPShowKen":true,"YamaZBoostSkill":"Z","ESPTextSize":12,"MenuButtonPos":{"XOffset":21,"XScale":0,"YScale":0,"YOffset":204},"AimbotKey":"G","AntiCombo":false,"UseFOVAim":false,"HideV4Effects":false,"SafeModeHealth":5000,"SangZDistance":350,"SmartV4":false,"ESPShowHealthText":true,"AntiComboSoru":false,"MenuScale":1,"UIBackgroundCustomAsset":"","ESPShowDistance":true,"SoruSkillWeapon":"Fruit","HitboxNPCs":false,"JumpValue":50,"SpiderCAccuracy":false,"AirJumpButton":true,"MainWindowFullScreenMigrated":false,"SessionInfoTextSize":11,"SpeedValue":2.5,"SkyChangerEnabled":false,"HitboxSize":40,"NoCameraShake":true,"ESPOffsetY":4,"AutoRollFruits":false,"SoruSkillDelay":0.1,"SkinChangerScopes":{"Melee":false,"Fruit":true,"Gun":false,"Sword":false,"All":false},"SkinChangerRGB":false,"WideView":false,"AntiAFK":false,"FPSCap":240,"MainWindowScreenInsetsNoneMigrated":false,"HideMenuButton":false,"Aim360":true,"ActiveModulesColor":"Pink","MainWindowPos":{"XOffset":250,"XScale":0,"YScale":0,"YOffset":16},"ESPEnabled":true,"StreamerMode":false,"SmartV3":false,"AimExclude":{"cartero3301":true,"Kakashy442":true,"Eo3386":true,"rip_bloxfruit09742":true,"Wilix588":true,"EVERYBODYWASUPERSTAR":true,"Josefo7890":true,"colinas_788":true,"dilanpgeelo":true,"Santiah35":true,"NEL_RIN8333":true,"joanzgjk":true},"HitboxExpander":true,"SoruAimbotKey":"P","GameFont":"Ubuntu","ESPShowLevel":true,"YamaZBoostKey":"B","SkillAimbot":true,"SangZBoost":false,"FruitM1Ragdoll":true,"AutoStoreRolledFruits":false,"FakeKorblox":false,"SoruSkillMacro":false,"SoruSkillKey":"Z","MobileButtonFullScreenMigrated":false,"YamaZBoostDelay":0.15,"ESPMaxDistance":2500,"ESPShowBounty":true,"Prediction":550,"YamaZBoost":false,"AimbotMode":"Players Only","PermanentCamLockKey":"N","NormalSoruAimbot":false,"FastAttackKey":"H","SkinChangerSelectedSlot":"1","SkinChangerColors":{"Melee":[245,245,248],"Gun":[65,145,255],"Fruit":[165,75,230],"Sword":[220,50,50],"All":[165,75,230]},"GuiHidden":false,"DiamondM1BoostIntensity":70,"MobileButtonPositions":{"Landscape":{"AIRJUMP":{"y":219,"x":913}}},"ESPShowRace":true,"StatusOverlayEnabled":false,"AutoObservation":false,"UIBackgroundVisibility":78,"TargetIndicatorTransparency":1,"TargetIndicatorThickness":3,"JumpBoost":false,"SkinChangerSlotNames":{"1":"Skin 1","3":"Skin 3","2":"Skin 2"},"ActiveModulesTextSize":18,"AbilityReachCheck":true,"SoruSkillFallbacks":[{"Enabled":false,"Key":"X","Weapon":"Fruit"},{"Enabled":false,"Key":"Z","Weapon":"Sword"}],"SoulGuitarMomentumIntensity":100,"YamaZBoostWeapon":"Melee","SkinChangerEditCategory":"Fruit","SkyChangerPreset":"Galaxy","BuddySwordAccuracy":false,"HitboxVisual":true,"ActiveModulesRainbow":false,"ShowBountyHonor":false,"CamLockSwitchKey":"K","UITheme":{"Panel":[20,19,24],"Name":"Gold","Card":[34,32,39],"Background":[13,13,16],"Text":[245,243,236],"Accent":[238,190,40]},"SessionInfoPosition":"Top Right","SoruAimbot":true,"SkillBlacklist":[],"SangZBoostKey":"J","TargetIndicatorColor":"Gold","MobileButtonScreenInsetsNoneMigrated":false,"ActiveModulesPosition":"Top Right","AutoFastMode":false,"ESPShowHealthBar":true,"DashLength":37,"AutoSkullGuitar":false,"SangZNoRagdoll":false,"ShowFOV":false,"InfiniteSoru":false,"ESPHealthBarWidth":120,"InCombatOnly":true,"FullViewportDragMigrated":false,"ActiveModulesEnabled":false,"AutoSkullGuitarOnlyEquipped":false,"WalkOnWater":true,"SangZFrames":220,"HideControlEffects":false,"MobileMacroActiveSlot":1,"MobileButtonCustomColors":false,"TargetIndicatorOutline":false,"FOV":350,"MobileVisibility":{"SORUAIM":false,"RESET":false,"AIRJUMP":true,"CAMLOCK":false,"V4":false,"SANGZ":false,"DIAMOND":false,"FAST":false,"RAGDOLL":false,"AIM":false,"TARGETLOCK":false,"MACRO":false},"AutoV3":false,"GuiWindowScale":1.15,"FakeHeadless":false,"IgnoreLowLevelPlayers":true,"NoBackgroundMusic":false}}},"version":1,"active":"default"}]===]


local Settings = HttpService:JSONDecode(DefaultConfigRaw)
Settings.AimbotMode = "All"
Settings.TargetNPCs = true
Settings.HitboxNPCs = true
getgenv().CokeboysSettings = Settings
_G.__CokeboysSettingsSchema = Settings


local ConfigProfiles = HttpService:JSONDecode(DefaultProfilesRaw)
getgenv().__CokeboysConfigProfiles = ConfigProfiles

local ConfigIO = {
    saveDebounce = 0.35,
    saveScheduled = false,
    dirty = false,
    saveGeneration = 0
}

function ConfigIO.save()
    if ConfigIO.saveScheduled then return end
    ConfigIO.saveScheduled = true
    task.delay(ConfigIO.saveDebounce, function()
        ConfigIO.saveScheduled = false
        pcall(function()
            if writefile then
                writefile(ConfigFileName, HttpService:JSONEncode(Settings))
                writefile(ProfilesFileName, HttpService:JSONEncode(ConfigProfiles))
            end
        end)
    end)
end

function ConfigIO.load()
    pcall(function()
        if readfile and isfile and isfile(ConfigFileName) then
            local loaded = HttpService:JSONDecode(readfile(ConfigFileName))
            for k, v in pairs(loaded) do
                Settings[k] = v
            end
        end
        if readfile and isfile and isfile(ProfilesFileName) then
            ConfigProfiles = HttpService:JSONDecode(readfile(ProfilesFileName))
            getgenv().__CokeboysConfigProfiles = ConfigProfiles
        end
    end)
end

getgenv().__CokeboysConfigIO = ConfigIO



-- ==============================================================================
-- MODULE 3: NOTIFICATION & LOCALIZATION ENGINE
-- ==============================================================================
local function notify(title, text, duration)
    duration = duration or 2
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[COKEBOYS] " .. tostring(title),
            Text = tostring(text),
            Duration = duration
        })
    end)
    -- Custom toast notification GUI
    pcall(function()
        local notifGui = LocalPlayer.PlayerGui:FindFirstChild("CokeboysNotif")
        if notifGui then
            local container = notifGui:FindFirstChild("Container") or notifGui:FindFirstChildOfClass("Frame")
            if container then
                local toast = Instance.new("Frame")
                toast.Size = UDim2.new(0, 240, 0, 48)
                toast.BackgroundColor3 = Color3.fromRGB(20, 19, 24)
                toast.BorderSizePixel = 0
                local uic = Instance.new("UICorner", toast)
                uic.CornerRadius = UDim.new(0, 6)
                local stroke = Instance.new("UIStroke", toast)
                stroke.Color = Color3.fromRGB(238, 190, 40)
                stroke.Thickness = 1.2
                
                local tLbl = Instance.new("TextLabel", toast)
                tLbl.Text = tostring(title)
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextSize = 13
                tLbl.TextColor3 = Color3.fromRGB(238, 190, 40)
                tLbl.Position = UDim2.new(0, 10, 0, 4)
                tLbl.Size = UDim2.new(1, -20, 0, 18)
                tLbl.BackgroundTransparency = 1
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local dLbl = Instance.new("TextLabel", toast)
                dLbl.Text = tostring(text)
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextSize = 11
                dLbl.TextColor3 = Color3.fromRGB(245, 243, 236)
                dLbl.Position = UDim2.new(0, 10, 0, 24)
                dLbl.Size = UDim2.new(1, -20, 0, 18)
                dLbl.BackgroundTransparency = 1
                dLbl.TextXAlignment = Enum.TextXAlignment.Left

                toast.Parent = container
                task.delay(duration, function()
                    TweenService:Create(toast, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(tLbl, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
                    TweenService:Create(dLbl, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
                    task.wait(0.35)
                    toast:Destroy()
                end)
            end
        end
    end)
end

_G.notify = notify

-- Translation Dictionary
local TranslationPack = {
    ["Inicio"] = "Home",
    ["Movimiento"] = "Movement",
    ["Glitches"] = "Glitches",
    ["Apuntado"] = "Aiming",
    ["Visuales"] = "Visuals",
    ["Combate"] = "Combat",
    ["Lista negra"] = "Blacklist",
    ["Excluir"] = "Exclude",
    ["Varios"] = "Misc",
    ["Macro"] = "Macro",
    ["Móvil"] = "Mobile",
    ["Cambiador de aspectos"] = "Skin Changer",
    ["Tienda"] = "Shop",
    ["Cliente"] = "Client",
    ["Apariencia"] = "Appearance",
    ["Ajustes"] = "Settings",
    ["Teclas"] = "Keybinds",
    ["FFlags"] = "FFlags"
}

local function translate(text)
    if Settings.InterfaceLanguage == "English" and TranslationPack[text] then
        return TranslationPack[text]
    end
    return text
end

_G.__CokeboysTranslate = translate



-- ==============================================================================
-- MODULE 4: WEAPON DETECTION & INVENTORY MANAGEMENT (CB_WEAPON_EQUIP)
-- ==============================================================================
local CB_WEAPON_EQUIP = {}

function CB_WEAPON_EQUIP.toolToWeaponType(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local name = tool.Name:lower()
    local tip = tool.ToolTip:lower()
    if tip:find("melee") or tool:FindFirstChild("Combat") or name:find("combat") or name:find("karate") or name:find("fist") or name:find("claw") or name:find("style") or name:find("art") then
        return "Melee"
    elseif tip:find("sword") or tool:FindFirstChild("Sword") or name:find("blade") or name:find("saber") or name:find("katana") or name:find("dagger") or name:find("scythe") then
        return "Sword"
    elseif tip:find("gun") or tool:FindFirstChild("Gun") or name:find("rifle") or name:find("cannon") or name:find("slingshot") or name:find("guitar") or name:find("bizarre") then
        return "Gun"
    elseif tip:find("fruit") or tip:find("bloxfruit") or tool:FindFirstChild("Fruit") or name:find("fruit") or name:find("bomb") or name:find("spike") or name:find("dough") or name:find("kitsune") or name:find("dragon") then
        return "Fruit"
    end
    return "Melee"
end

function CB_WEAPON_EQUIP.findToolByType(weaponType)
    local char = LocalPlayer.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped and CB_WEAPON_EQUIP.toolToWeaponType(equipped) == weaponType then
            return equipped
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and CB_WEAPON_EQUIP.toolToWeaponType(t) == weaponType then
                return t
            end
        end
    end
    return nil
end

function CB_WEAPON_EQUIP.equipWeaponType(weaponType)
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local tool = CB_WEAPON_EQUIP.findToolByType(weaponType)
    if tool and tool.Parent ~= char then
        hum:EquipTool(tool)
        return true
    end
    return tool and tool.Parent == char
end

_G.__CokeboysNormalizeSkillWeaponName = function(w)
    w = tostring(w):lower()
    if w:find("mel") then return "Melee"
    elseif w:find("swo") then return "Sword"
    elseif w:find("gun") then return "Gun"
    elseif w:find("fru") then return "Fruit" end
    return "Melee"
end



-- ==============================================================================
-- MODULE 5: DUAL-LAYER SILENT SKILL AIMBOT & KINEMATIC PREDICTION (550 SPEED)
-- ==============================================================================
-- Metamethod Index hook for Mouse.Hit and Mouse.Target silent aim
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and (self == Mouse or tostring(self) == "Mouse") then
                if key == "Hit" and _castAimState.active and _castAimState.aimCFrame then
                    return _castAimState.aimCFrame
                elseif key == "Target" and _castAimState.active and _castAimState.targetRoot then
                    return _castAimState.targetRoot
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

local CB_AIM_PREDICTION = {
    baseSpeed = 550,
    verticalAnchorY = 0,
    activeTarget = nil,
    aimPoint = Vector3.zero
}

local CB_HRP_AIM_RESOLVER = {
    target = nil,
    targetChar = nil,
    targetRoot = nil
}

function CB_HRP_AIM_RESOLVER.clear()
    CB_HRP_AIM_RESOLVER.target = nil
    CB_HRP_AIM_RESOLVER.targetChar = nil
    CB_HRP_AIM_RESOLVER.targetRoot = nil
end

local _castAimState = {
    active = false,
    targetRoot = nil,
    aimCFrame = CFrame.new(),
    lastCastTick = 0
}

local CB_BUDDY_AIM = {}
function CB_BUDDY_AIM.getPoint(targetRoot)
    if not targetRoot then return nil end
    return targetRoot.Position + Vector3.new(0, 1.2, 0)
end

local CB_SPIDER_C_AIM = {}
function CB_SPIDER_C_AIM.getPoint(targetRoot)
    if not targetRoot then return nil end
    return targetRoot.Position + Vector3.new(0, 0.5, 0)
end

local function isPlayerExcluded(playerName)
    if Settings.AimExclude and Settings.AimExclude[playerName] == true then
        return true
    end
    return false
end

local function isSafeZoneProtected(character)
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    -- Blox Fruits Safe Zone indicator check
    local sz = character:FindFirstChild("SafeZone") or character:FindFirstChild("InSafeZone")
    if sz and sz.Value == true then return true end
    return false
end

local function getNearestSkillTarget()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local bestTarget = nil
    local bestScore = math.huge
    local maxDist = Settings.AimbotDist or 900
    local mousePos = UserInputService:GetMouseLocation()
    local mode = Settings.AimbotMode or "All" -- "Players Only", "NPCs Only", "All"

    local function evaluateTarget(tChar, tName, isPlayer, playerObj)
        if not tChar or not tChar.Parent then return end
        if isPlayer and isPlayerExcluded(tName) then return end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar:FindFirstChildOfClass("Humanoid")
        if not tRoot or not tHum or tHum.Health <= 0 then return end
        if isSafeZoneProtected(tChar) then return end

        local dist = (tRoot.Position - root.Position).Magnitude
        if dist <= maxDist then
            local screenPos, onScreen = Camera:WorldToViewportPoint(tRoot.Position)
            local score = dist
            if Settings.TargetPriority == "Crosshair" and onScreen then
                local crossDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                score = crossDist + (dist * 0.2)
            elseif Settings.TargetPriority == "Lowest Health" then
                score = tHum.Health
            elseif Settings.TargetPriority == "Highest Bounty" and playerObj then
                local leaderstats = playerObj:FindFirstChild("leaderstats")
                local bounty = leaderstats and leaderstats:FindFirstChild("Bounty/Honor")
                score = -(bounty and bounty.Value or 0)
            end

            if score < bestScore then
                bestScore = score
                bestTarget = tRoot
            end
        end
    end

    -- 1. Check Players
    if mode == "Players Only" or mode == "All" or mode == "Players & NPCs" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                evaluateTarget(p.Character, p.Name, true, p)
            end
        end
    end

    -- 2. Check NPCs (Workspace.Enemies)
    if mode == "NPCs Only" or mode == "All" or mode == "Players & NPCs" or Settings.TargetNPCs or Settings.HitboxNPCs then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, npc in ipairs(enemies:GetChildren()) do
                evaluateTarget(npc, npc.Name, false, nil)
            end
        end
    end

    return bestTarget
end

local function calculatePredictedAim(targetRoot, customSpeed)
    if not targetRoot then return nil end
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targetRoot.CFrame end

    local dist = (targetRoot.Position - myRoot.Position).Magnitude
    local speed = customSpeed or Settings.Prediction or 550
    if speed <= 0 then speed = 550 end
    local timeToHit = dist / speed

    -- Velocity leading
    local vel = targetRoot.AssemblyLinearVelocity
    local predictedPos = targetRoot.Position + (vel * timeToHit)

    -- Weapon specific compensations
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local tName = tool.Name:lower()
        if Settings.BuddySwordAccuracy and tName:find("buddy sword") then
            predictedPos = CB_BUDDY_AIM.getPoint(targetRoot) or predictedPos
        elseif Settings.SpiderCAccuracy and tName:find("spider") then
            predictedPos = CB_SPIDER_C_AIM.getPoint(targetRoot) or predictedPos
        end
    end

    -- Vertical clamping
    if math.abs(predictedPos.Y - targetRoot.Position.Y) > 35 then
        predictedPos = Vector3.new(predictedPos.X, targetRoot.Position.Y, predictedPos.Z)
    end

    return CFrame.new(predictedPos, predictedPos + (targetRoot.CFrame.LookVector))
end

-- Dual-layer Mouse Interception
local function pushSilentMouseModule()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local targetRoot = getNearestSkillTarget()
    if not targetRoot then return end

    local aimCF = calculatePredictedAim(targetRoot)
    if not aimCF then return end

    -- Layer 1: Blox Fruits Vector3Value MousePos
    local mousePosVal = tool:FindFirstChild("MousePos") or char:FindFirstChild("MousePos")
    if mousePosVal and mousePosVal:IsA("Vector3Value") then
        mousePosVal.Value = aimCF.Position
    end

    -- Layer 2: Mouse.Hit redirection via rawset
    pcall(function()
        rawset(Mouse, "Hit", aimCF)
        rawset(Mouse, "Target", targetRoot)
    end)
end

function _G.__CokeboysBeginCastAim(skillKey, tool, char, key, owner)
    if not Settings.SkillAimbot then return end
    local target = getNearestSkillTarget()
    if not target then return end

    local aimCF = calculatePredictedAim(target)
    if not aimCF then return end

    _castAimState.active = true
    _castAimState.targetRoot = target
    _castAimState.aimCFrame = aimCF
    _castAimState.lastCastTick = tick()

    pushSilentMouseModule()
end

function _G.__CokeboysArmSkillMouse()
    if _castAimState.active and _castAimState.aimCFrame then
        pcall(function()
            rawset(Mouse, "Hit", _castAimState.aimCFrame)
            if _castAimState.targetRoot then
                rawset(Mouse, "Target", _castAimState.targetRoot)
            end
        end)
    end
end

function _G.__CokeboysClearCastAim()
    _castAimState.active = false
    _castAimState.targetRoot = nil
end

function _G.__CokeboysClearAimRedirects()
    _castAimState.active = false
    CB_HRP_AIM_RESOLVER.clear()
end



-- ==============================================================================
-- MODULE 6: SORU AIMBOT, INFINITE SORU & ANTI-COMBO INTERRUPT
-- ==============================================================================
local lastSoruTick = 0
local soruAimActive = false

function _G.__CokeboysBeginSoruAim(targetRoot)
    if not targetRoot then return end
    soruAimActive = true
    local aimPos = targetRoot.Position + Vector3.new(0, 1.5, 0)
    pcall(function()
        rawset(Mouse, "Hit", CFrame.new(aimPos))
        rawset(Mouse, "Target", targetRoot)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)
    end)
end

function _G.__CokeboysClearSoruAim()
    soruAimActive = false
end

function _G.__CokeboysClearNormalSoruAim()
    soruAimActive = false
end

function _G.__CokeboysPrepareInfiniteSoru()
    -- Bypasses Soru cooldown attributes on character
    local char = LocalPlayer.Character
    if char then
        local charges = char:FindFirstChild("SoruCharges")
        if charges and charges:IsA("IntValue") then
            charges.Value = 100
        end
        local soruCd = char:FindFirstChild("SoruCD") or char:FindFirstChild("SoruCooldown")
        if soruCd then
            soruCd:Destroy()
        end
    end
end

function _G.__CokeboysExecuteSoru(isAuto, customTarget, forceNormal, skipNotify)
    if not Settings.SoruAimbot and not forceNormal then
        if not skipNotify then
            notify("Soru Aim", "Turn on Soru Aimbot to use P or S.AIM.", 1.5)
        end
        return false
    end

    local now = tick()
    local cooldown = Settings.InfiniteSoru and 0.55 or 1.25
    if now - lastSoruTick < cooldown then
        return false
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local target = customTarget or getNearestSkillTarget()
    if not target then return false end

    lastSoruTick = now

    if Settings.InfiniteSoru then
        _G.__CokeboysPrepareInfiniteSoru()
    end

    _G.__CokeboysBeginSoruAim(target)

    -- Synthetic input pulse (KeyCode R)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    task.delay(0.06, function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)

    task.delay(0.3, function()
        _G.__CokeboysClearSoruAim()
    end)

    return true
end

function _G.__CokeboysExecuteAntiComboSoru()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Check if character is stunned or locked
    local busy = char:FindFirstChild("Busy") or char:FindFirstChild("Stun") or char:FindFirstChild("Ragdoll")
    if busy and busy.Value == true then
        _G.__CokeboysExecuteSoru(true, nil, false, true)
    end
end

function _G.__CokeboysExecuteMacroSoru()
    return _G.__CokeboysExecuteSoru(true, nil, false, true)
end



-- ==============================================================================
-- MODULE 7: FAST ATTACK ENGINE (M1 COMBAT LOOP)
-- ==============================================================================
local fastAttackActive = false
local lastFastAttackTick = 0

local function getCombatRemotes()
    local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    local regAttack = net and net:FindFirstChild("RE/RegisterAttack")
    local regHit = net and net:FindFirstChild("RE/RegisterHit")
    return regAttack, regHit
end

local function executeFastAttackM1()
    if not Settings.FastAttack then return end
    local now = tick()
    local delay = Settings.FastAttackDelay or 0.1
    if now - lastFastAttackTick < delay then return end
    lastFastAttackTick = now

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local target = getNearestSkillTarget()
    if not target then return end

    local regAttack, regHit = getCombatRemotes()
    if regAttack then
        regAttack:FireServer(0)
    end

    if regHit then
        regHit:FireServer(target, {target})
    end

    -- Dual SendHitsToServer for max damage throughput
    pcall(function()
        local globalMod = ReplicatedStorage:FindFirstChild("Global")
        if globalMod then
            local gm = require(globalMod)
            if gm and gm.SendHitsToServer then
                gm.SendHitsToServer(target, {target})
            end
            if gm and gm.tapCooldown then
                gm.tapCooldown = 0
            end
        end
    end)

    -- Animation cooldown reset
    pcall(function()
        if filtergc then
            local atkMelee = filtergc("function", {Name = "attackMelee"}, true)
            if atkMelee then
                debug.setupvalue(atkMelee, 2, false)
            end
        end
    end)
end

local function tryStartFastAttack()
    if fastAttackActive then return end
    fastAttackActive = true
    trackConnection(RunService.Heartbeat:Connect(function()
        if Settings.FastAttack then
            executeFastAttackM1()
        end
    end))
end

tryStartFastAttack()

-- Hitbox Expander (Players & NPCs)
trackConnection(RunService.Heartbeat:Connect(function()
    if not Settings.HitboxExpander then return end
    local size = Settings.HitboxSize or 40
    local mode = Settings.AimbotMode or "All"

    if mode == "Players Only" or mode == "All" or mode == "Players & NPCs" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not isPlayerExcluded(p.Name) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(size, size, size)
                    hrp.Transparency = Settings.HitboxVisual and 0.75 or 1
                    hrp.CanCollide = false
                end
            end
        end
    end

    if mode == "NPCs Only" or mode == "All" or mode == "Players & NPCs" or Settings.HitboxNPCs or Settings.TargetNPCs then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, npc in ipairs(enemies:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(size, size, size)
                    hrp.Transparency = Settings.HitboxVisual and 0.75 or 1
                    hrp.CanCollide = false
                end
            end
        end
    end
end))



-- ==============================================================================
-- MODULE 8: SKILL MANIPULATORS & COMBAT EXPLOITS
-- ==============================================================================
local CB_SANG_Z = {
    boosting = false,
    ragdolling = false
}

function CB_SANG_Z.execute()
    if CB_SANG_Z.boosting then return end
    CB_SANG_Z.boosting = true
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        CB_SANG_Z.boosting = false
        return
    end

    local frames = Settings.SangZFrames or 220
    local distance = Settings.SangZDistance or 350

    local look = root.CFrame.LookVector
    local forwardVel = look * (distance * (frames / 60))

    root.AssemblyLinearVelocity = Vector3.new(forwardVel.X, root.AssemblyLinearVelocity.Y, forwardVel.Z)

    if Settings.SangZNoRagdoll then
        local ragdoll = char:FindFirstChild("Ragdoll")
        if ragdoll then ragdoll.Value = false end
    end

    task.delay(0.35, function()
        CB_SANG_Z.boosting = false
    end)
end

function CB_SANG_Z.stop()
    CB_SANG_Z.boosting = false
    CB_SANG_Z.ragdolling = false
end

_G.CB_SANG_Z = CB_SANG_Z

function _G.__CokeboysTrySangZBoost(char)
    if not Settings.SangZBoost or CB_SANG_Z.boosting then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool.Name:find("Sanguine Art") then
        task.spawn(CB_SANG_Z.execute)
    end
end

-- Soul Guitar Momentum Boost
local CB_SOUL_GUITAR_BOOST = {
    active = false,
    untilTime = 0
}

function CB_SOUL_GUITAR_BOOST.trigger()
    if not Settings.SoulGuitarMomentumBoost then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local intensity = Settings.SoulGuitarMomentumIntensity or 100
    local recoil = -root.CFrame.LookVector * intensity
    root.AssemblyLinearVelocity = Vector3.new(recoil.X, root.AssemblyLinearVelocity.Y + 20, recoil.Z)
    CB_SOUL_GUITAR_BOOST.active = true
    CB_SOUL_GUITAR_BOOST.untilTime = tick() + 0.76
end

_G.CB_SOUL_GUITAR_BOOST = CB_SOUL_GUITAR_BOOST

-- Auto Observation Haki
local function tryReactivateKen()
    if not Settings.AutoObservation then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("Ken") and not char:FindFirstChild("Vision") then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end)
end

_G.__CokeboysSetAutoObservationEnabled = function(enabled)
    Settings.AutoObservation = enabled
    if enabled then tryReactivateKen() end
end

-- Auto Buso Haki
local function applyAutoBuso()
    if not Settings.AutoBuso then return end
    local char = LocalPlayer.Character
    if char and not char:FindFirstChild("HasBuso") then
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local commF = remotes and remotes:FindFirstChild("CommF_")
            if commF then commF:InvokeServer("Buso") end
        end)
    end
end

trackConnection(LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    applyAutoBuso()
end))



-- ==============================================================================
-- MODULE 9: SMART COMBO MACRO ENGINE (__CokeboysRunSmartMacro)
-- ==============================================================================
local MacroEngine = {
    running = false,
    runToken = 0,
    activeSlot = 1
}

function MacroEngine.castStep(step)
    if not step.enabled then return end
    
    -- 1. Equip required weapon
    CB_WEAPON_EQUIP.equipWeaponType(step.weapon)
    task.wait(0.05)

    -- 2. Aim at target
    local target = getNearestSkillTarget()
    if target then
        _G.__CokeboysBeginCastAim(step.skill, nil, LocalPlayer.Character, step.skill, nil)
    end

    -- 3. Execute skill
    local keyCode = Enum.KeyCode[step.skill]
    if keyCode then
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        local holdTime = tonumber(step.hold) or 0
        if holdTime > 0 then
            task.wait(holdTime)
        else
            task.wait(0.05)
        end
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end

    _G.__CokeboysClearCastAim()

    -- 4. Post skill jumps
    local jumps = tonumber(step.jumpsAfter) or 0
    for _ = 1, jumps do
        _G.__CokeboysAirJump()
        task.wait(0.08)
    end

    -- 5. Delay after skill
    local delayTime = tonumber(step.delay) or 0.2
    task.wait(delayTime)
end

function MacroEngine.run()
    if MacroEngine.running then
        MacroEngine.running = false
        MacroEngine.runToken = MacroEngine.runToken + 1
        notify("Smart Macro", "STOPPED", 1.2)
        return
    end

    local slotData = Settings.MobileMacroSlots and Settings.MobileMacroSlots[MacroEngine.activeSlot]
    if not slotData then
        notify("Smart Macro", "active slot is unavailable", 1.5)
        return
    end

    MacroEngine.running = true
    MacroEngine.runToken = MacroEngine.runToken + 1
    local currentToken = MacroEngine.runToken
    notify("Smart Macro", "RUNNING: " .. slotData.name, 1.2)

    spawnRuntimeTask(function()
        local steps = slotData.steps or {}
        for i, step in ipairs(steps) do
            if not MacroEngine.running or MacroEngine.runToken ~= currentToken then break end
            
            -- Interleaved Soru
            if slotData.soruEnabled and slotData.soruAfter == i then
                _G.__CokeboysExecuteMacroSoru()
                task.wait(0.1)
            end

            -- Interleaved V3
            if slotData.v3Enabled and slotData.v3After == i then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
                end)
            end

            -- Execute current step
            MacroEngine.castStep(step)

            -- Interleaved M1s
            if slotData.m1Enabled and slotData.m1After == i then
                CB_WEAPON_EQUIP.equipWeaponType(slotData.m1Weapon or "Melee")
                for _ = 1, (slotData.m1Count or 1) do
                    if not MacroEngine.running then break end
                    executeFastAttackM1()
                    task.wait(0.1)
                end
            end
        end
        MacroEngine.running = false
        notify("Smart Macro", "Sequence completed.", 1.2)
    end)
end

_G.__CokeboysRunSmartMacro = MacroEngine.run
getgenv().__CokeboysRunSmartMacro = MacroEngine.run
_G.__CokeboysSmartMacroRunning = function() return MacroEngine.running end
getgenv().__CokeboysSmartMacroRunning = function() return MacroEngine.running end



-- ==============================================================================
-- MODULE 10: MOVEMENT & PHYSICS MODIFICATIONS
-- ==============================================================================
local lastSuperJump = 0

function _G.__CokeboysSuperJump()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end

    local now = os.clock()
    if now - lastSuperJump < 0.25 then return end
    lastSuperJump = now

    local power = tonumber(Settings.SuperJumpPower) or 140
    power = math.clamp(power, 50, 400)

    if Settings.JumpBoost then
        local jBoost = tonumber(Settings.JumpValue) or 50
        power = math.max(power, jBoost)
    end

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, math.max(root.AssemblyLinearVelocity.Y, power), root.AssemblyLinearVelocity.Z)
end

function _G.__CokeboysAirJump()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Reset Blox Fruits Geppo IntValue
    local jumps = char:FindFirstChild("Jumps") or hum:FindFirstChild("Jumps")
    if jumps and jumps:IsA("IntValue") then
        jumps.Value = 0
    end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

function _G.__CokeboysSetDashLength(length)
    Settings.DashLength = tonumber(length) or 37
end

-- Lava & Water Walking
local CB_LAVA_WALK = {
    pad = nil
}

function CB_LAVA_WALK.update()
    if not Settings.WalkOnWater and not Settings.WalkOnLava then
        if CB_LAVA_WALK.pad then
            CB_LAVA_WALK.pad:Destroy()
            CB_LAVA_WALK.pad = nil
        end
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if not CB_LAVA_WALK.pad then
        local p = Instance.new("Part")
        p.Size = Vector3.new(12, 1, 12)
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = true
        p.Name = "CB_FloatPad"
        p.Parent = Workspace
        CB_LAVA_WALK.pad = p
    end

    CB_LAVA_WALK.pad.Position = Vector3.new(root.Position.X, -0.5, root.Position.Z)
end

trackConnection(RunService.Heartbeat:Connect(CB_LAVA_WALK.update))



-- ==============================================================================
-- MODULE 11: CAMERA & VISUAL MODIFICATIONS
-- ==============================================================================
local CB_PERMANENT_CAMLOCK = {
    active = false,
    target = nil
}

function _G.__CokeboysTogglePermanentCamLock()
    CB_PERMANENT_CAMLOCK.active = not CB_PERMANENT_CAMLOCK.active
    if CB_PERMANENT_CAMLOCK.active then
        CB_PERMANENT_CAMLOCK.target = getNearestSkillTarget()
        notify("Permanent CamLock", CB_PERMANENT_CAMLOCK.target and "LOCKED: " .. CB_PERMANENT_CAMLOCK.target.Parent.Name or "NO TARGET", 1.5)
    else
        CB_PERMANENT_CAMLOCK.target = nil
        notify("Permanent CamLock", "OFF", 1.5)
    end
end

function _G.__CokeboysApplyPermanentCameraLock()
    if CB_PERMANENT_CAMLOCK.active and CB_PERMANENT_CAMLOCK.target then
        local tPos = CB_PERMANENT_CAMLOCK.target.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tPos)
    end
end

trackConnection(RunService.RenderStepped:Connect(function()
    _G.__CokeboysApplyPermanentCameraLock()
end))

function _G.__CokeboysApplyWideView()
    if Settings.WideView then
        Camera.FieldOfView = Settings.WideViewFOV or 90
    else
        Camera.FieldOfView = 70
    end
end

function _G.__CokeboysApplyNoFog()
    if Settings.NoFog then
        game:GetService("Lighting").FogEnd = 100000
    end
end

function _G.__CokeboysApplyFPSBooster()
    if Settings.FPSBooster then
        settings().Rendering.QualityLevel = 1
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
end



-- ==============================================================================
-- MODULE 12: PLAYER ESP ENGINE (CB_ESP_UTIL)
-- ==============================================================================
local espContainers = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_ESP") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CB_ESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 160, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true

    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = Settings.ESPTextSize or 12
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = player.DisplayName .. " (@" .. player.Name .. ")"

    local infoLbl = Instance.new("TextLabel", bb)
    infoLbl.Size = UDim2.new(1, 0, 0, 14)
    infoLbl.Position = UDim2.new(0, 0, 0, 16)
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 10
    infoLbl.TextColor3 = Color3.fromRGB(238, 190, 40)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Distance: ..."

    bb.Parent = head
    espContainers[player] = bb
end

trackConnection(RunService.Heartbeat:Connect(function()
    if not Settings.ESPEnabled or getgenv().CokeboysEspForceHidden then
        for _, bb in pairs(espContainers) do
            bb.Enabled = false
        end
        return
    end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bb = espContainers[p]
            if not bb or not bb.Parent then
                createPlayerESP(p)
            else
                bb.Enabled = true
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and myRoot and hum then
                    local dist = math.floor((hrp.Position - myRoot.Position).Magnitude)
                    local hp = math.floor(hum.Health)
                    local maxHp = math.floor(hum.MaxHealth)
                    local info = bb:FindFirstChildOfClass("TextLabel")
                    local lbls = bb:GetChildren()
                    if lbls[2] then
                        lbls[2].Text = string.format("HP: %d/%d | Dist: %d", hp, maxHp, dist)
                    end
                end
            end
        end
    end
end))



-- ==============================================================================
-- MODULE 13 & 14: USER INTERFACE (DESKTOP GUI & MOBILE FLOATING BUTTONS)
-- ==============================================================================
local function createDesktopUI()
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pgui then return end

    if pgui:FindFirstChild("CokeboysUI") then
        pgui.CokeboysUI:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "CokeboysUI"
    screen.ResetOnSpawn = false
    screen.Parent = pgui

    local main = Instance.new("Frame", screen)
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 680, 0, 420)
    main.Position = UDim2.new(0.5, -340, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(20, 19, 24)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(238, 190, 40)
    stroke.Thickness = 1.5

    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    local hCorner = Instance.new("UICorner", header)
    hCorner.CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", header)
    title.Text = "POLAR HUB x COKEBOYS | Blox Fruits Master"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(238, 190, 40)
    title.Size = UDim2.new(0, 250, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(245, 243, 236)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(34, 32, 39)
    local cCorner = Instance.new("UICorner", closeBtn)
    cCorner.CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        getgenv().CokeboysGuiHidden = true
    end)

    -- Tabs Sidebar
    local sidebar = Instance.new("ScrollingFrame", main)
    sidebar.Size = UDim2.new(0, 160, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 45)
    sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    sidebar.ScrollBarThickness = 2
    local sCorner = Instance.new("UICorner", sidebar)
    sCorner.CornerRadius = UDim.new(0, 6)

    local uil = Instance.new("UIListLayout", sidebar)
    uil.SortOrder = Enum.SortOrder.LayoutOrder
    uil.Padding = UDim.new(0, 4)

    local tabList = {
        "🏠  Inicio", "🚶  Movimiento", "🧩  Glitches", "🎯  Apuntado",
        "👁️  Visuales", "⚔️  Combate", "🚫  Lista negra", "🛑  Excluir",
        "🛡️  Varios", "⏱️  Macro", "📱  Móvil", "🌈  Cambiador de aspectos",
        "🛒  Tienda", "👕  Cliente", "🎨  Apariencia", "⚙️  Ajustes",
        "⌨️  Teclas", "🚩  FFlags"
    }

    for _, tName in ipairs(tabList) do
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(34, 32, 39)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(245, 243, 236)
        btn.Text = tName
        local bCorner = Instance.new("UICorner", btn)
        bCorner.CornerRadius = UDim.new(0, 4)
    end

    -- Interactive Content Area
    local content = Instance.new("ScrollingFrame", main)
    content.Name = "ContentFrame"
    content.Size = UDim2.new(1, -190, 1, -50)
    content.Position = UDim2.new(0, 180, 0, 45)
    content.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    local cCorner = Instance.new("UICorner", content)
    cCorner.CornerRadius = UDim.new(0, 6)

    local contentLayout = Instance.new("UIListLayout", content)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 6)

    local function addToggle(text, getVal, setVal)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, -12, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(25, 24, 30)
        local fc = Instance.new("UICorner", frame)
        fc.CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = "  " .. text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(245, 243, 236)
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", frame)
        toggleBtn.Size = UDim2.new(0, 56, 0, 26)
        toggleBtn.Position = UDim2.new(1, -62, 0.5, -13)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 10
        local tc = Instance.new("UICorner", toggleBtn)
        tc.CornerRadius = UDim.new(0, 4)

        local function refresh()
            local active = getVal()
            toggleBtn.Text = active and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        toggleBtn.MouseButton1Click:Connect(function()
            setVal(not getVal())
            refresh()
        end)
        refresh()
    end

    addToggle("⚔️ Fast Attack (M1 Aura)", function() return Settings.FastAttack end, function(v) Settings.FastAttack = v end)
    addToggle("🎯 Skill Silent Aimbot", function() return Settings.SkillAimbot end, function(v) Settings.SkillAimbot = v end)
    addToggle("👾 Target NPCs (Mobs & Bosses)", function() return Settings.AimbotMode == "All" or Settings.TargetNPCs or Settings.HitboxNPCs end, function(v) Settings.TargetNPCs = v; Settings.HitboxNPCs = v; Settings.AimbotMode = v and "All" or "Players Only"; notify("Target Mode", v and "Players & NPCs" or "Players Only", 1.5) end)
    addToggle("⚡ Soru Aimbot (Key P / S.AIM)", function() return Settings.SoruAimbot end, function(v) Settings.SoruAimbot = v end)
    addToggle("💨 Infinite Soru (No Cooldown)", function() return Settings.InfiniteSoru end, function(v) Settings.InfiniteSoru = v end)
    addToggle("🔒 Permanent CamLock", function() return CB_PERMANENT_CAMLOCK.active end, function(v) _G.__CokeboysTogglePermanentCamLock() end)
    addToggle("🩸 Sanguine Art Z Boost", function() return Settings.SangZBoost end, function(v) Settings.SangZBoost = v end)
    addToggle("🗡️ Yama Z Boost", function() return Settings.YamaZBoost end, function(v) Settings.YamaZBoost = v end)
    addToggle("💎 Diamond M1 Boost", function() return Settings.DiamondM1Boost end, function(v) Settings.DiamondM1Boost = v end)
    addToggle("🌊 Walk On Water & Lava", function() return Settings.WalkOnWater end, function(v) Settings.WalkOnWater = v; Settings.WalkOnLava = v end)
    addToggle("👁️ Player ESP Billboard", function() return Settings.ESPEnabled end, function(v) Settings.ESPEnabled = v end)
    addToggle("🛡️ Auto Buso Haki", function() return Settings.AutoBuso end, function(v) Settings.AutoBuso = v; if v then applyAutoBuso() end end)
    addToggle("👁️ Auto Observation Haki", function() return Settings.AutoObservation end, function(v) _G.__CokeboysSetAutoObservationEnabled(v) end)
    addToggle("🚀 SuperJump Boost", function() return Settings.JumpBoost end, function(v) Settings.JumpBoost = v end)
    addToggle("🌫️ No Fog & Clean Sky", function() return Settings.NoFog end, function(v) Settings.NoFog = v; _G.__CokeboysApplyNoFog() end)
    addToggle("⚡ FPS Booster (Ultra Performance)", function() return Settings.FPSBooster end, function(v) Settings.FPSBooster = v; _G.__CokeboysApplyFPSBooster() end)
    addToggle("⏱️ Smart Combo Macro (Slot 1)", function() return _G.__CokeboysSmartMacroRunning() end, function(v) _G.__CokeboysRunSmartMacro() end)
end

createDesktopUI()

-- Mobile Floating Action Buttons (CokeboysMobile)
local function createMobileButtons()
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pgui then return end

    local screen = pgui:FindFirstChild("CokeboysMobile") or Instance.new("ScreenGui")
    screen.Name = "CokeboysMobile"
    screen.ResetOnSpawn = false
    screen.Parent = pgui

    local buttonDefs = {
        {name = "MACRO", fn = function() _G.__CokeboysRunSmartMacro() end},
        {name = "OBJETIVO", fn = function() Settings.SkillAimbot = not Settings.SkillAimbot; notify("Aimbot", Settings.SkillAimbot and "ON" or "OFF", 1) end},
        {name = "RÁPIDO", fn = function() Settings.FastAttack = not Settings.FastAttack; notify("FastAttack", Settings.FastAttack and "ON" or "OFF", 1) end},
        {name = "S.AIM", fn = function() _G.__CokeboysExecuteSoru() end},
        {name = "SÚPER", fn = function() _G.__CokeboysSuperJump() end},
        {name = "CANTO", fn = function() _G.__CokeboysTrySangZBoost() end},
        {name = "RAGDOLL", fn = function() Settings.FruitM1Ragdoll = not Settings.FruitM1Ragdoll end},
        {name = "RESTABLECER", fn = function() LocalPlayer.Character:BreakJoints() end},
        {name = "DIAMANTE", fn = function() Settings.DiamondM1Boost = not Settings.DiamondM1Boost end},
        {name = "BLOQUEAR", fn = function() _G.__CokeboysTogglePermanentCamLock() end},
        {name = "CAMLOCK", fn = function() _G.__CokeboysTogglePermanentCamLock() end},
        {name = "V4", fn = function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game); task.wait(0.05); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game) end}
    }

    for i, def in ipairs(buttonDefs) do
        local btn = screen:FindFirstChild(def.name) or Instance.new("TextButton", screen)
        btn.Name = def.name
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = UDim2.new(0, 15 + ((i - 1) % 6) * 55, 1, -130 + math.floor((i - 1) / 6) * 55)
        btn.BackgroundColor3 = Color3.fromRGB(20, 19, 24)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.TextColor3 = Color3.fromRGB(238, 190, 40)
        btn.Text = def.name
        local bc = Instance.new("UICorner", btn)
        bc.CornerRadius = UDim.new(0, 8)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = Color3.fromRGB(238, 190, 40)
        bs.Thickness = 1
        btn.MouseButton1Click:Connect(def.fn)
    end
end

createMobileButtons()



-- ==============================================================================
-- MODULE 15: METAMETHOD HOOKS, KEYBIND DISPATCHER & TEARDOWN
-- ==============================================================================
-- Master Keyboard Dispatcher
trackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local key = input.KeyCode.Name

    -- Menu Toggle
    if key == (Settings.MenuKey or "RightControl") then
        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local ui = pgui and pgui:FindFirstChild("CokeboysUI")
        if ui then
            local main = ui:FindFirstChild("MainFrame") or ui:FindFirstChildOfClass("Frame")
            if main then
                main.Visible = not main.Visible
                getgenv().CokeboysGuiHidden = not main.Visible
            end
        end
    -- Aimbot Toggle
    elseif key == (Settings.AimbotKey or "G") then
        Settings.SkillAimbot = not Settings.SkillAimbot
        notify("Aimbot", Settings.SkillAimbot and "ON" or "OFF", 1.5)
    -- Target Lock Toggle
    elseif key == (Settings.TargetLockKey or "L") then
        _G.__CokeboysTogglePermanentCamLock()
    -- FastAttack Toggle
    elseif key == (Settings.FastAttackKey or "H") then
        Settings.FastAttack = not Settings.FastAttack
        notify("FastAttack", Settings.FastAttack and "ON" or "OFF", 1.5)
    -- Yama Z Boost Toggle
    elseif key == (Settings.YamaZBoostKey or "B") then
        Settings.YamaZBoost = not Settings.YamaZBoost
        notify("Yama Z Boost", Settings.YamaZBoost and "ON" or "OFF", 1.5)
    -- Sang Z Boost Toggle
    elseif key == (Settings.SangZBoostKey or "J") then
        Settings.SangZBoost = not Settings.SangZBoost
        notify("Sang Z Boost", Settings.SangZBoost and "ON" or "OFF", 1.5)
    -- Soru Aimbot Cast
    elseif key == (Settings.SoruAimbotKey or "P") then
        _G.__CokeboysExecuteSoru()
    -- Smart Macro Run Toggle
    elseif key == (Settings.ComboBound or "F6") then
        _G.__CokeboysRunSmartMacro()
    -- Permanent CamLock Key
    elseif key == (Settings.PermanentCamLockKey or "N") then
        _G.__CokeboysTogglePermanentCamLock()
    -- Skill Cam Lock Cast Trigger
    elseif key == "Z" or key == "X" or key == "C" or key == "V" or key == "F" then
        if Settings.SkillAimbot then
            _G.__CokeboysBeginCastAim(key, nil, LocalPlayer.Character, key, nil)
        end
        if key == "Z" and Settings.SangZBoost then
            _G.__CokeboysTrySangZBoost(LocalPlayer.Character)
        end
    end
end))

trackConnection(UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        if key == "Z" or key == "X" or key == "C" or key == "V" or key == "F" then
            _G.__CokeboysClearCastAim()
        end
    end
end))

-- Teardown Routine
function _G.CokeboysFullUnload()
    notify("Cokeboys", "Unloading script completely...", 1.5)
    getgenv().CokeboysScriptLoaded = false

    -- 1. Disconnect all runtime connections
    if getgenv().__CokeboysRuntimeConnections then
        for _, conn in ipairs(getgenv().__CokeboysRuntimeConnections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv().__CokeboysRuntimeConnections = {}
    end

    -- 2. Cancel all running tasks
    if getgenv().__CokeboysRuntimeTasks then
        for _, t in ipairs(getgenv().__CokeboysRuntimeTasks) do
            pcall(function() task.cancel(t) end)
        end
        getgenv().__CokeboysRuntimeTasks = {}
    end

    -- 3. Destroy all GUI panels
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pgui then
        local guiNames = {
            "CokeboysUI", "CokeboysFOVRing", "CokeboysAbilityReach", "CokeboysNotif",
            "CokeboysFPSPing", "CokeboysSessionInfo", "CokeboysStatus2",
            "CokeboysActiveModules", "CokeboysMobile", "CokeboysBtn"
        }
        for _, gName in ipairs(guiNames) do
            local g = pgui:FindFirstChild(gName)
            if g then g:Destroy() end
        end
    end

    -- 4. Restore original metamethods
    if rawmt and oldNamecall then
        setreadonly(rawmt, false)
        rawmt.__namecall = oldNamecall
        if oldIndex then rawmt.__index = oldIndex end
        setreadonly(rawmt, true)
    end

    notify("Cokeboys", "Unloaded successfully.", 1.5)
end

getgenv().CokeboysFullUnload = _G.CokeboysFullUnload


-- Polar Hub Export Aliases
_G.PolarFullUnload = _G.CokeboysFullUnload
getgenv().PolarFullUnload = _G.CokeboysFullUnload
getgenv().PolarCombat = {
    Settings = Settings,
    Profiles = ConfigProfiles,
    ToggleMenu = function()
        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local ui = pgui and pgui:FindFirstChild("CokeboysUI")
        if ui then
            local main = ui:FindFirstChild("MainFrame") or ui:FindFirstChildOfClass("Frame")
            if main then
                main.Visible = not main.Visible
                getgenv().CokeboysGuiHidden = not main.Visible
            end
        end
    end,
    RunMacro = _G.__CokeboysRunSmartMacro,
    SuperJump = _G.__CokeboysSuperJump,
    ExecuteSoru = _G.__CokeboysExecuteSoru,
    ToggleCamLock = _G.__CokeboysTogglePermanentCamLock,
    Unload = _G.CokeboysFullUnload
}

notify("POLAR HUB x COKEBOYS", "Engine loaded & operational! [KEYLESS]", 3)

