--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (FIXED PERFECT CAST WORKING)
-- Rayfield UI + Lucide icons + Working Perfect Cast System
-- Author: Anggazyy (refactor)
--//////////////////////////////////////////////////////////////////////////////////

-- CONFIG: ubah sesuai kebutuhan
local AUTO_FISH_REMOTE_NAME = "UpdateAutoFishingState"
local NET_PACKAGES_FOLDER = "Packages"
local RAYFIELD_URL = 'https://sirius.menu/rayfield'
local PERFECT_CAST_ENABLED = true

-- Services & Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Main System Variables
local autoFishEnabled = false
local autoFishLoopThread = nil
local coordinateGui = nil
local statusParagraph = nil
local currentSelectedMap = nil

-- Player Configuration Variables
local antiLagEnabled = false
local savePositionEnabled = false
local lockPositionEnabled = false
local lastSavedPosition = nil
local lockPositionLoop = nil
local originalGraphicsSettings = {}

-- Bypass Variables
local fishingRadarEnabled = false
local divingGearEnabled = false
local autoSellEnabled = false
local autoSellThreshold = 3
local autoSellLoop = nil

-- Perfect Cast System Variables
local perfectCastEnabled = false
local perfectCastLoop = nil
local autoClickEnabled = false
local autoClickLoop = nil
local isFishingActive = false
local fishingModule = nil

-- UI Configuration
local COLOR_ENABLED = Color3.fromRGB(76, 175, 80)  -- Green
local COLOR_DISABLED = Color3.fromRGB(244, 67, 54) -- Red
local COLOR_PRIMARY = Color3.fromRGB(103, 58, 183) -- Purple
local COLOR_SECONDARY = Color3.fromRGB(30, 30, 46)  -- Dark

-- Auto-clean money icons
task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if obj and (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel")) then
                local nameLower = (obj.Name or ""):lower()
                local textLower = (obj.Text or ""):lower()
                if string.find(nameLower, "money") or string.find(textLower, "money") or string.find(nameLower, "100") then
                    pcall(function()
                        obj.Visible = false
                        if obj:IsA("GuiObject") then
                            obj.Active = false
                            obj.ZIndex = 0
                        end
                    end)
                end
            end
        end
    end
end)

-- Rayfield Loader
local successLoad, Rayfield = pcall(function()
    return loadstring(game:HttpGet(RAYFIELD_URL))()
end)
if not successLoad or not Rayfield then
    warn("Rayfield loading failed. Please check your executor configuration.")
    return
end

-- Notification System
local function Notify(opts)
    pcall(function()
        Rayfield:Notify({
            Title = opts.Title or "Notification",
            Content = opts.Content or "",
            Duration = opts.Duration or 3,
            Image = opts.Image or 4483362458
        })
    end)
end

-- Network Communication
local function GetAutoFishRemote()
    local ok, NetModule = pcall(function()
        local folder = ReplicatedStorage:WaitForChild(NET_PACKAGES_FOLDER, 5)
        if folder then
            local netCandidate = folder:FindFirstChild("Net")
            if netCandidate and netCandidate:IsA("ModuleScript") then
                return require(netCandidate)
            end
        end
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
            local m = ReplicatedStorage.Packages.Net
            if m:IsA("ModuleScript") then
                return require(m)
            end
        end
        return nil
    end)
    return ok and NetModule or nil
end

local function SafeInvokeAutoFishing(state)
    pcall(function()
        local Net = GetAutoFishRemote()
        if Net and type(Net.RemoteFunction) == "function" then
            local ok, rf = pcall(function() return Net:RemoteFunction(AUTO_FISH_REMOTE_NAME) end)
            if ok and rf then
                pcall(function() rf:InvokeServer(state) end)
                return
            end
        end
        
        local rfObj = ReplicatedStorage:FindFirstChild(AUTO_FISH_REMOTE_NAME) 
            or ReplicatedStorage:FindFirstChild("RemoteFunctions") and ReplicatedStorage.RemoteFunctions:FindFirstChild(AUTO_FISH_REMOTE_NAME)
        if rfObj and rfObj:IsA("RemoteFunction") then
            pcall(function() rfObj:InvokeServer(state) end)
            return
        end
    end)
end

-- =============================================================================
-- PERFECT CAST SYSTEM - WORKING FIXED VERSION
-- =============================================================================

