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

-- Initialize Fluent dengan ukuran sangat compact
local Window = Fluent:CreateWindow({
    Title = "Anggazyy Hub " .. Fluent.Version,
    SubTitle = "by Anggazyy",
    TabWidth = 100, -- Lebih kecil
    Size = UDim2.fromOffset(340, 260), -- Sangat compact
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Options for SaveManager
local Options = Fluent.Options

-- Main Tabs dengan ukuran compact
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Fish", Icon = "" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "" })
}

-- Auto Fish Section
Tabs.Main:AddParagraph({
    Title = "Fishing System",
    Content = "Auto fishing features"
})

local statusContent = "Disabled ❌"

local Toggle = Tabs.Main:AddToggle("AutoFishToggle", {
    Title = "Auto Fishing",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            statusContent = "Enabled ✅"
            Fluent:Notify({
                Title = "Auto Fishing",
                Content = "Enabled successfully!",
                Duration = 2
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
                Title = "Auto Fishing",
                Content = "Disabled!",
                Duration = 2
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
    Title = "Status:",
    Content = statusContent
})

Tabs.Main:AddButton({
    Title = "Quick Toggle",
    Callback = function()
        Toggle:Set(not autoFishEnabled)
    end
})

-- Teleport Section
Tabs.Teleport:AddParagraph({
    Title = "Locations",
    Content = "Quick teleport spots"
})

local teleportLocations = {
    {"Spawn", Vector3.new(0, 10, 0)},
    {"Mountain", Vector3.new(200, 150, 200)},
    {"Beach", Vector3.new(300, 15, -200)},
    {"City", Vector3.new(100, 30, 100)}
}

for i, location in ipairs(teleportLocations) do
    Tabs.Teleport:AddButton({
        Title = location[1],
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                Fluent:Notify({
                    Title = "Teleported",
                    Content = "To " .. location[1],
                    Duration = 1.5
                })
            end
        end
    })
end

Tabs.Teleport:AddToggle("CoordToggle", {
    Title = "Coordinates",
    Default = false,
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Fluent:Notify({
                Title = "Coordinates",
                Content = "Display enabled!",
                Duration = 1.5
            })
        elseif coordinateDisplay then
            coordinateDisplay:Destroy()
            coordinateDisplay = nil
        end
    end
})

-- Player Section
Tabs.Player:AddParagraph({
    Title = "Player Info",
    Content = player.DisplayName
})

Tabs.Player:AddParagraph({
    Title = "User ID:",
    Content = tostring(player.UserId)
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
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Fluent:Notify({
                Title = "Reset",
                Content = "Character reset!",
                Duration = 1.5
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

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingIcon"
    OpenButton.Size = UDim2.new(0, 35, 0, 35)
    OpenButton.Position = UDim2.new(0.5, -17.5, 0.5, -17.5) -- Posisi tengah
    OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    OpenButton.BackgroundTransparency = 0.1
    OpenButton.AutoButtonColor = false
    OpenButton.Image = "rbxassetid://7072717775"
    OpenButton.ScaleType = Enum.ScaleType.Fit
    OpenButton.BorderSizePixel = 0
    OpenButton.Visible = false -- Awalnya hidden, muncul saat minimize
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

    -- Toggle System yang work 100%
    OpenButton.MouseButton1Click:Connect(function()
        -- Show window dan hide floating icon
        Window.Root.Visible = true
        OpenButton.Visible = false
    end)

    return OpenButton, ScreenGui
end

-- Create floating icon
local floatingIcon, floatingGui = CreateAdvancedFloatingIcon()

-- Override minimize button untuk show floating icon
local originalMinimize
for _, child in pairs(Window.Root:GetChildren()) do
    if child:FindFirstChild("MinimizeBtn") then
        originalMinimize = child.MinimizeBtn
        break
    end
end

if originalMinimize then
    originalMinimize.MouseButton1Click:Connect(function()
        -- Hide window dan show floating icon di tengah
        Window.Root.Visible = false
        floatingIcon.Visible = true
        floatingIcon.Position = UDim2.new(0.5, -17.5, 0.5, -17.5) -- Reset ke tengah
    end)
end

-- Select first tab
Window:SelectTab(1)

-- Settings tab
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "" })

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
    local notifications = {
        {title = "🔧 Loading", content = "Loading 1/3 features...", delay = 1},
        {title = "🔄 Fetching", content = "Fetching Anggazyy Hub...", delay = 2},
        {title = "✅ Ready", content = "Hub loaded! Use RightShift", delay = 1}
    }
    
    for i, notif in ipairs(notifications) do
        wait(notif.delay)
        Fluent:Notify({
            Title = notif.title,
            Content = notif.content,
            Duration = 2
        })
    end
end

-- Start notifications
spawn(SendDelayedNotifications)

-- Window control functions
SettingsTab:AddButton({
    Title = "Hide UI",
    Callback = function()
        Window.Root.Visible = false
        floatingIcon.Visible = true
    end
})

SettingsTab:AddButton({
    Title = "Show UI",
    Callback = function()
        Window.Root.Visible = true
        floatingIcon.Visible = false
    end
})

-- Final notification
wait(6)
Fluent:Notify({
    Title = "🎣 Anggazyy Hub",
    Content = "Minimize → Floating Icon\nClick icon to reopen UI",
    Duration = 5
})
