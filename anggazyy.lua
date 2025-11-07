-- Wind UI Implementation for Anggazyy Hub
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
    Container.Size = UDim2.new(0, 250, 0, 120)
    Container.Position = UDim2.new(0.5, -125, 0.5, -60)
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
    Logo.Size = UDim2.new(0, 30, 0, 30)
    Logo.Position = UDim2.new(0.5, -15, 0.3, -15)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7072717775"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.Position = UDim2.new(0, 0, 0.6, 0)
    Title.BackgroundTransparency = 1
    Title.Text = ""
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Container

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 12)
    Subtitle.Position = UDim2.new(0, 0, 0.8, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Loading..."
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 9
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = Container

    -- Text animation
    local text = "ANGGAZYY HUB"
    local animatedText = ""
    
    spawn(function()
        for i = 1, #text do
            animatedText = animatedText .. string.sub(text, i, i)
            Title.Text = animatedText
            wait(0.04)
        end
    end)

    -- Logo animation
    spawn(function()
        while LoadingGui.Parent do
            game:GetService("TweenService"):Create(Logo, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            wait(0.9)
            Logo.Rotation = 0
        end
    end)

    return LoadingGui
end

-- Show loading screen
local loadingScreen = ShowLoadingScreen()
wait(1.5)
loadingScreen:Destroy()

-- Variables
local player = game.Players.LocalPlayer
local autoFishEnabled = false
local coordinateDisplay = nil

-- Create Wind UI Window dengan ukuran compact
local Window = WindUI:CreateWindow({
    Title = "Anggazyy Hub",
    Center = true,
    Size = UDim2.new(0, 360, 0, 300), -- Ukuran compact
    Theme = "Purple"
})

-- Auto Fish Tab
local AutoFishTab = Window:Tab({
    Title = "🎣 Auto Fish"
})

AutoFishTab:Section({
    Title = "Fishing System"
})

local StatusLabel = AutoFishTab:Label({
    Title = "Status",
    Content = "Disabled ❌"
})

local AutoFishToggle = AutoFishTab:Toggle({
    Title = "Enable Auto Fishing",
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            StatusLabel:Update({
                Title = "Status",
                Content = "Enabled ✅"
            })
            Window:Notification({
                Title = "🎣 Auto Fishing",
                Content = "Auto fishing has been enabled!",
                Duration = 3
            })
            
            -- Enable auto fishing
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        else
            StatusLabel:Update({
                Title = "Status",
                Content = "Disabled ❌"
            })
            Window:Notification({
                Title = "🎣 Auto Fishing",
                Content = "Auto fishing has been disabled!",
                Duration = 3
            })
            
            -- Disable auto fishing
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(false)
            end)
        end
    end
})

AutoFishTab:Button({
    Title = "Quick Toggle",
    Callback = function()
        AutoFishToggle:Set(not autoFishEnabled)
    end
})

-- Teleport Tab
local TeleportTab = Window:Tab({
    Title = "📍 Teleport"
})

TeleportTab:Section({
    Title = "Locations"
})

local teleportLocations = {
    {"Spawn", Vector3.new(0, 10, 0)},
    {"Mountain", Vector3.new(200, 150, 200)},
    {"Beach", Vector3.new(300, 15, -200)},
    {"City", Vector3.new(100, 30, 100)}
}

for i, location in ipairs(teleportLocations) do
    TeleportTab:Button({
        Title = location[1],
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                Window:Notification({
                    Title = "✨ Teleported",
                    Content = "To " .. location[1],
                    Duration = 2
                })
            end
        end
    })
end

TeleportTab:Section({
    Title = "Display"
})

TeleportTab:Toggle({
    Title = "Show Coordinates",
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Window:Notification({
                Title = "📍 Coordinates",
                Content = "Display enabled!",
                Duration = 2
            })
        else
            if coordinateDisplay then
                coordinateDisplay:Destroy()
                coordinateDisplay = nil
            end
        end
    end
})

-- Player Tab
local PlayerTab = Window:Tab({
    Title = "👤 Player"
})

PlayerTab:Section({
    Title = "Player Info"
})

PlayerTab:Label({
    Title = "Name",
    Content = player.Name
})

PlayerTab:Label({
    Title = "Display",
    Content = player.DisplayName
})

PlayerTab:Label({
    Title = "User ID", 
    Content = tostring(player.UserId)
})

PlayerTab:Section({
    Title = "Settings"
})

PlayerTab:Slider({
    Title = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:Slider({
    Title = "Jump Power",
    Min = 50,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:Button({
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Window:Notification({
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
    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
    CoordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local CoordFrame = Instance.new("Frame")
    CoordFrame.Size = UDim2.new(0, 120, 0, 22)
    CoordFrame.Position = UDim2.new(0.5, -60, 0, 3)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    CoordFrame.BackgroundTransparency = 0.3
    CoordFrame.BorderSizePixel = 0
    CoordFrame.Parent = CoordGui
    
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 5), Parent = CoordFrame})
    Instance.new("UIStroke", {Color = Color3.fromRGB(100, 100, 200), Thickness = 1, Parent = CoordFrame})
    
    local CoordLabel = Instance.new("TextLabel")
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 10
    CoordLabel.Font = Enum.Font.GothamMedium
    CoordLabel.Parent = CoordFrame
    
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

-- Floating Icon System
local function CreateFloatingIcon()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnggazyyHubFloating"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingIcon"
    OpenButton.Size = UDim2.new(0, 32, 0, 32)
    OpenButton.Position = UDim2.new(0, 8, 0.2, 0)
    OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    OpenButton.BackgroundTransparency = 0.1
    OpenButton.AutoButtonColor = false
    OpenButton.Image = "rbxassetid://7072717775"
    OpenButton.ScaleType = Enum.ScaleType.Fit
    OpenButton.BorderSizePixel = 0
    OpenButton.Parent = ScreenGui

    Instance.new("UICorner", {CornerRadius = UDim.new(0.3, 0), Parent = OpenButton})
    Instance.new("UIStroke", {Color = Color3.fromRGB(138, 43, 226), Thickness = 1.5, Transparency = 0.3, Parent = OpenButton})

    -- Dragging System
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

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

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- Toggle UI
    local uiVisible = false

    OpenButton.MouseButton1Click:Connect(function()
        if uiVisible then
            Window:Hide()
            uiVisible = false
        else
            Window:Show()
            uiVisible = true
        end
    end)

    return OpenButton
end

-- Create floating icon
CreateFloatingIcon()

-- Delayed notifications
task.spawn(function()
    wait(0.5)
    
    Window:Notification({
        Title = "🔧 Loading",
        Content = "Loading 1/3 features...",
        Duration = 2
    })
    
    wait(2.2)
    
    Window:Notification({
        Title = "🔄 Fetching",
        Content = "Fetching Anggazyy Hub...",
        Duration = 2
    })
    
    wait(2.2)
    
    Window:Notification({
        Title = "✅ Ready",
        Content = "Hub loaded successfully!",
        Duration = 3
    })
end)

-- Final notification
wait(6)
Window:Notification({
    Title = "🎣 Anggazyy Hub",
    Content = "Floating icon: Drag & Click to toggle UI",
    Duration = 4
})

-- Initialize Window
Window:Init()
