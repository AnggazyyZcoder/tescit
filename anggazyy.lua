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
        LoadingTitle = "Loading Anggazyy Hub...",
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
        KeySettings = {
            Title = "Anggazyy Hub",
            Subtitle = "Key System",
            Note = "No key required",
            FileName = "Key",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = {"Hello"}
        }
    })

    -- TAB UTAMA & PENJELASAN
    local MainTab = Window:CreateTab("📋 Info & Guide", 7072717775)

    local MainSection = MainTab:CreateSection("🎯 Tentang Script Ini")

    local InfoParagraph = MainTab:CreateParagraph({
        Title = "🌟 FITUR UTAMA",
        Content = "Script ini dibuat khusus untuk game **Fish It!** dengan fitur:\n\n" ..
                "🎣 **Auto Fishing** - Sistem memancing otomatis\n" ..
                "📍 **Coordinate Display** - Menampilkan koordinat karakter\n" ..
                "🚀 **Player Boosts** - Meningkatkan WalkSpeed & JumpPower\n" ..
                "⚡ **Quick Teleport** - Teleport ke lokasi penting"
    })

    local UsageParagraph = MainTab:CreateParagraph({
        Title = "📝 CARA PENGGUNAAN",
        Content = "1. **Auto Fishing**: Pergi ke tab '🎣 Auto Fish' dan klik toggle\n" ..
                "2. **Koordinat**: Aktifkan di tab '📍 Teleport' untuk melihat posisi\n" ..
                "3. **Player Boost**: Atur WalkSpeed/JumpPower di tab '👤 Player'\n" ..
                "4. **Teleport**: Pilih lokasi di tab '📍 Teleport'"
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

    local TeleportInfo = TeleportTab:CreateParagraph({
        Title = "🗺️ LOKASI TELEPORT",
        Content = "Teleport ke berbagai lokasi strategis:\n" ..
                "• Spawn Point - Kembali ke spawn awal\n" ..
                "• Mountain Top - Puncak gunung\n" ..
                "• Beach Side - Area pantai\n" ..
                "• City Center - Pusat kota"
    })

    local teleportLocations = {
        {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
        {"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
        {"🏖️ Beach Side", Vector3.new(300, 15, -200)},
        {"🏙️ City Center", Vector3.new(100, 30, 100)},
    }

    for _, location in ipairs(teleportLocations) do
        TeleportTab:CreateButton({
            Name = location[1],
            Callback = function()
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                    Rayfield:Notify({
                        Title = "✨ Teleported!",
                        Content = "Teleported to " .. location[1],
                        Duration = 3,
                        Image = 7072717775
                    })
                end
            end,
        })
    end

    local UtilitySection = TeleportTab:CreateSection("⚙️ Utility")

    local CoordInfo = TeleportTab:CreateParagraph({
        Title = "📍 COORDINATE DISPLAY",
        Content = "Fitur untuk menampilkan koordinat real-time:\n" ..
                "• X, Y, Z position\n" ..
                "• Update setiap 0.1 detik\n" ..
                "• Posisi di tengah atas layar"
    })

    local CoordToggle = TeleportTab:CreateToggle({
        Name = "📍 Show Coordinates",
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

    local PlayerInfo = PlayerTab:CreateParagraph({
        Title = "⚡ PLAYER BOOST",
        Content = "Tingkatkan kemampuan karakter:\n" ..
                "• WalkSpeed - Kecepatan berjalan\n" ..
                "• JumpPower - Kekuatan lompat\n" ..
                "• Nilai default: WalkSpeed=16, JumpPower=50"
    })

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

    -- Tambahkan button untuk reset player stats
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
end

------------------------------------------------------------
-- LOADING SCREEN
------------------------------------------------------------
local function showLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.Parent = game.CoreGui
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
    Background.Parent = LoadingGui

    local Label = Instance.new("TextLabel")
    Label.Text = "ANGGAZYY HUB - FISH IT"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 24
    Label.AnchorPoint = Vector2.new(0.5, 0.5)
    Label.Position = UDim2.new(0.5, 0, 0.5, 0)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0, 300, 0, 50)
    Label.Parent = Background

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Text = "Loading Rayfield UI..."
    SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 14
    SubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    SubLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Size = UDim2.new(0, 200, 0, 30)
    SubLabel.Parent = Background

    task.wait(2)
    LoadingGui:Destroy()
    createMainUI()
end

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------
showLoadingScreen()
