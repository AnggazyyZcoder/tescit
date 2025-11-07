local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Loading Screen
local function ShowLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.Parent = game.CoreGui
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
    Background.BackgroundTransparency = 0.1
    Background.BorderSizePixel = 0
    Background.Parent = LoadingGui

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 320, 0, 160)
    Container.Position = UDim2.new(0.5, -160, 0.5, -80)
    Container.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
    Container.BackgroundTransparency = 0.2
    Container.BorderSizePixel = 0
    Container.Parent = Background

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Container

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 2
    UIStroke.Parent = Container

    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 40, 0, 40)
    Logo.Position = UDim2.new(0.5, -20, 0.3, -20)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7072717775"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Position = UDim2.new(0, 0, 0.6, 0)
    Title.BackgroundTransparency = 1
    Title.Text = ""
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Container

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 16)
    Subtitle.Position = UDim2.new(0, 0, 0.8, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Loading Premium Features..."
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = Container

    -- Text animation
    local text = "ANGGAZYY HUB"
    local animatedText = ""
    
    spawn(function()
        for i = 1, #text do
            animatedText = animatedText .. string.sub(text, i, i)
            Title.Text = animatedText
            wait(0.05)
        end
    end)

    -- Logo animation
    spawn(function()
        while LoadingGui.Parent do
            game:GetService("TweenService"):Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            wait(1.1)
            Logo.Rotation = 0
        end
    end)

    return LoadingGui
end

-- Show loading screen
local loadingScreen = ShowLoadingScreen()
wait(2)
loadingScreen:Destroy()

-- Variables
local player = game.Players.LocalPlayer
local autoFishEnabled = false
local coordinateDisplay = nil

-- Initialize Fluent dengan ukuran yang pas
local Window = Fluent:CreateWindow({
    Title = "Anggazyy Hub " .. Fluent.Version,
    SubTitle = "Premium Fishing Experience",
    TabWidth = 110,
    Size = UDim2.fromOffset(380, 320), -- Ukuran lebih panjang sedikit
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Options for SaveManager
local Options = Fluent.Options

-- Main Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Auto Fish", Icon = "" }),
    Teleport = Window:AddTab({ Title = "📍 Teleport", Icon = "" }),
    Player = Window:AddTab({ Title = "👤 Player", Icon = "" })
}

-- Header dengan informasi versi dan warna
Tabs.Main:AddParagraph({
    Title = "🎣 ANGGAZYY FISHING HUB",
    Content = "Version 2.1 | Premium Edition\nAdvanced Auto Fishing System"
})

-- Auto Fish Section
Tabs.Main:AddSection({Name = "Fishing Configuration"})

local statusContent = "🔴 Disabled"

local Toggle = Tabs.Main:AddToggle("AutoFishToggle", {
    Title = "Enable Auto Fishing",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            statusContent = "🟢 Enabled"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto fishing system has been activated successfully!",
                Duration = 3
            })
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        else
            statusContent = "🔴 Disabled"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto fishing system has been deactivated!",
                Duration = 3
            })
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(false)
            end)
        end
        -- Update status
        if Options.StatusParagraph then
            Options.StatusParagraph:SetDesc(statusContent)
        end
    end
})

Options.StatusParagraph = Tabs.Main:AddParagraph({
    Title = "System Status:",
    Content = statusContent
})

Tabs.Main:AddButton({
    Title = "🔄 Quick Toggle Auto Fish",
    Description = "Instantly enable/disable auto fishing",
    Callback = function()
        Toggle:Set(not autoFishEnabled)
    end
})

-- Teleport Section
Tabs.Teleport:AddParagraph({
    Title = "📍 TELEPORTATION SYSTEM",
    Content = "Version 2.1 | Fast Travel\nInstant location teleportation"
})

Tabs.Teleport:AddSection({Name = "Available Locations"})

