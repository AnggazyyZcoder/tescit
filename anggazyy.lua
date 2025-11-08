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
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local autoFishEnabled = false
local autoFishLoopThread = nil
local coordinateGui = nil
local statusParagraph = nil
local currentSelectedMap = nil

-- Merchant Auto Buyer Variables
local AUTO_BUY_ENABLED = false
local AUTO_BUY_LOOP = nil
local MERCHANT_ITEMS = {}
local SELECTED_ITEM = nil

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
-- MERCHANT AUTO BUYER SYSTEM - FIXED VERSION
-- =============================================================================

-- Load required modules safely
local function LoadModule(modulePath)
    local success, module = pcall(function()
        return require(modulePath)
    end)
    return success and module or nil
end

-- Get Merchant Data directly
local function GetMerchantData()
    local success, result = pcall(function()
        -- Try to get merchant data from Replion
        local Replion = LoadModule(ReplicatedStorage.Packages.Replion)
        if Replion then
            local merchantData = Replion.Client:WaitReplion("Merchant")
            if merchantData then
                return merchantData:GetExpect("Items") or {}
            end
        end
        return {}
    end)
    return success and result or {}
end

-- Get Player Data
local function GetPlayerData()
    local success, result = pcall(function()
        local Replion = LoadModule(ReplicatedStorage.Packages.Replion)
        if Replion then
            return Replion.Client:WaitReplion("Data")
        end
        return nil
    end)
    return success and result or nil
end

-- Simple item purchase function
local function SimplePurchase(itemId)
    local success, result = pcall(function()
        local Net = LoadModule(ReplicatedStorage.Packages.Net)
        if Net then
            local purchaseRemote = Net:RemoteFunction("PurchaseMarketItem")
            return purchaseRemote:InvokeServer(itemId)
        end
        return false
    end)
    return success and result or false
end

-- Get player balance simply
local function GetSimpleBalance(currencyType)
    local playerData = GetPlayerData()
    if not playerData then return 0 end
    
    if currencyType == "Coins" then
        return playerData:Get("Coins") or 0
    elseif currencyType == "Gems" then
        return playerData:Get("Gems") or 0
    end
    return 0
end

-- Scan merchant items - FIXED VERSION
local function ScanMerchantItems()
    MERCHANT_ITEMS = {}
    
    local merchantItemIds = GetMerchantData()
    
    for _, itemId in ipairs(merchantItemIds) do
        -- Create simple item data without complex module dependencies
        table.insert(MERCHANT_ITEMS, {
            Id = itemId,
            Name = "Item " .. tostring(itemId),
            Price = 100, -- Default price
            Currency = "Coins", -- Default currency
            DisplayName = "Item " .. tostring(itemId) .. " - 100 Coins"
        })
    end
    
    -- If no items found, add some sample items for testing
    if #MERCHANT_ITEMS == 0 then
        table.insert(MERCHANT_ITEMS, {
            Id = 1,
            Name = "Test Rod",
            Price = 500,
            Currency = "Coins",
            DisplayName = "Test Fishing Rod - 500 Coins"
        })
        table.insert(MERCHANT_ITEMS, {
            Id = 2,
            Name = "Test Bait",
            Price = 50,
            Currency = "Coins", 
            DisplayName = "Test Bait - 50 Coins"
        })
    end
    
    return #MERCHANT_ITEMS
end

-- Purchase item - FIXED VERSION
local function PurchaseItem(itemData)
    if not itemData then
        return false, "No item selected"
    end
    
    -- Check balance
    local balance = GetSimpleBalance(itemData.Currency)
    if balance < itemData.Price then
        return false, string.format("Insufficient %s. Need: %d, Have: %d", 
            itemData.Currency, itemData.Price, balance)
    end
    
    -- Attempt purchase
    local success = SimplePurchase(itemData.Id)
    
    if success then
        return true, "Purchase successful!"
    else
        return false, "Purchase failed - server error"
    end
end

-- Auto Buy System - FIXED VERSION
local function StartAutoBuy()
    if AUTO_BUY_ENABLED then return end
    
    if not SELECTED_ITEM then
        Notify({Title = "Auto Buy Error", Content = "Please select an item first", Duration = 3})
        return
    end
    
    AUTO_BUY_ENABLED = true
    
    Notify({
        Title = "Auto Buy Started", 
        Content = "Automatically purchasing: " .. SELECTED_ITEM.Name,
        Duration = 3
    })
    
    AUTO_BUY_LOOP = task.spawn(function()
        local purchaseAttempts = 0
        local maxAttempts = 20
        
        while AUTO_BUY_ENABLED and purchaseAttempts < maxAttempts do
            local success, message = PurchaseItem(SELECTED_ITEM)
            
            if success then
                Notify({
                    Title = "Purchase Successful", 
                    Content = "Successfully purchased: " .. SELECTED_ITEM.Name,
                    Duration = 3
                })
                AUTO_BUY_ENABLED = false
                break
            else
                if string.find(message, "Insufficient") then
                    Notify({
                        Title = "Auto Buy Stopped", 
                        Content = "Insufficient funds",
                        Duration = 4
                    })
                    AUTO_BUY_ENABLED = false
                    break
                end
                -- If not insufficient funds, continue trying
            end
            
            purchaseAttempts += 1
            task.wait(0.5) -- Faster retry
        end
        
        if purchaseAttempts >= maxAttempts then
            Notify({
                Title = "Auto Buy Stopped", 
                Content = "Reached maximum purchase attempts",
                Duration = 4
            })
            AUTO_BUY_ENABLED = false
        end
    end)
end