-- Load Fishing Module dengan cara yang benar
local function LoadFishingModule()
    if fishingModule then return fishingModule end
    
    local success, result = pcall(function()
        -- Load required modules untuk fishing system
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local Net = require(ReplicatedStorage.Packages.Net)
        
        -- Tunggu sampai fishing module tersedia
        local fishingScript = ReplicatedStorage.Modules:WaitForChild("Fishing", 10)
        if fishingScript and fishingScript:IsA("ModuleScript") then
            fishingModule = require(fishingScript)
            print("✅ Fishing Module loaded successfully!")
            return fishingModule
        else
            warn("❌ Fishing module not found in ReplicatedStorage.Modules")
            return nil
        end
    end)
    
    if success and result then
        return result
    else
        warn("❌ Failed to load fishing module: " .. tostring(result))
        return nil
    end
end

-- Cek apakah sedang fishing aktif
local function IsFishingActive()
    if not fishingModule then
        fishingModule = LoadFishingModule()
        if not fishingModule then return false end
    end
    
    local success, result = pcall(function()
        if fishingModule.GetCurrentGUID then
            local guid = fishingModule:GetCurrentGUID()
            return guid ~= nil
        end
        return false
    end)
    
    return success and result or false
end

-- Auto Click System untuk Minigame
local function StartAutoClick()
    if autoClickEnabled then return end
    
    autoClickEnabled = true
    print("🔄 Auto Click started")
    
    autoClickLoop = task.spawn(function()
        local clickCount = 0
        while autoClickEnabled and perfectCastEnabled do
            pcall(function()
                if fishingModule and fishingModule.RequestFishingMinigameClick then
                    fishingModule:RequestFishingMinigameClick()
                    clickCount = clickCount + 1
                    
                    -- Cek jika fishing sudah selesai
                    if not IsFishingActive() then
                        StopAutoClick()
                        print("✅ Fishing completed with " .. clickCount .. " clicks")
                    end
                end
            end)
            task.wait(0.1) -- Click setiap 0.1 detik
        end
    end)
end

local function StopAutoClick()
    if not autoClickEnabled then return end
    
    autoClickEnabled = false
    print("🛑 Auto Click stopped")
    
    if autoClickLoop then
        task.cancel(autoClickLoop)
        autoClickLoop = nil
    end
end

-- Perfect Cast Fishing System - WORKING VERSION
local function StartPerfectCastFishing()
    if perfectCastEnabled then return end
    
    -- Load fishing module pertama kali
    fishingModule = LoadFishingModule()
    if not fishingModule then
        Notify({Title = "Perfect Cast Error", Content = "Fishing module not found!", Duration = 4})
        return
    end
    
    perfectCastEnabled = true
    Notify({Title = "Perfect Cast", Content = "Perfect cast fishing activated!", Duration = 3})
    print("🎣 Perfect Cast Fishing STARTED")
    
    perfectCastLoop = task.spawn(function()
        local attemptCount = 0
        
        while perfectCastEnabled do
            attemptCount = attemptCount + 1
            print("🎯 Fishing Attempt: " .. attemptCount)
            
            -- Cek cooldown
            if fishingModule.OnCooldown and fishingModule:OnCooldown() then
                print("⏳ On cooldown, waiting...")
                task.wait(3)
                continue
            end
            
            -- Cek inventory space
            local Constants = require(ReplicatedStorage.Shared.Constants)
            local Replion = require(ReplicatedStorage.Packages.Replion)
            local Data = Replion.Client:WaitReplion("Data")
            
            if Data and Constants.MaxInventorySize <= Constants:CountInventorySize(Data) then
                if fishingModule.NoInventorySpace then
                    fishingModule:NoInventorySpace()
                end
                task.wait(2)
                continue
            end
            
            -- Cek fishing rod equipped
            local equippedId = Data:Get("EquippedId")
            if not equippedId or equippedId == "" then
                print("❌ No fishing rod equipped!")
                task.wait(3)
                continue
            end
            
            -- Cek apakah sedang tidak fishing
            if not IsFishingActive() then
                print("🎣 Starting new fishing cycle...")
                
                -- Gunakan RequestChargeFishingRod untuk mulai fishing
                local screenCenter = Vector2.new(
                    workspace.CurrentCamera.ViewportSize.X / 2,
                    workspace.CurrentCamera.ViewportSize.Y / 2
                )
                
                if fishingModule.RequestChargeFishingRod then
                    fishingModule:RequestChargeFishingRod(screenCenter)
                    print("✅ RequestChargeFishingRod called")
                    
                    -- Tunggu untuk minigame mulai
                    local minigameWaitTime = 0
                    while minigameWaitTime < 5 do -- Max 5 detik tunggu minigame
                        task.wait(0.5)
                        minigameWaitTime = minigameWaitTime + 0.5
                        
                        if IsFishingActive() then
                            print("🎮 Minigame detected, starting auto click...")
                            StartAutoClick()
                            break
                        end
                    end
                    
                    -- Tunggu sampai fishing selesai
                    local fishingWaitTime = 0
                    while IsFishingActive() and fishingWaitTime < 30 do -- Max 30 detik
                        task.wait(1)
                        fishingWaitTime = fishingWaitTime + 1
                    end
                    
                    StopAutoClick()
                    print("✅ Fishing cycle completed")
                    
                else
                    print("❌ RequestChargeFishingRod not available")
                end
            else
                print("⚠️ Already fishing, waiting...")
            end
            
            -- Cooldown antara attempts
            local cooldown = math.random(2, 4)
            task.wait(cooldown)
            
            -- Safety break
            if attemptCount > 50 then
                print("🛑 Safety break - too many attempts")
                break
            end
        end
        
        print("🛑 Perfect Cast Fishing STOPPED")
    end)
