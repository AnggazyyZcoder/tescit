local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local Window = nil
local uiInitialized = false

------------------------------------------------------------
-- 🐟 AUTO FISH SYSTEM
------------------------------------------------------------
local autoFishEnabled = false
local statusLabel = nil

local function toggleAutoFish()
    autoFishEnabled = not autoFishEnabled
    if autoFishEnabled then
        Rayfield:Notify({
            Title = "🎣 Auto Fishing",
            Content = "Auto Fishing Enabled!",
            Duration = 2,
            Image = 7072717775
        })
        if statusLabel then
            statusLabel:Set("Status: 🟢 Enabled")
        end

        -- Jalankan fungsi auto fish
        task.spawn(function()
            while autoFishEnabled do
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Replion = require(ReplicatedStorage.Packages.Replion)
                    local Data = Replion.Client:WaitReplion("Data")
                    local Net = require(ReplicatedStorage.Packages.Net)
                    local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                    updateFishing:InvokeServer(true)
                end)
                task.wait(5)
            end
        end)
    else
        Rayfield:Notify({
            Title = "🎣 Auto Fishing",
            Content = "Auto Fishing Disabled!",
            Duration = 2,
            Image = 7072717775
        })
        if statusLabel then
            statusLabel:Set("Status: 🔴 Disabled")
        end

        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Replion = require(ReplicatedStorage.Packages.Replion)
            local Data = Replion.Client:WaitReplion("Data")
            local Net = require(ReplicatedStorage.Packages.Net)
            local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
            updateFishing:InvokeServer(false)
        end)
    end
end

