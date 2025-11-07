local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Loading Screen Function
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
    Container.Size = UDim2.new(0, 400, 0, 200)
    Container.Position = UDim2.new(0.5, -200, 0.5, -100)
    Container.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
    Container.BackgroundTransparency = 0.2
    Container.BorderSizePixel = 0
    Container.Parent = Background

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Container

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 3
    UIStroke.Parent = Container

    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 60, 0, 60)
    Logo.Position = UDim2.new(0.5, -30, 0.3, -30)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7072717775"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0.6, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ANGGAZYY HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBlack
    Title.TextStrokeTransparency = 0.8
    Title.Parent = Container

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0.8, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Loading Premium Features..."
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = Container

    -- Animate text
    local text = "ANGGAZYY HUB"
    local animatedText = ""
    Title.Text = ""
    
    spawn(function()
        for i = 1, #text do
            animatedText = animatedText .. string.sub(text, i, i)
            Title.Text = animatedText
            wait(0.1)
        end
        
        -- Rotate logo
        while LoadingGui.Parent do
            game:GetService("TweenService"):Create(Logo, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            wait(2.1)
            Logo.Rotation = 0
        end
    end)

    return LoadingGui
end

-- Show loading screen first
local loadingScreen = ShowLoadingScreen()

-- Wait for loading screen
wait(3)

-- Remove loading screen
loadingScreen:Destroy()

-- Initialize Fluent setelah loading screen
local Window = Fluent:CreateWindow({
    Title = "Anggazyy Hub " .. Fluent.Version,
    SubTitle = "by Anggazyy",
    TabWidth = 130,
    Size = UDim2.fromOffset(450, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Variables
local player = game.Players.LocalPlayer
local autoFishEnabled = false
local coordinateDisplay = nil

-- Options for SaveManager
local Options = Fluent.Options

-- Main Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Auto Fish", Icon = "" }),
    Teleport = Window:AddTab({ Title = "📍 Teleport", Icon = "" }),
    Player = Window:AddTab({ Title = "👤 Player", Icon = "" })
}

-- Auto Fish Section
Tabs.Main:AddParagraph({
    Title = "Auto Fishing System",
    Content = "Automatically fish for you."
})

-- Status variable untuk menghindari error SetText
local statusContent = "Disabled ❌"

local Toggle = Tabs.Main:AddToggle("AutoFishToggle", {
    Title = "Enable Auto Fishing",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            statusContent = "Enabled ✅"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto Fishing enabled!",
                Duration = 3
            })
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        else
            statusContent = "Disabled ❌"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto Fishing disabled!",
                Duration = 3
            })
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(false)
            end)
        end
        -- Update status dengan cara yang aman
        if Options.StatusParagraph then
            Options.StatusParagraph:SetDesc(statusContent)
        end
    end
})

-- Fix untuk paragraph yang bisa di-update
Options.StatusParagraph = Tabs.Main:AddParagraph({
    Title = "Status:",
    Content = statusContent
})

Tabs.Main:AddButton({
    Title = "Toggle Auto Fishing",
    Description = "Quick toggle",
    Callback = function()
        Toggle:Set(not autoFishEnabled)
    end
})

-- Teleport Section
Tabs.Teleport:AddParagraph({
    Title = "Teleport Locations",
    Content = "Teleport to various locations."
})

local teleportLocations = {
    {"Spawn Point", Vector3.new(0, 10, 0)},
    {"Mountain Top", Vector3.new(200, 150, 200)},
    {"Beach Side", Vector3.new(300, 15, -200)},
    {"City Center", Vector3.new(100, 30, 100)}
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
                    Title = "✨ Teleported!",
                    Content = "To " .. location[1],
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "❌ Error",
                    Content = "Character not found!",
                    Duration = 2
                })
            end
        end
    })
end

-- Coordinate Display Toggle
Tabs.Teleport:AddToggle("CoordToggle", {
    Title = "Show Coordinates",
    Default = false,
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Fluent:Notify({
                Title = "📍 Coordinates",
                Content = "Coordinate display enabled!",
                Duration = 2
            })
        else
            if coordinateDisplay then
                coordinateDisplay:Destroy()
                coordinateDisplay = nil
            end
            Fluent:Notify({
                Title = "📍 Coordinates",
                Content = "Coordinate display disabled!",
                Duration = 2
            })
        end
    end
})