end

local function StopPerfectCastFishing()
    if not perfectCastEnabled then return end
    
    perfectCastEnabled = false
    StopAutoClick()
    
    if perfectCastLoop then
        task.cancel(perfectCastLoop)
        perfectCastLoop = nil
    end
    
    Notify({Title = "Perfect Cast", Content = "Perfect cast fishing stopped", Duration = 3})
    print("🛑 Perfect Cast Fishing STOPPED")
end

-- Test Function untuk debugging
local function TestFishingSystem()
    fishingModule = LoadFishingModule()
    if not fishingModule then
        Notify({Title = "Test Failed", Content = "Fishing module not found!", Duration = 4})
        return
    end
    
    local methods = {}
    for methodName, method in pairs(fishingModule) do
        if type(method) == "function" then
            table.insert(methods, methodName)
        end
    end
    
    Notify({
        Title = "Fishing Module Test", 
        Content = "Module loaded! Methods: " .. table.concat(methods, ", "),
        Duration = 5
    })
    
    print("🔍 Fishing Module Methods:")
    for _, method in ipairs(methods) do
        print(" - " .. method)
    end
end

-- Auto Fishing System (Original)
local function StartAutoFish()
    if autoFishEnabled then return end
    autoFishEnabled = true
    if statusParagraph then 
        pcall(function() 
            statusParagraph:Set("Status: AUTO FISHING ACTIVE")
        end) 
    end
    Notify({Title = "Auto Fishing", Content = "System activated successfully", Duration = 2})

    autoFishLoopThread = task.spawn(function()
        while autoFishEnabled do
            pcall(function()
                SafeInvokeAutoFishing(true)
            end)
            task.wait(4)
        end
    end)
end

local function StopAutoFish()
    if not autoFishEnabled then return end
    autoFishEnabled = false
    if statusParagraph then 
        pcall(function() 
            statusParagraph:Set("Status: DISABLED")
        end) 
    end
    Notify({Title = "Auto Fishing", Content = "System deactivated", Duration = 2})
    
    pcall(function()
        SafeInvokeAutoFishing(false)
    end)
    
    if autoFishLoopThread then
        task.cancel(autoFishLoopThread)
        autoFishLoopThread = nil
    end
end

-- =============================================================================
-- ULTRA ANTI LAG SYSTEM - WHITE TEXTURE MODE
-- =============================================================================

-- Save original graphics settings
local function SaveOriginalGraphics()
    originalGraphicsSettings = {
        GraphicsQualityLevel = UserGameSettings.GraphicsQualityLevel,
        SavedQualityLevel = UserGameSettings.SavedQualityLevel,
        MasterVolume = Lighting.GlobalShadows,
        Brightness = Lighting.Brightness,
        FogEnd = Lighting.FogEnd,
        ShadowSoftness = Lighting.ShadowSoftness,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    }
end

