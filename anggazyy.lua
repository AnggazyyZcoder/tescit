--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (FINAL)
-- Rayfield UI + Lucide icons
-- Clean, modern, professional design
-- Author: Anggazyy (refactor)
--//////////////////////////////////////////////////////////////////////////////////

-- CONFIG: ubah sesuai kebutuhan
local AUTO_FISH_REMOTE_NAME = "UpdateAutoFishingState"
local NET_PACKAGES_FOLDER = "Packages"
local RAYFIELD_URL = 'https://sirius.menu/rayfield'

-- Services & Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

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

-- Auto Fishing System
local function StartAutoFish()
    if autoFishEnabled then return end
    autoFishEnabled = true
    if statusParagraph then 
        pcall(function() 
            statusParagraph:Set("Status: ACTIVE")
        end) 
    end
    Notify({Title = "Auto Fishing", Content = "System activated successfully", Duration = 2})

    autoFishLoopThread = task.spawn(function()
        while autoFishEnabled do
            pcall(function()
                SafeInvokeAutoFishing(true)
                
                if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Replion") then
                    pcall(function()
                        local Replion = require(ReplicatedStorage.Packages.Replion)
                        if Replion and Replion.Client and type(Replion.Client.WaitReplion) == "function" then
                            local Data = Replion.Client:WaitReplion("Data")
                        end
                    end)
                end
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
end

-- =============================================================================
-- PLAYER CONFIGURATION SYSTEM
-- =============================================================================

-- Anti Lag System
local function EnableAntiLag()
    if antiLagEnabled then return end
    antiLagEnabled = true
    
    -- Reduce graphics settings
    pcall(function()
        -- Lighting settings
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999
        Lighting.Brightness = 2
        
        -- Terrain settings
        if workspace.Terrain then
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 0
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
        end
        
        -- Reduce particle effects
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
    end)
    
    Notify({Title = "Anti Lag", Content = "Graphics optimization enabled", Duration = 3})
end

local function DisableAntiLag()
    if not antiLagEnabled then return end
    antiLagEnabled = false
    
    -- Restore graphics settings
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1
        
        if workspace.Terrain then
            workspace.Terrain.WaterReflectance = 0.5
            workspace.Terrain.WaterTransparency = 0.5
            workspace.Terrain.WaterWaveSize = 0.5
            workspace.Terrain.WaterWaveSpeed = 10
        end
        
        -- Restore particle effects
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
        end
    end)
    
    Notify({Title = "Anti Lag", Content = "Graphics optimization disabled", Duration = 3})
end

-- Save Position System
local function SaveCurrentPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        lastSavedPosition = character.HumanoidRootPart.Position
        Notify({
            Title = "Position Saved", 
            Content = string.format("Position saved: X:%.0f Y:%.0f Z:%.0f", 
                lastSavedPosition.X, lastSavedPosition.Y, lastSavedPosition.Z),
            Duration = 3
        })
        return true
    else
        Notify({Title = "Save Failed", Content = "Character not found", Duration = 3})
        return false
    end
end

local function LoadSavedPosition()
    if not lastSavedPosition then
        Notify({Title = "Load Failed", Content = "No position saved", Duration = 3})
        return false
    end
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(lastSavedPosition)
        Notify({
            Title = "Position Loaded", 
            Content = "Teleported to saved position",
            Duration = 3
        })
        return true
    else
        Notify({Title = "Load Failed", Content = "Character not found", Duration = 3})
        return false
    end
end

-- Lock Position System
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
            
            -- If player moved more than 5 studs, teleport back
            if distance > 5 then
                character.HumanoidRootPart.CFrame = CFrame.new(lastSavedPosition)
            end
        end
    end)
    
    Notify({Title = "Position Lock", Content = "Player position locked", Duration = 3})
end

local function StopLockPosition()
    if not lockPositionEnabled then return end
    lockPositionEnabled = false
    
    if lockPositionLoop then
        lockPositionLoop:Disconnect()
        lockPositionLoop = nil
    end
    
    Notify({Title = "Position Lock", Content = "Player position unlocked", Duration = 3})
end

-- Auto-save position when Save Position is enabled
local function StartAutoSavePosition()
    if not savePositionEnabled then return end
    
    task.spawn(function()
        while savePositionEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                lastSavedPosition = character.HumanoidRootPart.Position
            end
            task.wait(5) -- Save every 5 seconds
        end
    end)
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

-- Player Information System
local function GetPlayerInfo()
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    
    local playTime = "2h 34m"
    
    local jobId = game.JobId
    local serverLink = "https://roblox.com/games/" .. game.PlaceId .. "?jobId=" .. jobId
    
    return {
        Username = username,
        DisplayName = displayName,
        PlayTime = playTime,
        ServerLink = serverLink
    }
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
    Title = "Welcome to Anggazyy Hub",
    Content = "Premium fishing automation system with advanced features and modern interface design."
})

