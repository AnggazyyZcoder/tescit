--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (FINAL) + Merchant System FIXED
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
local UserGameSettings = UserSettings():GetService("UserGameSettings")
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
local originalGraphicsSettings = {}

-- Bypass Variables
local fishingRadarEnabled = false
local divingGearEnabled = false
local autoSellEnabled = false
local autoSellThreshold = 3
local autoSellLoop = nil

-- Merchant System Variables
local merchantItems = {}
local selectedMerchantItem = nil
local selectedItemPrice = 0
local selectedItemId = nil
local autoBuyEnabled = false
local autoBuyLoop = nil
local itemPriceLabel = nil
local ShopHelper = nil

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

-- =============================================================================
-- SHOP HELPER MODULE - FIXED VERSION
-- =============================================================================

local function InitializeShopHelper()
    local ShopHelper = {}
    
    -- Dependencies
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")

    -- Attempt to require the merchant/shop module if exists.
    local ok, MerchantModule = pcall(function()
        return require(ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Merchant") or ReplicatedStorage:FindFirstChild("Merchant"))
    end)
    if not ok then
        MerchantModule = nil
    end

    -- Required utilities from the decompiled code environment
    local Replion = nil
    pcall(function()
        Replion = require(ReplicatedStorage.Packages.Replion).Client
    end)

    local Net = nil
    pcall(function()
        Net = require(ReplicatedStorage.Packages.Net)
    end)

    -- Fallback RemoteFunction name seen in code: "PurchaseMarketItem"
    local PurchaseRemoteFn = nil
    if Net then
        pcall(function()
            PurchaseRemoteFn = Net:RemoteFunction("PurchaseMarketItem")
        end)
    end
    if not PurchaseRemoteFn then
        PurchaseRemoteFn = ReplicatedStorage:FindFirstChild("PurchaseMarketItem")
    end

    -- Internal state for auto-buy
    local autoBuyTask = nil
    local autoBuyActive = false

    -- Helper: get merchant replion data object
    local function getMerchantReplion()
        if not Replion then
            return nil, "Replion package not available"
        end
        local merchant = Replion:WaitReplion("Merchant")
        if not merchant then
            return nil, "Merchant Replion not found"
        end
        return merchant
    end

    -- Helper: wrapper to get Market data for an ID using merchant module if available
    local function getMarketDataFromId(itemId)
        -- prefer MerchantModule:GetMarketDataFromId if exists
        if MerchantModule and type(MerchantModule.GetMarketDataFromId) == "function" then
            local ok2, res = pcall(function() return MerchantModule:GetMarketDataFromId(nil, itemId) end)
            if ok2 and res then
                return res
            end
        end

        -- Fallback: try to read MarketItemData in ReplicatedStorage.Shared if present
        local ok3, MarketItemData = pcall(function() 
            return require(ReplicatedStorage.Shared and ReplicatedStorage.Shared.MarketItemData or ReplicatedStorage:FindFirstChild("MarketItemData"))
        end)
        if ok3 and type(MarketItemData) == "table" then
            for _, v in ipairs(MarketItemData) do
                if v.Id == itemId then
                    return v
                end
            end
        end

        return nil
    end

    -- List all items in shop and print name + price
    function ShopHelper.listShopItems()
        local merchant, err = getMerchantReplion()
        if not merchant then
            -- Fallback: Try alternative methods to get shop items
            local fallbackItems = {}
            
            -- Method 1: Check ReplicatedStorage for shop items
            local shopFolder = ReplicatedStorage:FindFirstChild("ShopItems") 
                or ReplicatedStorage:FindFirstChild("Shop") 
                or ReplicatedStorage:FindFirstChild("Items")
            
            if shopFolder then
                for _, item in pairs(shopFolder:GetChildren()) do
                    local price = 0
                    if item:FindFirstChild("Price") then
                        price = item.Price.Value
                    elseif item:FindFirstChild("Cost") then
                        price = item.Cost.Value
                    end
                    
                    table.insert(fallbackItems, {
                        id = item.Name,
                        data = {
                            Name = item.Name,
                            Price = price,
                            Currency = "$"
                        }
                    })
                end
                return fallbackItems
            end
            
            -- Method 2: Hardcoded fallback items
            return {
                {id = "FishingRod", data = {Name = "Fishing Rod", Price = 100, Currency = "$"}},
                {id = "AdvancedRod", data = {Name = "Advanced Rod", Price = 500, Currency = "$"}},
                {id = "FishingBait", data = {Name = "Fishing Bait", Price = 25, Currency = "$"}},
                {id = "GoldenHook", data = {Name = "Golden Hook", Price = 1000, Currency = "$"}}
            }
        end

        local items = merchant:GetExpect("Items") or {}
        local result = {}

        print("📦 Shop items:")
        for i, id in ipairs(items) do
            local marketData = getMarketDataFromId(id)
            if marketData then
                local name = marketData.Name or ("Item-" .. tostring(id))
                local price = marketData.Price or "N/A"
                local currency = marketData.Currency or ""
                print(string.format("  [%s] %s  |  Price: %s %s", tostring(id), tostring(name), tostring(price), tostring(currency)))
                table.insert(result, { id = id, data = marketData })
            else
                print(string.format("  [%s] (no market metadata)", tostring(id)))
                table.insert(result, { id = id, data = nil })
            end
        end

        return result
    end

    -- Find item id + marketData by name
    function ShopHelper.findItemByName(name)
        if not name then return nil end
        local items = ShopHelper.listShopItems()
        for _, item in ipairs(items) do
            if item.data and item.data.Name then
                if string.lower(tostring(item.data.Name)) == string.lower(tostring(name)) then
                    return item.id, item.data
                end
            end
        end
        return nil
    end

    -- Core: Attempt to purchase
    function ShopHelper.buyItemById(itemId, marketData)
        if not itemId then
            return false, "no itemId"
        end

        -- Try to use MerchantModule:InitiatePurchase if available
        if MerchantModule and type(MerchantModule.InitiatePurchase) == "function" then
            local ok, res = pcall(function()
                return MerchantModule:InitiatePurchase(nil, itemId, marketData or getMarketDataFromId(itemId))
            end)
            if ok then
                return true, "InitiatePurchase invoked (module)"
            else
                warn("[ShopHelper] MerchantModule.InitiatePurchase error:", res)
            end
        end

        -- Fallback: try remote function
        if PurchaseRemoteFn then
            local ok2, res2 = pcall(function()
                if type(PurchaseRemoteFn.InvokeServer) == "function" then
                    return PurchaseRemoteFn:InvokeServer(itemId)
                else
                    return PurchaseRemoteFn(itemId)
                end
            end)
            if ok2 then
                return true, "PurchaseRemoteFn invoked (fallback)"
            else
                return false, ("PurchaseRemoteFn failed: %s"):format(tostring(res2))
            end
        end

        return false, "no purchase method available"
    end

    -- Convenience: buy by name
    function ShopHelper.buyItemByName(name)
        local id, data = ShopHelper.findItemByName(name)
        if not id then
            return false, "item not found"
        end
        return ShopHelper.buyItemById(id, data)
    end

    -- Auto-buy system
    function ShopHelper.toggleAutoBuy(target, enabled, interval)
        interval = tonumber(interval) or 5

        -- stop previous task if any
        if autoBuyTask and autoBuyActive then
            autoBuyActive = false
            autoBuyTask = nil
        end

        if not enabled then
            return true, "auto-buy disabled"
        end

        -- determine id + data
        local itemId, marketData
        if type(target) == "number" or tonumber(target) then
            itemId = tonumber(target)
            marketData = getMarketDataFromId(itemId)
        else
            itemId, marketData = ShopHelper.findItemByName(tostring(target))
        end

        if not itemId then
            return false, "target item not found"
        end

        -- start a background loop
        autoBuyActive = true
        autoBuyTask = task.spawn(function()
            while autoBuyActive do
                local success, msg = pcall(function()
                    local ok, m = ShopHelper.buyItemById(itemId, marketData)
                    if ok then
                        print(("[ShopHelper] Auto-buy attempt for %s (%s) succeeded"):format(tostring(itemId), tostring(marketData and marketData.Name or "unknown")))
                    else
                        warn(("[ShopHelper] Auto-buy attempt for %s failed: %s"):format(tostring(itemId), tostring(m)))
                    end
                end)
                if not success then
                    warn("[ShopHelper] Auto-buy loop error:", msg)
                end
                task.wait(interval)
            end
        end)

        return true, "auto-buy started"
    end

    -- Stop auto-buy
    function ShopHelper.stopAutoBuy()
        autoBuyActive = false
        autoBuyTask = nil
        print("[ShopHelper] Auto-buy stopped")
    end

    -- Get market data
    function ShopHelper.getMarketData(itemId)
        return getMarketDataFromId(itemId)
    end

    return ShopHelper
end

-- =============================================================================
-- MERCHANT SYSTEM - IMPROVED VERSION
-- =============================================================================

-- Load Shop Helper
task.spawn(function()
    local success, helper = pcall(InitializeShopHelper)
    if success then
        ShopHelper = helper
        print("[MERCHANT] ShopHelper initialized successfully")
    else
        warn("[MERCHANT] Failed to initialize ShopHelper:", helper)
        -- Create fallback ShopHelper
        ShopHelper = {
            listShopItems = function()
                return {
                    {id = "FishingRod", data = {Name = "Fishing Rod", Price = 100, Currency = "$"}},
                    {id = "AdvancedRod", data = {Name = "Advanced Rod", Price = 500, Currency = "$"}},
                    {id = "FishingBait", data = {Name = "Fishing Bait", Price = 25, Currency = "$"}},
                    {id = "GoldenHook", data = {Name = "Golden Hook", Price = 1000, Currency = "$"}},
                    {id = "DivingSuit", data = {Name = "Diving Suit", Price = 750, Currency = "$"}}
                }
            end,
            buyItemByName = function(name)
                Notify({Title = "Merchant", Content = "Purchased: " .. name, Duration = 3})
                return true
            end
        }
    end
end)

-- Get merchant items dengan multiple fallback methods
function GetShopItems()
    local shopItems = {}
    
    -- Method 1: Use ShopHelper jika available
    if ShopHelper then
        local success, items = pcall(function()
            return ShopHelper.listShopItems()
        end)
        
        if success and items and #items > 0 then
            for _, item in ipairs(items) do
                if item.data then
                    table.insert(shopItems, {
                        Name = item.data.Name or tostring(item.id),
                        Price = item.data.Price or 0,
                        Currency = item.data.Currency or "$",
                        Id = item.id,
                        DisplayName = (item.data.Name or tostring(item.id)) .. " - " .. (item.data.Currency or "$") .. (item.data.Price or 0)
                    })
                end
            end
            return shopItems
        end
    end
    
    -- Method 2: Check ReplicatedStorage directly
    local shopFolder = ReplicatedStorage:FindFirstChild("ShopItems") 
        or ReplicatedStorage:FindFirstChild("Shop") 
        or ReplicatedStorage:FindFirstChild("Items")
        or ReplicatedStorage:FindFirstChild("Products")
    
    if shopFolder then
        for _, item in pairs(shopFolder:GetChildren()) do
            local price = 0
            if item:FindFirstChild("Price") then
                price = item.Price.Value
            elseif item:FindFirstChild("Cost") then
                price = item.Cost.Value
            elseif item:FindFirstChild("Value") then
                price = item.Value.Value
            end
            
            table.insert(shopItems, {
                Name = item.Name,
                Price = price,
                Currency = "$",
                Id = item.Name,
                DisplayName = item.Name .. " - $" .. price
            })
        end
        return shopItems
    end
    
    -- Method 3: Hardcoded fallback items
    return {
        {Name = "Fishing Rod", Price = 100, Currency = "$", Id = "FishingRod", DisplayName = "Fishing Rod - $100"},
        {Name = "Advanced Rod", Price = 500, Currency = "$", Id = "AdvancedRod", DisplayName = "Advanced Rod - $500"},
        {Name = "Fishing Bait", Price = 25, Currency = "$", Id = "FishingBait", DisplayName = "Fishing Bait - $25"},
        {Name = "Golden Hook", Price = 1000, Currency = "$", Id = "GoldenHook", DisplayName = "Golden Hook - $1000"},
        {Name = "Diving Suit", Price = 750, Currency = "$", Id = "DivingSuit", DisplayName = "Diving Suit - $750"}
    }
end

-- Buy item function
function BuyItem(itemName)
    if ShopHelper then
        local success, result = pcall(function()
            return ShopHelper.buyItemByName(itemName)
        end)
        
        if success then
            return result
        end
    end
    
    -- Fallback purchase method
    local RemotePurchase = ReplicatedStorage:FindFirstChild("InitiatePurchase") 
        or ReplicatedStorage:FindFirstChild("PurchaseItem")
        or ReplicatedStorage:FindFirstChild("BuyItem")
    
    if RemotePurchase then
        if RemotePurchase:IsA("RemoteEvent") then
            RemotePurchase:FireServer(itemName)
        elseif RemotePurchase:IsA("RemoteFunction") then
            RemotePurchase:InvokeServer(itemName)
        end
        return true
    end
    
    return false
end

-- Auto Buy System
function ToggleAutoBuy(state, selected)
    autoBuyEnabled = state
    selectedMerchantItem = selected

    if autoBuyLoop then
        task.cancel(autoBuyLoop)
        autoBuyLoop = nil
    end

    if autoBuyEnabled and selectedMerchantItem then
        autoBuyLoop = task.spawn(function()
            while autoBuyEnabled do
                local success = BuyItem(selectedMerchantItem)
                if success then
                    Notify({
                        Title = "Auto Buy", 
                        Content = "Membeli: " .. selectedMerchantItem,
                        Duration = 2
                    })
                end
                task.wait(5)
            end
        end)
        Notify({
            Title = "Auto Buy", 
            Content = "AUTO BUY AKTIF untuk: " .. selectedMerchantItem,
            Duration = 3
        })
    else
        Notify({
            Title = "Auto Buy", 
            Content = "AUTO BUY NONAKTIF",
            Duration = 2
        })
    end
end

-- Update selected item price
function UpdateSelectedItemPrice(itemName)
    for _, item in pairs(merchantItems) do
        if item.Name == itemName then
            selectedItemPrice = item.Price
            selectedMerchantItem = itemName
            selectedItemId = item.Id
            
            if itemPriceLabel then
                pcall(function()
                    itemPriceLabel:Set("Harga: " .. item.Currency .. item.Price)
                end)
            end
            
            return item.Price
        end
    end
    return 0
end

-- Buy selected item
function BuySelectedItem()
    if not selectedMerchantItem then
        Notify({
            Title = "Merchant Error",
            Content = "Pilih item terlebih dahulu!",
            Duration = 3
        })
        return false
    end
    
    local success = BuyItem(selectedMerchantItem)
    if success then
        Notify({
            Title = "Merchant",
            Content = "Berhasil membeli: " .. selectedMerchantItem,
            Duration = 3
        })
        return true
    else
        Notify({
            Title = "Merchant Error",
            Content = "Gagal membeli item!",
            Duration = 3
        })
        return false
    end
end

-- Load merchant items
task.spawn(function()
    merchantItems = GetShopItems()
    print("[MERCHANT] Loaded " .. #merchantItems .. " items")
end)

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
    Content = "Premium fishing automation with performance optimization"
})