-- Ultra Anti Lag System - White Texture Mode
local function EnableAntiLag()
    if antiLagEnabled then return end
    
    SaveOriginalGraphics()
    antiLagEnabled = true
    
    -- Extreme graphics optimization with white textures
    pcall(function()
        -- Graphics quality settings
        UserGameSettings.GraphicsQualityLevel = 1
        UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        
        -- Lighting optimization - Bright white environment
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999
        Lighting.Brightness = 5  -- Extra bright
        Lighting.ShadowSoftness = 0
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 0
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)  -- Pure white ambient
        Lighting.Ambient = Color3.new(1, 1, 1)  -- Pure white
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        
        -- Terrain optimization - White terrain
        if workspace.Terrain then
            workspace.Terrain.Decoration = false
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 1
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
        end
        
        -- Make all parts white and disable effects
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                -- Set all parts to white
                if obj:FindFirstChildOfClass("Texture") then
                    obj:FindFirstChildOfClass("Texture"):Destroy()
                end
                if obj:FindFirstChildOfClass("Decal") then
                    obj:FindFirstChildOfClass("Decal"):Destroy()
                end
                obj.Material = Enum.Material.SmoothPlastic
                obj.BrickColor = BrickColor.new("White")
                obj.Reflectance = 0
            elseif obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            elseif obj:IsA("Fire") then
                obj.Enabled = false
            elseif obj:IsA("Smoke") then
                obj.Enabled = false
            elseif obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Beam") then
                obj.Enabled = false
            elseif obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Sound") and not obj:FindFirstAncestorWhichIsA("Player") then
                obj:Stop()
            end
        end
        
        -- Reduce texture quality to minimum
        settings().Rendering.QualityLevel = 1
    end)
    
    Notify({Title = "Ultra Anti Lag", Content = "White texture mode enabled - Maximum performance", Duration = 3})
end

local function DisableAntiLag()
    if not antiLagEnabled then return end
    antiLagEnabled = false
    
    -- Restore original graphics settings
    pcall(function()
        if originalGraphicsSettings.GraphicsQualityLevel then
            UserGameSettings.GraphicsQualityLevel = originalGraphicsSettings.GraphicsQualityLevel
        end
        if originalGraphicsSettings.SavedQualityLevel then
            UserGameSettings.SavedQualityLevel = originalGraphicsSettings.SavedQualityLevel
        end
        if originalGraphicsSettings.MasterVolume ~= nil then
            Lighting.GlobalShadows = originalGraphicsSettings.MasterVolume
        end
        if originalGraphicsSettings.Brightness then
            Lighting.Brightness = originalGraphicsSettings.Brightness
        end
        if originalGraphicsSettings.FogEnd then
            Lighting.FogEnd = originalGraphicsSettings.FogEnd
        end
        if originalGraphicsSettings.ShadowSoftness then
            Lighting.ShadowSoftness = originalGraphicsSettings.ShadowSoftness
        end
        if originalGraphicsSettings.EnvironmentDiffuseScale then
            Lighting.EnvironmentDiffuseScale = originalGraphicsSettings.EnvironmentDiffuseScale
        end
        if originalGraphicsSettings.EnvironmentSpecularScale then
            Lighting.EnvironmentSpecularScale = originalGraphicsSettings.EnvironmentSpecularScale
        end
        
        -- Restore terrain
        if workspace.Terrain then
            workspace.Terrain.Decoration = true
            workspace.Terrain.WaterReflectance = 0.5
            workspace.Terrain.WaterTransparency = 0.5
            workspace.Terrain.WaterWaveSize = 0.5
            workspace.Terrain.WaterWaveSpeed = 10
        end
        
        -- Restore lighting
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
        
        -- Restore texture quality
        settings().Rendering.QualityLevel = 10
    end)
    
    Notify({Title = "Anti Lag", Content = "Graphics settings restored", Duration = 3})
end

-- Position Management System
local function SaveCurrentPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        lastSavedPosition = character.HumanoidRootPart.Position
        Notify({
            Title = "Position Saved", 
            Content = string.format("Position saved successfully"),
            Duration = 2
        })
        return true
    end
    return false
end

local function LoadSavedPosition()
    if not lastSavedPosition then
        Notify({Title = "Load Failed", Content = "No position saved", Duration = 2})
        return false
    end
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(lastSavedPosition)
        Notify({Title = "Position Loaded", Content = "Teleported to saved position", Duration = 2})
        return true
    end
    return false
end

local function StartLockPosition()
    if lockPositionEnabled then return end
    lockPositionEnabled = true
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        lastSavedPosition = character.HumanoidRootPart.Position
    end
    
    lockPositionLoop = RunService.Heartbeat:Connect(function()
        if not lockPositionEnabled then return end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and lastSavedPosition then
            local currentPos = character.HumanoidRootPart.Position
            local distance = (currentPos - lastSavedPosition).Magnitude
            
            if distance > 3 then
                character.HumanoidRootPart.CFrame = CFrame.new(lastSavedPosition)
            end
        end
    end)
    
    Notify({Title = "Position Lock", Content = "Player position locked", Duration = 2})
end

local function StopLockPosition()
    if not lockPositionEnabled then return end
    lockPositionEnabled = false
    
    if lockPositionLoop then
        lockPositionLoop:Disconnect()
        lockPositionLoop = nil
    end
    
    Notify({Title = "Position Lock", Content = "Player position unlocked", Duration = 2})
