local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Floating Icon
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AnggazyyHubUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 50, 0, 50) -- Lebih kecil
OpenButton.Position = UDim2.new(0, 15, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
OpenButton.BackgroundTransparency = 0.1
OpenButton.AutoButtonColor = false
OpenButton.Image = "rbxassetid://7072717775"
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.BorderSizePixel = 0
OpenButton.Visible = false

-- Corner radius
UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.3, 0)

-- Border effect
UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(138, 43, 226) -- Ungu
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3

-- Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local Window = nil
local uiInitialized = false

-- Auto Fishing Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextNotificationController_upvr = require(ReplicatedStorage.Controllers.TextNotificationController)
local LocalPlayer_upvr = game:GetService("Players").LocalPlayer
local AutoFishingEnabled = false
local AutoFishingLoop = nil

-- Function untuk mendapatkan Auto Button
local function getAutoButton()
    local success, result = pcall(function()
        return LocalPlayer_upvr.PlayerGui:WaitForChild("HUD"):WaitForChild("Frame"):WaitForChild("Small Buttons"):WaitForChild("Auto")
    end)
    return success and result or nil
end

-- Function untuk toggle Auto Fishing
local function toggleAutoFishing()
    local AutoButton = getAutoButton()
    if AutoButton then
        -- Simulate button click
        local clickDetector = AutoButton:FindFirstChildWhichIsA("ClickDetector") or AutoButton:FindFirstChild("ClickDetector")
        if clickDetector then
            clickDetector:Click()
        else
            -- Alternative method: fire the click event directly
            local bindableEvent = AutoButton:FindFirstChildWhichIsA("BindableEvent")
            if bindableEvent then
                bindableEvent:Fire()
            else
                -- Last resort: use remote function
                local any_RemoteFunction_result1_upvr = require(ReplicatedStorage.Packages.Net):RemoteFunction("UpdateAutoFishingState")
                local Replion_upvr = require(ReplicatedStorage.Packages.Replion)
                local var11_upvw = Replion_upvr.Client:WaitReplion("Data")
                
                local currentState = var11_upvw:GetExpect("AutoFishing")
                any_RemoteFunction_result1_upvr:InvokeServer(not currentState)
            end
        end
        return true
    end
    return false
end

-- Function untuk check Auto Fishing status
local function getAutoFishingStatus()
    local Replion_upvr = require(ReplicatedStorage.Packages.Replion)
    local var11_upvw = Replion_upvr.Client:WaitReplion("Data")
    return var11_upvw:GetExpect("AutoFishing")
end

-- Function untuk start Auto Fishing loop
local function startAutoFishingLoop()
    if AutoFishingLoop then
        AutoFishingLoop:Disconnect()
        AutoFishingLoop = nil
    end
    
    AutoFishingLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if AutoFishingEnabled then
            -- Check if player has fishing rod equipped
            local Replion_upvr = require(ReplicatedStorage.Packages.Replion)
            local var11_upvw = Replion_upvr.Client:WaitReplion("Data")
            local equippedType = var11_upvw:GetExpect("EquippedType")
            
            if equippedType == "Fishing Rods" then
                local autoFishingState = getAutoFishingStatus()
                if not autoFishingState then
                    toggleAutoFishing()
                end
            else
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Please equip a fishing rod first!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
                AutoFishingEnabled = false
            end
        end
    end)
end