------------------------------------------------------------
-- 📍 KOORDINAT
------------------------------------------------------------
local function createCoordinateDisplay()
    if coordinateDisplay then coordinateDisplay:Destroy() end
    local CoordGui = Instance.new("ScreenGui")
    local CoordFrame = Instance.new("Frame")
    local CoordLabel = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
    CoordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    CoordFrame.Parent = CoordGui
    CoordFrame.Size = UDim2.new(0, 150, 0, 40)
    CoordFrame.Position = UDim2.new(0.5, -75, 0, 5)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    CoordFrame.BackgroundTransparency = 0.1
    CoordFrame.BorderSizePixel = 0
    
    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0.2, 0)
    
    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(147, 112, 219)
    UIStroke.Thickness = 1.5
    
    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 11
    CoordLabel.Font = Enum.Font.GothamMedium
    
    coordinateDisplay = CoordGui

    spawn(function()
        while CoordGui and CoordGui.Parent do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                CoordLabel.Text = string.format("X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
            end
            wait(0.1)
        end
    end)
end

------------------------------------------------------------
-- 💜 MAIN UI RAYFIELD
------------------------------------------------------------
local function createMainUI()
    if uiInitialized then return end
    uiInitialized = true

    Window = Rayfield:CreateWindow({
        Name = "🎣 Anggazyy Hub - Fish It",
        LoadingTitle = "Memuat Anggazyy Hub...",
        LoadingSubtitle = "by Anggazyy",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "AnggazyyHub",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "noinvitelink",
            RememberJoins = true
        },
        KeySystem = false,
    })

    -- TAB UTAMA & PENJELASAN
    local MainTab = Window:CreateTab("📋 Info & Guide", 7072717775)

    local MainSection = MainTab:CreateSection("🎯 Tentang Script Ini")

    local InfoParagraph = MainTab:CreateParagraph({
        Title = "🌟 FITUR UTAMA",
        Content = "Script ini dibuat khusus untuk game Fish It! dengan fitur:\n\n" ..
                "🎣 Auto Fishing - Sistem memancing otomatis\n" ..
                "📍 Coordinate Display - Menampilkan koordinat karakter\n" ..
                "🚀 Player Boosts - Meningkatkan WalkSpeed & JumpPower\n" ..
                "⚡ Quick Teleport - Teleport ke lokasi penting"
    })

    local UsageParagraph = MainTab:CreateParagraph({
        Title = "📝 CARA PENGGUNAAN",
        Content = "1. Auto Fishing: Pergi ke tab '🎣 Auto Fish' dan klik toggle\n" ..
                "2. Koordinat: Aktifkan di tab '📍 Teleport' untuk melihat posisi\n" ..
                "3. Player Boost: Atur WalkSpeed/JumpPower di tab '👤 Player'\n" ..
                "4. Teleport: Pilih lokasi di tab '📍 Teleport'"
    })

    local WarningParagraph = MainTab:CreateParagraph({
        Title = "⚠️ PERINGATAN",
        Content = "• Gunakan dengan bijak\n" ..
                "• Risiko ditanggung pengguna\n" ..
                "• Disarankan untuk tidak abuse fitur"
    })

    -- TAB AUTO FISH
    local AutoTab = Window:CreateTab("🎣 Auto Fish", 7072717775)

    local AutoSection = AutoTab:CreateSection("Auto Fishing Control")

    local AutoInfo = AutoTab:CreateParagraph({
        Title = "ℹ️ FITUR AUTO FISH",
        Content = "Fitur ini akan secara otomatis melakukan:\n" ..
                "• Casting fishing rod\n" ..
                "• Menunggu ikan menyambar\n" ..
                "• Reeling ikan secara otomatis\n" ..
                "• Mengulangi proses terus menerus"
    })

    local ToggleButton = AutoTab:CreateButton({
        Name = "🎣 Toggle Auto Fishing",
        Callback = function()
            toggleAutoFish()
        end,
    })

    statusLabel = AutoTab:CreateLabel("Status: 🔴 Disabled")

    -- TAB TELEPORT
    local TeleportTab = Window:CreateTab("📍 Teleport", 7072717775)

    local TeleportSection = TeleportTab:CreateSection("📍 Teleport Locations")

    local teleportLocations = {
        "🏠 Spawn Point",
        "⛰️ Mountain Top", 
        "🏖️ Beach Side",
        "🏙️ City Center"
    }

    local locationVectors = {
        ["🏠 Spawn Point"] = Vector3.new(0, 10, 0),
        ["⛰️ Mountain Top"] = Vector3.new(200, 150, 200),
        ["🏖️ Beach Side"] = Vector3.new(300, 15, -200),
        ["🏙️ City Center"] = Vector3.new(100, 30, 100)
    }

    local TeleportDropdown = TeleportTab:CreateDropdown({
        Name = "📍 Pilih Lokasi Teleport",
        Options = teleportLocations,
        CurrentOption = "🏠 Spawn Point",
        Flag = "TeleportDropdown",
        Callback = function(Option)
            local location = locationVectors[Option]
            if location then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(location)
                    Rayfield:Notify({
                        Title = "✨ Teleported!",
                        Content = "Teleported to " .. Option,
                        Duration = 3,
                        Image = 7072717775
                    })
                end
            end
        end,
    })

    local UtilitySection = TeleportTab:CreateSection("⚙️ Utility")

    local CoordToggle = TeleportTab:CreateToggle({
        Name = "📍 Tampilkan Koordinat",
        CurrentValue = false,
        Flag = "ShowCoordinates",
        Callback = function(Value)
            if Value then
                createCoordinateDisplay()
                Rayfield:Notify({
                    Title = "📍 Coordinates",
                    Content = "Coordinate display enabled!",
                    Duration = 2,
                    Image = 7072717775
                })
            else
                if coordinateDisplay then 
                    coordinateDisplay:Destroy() 
                    Rayfield:Notify({
                        Title = "📍 Coordinates",
                        Content = "Coordinate display disabled!",
                        Duration = 2,
                        Image = 7072717775
                    })
                end
            end
        end,
    })

    -- TAB PLAYER
    local PlayerTab = Window:CreateTab("👤 Player", 7072717775)

    local PlayerSection = PlayerTab:CreateSection("Player Settings")

    local WalkSpeedSlider = PlayerTab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 100},
        Increment = 1,
        Suffix = "speed",
        CurrentValue = 16,
        Flag = "WalkSpeed",
        Callback = function(Value)
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end,
    })

    local JumpPowerSlider = PlayerTab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 200},
        Increment = 1,
        Suffix = "power",
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(Value)
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = Value
            end
        end,
    })

    PlayerTab:CreateButton({
        Name = "🔄 Reset Player Stats",
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                WalkSpeedSlider:Set(16)
                JumpPowerSlider:Set(50)
                Rayfield:Notify({
                    Title = "🔄 Reset Complete",
                    Content = "Player stats reset to default!",
                    Duration = 2,
                    Image = 7072717775
                })
            end
        end,
    })

    -- Hide Rayfield watermark and show Anggazyy Hub
    local CoreGui = game:GetService("CoreGui")
    local RayfieldWatermark = CoreGui:FindFirstChild("Rayfield_Watermark")
    if RayfieldWatermark then
        RayfieldWatermark:Destroy()
    end

    -- Create custom Anggazyy Hub watermark
    local AnggazyyWatermark = Instance.new("ScreenGui")
    AnggazyyWatermark.Name = "AnggazyyHub_Watermark"
    AnggazyyWatermark.Parent = CoreGui
    AnggazyyWatermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Size = UDim2.new(0, 200, 0, 30)
    WatermarkFrame.Position = UDim2.new(1, -210, 0, 10)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    WatermarkFrame.BackgroundTransparency = 0.1
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = AnggazyyWatermark

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = WatermarkFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(147, 112, 219)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = WatermarkFrame

    local WatermarkLabel = Instance.new("TextLabel")
    WatermarkLabel.Size = UDim2.new(1, 0, 1, 0)
    WatermarkLabel.BackgroundTransparency = 1
    WatermarkLabel.Text = "🎣 Anggazyy Hub v1.0"
    WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WatermarkLabel.TextSize = 12
    WatermarkLabel.Font = Enum.Font.GothamMedium
    WatermarkLabel.Parent = WatermarkFrame

    -- Function to toggle UI
    local function toggleUI()
        Rayfield:Destroy()
        AnggazyyWatermark.Enabled = false
        
        task.wait(1)
        
        -- Recreate the UI when needed
        AnggazyyWatermark.Enabled = true
        createMainUI()
    end

    -- Bind key to toggle UI (optional)
    local InputService = game:GetService("UserInputService")
    InputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)