end

-- =============================================================================
-- BYPASS SYSTEM - FISHING RADAR, DIVING GEAR & AUTO SELL
-- =============================================================================

-- Fishing Radar System
local function ToggleFishingRadar()
    local success, result = pcall(function()
        -- Load required modules
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local Net = require(ReplicatedStorage.Packages.Net)
        local UpdateFishingRadar = Net:RemoteFunction("UpdateFishingRadar")
        
        -- Get player data
        local Data = Replion.Client:WaitReplion("Data")
        if not Data then
            return false, "Data Replion tidak ditemukan!"
        end

        -- Get current radar state
        local currentState = Data:Get("RegionsVisible")
        local desiredState = not currentState

        -- Invoke server to update radar
        local invokeSuccess = UpdateFishingRadar:InvokeServer(desiredState)
        
        if invokeSuccess then
            fishingRadarEnabled = desiredState
            return true, "Radar: " .. (desiredState and "ENABLED" or "DISABLED")
        else
            return false, "Failed to update radar"
        end
    end)
    
    if success then
        return true, result
    else
        return false, "Error: " .. tostring(result)
    end
end

local function StartFishingRadar()
    if fishingRadarEnabled then return end
    
    local success, message = ToggleFishingRadar()
    if success then
        fishingRadarEnabled = true
        Notify({Title = "Fishing Radar", Content = message, Duration = 3})
    else
        Notify({Title = "Radar Error", Content = message, Duration = 4})
    end
end

local function StopFishingRadar()
    if not fishingRadarEnabled then return end
    
    local success, message = ToggleFishingRadar()
    if success then
        fishingRadarEnabled = false
        Notify({Title = "Fishing Radar", Content = message, Duration = 3})
    else
        Notify({Title = "Radar Error", Content = message, Duration = 4})
    end
end

-- Diving Gear System
local function ToggleDivingGear()
    local success, result = pcall(function()
        -- Load required modules
        local Net = require(ReplicatedStorage.Packages.Net)
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        
        -- Get diving gear data
        local DivingGear = ItemUtility.GetItemDataFromItemType("Gears", "Diving Gear")
        if not DivingGear then
            return false, "Diving Gear tidak ditemukan!"
        end

        -- Get player data
        local Data = Replion.Client:WaitReplion("Data")
        if not Data then
            return false, "Data Replion tidak ditemukan!"
        end

        -- Get remote functions
        local UnequipOxygenTank = Net:RemoteFunction("UnequipOxygenTank")
        local EquipOxygenTank = Net:RemoteFunction("EquipOxygenTank")

        -- Check current equipment state
        local EquippedId = Data:Get("EquippedOxygenTankId")
        local isEquipped = EquippedId == DivingGear.Data.Id
        local success

        -- Toggle equipment
        if isEquipped then
            success = UnequipOxygenTank:InvokeServer()
        else
            success = EquipOxygenTank:InvokeServer(DivingGear.Data.Id)
        end

        if success then
            divingGearEnabled = not isEquipped
            return true, "Diving Gear: " .. (not isEquipped and "ON" or "OFF")
        else
            return false, "Failed to toggle diving gear"
        end
    end)
    
    if success then
        return true, result
    else
        return false, "Error: " .. tostring(result)
    end
end

local function StartDivingGear()
    if divingGearEnabled then return end
    
    local success, message = ToggleDivingGear()
    if success then
        divingGearEnabled = true
        Notify({Title = "Diving Gear", Content = message, Duration = 3})
    else
        Notify({Title = "Diving Gear Error", Content = message, Duration = 4})
    end
end

local function StopDivingGear()
    if not divingGearEnabled then return end
    
    local success, message = ToggleDivingGear()
    if success then
        divingGearEnabled = false
        Notify({Title = "Diving Gear", Content = message, Duration = 3})
    else
        Notify({Title = "Diving Gear Error", Content = message, Duration = 4})
    end
end

-- =============================================================================
-- FIXED AUTO SELL SYSTEM - BYPASS CONFIRMATION PROMPT
-- =============================================================================