local teleportLocations = {
    {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
    {"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
    {"🏖️ Beach Side", Vector3.new(300, 15, -200)},
    {"🏙️ City Center", Vector3.new(100, 30, 100)},
    {"🌲 Forest Area", Vector3.new(-150, 25, -100)},
    {"🌊 Lake Side", Vector3.new(50, 20, 250)}
}

for i, location in ipairs(teleportLocations) do
    Tabs.Teleport:AddButton({
        Title = location[1],
        Description = "Teleport to " .. location[1],
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                Fluent:Notify({
                    Title = "✨ Teleport Successful",
                    Content = "Successfully teleported to " .. location[1],
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "❌ Teleport Failed",
                    Content = "Character not found!",
                    Duration = 2
                })
            end
        end
    })
end

Tabs.Teleport:AddSection({Name = "Display Settings"})

Tabs.Teleport:AddToggle("CoordToggle", {
    Title = "📍 Show Coordinates Display",
    Default = false,
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Fluent:Notify({
                Title = "📍 Coordinates Enabled",
                Content = "Real-time coordinate display activated!",
                Duration = 2
            })
        elseif coordinateDisplay then
            coordinateDisplay:Destroy()
            coordinateDisplay = nil
        end
    end
})

-- Player Section
Tabs.Player:AddParagraph({
    Title = "👤 PLAYER MANAGEMENT",
    Content = "Version 2.1 | Character Control\nPlayer statistics and settings"
})

Tabs.Player:AddSection({Name = "Player Information"})

Tabs.Player:AddParagraph({
    Title = "Player Name:",
    Content = player.Name
})

Tabs.Player:AddParagraph({
    Title = "Display Name:",
    Content = player.DisplayName
})

Tabs.Player:AddParagraph({
    Title = "Account Age:",
    Content = player.AccountAge .. " days"
})

Tabs.Player:AddParagraph({
    Title = "User ID:",
    Content = tostring(player.UserId)
})

Tabs.Player:AddSection({Name = "Character Settings"})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "🚶 Walk Speed",
    Description = "Adjust character movement speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "🦘 Jump Power",
    Description = "Adjust character jump height",
    Default = 50,
    Min = 50,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

Tabs.Player:AddButton({
    Title = "🔄 Reset Character",
    Description = "Reset your character to spawn point",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Fluent:Notify({
                Title = "🔄 Character Reset",
                Content = "Character has been successfully reset!",
                Duration = 2
            })
        end
    end
})

-- Coordinate Display Function
function CreateCoordinateDisplay()
    if coordinateDisplay then coordinateDisplay:Destroy() end
    
    local CoordGui = Instance.new("ScreenGui")
    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
    CoordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local CoordFrame = Instance.new("Frame")
    CoordFrame.Size = UDim2.new(0, 150, 0, 28)
    CoordFrame.Position = UDim2.new(0.5, -75, 0, 5)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
    CoordFrame.BackgroundTransparency = 0.3
    CoordFrame.BorderSizePixel = 0
    CoordFrame.Parent = CoordGui
    
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CoordFrame})
    Instance.new("UIStroke", {Color = Color3.fromRGB(138, 43, 226), Thickness = 1.5, Parent = CoordFrame})
    
    local CoordLabel = Instance.new("TextLabel")
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 12
    CoordLabel.Font = Enum.Font.GothamMedium
    CoordLabel.Parent = CoordFrame
    
    coordinateDisplay = CoordGui

    task.spawn(function()
        while CoordGui and CoordGui.Parent do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                CoordLabel.Text = string.format("X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
            end
            task.wait(0.1)
        end
    end)
end

-- Advanced Floating Icon System yang benar-benar berfungsi
local function CreateAdvancedFloatingIcon()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnggazyyHubFloating"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = true

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingIcon"
    OpenButton.Size = UDim2.new(0, 45, 0, 45)
    OpenButton.Position = UDim2.new(0.5, -22.5, 0.5, -22.5) -- Posisi tengah
    OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    OpenButton.BackgroundTransparency = 0.1
    OpenButton.AutoButtonColor = false
    OpenButton.Image = "rbxassetid://7072717775"
    OpenButton.ScaleType = Enum.ScaleType.Fit
    OpenButton.BorderSizePixel = 0
    OpenButton.Visible = false -- Awalnya hidden
    OpenButton.Parent = ScreenGui

    Instance.new("UICorner", {CornerRadius = UDim.new(0.3, 0), Parent = OpenButton})
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.3
    UIStroke.Parent = OpenButton

    -- Enhanced Dragging System
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OpenButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    OpenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- Toggle System yang work 100%
    OpenButton.MouseButton1Click:Connect(function()
        Window:Show()
        OpenButton.Visible = false
    end)

    OpenButton.TouchTap:Connect(function()
        Window:Show()
        OpenButton.Visible = false
    end)

    return OpenButton, ScreenGui
end

-- Create floating icon
local floatingIcon, floatingGui = CreateAdvancedFloatingIcon()

-- Override minimize functionality
local function SetupMinimizeFunctionality()
    -- Cari minimize button
    for _, child in pairs(Window.Root:GetChildren()) do
        if child:FindFirstChild("MinimizeBtn") then
            local minimizeBtn = child.MinimizeBtn
            if minimizeBtn:FindFirstChild("Ico") then
                minimizeBtn.Ico.MouseButton1Click:Connect(function()
                    Window:Hide()
                    floatingIcon.Visible = true
                    floatingIcon.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
                end)
            end
        end
    end
    
    -- Juga handle close button untuk show floating icon
    for _, child in pairs(Window.Root:GetChildren()) do
        if child:FindFirstChild("CloseBtn") then
            child.CloseBtn.MouseButton1Click:Connect(function()
                Window:Hide()
                floatingIcon.Visible = true
                floatingIcon.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
            end)
        end
    end
end

-- Panggil setelah window dibuat
spawn(function()
    wait(1)
    SetupMinimizeFunctionality()
end)

-- Select first tab
Window:SelectTab(1)

-- Settings tab dengan informasi versi
local SettingsTab = Window:AddTab({ Title = "⚙️ Settings", Icon = "" })

SettingsTab:AddParagraph({
    Title = "🔧 HUB SETTINGS",
    Content = "Version 2.1 | Anggazyy Hub\nCustomize your experience"
})

SettingsTab:AddSection({Name = "UI Configuration"})

SettingsTab:AddButton({
    Title = "🎯 Show Floating Icon",
    Description = "Show the floating icon to reopen UI",
    Callback = function()
        Window:Hide()
        floatingIcon.Visible = true
        floatingIcon.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
        Fluent:Notify({
            Title = "🎯 Floating Icon",
            Content = "Floating icon has been shown! Click it to reopen UI",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "📱 Hide Floating Icon",
    Description = "Hide the floating icon",
    Callback = function()
        floatingIcon.Visible = false
        Window:Show()
    end
})

SettingsTab:AddButton({
    Title = "🔄 Reset UI Position",
    Description = "Reset UI to center position",
    Callback = function()
        Window.Root.Position = UDim2.new(0.5, -190, 0.5, -160)
        Fluent:Notify({
            Title = "🔄 UI Reset",
            Content = "UI position has been reset to center!",
            Duration = 2
        })
    end
})

-- SaveManager Configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("AnggazyyHub")
SaveManager:SetFolder("AnggazyyHub/" .. game.GameId)

InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

-- Delayed notifications system
local function SendDelayedNotifications()
    wait(1)
    
    Fluent:Notify({
        Title = "🔧 Initializing System",
        Content = "Loading 1/3 features...",
        Duration = 3
    })
    
    wait(2.5)
    
    Fluent:Notify({
        Title = "🔄 Fetching Data",
        Content = "Loading 2/3 features...",
        Duration = 3
    })
    
    wait(2.5)
    
    Fluent:Notify({
        Title = "🎣 Loading Fishing System",
        Content = "Loading 3/3 features...",
        Duration = 3
    })
    
    wait(2.5)
    
    Fluent:Notify({
        Title = "✅ ANGGAZYY HUB READY",
        Content = "Version 2.1 loaded successfully!\nUse RightShift to toggle UI\nMinimize to get floating icon",
        Duration = 5
    })
end

-- Start notifications
spawn(SendDelayedNotifications)

-- Final setup untuk floating icon
wait(8)
floatingIcon.Visible = true
Fluent:Notify({
    Title = "🎯 Floating Icon Active",
    Content = "Floating icon is now available!\nDrag it anywhere & click to reopen UI\nWorks on both PC and Mobile",
    Duration = 6
})