-- Player Section dengan Info Player
Tabs.Player:AddParagraph({
    Title = "Player Info",
    Content = player.Name
})

-- Avatar display
local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"

Tabs.Player:AddParagraph({
    Title = "Avatar:",
    Content = "Display Name: " .. player.DisplayName
})

Tabs.Player:AddParagraph({
    Title = "Account Age:",
    Content = player.AccountAge .. " days"
})

Tabs.Player:AddParagraph({
    Title = "Player Settings",
    Content = "Modify player properties."
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
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
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 150,
    Rounding = 1,
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

Tabs.Player:AddButton({
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Fluent:Notify({
                Title = "🔄 Character Reset",
                Content = "Character has been reset!",
                Duration = 2
            })
        end
    end
})

-- Coordinate Display Function
function CreateCoordinateDisplay()
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
    CoordFrame.Size = UDim2.new(0, 150, 0, 35)
    CoordFrame.Position = UDim2.new(0.5, -75, 0, 10)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    CoordFrame.BackgroundTransparency = 0.3
    CoordFrame.BorderSizePixel = 0
    
    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0, 8)
    
    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(100, 100, 200)
    UIStroke.Thickness = 1.5
    
    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 12
    CoordLabel.Font = Enum.Font.GothamMedium
    CoordLabel.TextStrokeTransparency = 0.8
    
    coordinateDisplay = CoordGui

    -- Update coordinates
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

-- Improved Floating Icon dengan drag functionality
local function CreateFloatingIcon()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnggazyyHubFloating"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingIcon"
    OpenButton.Size = UDim2.new(0, 45, 0, 45)
    OpenButton.Position = UDim2.new(0, 20, 0.5, -22)
    OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    OpenButton.BackgroundTransparency = 0.1
    OpenButton.AutoButtonColor = false
    OpenButton.Image = "rbxassetid://7072717775"
    OpenButton.ScaleType = Enum.ScaleType.Fit
    OpenButton.BorderSizePixel = 0
    OpenButton.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.3, 0)
    UICorner.Parent = OpenButton
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.3
    UIStroke.Parent = OpenButton

    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle UI functionality
    local uiVisible = false

    OpenButton.MouseButton1Click:Connect(function()
        if not uiVisible then
            Window:Show()
            uiVisible = true
        else
            Window:Hide()
            uiVisible = false
        end
    end)

    return OpenButton
end

-- Create floating icon
CreateFloatingIcon()

-- Select first tab
Window:SelectTab(1)

-- Add settings tab
local SettingsTab = Window:AddTab({ Title = "⚙️ Settings", Icon = "" })

-- SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentAnggazyy")
SaveManager:SetFolder("FluentAnggazyy/specific-game")

InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

SaveManager:LoadAutoloadConfig()

-- Delayed notifications setelah loading screen
local notificationDelay = 1 -- delay antara notifikasi

task.spawn(function()
    wait(0.5) -- Tunggu sebentar setelah loading screen
    
    local totalFeatures = 3 -- Auto Fish, Teleport, Player
    
    for i = 1, totalFeatures do
        Fluent:Notify({
            Title = "🔧 Loading Features",
            Content = "Loading " .. i .. "/" .. totalFeatures .. " features...",
            Duration = 2
        })
        wait(notificationDelay + 1) -- Delay antara notifikasi
    end
    
    wait(1)
    
    Fluent:Notify({
        Title = "🔄 Fetching Version",
        Content = "Fetching new version Anggazyy Hub...",
        Duration = 2
    })
    
    wait(notificationDelay + 1)
    
    Fluent:Notify({
        Title = "✅ Ready",
        Content = "Anggazyy Hub v1.0 loaded successfully!\nUse RightShift to toggle UI",
        Duration = 4
    })
end)

-- Window resize functionality
Window:AddButton({
    Title = "Toggle Size",
    Callback = function()
        local currentSize = Window.Root.Size
        if currentSize == UDim2.fromOffset(450, 350) then
            Window:SetSize(UDim2.fromOffset(550, 400))
        else
            Window:SetSize(UDim2.fromOffset(450, 350))
        end
    end
})