-- Auto Sell System - Fixed version without confirmation
local function ManualSellAllFish()
    local success, result = pcall(function()
        -- Load required modules
        local Net = require(ReplicatedStorage.Packages.Net)
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local VendorController = require(ReplicatedStorage.Controllers.VendorController)
        
        -- Get player data
        local Data = Replion.Client:WaitReplion("Data")
        if not Data then
            return false, "Player data not found"
        end

        -- Check if player has Sell Anywhere gamepass
        local hasGamepass = true -- Assume player has gamepass to bypass check
        
        if hasGamepass then
            -- Direct sell without confirmation
            if VendorController and VendorController.SellAllItems then
                VendorController:SellAllItems()
                return true, "All fish sold successfully!"
            else
                return false, "VendorController not found"
            end
        else
            return false, "Sell Anywhere gamepass required"
        end
    end)
    
    if success then
        Notify({Title = "Manual Sell", Content = result, Duration = 3})
        return true
    else
        Notify({Title = "Sell Error", Content = result, Duration = 4})
        return false
    end
end

local function StartAutoSell()
    if autoSellEnabled then return end
    autoSellEnabled = true
    
    autoSellLoop = task.spawn(function()
        while autoSellEnabled do
            pcall(function()
                local Replion = require(ReplicatedStorage.Packages.Replion)
                local Net = require(ReplicatedStorage.Packages.Net)
                local VendorController = require(ReplicatedStorage.Controllers.VendorController)
                local Data = Replion.Client:WaitReplion("Data")
                
                if Data and VendorController and VendorController.SellAllItems then
                    local inventory = Data:Get("Inventory")
                    if inventory and inventory.Fish then
                        local fishCount = 0
                        for _, fish in pairs(inventory.Fish) do
                            fishCount = fishCount + (fish.Amount or 1)
                        end
                        
                        if fishCount >= autoSellThreshold then
                            -- Bypass gamepass check and sell directly
                            VendorController:SellAllItems()
                            Notify({
                                Title = "Auto Sell", 
                                Content = string.format("Sold %d fish automatically", fishCount),
                                Duration = 2
                            })
                        end
                    end
                end
            end)
            task.wait(2) -- Check every 2 seconds
        end
    end)
    
    Notify({
        Title = "Auto Sell Started", 
        Content = string.format("Auto selling when fish count >= %d", autoSellThreshold),
        Duration = 3
    })
end

local function StopAutoSell()
    if not autoSellEnabled then return end
    autoSellEnabled = false
    
    if autoSellLoop then
        task.cancel(autoSellLoop)
        autoSellLoop = nil
    end
    
    Notify({Title = "Auto Sell", Content = "Auto sell stopped", Duration = 2})
end

local function SetAutoSellThreshold(amount)
    if type(amount) == "number" and amount > 0 then
        autoSellThreshold = amount
        Notify({
            Title = "Auto Sell Threshold", 
            Content = string.format("Threshold set to %d fish", amount),
            Duration = 3
        })
        return true
    end
    return false
end

-- Auto Radar Toggle with safety
local function SafeToggleRadar()
    local success, message = ToggleFishingRadar()
    if success then
        Notify({Title = "Fishing Radar", Content = message, Duration = 3})
    else
        Notify({Title = "Radar Error", Content = message, Duration = 4})
    end
end

-- Auto Diving Gear Toggle with safety
local function SafeToggleDivingGear()
    local success, message = ToggleDivingGear()
    if success then
        Notify({Title = "Diving Gear", Content = message, Duration = 3})
    else
        Notify({Title = "Diving Gear Error", Content = message, Duration = 4})
    end
end

-- Coordinate Display System
local function CreateCoordinateDisplay()
    if coordinateGui and coordinateGui.Parent then coordinateGui:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "Anggazyy_Coordinates"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0.5, -110, 0, 15)
    frame.BackgroundColor3 = COLOR_SECONDARY
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0.3, 0)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = COLOR_PRIMARY
    stroke.Thickness = 1.6

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Text = "X: 0 | Y: 0 | Z: 0"
    label.TextXAlignment = Enum.TextXAlignment.Left

    coordinateGui = sg

    task.spawn(function()
        while coordinateGui and coordinateGui.Parent do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                label.Text = string.format("X: %d | Y: %d | Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
            else
                label.Text = "X: - | Y: - | Z: -"
            end
            task.wait(0.12)
        end
    end)
end

local function DestroyCoordinateDisplay()
    if coordinateGui and coordinateGui.Parent then
        pcall(function() coordinateGui:Destroy() end)
        coordinateGui = nil
    end
end

-- =============================================================================
-- MAIN WINDOW CREATION
-- =============================================================================

-- Main Window Creation
local Window = Rayfield:CreateWindow({
    Name = "Anggazyy Hub - Fish It",
    Icon = "fish",
    LoadingTitle = "Anggazyy Hub",
    LoadingSubtitle = "Premium Automation System",
    Theme = "Dark",
    ShowText = "AnggazyyHub",
    ToggleUIKeybind = Enum.KeyCode.K,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AnggazyyHubConfig",
        FileName = "FishIt_Config"
    }
})