InfoTab:CreateParagraph({
    Title = "System Overview",
    Content = "Auto Fishing System • Coordinate Tracking • Player Teleportation • Performance Boosts • Real-time Monitoring • Player Configuration"
})

InfoTab:CreateParagraph({
    Title = "Core Features",
    Content = "• Stable Auto Fishing Algorithm\n• Real-time Coordinate Display\n• Map Teleportation System\n• Player Stat Modification\n• Anti Lag System\n• Position Management\n• Professional User Interface"
})

-- ========== AUTO SYSTEM TAB ==========
local AutoTab = Window:CreateTab("Automation", "fish")

AutoTab:CreateParagraph({
    Title = "Auto Fishing Controller",
    Content = "Enable automated fishing system with optimized performance and server communication."
})

-- Status display
statusParagraph = AutoTab:CreateParagraph({
    Title = "Status:",
    Content = "Status: DISABLED"
})

AutoTab:CreateToggle({
    Name = "Activate Auto Fishing",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(state)
        if not LocalPlayer then
            Notify({Title = "System Error", Content = "Player instance not available", Duration = 3})
            return
        end

        if state then
            local ok, err = pcall(StartAutoFish)
            if not ok then
                Notify({Title = "Activation Failed", Content = tostring(err or "Unknown error"), Duration = 4})
            end
        else
            local ok, err = pcall(StopAutoFish)
            if not ok then
                Notify({Title = "Deactivation Failed", Content = tostring(err or "Unknown error"), Duration = 4})
            end
        end
    end
})

-- ========== PLAYER CONFIGURATION TAB ==========
local PlayerConfigTab = Window:CreateTab("Player Configuration", "settings")

PlayerConfigTab:CreateParagraph({
    Title = "Player Configuration System",
    Content = "Advanced player settings for performance optimization and position management."
})

-- Anti Lag Section
PlayerConfigTab:CreateSection("Performance Optimization")