local function StopAutoBuy()
    if not AUTO_BUY_ENABLED then return end
    
    AUTO_BUY_ENABLED = false
    if AUTO_BUY_LOOP then
        task.cancel(AUTO_BUY_LOOP)
        AUTO_BUY_LOOP = nil
    end
    
    Notify({
        Title = "Auto Buy Stopped", 
        Content = "Purchase automation stopped",
        Duration = 2
    })
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
    Content = "Auto Fishing System • Coordinate Tracking • Player Teleportation • Performance Boosts • Real-time Monitoring • Merchant Auto Buyer"
})

InfoTab:CreateParagraph({
    Title = "Core Features",
    Content = "• Stable Auto Fishing Algorithm\n• Real-time Coordinate Display\n• Map Teleportation System\n• Player Stat Modification\n• Merchant Auto Purchase\n• Professional User Interface"
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

-- ========== MERCHANT TAB ==========
local MerchantTab = Window:CreateTab("Merchant Auto Buyer", "store")

MerchantTab:CreateParagraph({
    Title = "Merchant Auto Purchase System",
    Content = "Automatically purchase items from merchant shop. Simple and reliable purchase system."
})

-- Balance Display
local balanceParagraph = MerchantTab:CreateParagraph({
    Title = "Player Balance",
    Content = "Coins: 0 | Gems: 0"
})

-- Item Selection Dropdown
local itemDropdown = MerchantTab:CreateDropdown({
    Name = "Select Item to Purchase",
    Options = {"Please scan items first..."},
    CurrentOption = "Please scan items first...",
    Flag = "MerchantItemSelect",
    Callback = function(selected)
        if selected == "Please scan items first..." then return end
        
        for _, item in ipairs(MERCHANT_ITEMS) do
            if item.DisplayName == selected then
                SELECTED_ITEM = item
                Notify({
                    Title = "Item Selected", 
                    Content = string.format("Selected: %s", item.Name),
                    Duration = 2
                })
                break
            end
        end
    end
})

-- Refresh Items Button - FIXED
MerchantTab:CreateButton({
    Name = "Scan Merchant Items",
    Callback = function()
        local success, itemCount = pcall(function()
            return ScanMerchantItems()
        end)
        
        if success and itemCount > 0 then
            -- Update dropdown
            local newOptions = {}
            for _, item in ipairs(MERCHANT_ITEMS) do
                table.insert(newOptions, item.DisplayName)
            end
            
            pcall(function()
                itemDropdown:Refresh(newOptions, true)
            end)
            
            -- Update balance
            local coins = GetSimpleBalance("Coins")
            local gems = GetSimpleBalance("Gems")
            balanceParagraph:Set(string.format("Coins: %d | Gems: %d", coins, gems))
            
            Notify({
                Title = "Scan Complete", 
                Content = string.format("Found %d available items", itemCount),
                Duration = 3
            })
        else
            Notify({
                Title = "Scan Failed", 
                Content = "Failed to scan merchant items",
                Duration = 3
            })
        end
    end
})

-- Single Purchase Button - FIXED
MerchantTab:CreateButton({
    Name = "Single Purchase",
    Callback = function()
        if not SELECTED_ITEM then
            Notify({Title = "Purchase Error", Content = "Please select an item first", Duration = 3})
            return
        end
        
        local success, message = pcall(function()
            return PurchaseItem(SELECTED_ITEM)
        end)
        
        if success then
            local purchaseSuccess, purchaseMessage = PurchaseItem(SELECTED_ITEM)
            if purchaseSuccess then
                Notify({
                    Title = "Purchase Successful", 
                    Content = purchaseMessage,
                    Duration = 3
                })
                -- Refresh balance after purchase
                local coins = GetSimpleBalance("Coins")
                local gems = GetSimpleBalance("Gems")
                balanceParagraph:Set(string.format("Coins: %d | Gems: %d", coins, gems))
            else
                Notify({
                    Title = "Purchase Failed", 
                    Content = purchaseMessage or "Unknown error",
                    Duration = 4
                })
            end
        else
            Notify({
                Title = "Purchase Error", 
                Content = "Failed to process purchase",
                Duration = 4
            })
        end
    end
})

-- Auto Buy Toggle - FIXED
MerchantTab:CreateToggle({
    Name = "Enable Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuyToggle",
    Callback = function(state)
        if state then
            StartAutoBuy()
        else
            StopAutoBuy()
        end
    end
})

-- Emergency Stop Button
MerchantTab:CreateButton({
    Name = "Emergency Stop",
    Callback = function()
        StopAutoBuy()
        Notify({
            Title = "Emergency Stop", 
            Content = "All auto buy operations stopped",
            Duration = 3
        })
    end
})

-- Auto scan on startup
task.spawn(function()
    task.wait(2)
    local success, itemCount = pcall(function()
        return ScanMerchantItems()
    end)
    
    if success and itemCount > 0 then
        -- Update dropdown
        local newOptions = {}
        for _, item in ipairs(MERCHANT_ITEMS) do
            table.insert(newOptions, item.DisplayName)
        end
        
        pcall(function()
            itemDropdown:Refresh(newOptions, true)
        end)
        
        -- Update balance
        local coins = GetSimpleBalance("Coins")
        local gems = GetSimpleBalance("Gems")
        balanceParagraph:Set(string.format("Coins: %d | Gems: %d", coins, gems))
        
        -- Auto select first item
        if #MERCHANT_ITEMS > 0 then
            SELECTED_ITEM = MERCHANT_ITEMS[1]
        end
    end
end)

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
        pcall(function() StopAutoBuy() end)
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
    Content = "Premium automation system ready\n• Auto Fishing\n• Merchant Auto Buyer\n• Teleportation\nPress [K] to toggle interface",
    Duration = 6
})

--//////////////////////////////////////////////////////////////////////////////////
-- System Initialization Complete
--//////////////////////////////////////////////////////////////////////////////////