-- Function to create coordinate display
local function createCoordinateDisplay()
    if coordinateDisplay then
        coordinateDisplay:Destroy()
    end

    local CoordGui = Instance.new("ScreenGui")
    local CoordFrame = Instance.new("Frame")
    local CoordLabel = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
    CoordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    CoordFrame.Parent = CoordGui
    CoordFrame.Size = UDim2.new(0, 150, 0, 40) -- Lebih kecil
    CoordFrame.Position = UDim2.new(0.5, -75, 0, 5)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
    CoordFrame.BackgroundTransparency = 0.1
    CoordFrame.BorderSizePixel = 0

    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0.2, 0)

    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(147, 112, 219) -- Ungu medium
    UIStroke.Thickness = 1.5

    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 11 -- Lebih kecil
    CoordLabel.Font = Enum.Font.GothamMedium
    CoordLabel.TextStrokeTransparency = 0.8

    coordinateDisplay = CoordGui

    -- Update coordinates
    spawn(function()
        while CoordGui and CoordGui.Parent do
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local pos = character.HumanoidRootPart.Position
                CoordLabel.Text = string.format("X: %d | Y: %d | Z: %d", 
                    math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
            end
            wait(0.1)
        end
    end)

    return CoordGui
end

-- Main UI Creation
local function createMainUI()
    -- Cek jika UI sudah dibuat, jangan buat duplikat
    if uiInitialized then
        return
    end
    
    uiInitialized = true

    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false,
        -- Ukuran window lebih kecil dan responsive
        Center = true
    })

    -- =============================================
    -- TAB 1: TELEPORT TAB
    -- =============================================
    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    -- Section untuk Teleport Lokasi
    TeleportTab:AddSection({
        Name = "📍 Teleport Locations"
    })

    -- Contoh teleport points dengan warna ungu
    local teleportLocations = {
        {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
        {"🚀 High Platform", Vector3.new(50, 100, 50)},
        {"🔒 Secret Area", Vector3.new(-100, 25, -100)},
        {"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
        {"🕳️ Underground", Vector3.new(0, -50, 0)},
        {"🌲 Forest Area", Vector3.new(-150, 20, 150)},
        {"🏖️ Beach Side", Vector3.new(300, 15, -200)},
        {"🏙️ City Center", Vector3.new(100, 30, 100)},
        {"☁️ Sky Island", Vector3.new(0, 500, 0)},
        {"🕸️ Cave Entrance", Vector3.new(-200, 10, -50)},
        {"🌟 Crystal Cave", Vector3.new(-300, -20, 100)},
        {"🌋 Volcano", Vector3.new(400, 80, -300)}
    }

    -- Loop untuk membuat button teleport dengan warna ungu
    for i, location in ipairs(teleportLocations) do
        TeleportTab:AddButton({
            Name = location[1],
            Callback = function()
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(location[2])
                    OrionLib:MakeNotification({
                        Name = "✨ Teleported!",
                        Content = "Teleported to " .. location[1],
                        Image = "rbxassetid://7072717775",
                        Time = 3
                    })
                end
            end
        })
    end

    -- Section untuk Custom Teleport
    TeleportTab:AddSection({
        Name = "🎯 Custom Teleport"
    })

    -- Input untuk custom coordinates
    local xInput = TeleportTab:AddTextbox({
        Name = "X Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    local yInput = TeleportTab:AddTextbox({
        Name = "Y Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    local zInput = TeleportTab:AddTextbox({
        Name = "Z Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    -- Button untuk execute custom teleport
    TeleportTab:AddButton({
        Name = "🚀 Teleport to Coordinates",
        Callback = function()
            local x = tonumber(xInput.Value) or 0
            local y = tonumber(yInput.Value) or 0
            local z = tonumber(zInput.Value) or 0
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
                OrionLib:MakeNotification({
                    Name = "🎯 Custom Teleport",
                    Content = string.format("Teleported to X: %d, Y: %d, Z: %d", x, y, z),
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Player Utilities Section
    TeleportTab:AddSection({
        Name = "⚡ Player Utilities"
    })

    TeleportTab:AddSlider({
        Name = "🎯 WalkSpeed",
        Min = 16,
        Max = 150, -- Max lebih rendah untuk balance
        Default = 16,
        Color = Color3.fromRGB(147, 112, 219), -- Ungu
        Increment = 1,
        ValueName = "speed",
        Callback = function(Value)
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = Value
                end
            end
        end
    })

    TeleportTab:AddSlider({
        Name = "🦘 JumpPower",
        Min = 50,
        Max = 150, -- Max lebih rendah untuk balance
        Default = 50,
        Color = Color3.fromRGB(186, 85, 211), -- Ungu muda
        Increment = 1,
        ValueName = "power",
        Callback = function(Value)
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = Value
                end
            end
        end
    })

    -- Visual Features
    TeleportTab:AddSection({
        Name = "👁️ Visual Features"
    })

    local noclipToggle = TeleportTab:AddToggle({
        Name = "🚶 Noclip",
        Default = false,
        Callback = function(Value)
            getgenv().Noclip = Value
            OrionLib:MakeNotification({
                Name = Value and "🚶 Noclip Enabled" or "🚶 Noclip Disabled",
                Content = "Noclip feature " .. (Value and "activated" or "deactivated"),
                Image = "rbxassetid://7072717775",
                Time = 2
            })
        end
    })

    local coordinateToggle = TeleportTab:AddToggle({
        Name = "📍 Show Coordinates",
        Default = false,
        Callback = function(Value)
            if Value then
                createCoordinateDisplay()
                OrionLib:MakeNotification({
                    Name = "📍 Coordinates Enabled",
                    Content = "Player coordinates display activated",
                    Image = "rbxassetid://7072717775",
                    Time = 2
                })
            else
                if coordinateDisplay then
                    coordinateDisplay:Destroy()
                    coordinateDisplay = nil
                end
            end
        end
    })

    -- =============================================
    -- TAB 2: AUTO FISHING TAB
    -- =============================================
    local AutoFishingTab = Window:MakeTab({
        Name = "🎣 Auto Fishing",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    AutoFishingTab:AddSection({
        Name = "🤖 Auto Fishing Features"
    })

    -- Toggle untuk Auto Fishing
    local autoFishToggle = AutoFishingTab:AddToggle({
        Name = "🎣 Enable Auto Fishing",
        Default = false,
        Callback = function(Value)
            AutoFishingEnabled = Value
            if Value then
                -- Check if fishing rod is equipped
                local Replion_upvr = require(ReplicatedStorage.Packages.Replion)
                local var11_upvw = Replion_upvr.Client:WaitReplion("Data")
                local equippedType = var11_upvw:GetExpect("EquippedType")
                
                if equippedType ~= "Fishing Rods" then
                    OrionLib:MakeNotification({
                        Name = "🎣 Auto Fishing",
                        Content = "Please equip a fishing rod first!",
                        Image = "rbxassetid://7072717775",
                        Time = 3
                    })
                    AutoFishingEnabled = false
                    autoFishToggle:Set(false)
                    return
                end
                
                -- Start auto fishing loop
                startAutoFishingLoop()
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Auto Fishing activated!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            else
                if AutoFishingLoop then
                    AutoFishingLoop:Disconnect()
                    AutoFishingLoop = nil
                end
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Auto Fishing deactivated!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Manual toggle button
    AutoFishingTab:AddButton({
        Name = "🔄 Toggle Auto Fishing Button",
        Callback = function()
            local success = toggleAutoFishing()
            if success then
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Toggled Auto Fishing button!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Failed to find Auto Fishing button!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Check Auto Fishing Status
    AutoFishingTab:AddButton({
        Name = "📊 Check Auto Fishing Status",
        Callback = function()
            local status = getAutoFishingStatus()
            OrionLib:MakeNotification({
                Name = "🎣 Auto Fishing Status",
                Content = "Auto Fishing is: " .. (status and "ENABLED" or "DISABLED"),
                Image = "rbxassetid://7072717775",
                Time = 4
            })
        end
    })

    AutoFishingTab:AddSection({
        Name = "ℹ️ Auto Fishing Info"
    })

    AutoFishingTab:AddParagraph("🎣 Auto Fishing Guide", 
        "1. Equip a fishing rod first\n" ..
        "2. Enable Auto Fishing toggle\n" ..
        "3. Make sure you're near water\n" ..
        "4. System will automatically fish for you!")

    -- =============================================
    -- TAB 3: SETTINGS TAB
    -- =============================================
    local SettingsTab = Window:MakeTab({
        Name = "Settings",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    SettingsTab:AddSection({
        Name = "🔧 UI Settings"
    })

    SettingsTab:AddButton({
        Name = "🗑️ Destroy UI",
        Callback = function()
            OrionLib:Destroy()
            ScreenGui:Destroy()
            if coordinateDisplay then
                coordinateDisplay:Destroy()
            end
            if AutoFishingLoop then
                AutoFishingLoop:Disconnect()
            end
            uiInitialized = false
        end
    })

    SettingsTab:AddBind({
        Name = "🎮 Toggle UI Keybind",
        Default = Enum.KeyCode.RightShift,
        Hold = false,
        Callback = function()
            if Window then
                Window:Toggle()
            end
        end
    })

    SettingsTab:AddSection({
        Name = "📝 Information"
    })

    SettingsTab:AddParagraph("🎉 Anggazyy Hub", "✨ Version 2.0\n💜 Premium Teleport Hub\n🎣 Auto Fishing Feature\n🎯 Created by Anggazyy")

    -- Initialize Orion dengan theme ungu
    OrionLib:Init()

    -- Apply purple theme to existing elements
    for _, tab in next, OrionLib:GetWindow().Tabs do
        for _, section in next, tab.Sections do
            section.Color = Color3.fromRGB(147, 112, 219)
        end
    end

    -- Hide window initially
    if Window then
        Window:Toggle()
    end

    -- Button click event dengan animasi sederhana
    OpenButton.MouseButton1Click:Connect(function()
        if Window then
            Window:Toggle()
            
            -- Simple scale animation
            spawn(function()
                OpenButton.Size = UDim2.new(0, 45, 0, 45)
                wait(0.1)
                OpenButton.Size = UDim2.new(0, 50, 0, 50)
            end)
        end
    end)

    -- Make floating icon visible
    OpenButton.Visible = true
end

-- Loading Screen Function yang lebih kecil
local function showLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    local Background = Instance.new("Frame")
    local LoadingFrame = Instance.new("Frame")
    local LoadingLabel = Instance.new("TextLabel")
    local LoadingBar = Instance.new("Frame")
    local LoadingBarFill = Instance.new("Frame")
    local UICorner1 = Instance.new("UICorner")
    local UICorner2 = Instance.new("UICorner")
    local UICorner3 = Instance.new("UICorner")

    LoadingGui.Name = "LoadingGui"
    LoadingGui.Parent = game.CoreGui
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Background.Name = "Background"
    Background.Parent = LoadingGui
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30) -- Background ungu gelap
    Background.BackgroundTransparency = 0
    Background.ZIndex = 10

    -- Ukuran lebih kecil untuk mobile
    LoadingFrame.Parent = Background
    LoadingFrame.Size = UDim2.new(0, 280, 0, 100) -- Lebih kecil
    LoadingFrame.Position = UDim2.new(0.5, -140, 0.5, -50)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 11

    UICorner1.Parent = LoadingFrame
    UICorner1.CornerRadius = UDim.new(0.15, 0)

    LoadingLabel.Parent = LoadingFrame
    LoadingLabel.Size = UDim2.new(1, 0, 0.6, 0)
    LoadingLabel.Position = UDim2.new(0, 0, 0.1, 0)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = ""
    LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingLabel.TextSize = 16  -- Ukuran lebih kecil
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.ZIndex = 12

    LoadingBar.Parent = LoadingFrame
    LoadingBar.Size = UDim2.new(0.8, 0, 0.15, 0) -- Lebih tipis
    LoadingBar.Position = UDim2.new(0.1, 0, 0.75, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(60, 35, 85) -- Ungu medium gelap
    LoadingBar.BorderSizePixel = 0
    LoadingBar.ZIndex = 12

    UICorner2.Parent = LoadingBar
    UICorner2.CornerRadius = UDim.new(0.5, 0)

    LoadingBarFill.Parent = LoadingBar
    LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingBarFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219) -- Ungu terang
    LoadingBarFill.BorderSizePixel = 0
    LoadingBarFill.ZIndex = 13

    UICorner3.Parent = LoadingBarFill
    UICorner3.CornerRadius = UDim.new(0.5, 0)

    -- Animated text function
    local function animateText(speed)
        local fullText = "ANGGAZYY HUB"
        local currentText = ""
        
        for i = 1, #fullText do
            currentText = string.sub(fullText, 1, i)
            LoadingLabel.Text = currentText
            -- Update loading bar
            LoadingBarFill.Size = UDim2.new((i / #fullText), 0, 1, 0)
            wait(speed)
        end
    end

    -- Show loading animation
    spawn(function()
        animateText(0.1)
        wait(0.3)
        
        -- Fade out animation
        for i = 0, 1, 0.08 do
            Background.BackgroundTransparency = i
            LoadingFrame.BackgroundTransparency = i
            LoadingLabel.TextTransparency = i
            LoadingBar.BackgroundTransparency = i
            LoadingBarFill.BackgroundTransparency = i
            wait(0.02)
        end
        
        LoadingGui:Destroy()
        
        -- Show notification dulu sebelum buka UI
        OrionLib:MakeNotification({
            Name = "💜 Anggazyy Hub Ready!",
            Content = "Click the purple icon to open menu!\n🎣 Auto Fishing feature included!",
            Image = "rbxassetid://7072717775",
            Time = 4
        })
        
        -- Tunggu sebentar lalu buat UI
        wait(1.5)
        createMainUI()
    end)
end

-- Noclip loop
spawn(function()
    while wait(0.1) do
        if getgenv().Noclip then
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- Start loading screen when script executes
showLoadingScreen()