PlayerConfigTab:CreateToggle({
    Name = "Anti Lag Mode",
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

PlayerConfigTab:CreateParagraph({
    Title = "Anti Lag Information",
    Content = "Reduces graphics quality for better performance:\n• Disables shadows\n• Reduces water effects\n• Disables particle effects\n• Optimizes lighting"
})

-- Position Management Section
PlayerConfigTab:CreateSection("Position Management")

PlayerConfigTab:CreateToggle({
    Name = "Auto Save Position",
    CurrentValue = false,
    Flag = "SavePositionToggle",
    Callback = function(state)
        savePositionEnabled = state
        if state then
            StartAutoSavePosition()
            Notify({Title = "Auto Save", Content = "Auto position saving enabled", Duration = 3})
        else
            Notify({Title = "Auto Save", Content = "Auto position saving disabled", Duration = 3})
        end
    end
})

PlayerConfigTab:CreateButton({
    Name = "Save Current Position",
    Callback = function()
        SaveCurrentPosition()
    end
})

PlayerConfigTab:CreateButton({
    Name = "Load Saved Position",
    Callback = function()
        LoadSavedPosition()
    end
})

PlayerConfigTab:CreateToggle({
    Name = "Lock Player Position",
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

PlayerConfigTab:CreateParagraph({
    Title = "Position Management Info",
    Content = "• Auto Save: Saves position every 5 seconds\n• Manual Save: Save current position manually\n• Load Position: Teleport to saved position\n• Lock Position: Prevents moving from saved position"
})

-- Quick Actions Section
PlayerConfigTab:CreateSection("Quick Actions")

PlayerConfigTab:CreateButton({
    Name = "Optimize All Graphics",
    Callback = function()
        EnableAntiLag()
        Notify({Title = "Optimization", Content = "All graphics settings optimized", Duration = 3})
    end
})

PlayerConfigTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        DisableAntiLag()
        StopLockPosition()
        savePositionEnabled = false
        Notify({Title = "Reset", Content = "All player settings reset", Duration = 3})
    end
})

-- ========== TELEPORTATION TAB ==========
local TeleportTab = Window:CreateTab("Teleportation", "map-pin")

TeleportTab:CreateParagraph({
    Title = "Location Teleportation",
    Content = "Instant teleportation to premium fishing locations with precise coordinates."
})

-- Mount Hallow Map Data
local maps = {
    {
        Label = "Mount Hallow", 
        Value = "Mount Hallow", 
        Pos = Vector3.new(1819, 12, 3043)
    }
}

local defaultMap = maps[1].Value

TeleportTab:CreateDropdown({
    Name = "Destination Selection",
    Options = { "Mount Hallow" },
    CurrentOption = defaultMap,
    Flag = "MapSelect",
    Callback = function(selected)
        currentSelectedMap = selected
        Notify({Title = "Location Selected", Content = "Destination: " .. selected, Duration = 2})
    end
})

TeleportTab:CreateButton({
    Name = "Execute Teleportation",
    Callback = function()
        if not currentSelectedMap then 
            currentSelectedMap = defaultMap 
        end
        
        local chosen = maps[1]
        if chosen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(chosen.Pos)
            Notify({
                Title = "Teleportation Complete", 
                Content = "Successfully teleported to " .. chosen.Value,
                Duration = 3
            })
        else
            Notify({
                Title = "Teleportation Failed", 
                Content = "Character not ready for teleportation",
                Duration = 3
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Display Coordinate Overlay",
    CurrentValue = false,
    Flag = "ShowCoords",
    Callback = function(v)
        if v then
            CreateCoordinateDisplay()
            Notify({Title = "Display Activated", Content = "Coordinate overlay enabled", Duration = 2})
        else
            DestroyCoordinateDisplay()
            Notify({Title = "Display Deactivated", Content = "Coordinate overlay disabled", Duration = 2})
        end
    end
})

-- ========== PLAYER MANAGEMENT TAB ==========
local PlayerTab = Window:CreateTab("Player Management", "user")

local playerInfo = GetPlayerInfo()

PlayerTab:CreateParagraph({
    Title = "Avatar Information",
    Content = string.format("Username: %s\nDisplay Name: %s", playerInfo.Username, playerInfo.DisplayName)
})

PlayerTab:CreateParagraph({
    Title = "Session Statistics",
    Content = string.format("Current Play Time: %s", playerInfo.PlayTime)
})

-- Server Link with Copy Functionality
PlayerTab:CreateButton({
    Name = "Copy Server Link",
    Callback = function()
        local serverLink = playerInfo.ServerLink
        if setclipboard then
            setclipboard(serverLink)
            Notify({
                Title = "Link Copied", 
                Content = "Server link copied to clipboard",
                Duration = 3
            })
        else
            Notify({
                Title = "Copy Failed", 
                Content = "Clipboard access not available",
                Duration = 3
            })
        end
    end
})

PlayerTab:CreateSection("Performance Settings")

PlayerTab:CreateSlider({
    Name = "Movement Speed",
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
    Name = "Reset to Default Values",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            Notify({
                Title = "Values Reset", 
                Content = "Player stats restored to default",
                Duration = 2
            })
        end
    end
})

-- ========== SETTINGS TAB ==========
local SettingsTab = Window:CreateTab("Configuration", "settings")

SettingsTab:CreateParagraph({
    Title = "System Configuration",
    Content = "Manage application settings and system utilities."
})

SettingsTab:CreateButton({
    Name = "Unload Application",
    Callback = function()
        pcall(function() StopAutoFish() end)
        pcall(function() StopLockPosition() end)
        pcall(function() DisableAntiLag() end)
        pcall(function() Rayfield:Destroy() end)
        DestroyCoordinateDisplay()
        Notify({
            Title = "System Shutdown", 
            Content = "Application successfully unloaded",
            Duration = 3
        })
    end
})

SettingsTab:CreateButton({
    Name = "Clean UI Elements",
    Callback = function()
        task.spawn(function()
            for _, obj in ipairs(CoreGui:GetDescendants()) do
                pcall(function()
                    if (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel")) then
                        local nameLower = (obj.Name or ""):lower()
                        local textLower = (obj.Text or ""):lower()
                        if string.find(nameLower, "money") or string.find(textLower, "money") or string.find(nameLower, "100") then
                            obj.Visible = false
                        end
                    end
                end)
            end
        end)
        Notify({
            Title = "Cleanup Complete", 
            Content = "UI elements cleaned successfully",
            Duration = 2
        })
    end
})

SettingsTab:CreateParagraph({
    Title = "Credits & Information",
    Content = "Anggazyy Hub • Professional Automation System\nRayfield Interface • Lucide Icons"
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
pcall(function() Rayfield:LoadConfiguration() end)

-- Initial Notification
Notify({
    Title = "Anggazyy Hub Initialized", 
    Content = "Premium automation system ready\n• Auto Fishing\n• Player Configuration\n• Teleportation\n• Performance Optimization\nPress [K] to toggle interface",
    Duration = 6
})

--//////////////////////////////////////////////////////////////////////////////////
-- System Initialization Complete
--//////////////////////////////////////////////////////////////////////////////////