end

------------------------------------------------------------
-- CUSTOM LOADING SCREEN
------------------------------------------------------------
local function showCustomLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "AnggazyyHub_Loading"
    LoadingGui.Parent = game.CoreGui
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
    Background.Parent = LoadingGui

    local MainLabel = Instance.new("TextLabel")
    MainLabel.Text = "🎣 ANGGAZYY HUB"
    MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainLabel.Font = Enum.Font.GothamBold
    MainLabel.TextSize = 28
    MainLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    MainLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
    MainLabel.BackgroundTransparency = 1
    MainLabel.Size = UDim2.new(0, 300, 0, 50)
    MainLabel.Parent = Background

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Text = "Fish It! Automation Suite"
    SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 16
    SubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    SubLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Size = UDim2.new(0, 250, 0, 30)
    SubLabel.Parent = Background

    local LoadingBar = Instance.new("Frame")
    LoadingBar.Size = UDim2.new(0, 300, 0, 4)
    LoadingBar.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingBar.Position = UDim2.new(0.5, 0, 0.6, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
    LoadingBar.BorderSizePixel = 0
    LoadingBar.Parent = Background

    local LoadingProgress = Instance.new("Frame")
    LoadingProgress.Size = UDim2.new(0, 0, 1, 0)
    LoadingProgress.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    LoadingProgress.BorderSizePixel = 0
    LoadingProgress.Parent = LoadingBar

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 2)
    UICorner.Parent = LoadingBar

    -- Animate loading bar
    spawn(function()
        for i = 1, 100 do
            LoadingProgress.Size = UDim2.new(0, (i / 100) * 300, 1, 0)
            task.wait(0.02)
        end
    end)

    task.wait(2)
    LoadingGui:Destroy()
    createMainUI()
end

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------
showCustomLoadingScreen()
