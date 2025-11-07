-- Compkiller UI Implementation for Anggazyy Hub
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()

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
    Container.Size = UDim2.new(0, 280, 0, 140)
    Container.Position = UDim2.new(0.5, -140, 0.5, -70)
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
    Logo.Size = UDim2.new(0, 35, 0, 35)
    Logo.Position = UDim2.new(0.5, -17.5, 0.3, -17.5)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7072717775"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.Position = UDim2.new(0, 0, 0.6, 0)
    Title.BackgroundTransparency = 1
    Title.Text = ""
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Container

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 14)
    Subtitle.Position = UDim2.new(0, 0, 0.8, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Loading..."
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 10
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
wait(1.8)
loadingScreen:Destroy()

-- Variables
local player = game.Players.LocalPlayer
local autoFishEnabled = false
local coordinateDisplay = nil

-- Create Notifier
local Notifier = Compkiller.newNotify()

-- Loading UI dengan durasi lebih singkat
Compkiller:Loader("rbxassetid://7072717775", 1).yield()

-- Create Window dengan ukuran sangat compact
local Window = Compkiller.new({
    Name = "ANGGAZYY HUB",
    Keybind = "RightShift",
    Logo = "rbxassetid://7072717775",
    Scale = Compkiller.Scale.Window,
    TextSize = 11, -- Text size lebih kecil
})

-- Set custom size untuk window yang lebih kecil
Window.Root.Size = UDim2.new(0, 350, 0, 280)

-- Watermark dengan info player
local Watermark = Window:Watermark()

Watermark:AddText({
    Icon = "user",
    Text = player.DisplayName,
})

Watermark:AddText({
    Icon = "id-card",
    Text = "ID: " .. player.UserId,
})

local Time = Watermark:AddText({
    Icon = "clock",
    Text = Compkiller:GetTimeNow(),
})

-- Update time
task.spawn(function()
    while true do 
        task.wait(1)
        Time:SetText(Compkiller:GetTimeNow())
    end
end)

-- Create Tabs dengan ukuran compact
Window:DrawCategory({
    Name = "Main"
})

-- Auto Fish Tab
local AutoFishTab = Window:DrawTab({
    Name = "Fishing",
    Icon = "fish",
    EnableScrolling = true
})

local FishingSection = AutoFishTab:DrawSection({
    Name = "Auto Fish",
    Position = 'left'
})

local StatusLabel = FishingSection:AddParagraph({
    Title = "Status",
    Content = "Disabled ❌"
})

local AutoFishToggle = FishingSection:AddToggle({
    Name = "Enable Auto Fish",
    Flag = "AutoFish_Enabled",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            StatusLabel:Set({
                Title = "Status", 
                Content = "Enabled ✅"
            })
            Notifier.new({
                Title = "Auto Fishing",
                Content = "Enabled successfully!",
                Duration = 2,
                Icon = "rbxassetid://7072717775"
            })
            
            -- Enable auto fishing
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        else
            StatusLabel:Set({
                Title = "Status",
                Content = "Disabled ❌"
            })
            Notifier.new({
                Title = "Auto Fishing",
                Content = "Disabled!",
                Duration = 2,
                Icon = "rbxassetid://7072717775"
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

FishingSection:AddButton({
    Name = "Quick Toggle",
    Callback = function()
        AutoFishToggle:Set(not autoFishEnabled)
    end
})

-- Teleport Tab
local TeleportTab = Window:DrawTab({
    Name = "Teleport",
    Icon = "map-pin",
    EnableScrolling = true
})

local LocationsSection = TeleportTab:DrawSection({
    Name = "Locations",
    Position = 'left'
})

local teleportLocations = {
    {"Spawn", Vector3.new(0, 10, 0)},
    {"Mountain", Vector3.new(200, 150, 200)},
    {"Beach", Vector3.new(300, 15, -200)},
    {"City", Vector3.new(100, 30, 100)}
}

for i, location in ipairs(teleportLocations) do
    LocationsSection:AddButton({
        Name = location[1],
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                Notifier.new({
                    Title = "Teleported",
                    Content = "To " .. location[1],
                    Duration = 1.5,
                    Icon = "rbxassetid://7072717775"
                })
            end
        end
    })
end

local DisplaySection = TeleportTab:DrawSection({
    Name = "Display",
    Position = 'right'
})

DisplaySection:AddToggle({
    Name = "Coordinates",
    Flag = "Show_Coordinates",
    Default = false,
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Notifier.new({
                Title = "Coordinates",
                Content = "Display enabled!",
                Duration = 1.5,
                Icon = "rbxassetid://7072717775"
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
local PlayerTab = Window:DrawTab({
    Name = "Player",
    Icon = "user",
    EnableScrolling = true
})

local InfoSection = PlayerTab:DrawSection({
    Name = "Info",
    Position = 'left'
})

InfoSection:AddParagraph({
    Title = "Name",
    Content = player.Name
})

InfoSection:AddParagraph({
    Title = "Display", 
    Content = player.DisplayName
})

local SettingsSection = PlayerTab:DrawSection({
    Name = "Settings",
    Position = 'right'
})

SettingsSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Round = 0,
    Flag = "WalkSpeed_Value",
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

SettingsSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 100,
    Default = 50,
    Round = 0,
    Flag = "JumpPower_Value",
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

SettingsSection:AddButton({
    Name = "Reset Char",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Notifier.new({
                Title = "Reset",
                Content = "Character reset!",
                Duration = 1.5,
                Icon = "rbxassetid://7072717775"
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

-- Advanced Floating Icon System dengan fix toggle
local function CreateAdvancedFloatingIcon()
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

    -- Enhanced Dragging System
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

    -- FIXED Toggle System - Pastikan Window tersedia
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

    -- Right click untuk options tambahan
    OpenButton.MouseButton2Click:Connect(function()
        Window:Dialog({
            Title = "Anggazyy Hub",
            Content = "Options:",
            Buttons = {
                {
                    Title = "Show/Hide",
                    Callback = function()
                        if uiVisible then
                            Window:Hide()
                            uiVisible = false
                        else
                            Window:Show()
                            uiVisible = true
                        end
                    end
                },
                {
                    Title = "Close UI",
                    Callback = function()
                        ScreenGui:Destroy()
                        Window:Hide()
                    end
                }
            }
        })
    end)

    return OpenButton
end

-- Create floating icon
CreateAdvancedFloatingIcon()

-- Delayed notifications dengan interval yang tepat
task.spawn(function()
    wait(0.5)
    
    Notifier.new({
        Title = "Loading",
        Content = "Loading 1/3 features...",
        Duration = 2,
        Icon = "rbxassetid://7072717775"
    })
    
    wait(2.2)
    
    Notifier.new({
        Title = "Fetching",
        Content = "Fetching Anggazyy Hub...",
        Duration = 2,
        Icon = "rbxassetid://7072717775"
    })
    
    wait(2.2)
    
    Notifier.new({
        Title = "Ready",
        Content = "Hub loaded! Use RightShift",
        Duration = 3,
        Icon = "rbxassetid://7072717775"
    })
end)

-- Final notification setelah semua load
wait(6)
Notifier.new({
    Title = "Anggazyy Hub",
    Content = "Floating icon: Drag & Click",
    Duration = 4,
    Icon = "rbxassetid://7072717775"
})