-- ========== INFORMATION TAB ==========
local InfoTab = Window:CreateTab("Information", "info")

InfoTab:CreateParagraph({
    Title = "Anggazyy Hub - Fish It",
    Content = "Premium fishing automation with performance optimization\n• Auto Fishing System\n• Perfect Cast System\n• Advanced Bypass Features\n• Performance Optimization"
})

-- ========== FISHING TAB ==========
local FishingTab = Window:CreateTab("Fishing", "fish")

FishingTab:CreateParagraph({
    Title = "Auto Fishing System",
    Content = "Automated fishing with server communication"
})

statusParagraph = FishingTab:CreateParagraph({
    Title = "Status:",
    Content = "DISABLED"
})

-- Auto Fishing Section
FishingTab:CreateSection("🤖 Auto Fishing")

FishingTab:CreateToggle({
    Name = "Enable Auto Fishing",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(state)
        if state then
            StartAutoFish()
        else
            StopAutoFish()
        end
    end
})

-- Perfect Cast Section
FishingTab:CreateSection("🎯 Perfect Cast System")

FishingTab:CreateToggle({
    Name = "Perfect Cast Fishing",
    CurrentValue = false,
    Flag = "PerfectCastToggle",
    Callback = function(state)
        if state then
            StartPerfectCastFishing()
        else
            StopPerfectCastFishing()
        end
    end
})

FishingTab:CreateButton({
    Name = "Test Fishing Module",
    Callback = TestFishingSystem
})

FishingTab:CreateParagraph({
    Title = "Perfect Cast Features:",
    Content = "• Automatic charge timing\n• Perfect throw accuracy\n• Auto minigame completion\n• Maximum efficiency"
})

FishingTab:CreateParagraph({
    Title = "Auto Fishing Features:",
    Content = "• Automated fishing system\n• Server communication\n• Easy toggle on/off\n• Compatible with all bypass features"
})

-- ========== BYPASS TAB ==========
local BypassTab = Window:CreateTab("Bypass", "radar")

BypassTab:CreateParagraph({
    Title = "Game Bypass Features",
    Content = "Advanced features to enhance gameplay and automation"
})

-- Fishing Radar Section
BypassTab:CreateSection("📡 Fishing Radar")

BypassTab:CreateToggle({
    Name = "Fishing Radar",
    CurrentValue = false,
    Flag = "FishingRadarToggle",
    Callback = function(state)
        if state then
            StartFishingRadar()
        else
            StopFishingRadar()
        end
    end
})

BypassTab:CreateButton({
    Name = "Toggle Radar",
    Callback = SafeToggleRadar
})

-- Diving Gear Section
BypassTab:CreateSection("🤿 Diving Gear")

BypassTab:CreateToggle({
    Name = "Diving Gear",
    CurrentValue = false,
    Flag = "DivingGearToggle",
    Callback = function(state)
        if state then
            StartDivingGear()
        else
            StopDivingGear()
        end
    end
})

BypassTab:CreateButton({
    Name = "Toggle Diving Gear",
    Callback = SafeToggleDivingGear
})

-- Auto Sell Section
BypassTab:CreateSection("💰 Auto Sell Fish")

BypassTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(state)
        if state then
            StartAutoSell()
        else
            StopAutoSell()
        end
    end
})

BypassTab:CreateSlider({
    Name = "Sell Threshold",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 3,
    Suffix = "fish",
    Flag = "AutoSellThreshold",
    Callback = function(value)
        SetAutoSellThreshold(value)
    end
})

BypassTab:CreateButton({
    Name = "Sell All Fish Now",
    Callback = ManualSellAllFish
})

-- Quick Actions Section
BypassTab:CreateSection("⚡ Quick Actions")

BypassTab:CreateButton({
    Name = "Enable All Bypass",
    Callback = function()
        StartFishingRadar()
        StartDivingGear()
        StartAutoSell()
        Notify({Title = "Bypass", Content = "All bypass features enabled", Duration = 3})
    end
})

BypassTab:CreateButton({
    Name = "Disable All Bypass",
    Callback = function()
        StopFishingRadar()
        StopDivingGear()
        StopAutoSell()
        Notify({Title = "Bypass", Content = "All bypass features disabled", Duration = 3})
    end
})

-- ========== PLAYER CONFIGURATION TAB ==========
local PlayerConfigTab = Window:CreateTab("Player Config", "settings")

-- Performance Section
PlayerConfigTab:CreateSection("🚀 Performance")