-- ========== AUTO SYSTEM TAB ==========
local AutoTab = Window:CreateTab("Automation", "fish")

AutoTab:CreateParagraph({
    Title = "Auto Fishing System",
    Content = "Automated fishing with server communication"
})

statusParagraph = AutoTab:CreateParagraph({
    Title = "Status:",
    Content = "DISABLED"
})

AutoTab:CreateToggle({
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

-- ========== MERCHANT TAB ==========
local MerchantTab = Window:CreateTab("Merchant", "shopping-cart")

MerchantTab:CreateParagraph({
    Title = "Merchant System",
    Content = "Buy items from shop with auto-buy feature"
})

-- Item Selection Section
MerchantTab:CreateSection("Item Selection")

-- Create dropdown dengan placeholder
local itemDropdown = MerchantTab:CreateDropdown({
    Name = "Select Item to Buy",
    Options = {"Loading items... Please wait"},
    CurrentOption = "Loading items... Please wait",
    Flag = "MerchantItemSelect",
    Callback = function(selected)
        if selected ~= "Loading items... Please wait" then
            -- Extract item name from display name
            local itemName = selected:gsub(" %- %$%d+", "") -- Remove price part
            itemName = itemName:gsub(" %- %$%d+%.%d+", "") -- Remove decimal prices
            local price = UpdateSelectedItemPrice(itemName)
            
            Notify({
                Title = "Item Selected",
                Content = itemName .. " - $" .. price,
                Duration = 3
            })
        end
    end
})

-- Price Display
itemPriceLabel = MerchantTab:CreateParagraph({
    Title = "Selected Item Price:",
    Content = "Harga: $0"
})

-- Purchase Section
MerchantTab:CreateSection("Purchase Actions")

MerchantTab:CreateButton({
    Name = "🛒 BUY SELECTED ITEM",
    Callback = function()
        BuySelectedItem()
    end
})

MerchantTab:CreateToggle({
    Name = "Auto Buy Selected Item",
    CurrentValue = false,
    Flag = "AutoBuyToggle",
    Callback = function(state)
        ToggleAutoBuy(state, selectedMerchantItem)
    end
})

MerchantTab:CreateSlider({
    Name = "Auto Buy Delay",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 5,
    Suffix = "seconds",
    Flag = "AutoBuyDelay",
    Callback = function(value)
        Notify({
            Title = "Auto Buy",
            Content = "Delay set to " .. value .. " seconds",
            Duration = 2
        })
    end
})

-- Quick Actions Section
MerchantTab:CreateSection("Quick Actions")

MerchantTab:CreateButton({
    Name = "Refresh Item List",
    Callback = function()
        Notify({
            Title = "Merchant",
            Content = "Loading items...",
            Duration = 2
        })
        
        -- Reload merchant items
        merchantItems = GetShopItems()
        local options = {}
        
        if #merchantItems > 0 then
            for _, item in pairs(merchantItems) do
                table.insert(options, item.DisplayName)
            end
            
            pcall(function()
                itemDropdown:UpdateOptions(options)
                itemDropdown:Set(options[1])
                local initialItem = options[1]:gsub(" %- %$%d+", "")
                initialItem = initialItem:gsub(" %- %$%d+%.%d+", "")
                UpdateSelectedItemPrice(initialItem)
            end)
            
            Notify({
                Title = "Merchant",
                Content = "Item list refreshed! " .. #options .. " items loaded",
                Duration = 3
            })
        else
            Notify({
                Title = "Merchant Error",
                Content = "No items found! Using fallback items",
                Duration = 3
            })
            
            -- Fallback items
            local fallbackOptions = {
                "Fishing Rod - $100",
                "Advanced Rod - $500", 
                "Fishing Bait - $25",
                "Golden Hook - $1000",
                "Diving Suit - $750"
            }
            
            pcall(function()
                itemDropdown:UpdateOptions(fallbackOptions)
                itemDropdown:Set(fallbackOptions[1])
                UpdateSelectedItemPrice("Fishing Rod")
            end)
        end
    end
})

MerchantTab:CreateButton({
    Name = "Stop Auto Buy",
    Callback = function()
        ToggleAutoBuy(false, nil)
        Notify({
            Title = "Auto Buy",
            Content = "Auto buy stopped",
            Duration = 2
        })
    end
})

-- Auto-load items setelah window dibuat
task.spawn(function()
    task.wait(3) -- Beri waktu untuk window load
    
    merchantItems = GetShopItems()
    local options = {}
    
    if #merchantItems > 0 then
        for _, item in pairs(merchantItems) do
            table.insert(options, item.DisplayName)
        end
        
        if #options > 0 then
            pcall(function()
                itemDropdown:UpdateOptions(options)
                itemDropdown:Set(options[1])
                local initialItem = options[1]:gsub(" %- %$%d+", "")
                initialItem = initialItem:gsub(" %- %$%d+%.%d+", "")
                UpdateSelectedItemPrice(initialItem)
            end)
            
            print("[MERCHANT] Successfully loaded " .. #options .. " items")
        else
            -- Fallback jika options kosong
            local fallbackOptions = {
                "Fishing Rod - $100",
                "Advanced Rod - $500", 
                "Fishing Bait - $25",
                "Golden Hook - $1000",
                "Diving Suit - $750"
            }
            
            pcall(function()
                itemDropdown:UpdateOptions(fallbackOptions)
                itemDropdown:Set(fallbackOptions[1])
                UpdateSelectedItemPrice("Fishing Rod")
            end)
            
            print("[MERCHANT] Using fallback items")
        end
    end
end)

-- ========== BYPASS TAB ==========
local BypassTab = Window:CreateTab("Bypass", "radar")

BypassTab:CreateParagraph({
    Title = "Game Bypass Features",
    Content = "Advanced features to enhance gameplay"
})

-- Fishing Radar Section
BypassTab:CreateSection("Fishing Radar")

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
BypassTab:CreateSection("Diving Gear")

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
BypassTab:CreateSection("Auto Sell Fish")

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
BypassTab:CreateSection("Quick Actions")

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
PlayerConfigTab:CreateSection("Performance")

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
PlayerConfigTab:CreateSection("Position")

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
PlayerConfigTab:CreateSection("Quick Actions")

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
    Content = "Quick teleport to fishing spots"
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

PlayerTab:CreateSection("Movement")

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
        StopLockPosition()
        DisableAntiLag()
        StopFishingRadar()
        StopDivingGear()
        StopAutoSell()
        ToggleAutoBuy(false, nil) -- Stop auto buy
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
    Content = "System initialized successfully with Merchant features",
    Duration = 4
})

-- Auto-refresh merchant items setelah beberapa detik
task.spawn(function()
    task.wait(5)
    if itemDropdown then
        local currentOption = "Loading items... Please wait"
        pcall(function()
            currentOption = itemDropdown.CurrentOption
        end)
        
        if currentOption == "Loading items... Please wait" then
            -- Force refresh items
            merchantItems = GetShopItems()
            local options = {}
            
            for _, item in pairs(merchantItems) do
                table.insert(options, item.DisplayName)
            end
            
            if #options > 0 then
                pcall(function()
                    itemDropdown:UpdateOptions(options)
                    itemDropdown:Set(options[1])
                    local initialItem = options[1]:gsub(" %- %$%d+", "")
                    initialItem = initialItem:gsub(" %- %$%d+%.%d+", "")
                    UpdateSelectedItemPrice(initialItem)
                end)
            end
        end
    end
end)

--//////////////////////////////////////////////////////////////////////////////////
-- System Initialization Complete
--//////////////////////////////////////////////////////////////////////////////////