PlayerConfigTab:CreateToggle({
    Name = "Ultra Anti Lag",
    CurrentValue = false,
    Flag = "AntiLagToggle",
    Callback = function(state)
        if state then
            EnableAntiLag()
        else
            DisableAntiLag()
        end
    end
})

-- Position Section
PlayerConfigTab:CreateSection("📍 Position")

PlayerConfigTab:CreateButton({
    Name = "Save Position",
    Callback = SaveCurrentPosition
})

PlayerConfigTab:CreateButton({
    Name = "Load Position", 
    Callback = LoadSavedPosition
})

PlayerConfigTab:CreateToggle({
    Name = "Lock Position",
    CurrentValue = false,
    Flag = "LockPositionToggle",
    Callback = function(state)
        if state then
            StartLockPosition()
        else
            StopLockPosition()
        end
    end
})

-- Quick Actions
PlayerConfigTab:CreateSection("⚡ Quick Actions")

PlayerConfigTab:CreateButton({
    Name = "Max Performance",
    Callback = function()
        EnableAntiLag()
        Notify({Title = "Performance", Content = "Maximum performance enabled", Duration = 2})
    end
})

-- ========== TELEPORTATION TAB ==========
local TeleportTab = Window:CreateTab("Teleportation", "map-pin")

TeleportTab:CreateParagraph({
    Title = "Location Teleport",
    Content = "Quick teleport to fishing spots and optimal locations"
})

TeleportTab:CreateDropdown({
    Name = "Select Destination",
    Options = { "Mount Hallow" },
    CurrentOption = "Mount Hallow",
    Flag = "MapSelect",
    Callback = function(selected)
        currentSelectedMap = selected
    end
})

TeleportTab:CreateButton({
    Name = "Teleport Now",
    Callback = function()
        local pos = Vector3.new(1819, 12, 3043)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            Notify({Title = "Teleport", Content = "Teleported to Mount Hallow", Duration = 2})
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Show Coordinates",
    CurrentValue = false,
    Flag = "ShowCoords",
    Callback = function(v)
        if v then
            CreateCoordinateDisplay()
        else
            DestroyCoordinateDisplay()
        end
    end
})

-- ========== PLAYER MANAGEMENT TAB ==========
local PlayerTab = Window:CreateTab("Player Stats", "user")

PlayerTab:CreateSection("🏃 Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Suffix = "studs/s",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 350},
    Increment = 1,
    CurrentValue = 50,
    Suffix = "power",
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end
})

PlayerTab:CreateButton({
    Name = "Reset Movement",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            Notify({Title = "Reset", Content = "Movement reset to default", Duration = 2})
        end
    end
})

-- ========== SETTINGS TAB ==========
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateButton({
    Name = "Unload Hub",
    Callback = function()
        StopAutoFish()
        StopPerfectCastFishing()
        StopLockPosition()
        DisableAntiLag()
        StopFishingRadar()
        StopDivingGear()
        StopAutoSell()
        DestroyCoordinateDisplay()
        Rayfield:Destroy()
        Notify({Title = "Unload", Content = "Hub unloaded successfully", Duration = 2})
    end
})

SettingsTab:CreateButton({
    Name = "Clean UI",
    Callback = function()
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            pcall(function()
                if (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel")) then
                    local name = (obj.Name or ""):lower()
                    local text = (obj.Text or ""):lower()
                    if string.find(name, "money") or string.find(text, "money") then
                        obj.Visible = false
                    end
                end
            end)
        end
        Notify({Title = "Clean", Content = "UI cleaned", Duration = 2})
    end
})

-- Enhanced Visual Effects
pcall(function()
    local mainBG = Window.UIElements and Window.UIElements.MainFrame and Window.UIElements.MainFrame.Background
    if mainBG then
        task.spawn(function()
            local colors = {
                Color3.fromRGB(30, 18, 45),
                Color3.fromRGB(35, 22, 55),
                Color3.fromRGB(25, 18, 40),
            }
            local i = 1
            while task.wait(6) and mainBG.Parent do
                local nextI = i % #colors + 1
                local tween = TweenService:Create(mainBG, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = colors[nextI]})
                tween:Play()
                i = nextI
            end
        end)
    end
end)

-- Configuration Loading
Rayfield:LoadConfiguration()

-- Initial Notification
Notify({
    Title = "Anggazyy Hub Ready", 
    Content = "System initialized successfully\n• Auto Fishing System\n• Perfect Cast System\n• Advanced Bypass Features\n• Performance Optimization",
    Duration = 4
})

--//////////////////////////////////////////////////////////////////////////////////
-- System Initialization Complete
--//////////////////////////////////////////////////////////////////////////////////
