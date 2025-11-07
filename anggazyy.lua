-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local autoFishEnabled = false
local statusLabel = nil
local coordinateDisplay = nil
local mainUI = nil
local uiVisible = false

-- Colors
local Theme = {
    Primary = Color3.fromRGB(106, 43, 186),
    Secondary = Color3.fromRGB(75, 25, 130),
    Accent = Color3.fromRGB(147, 112, 219),
    Background = Color3.fromRGB(30, 20, 45),
    Text = Color3.fromRGB(255, 255, 255),
    DarkText = Color3.fromRGB(180, 180, 180)
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Tween(Object, Properties, Duration, Style)
    local tweenInfo = TweenInfo.new(Duration or 0.3, Style or Enum.EasingStyle.Quint)
    local tween = TweenService:Create(Object, tweenInfo, Properties)
    tween:Play()
    return tween
end

-- Floating Icon
local function CreateFloatingIcon()
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "AnggazyyHubUI",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local OpenButton = CreateInstance("ImageButton", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 15, 0.5, -25),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.1,
        AutoButtonColor = false,
        Image = "rbxassetid://7072717775",
        ScaleType = Enum.ScaleType.Fit,
        BorderSizePixel = 0,
        Visible = false
    })

    CreateInstance("UICorner", {
        Parent = OpenButton,
        CornerRadius = UDim.new(0.3, 0)
    })

    CreateInstance("UIStroke", {
        Parent = OpenButton,
        Color = Theme.Accent,
        Thickness = 2,
        Transparency = 0.3
    })

    return OpenButton
end

-- Notification System
local function ShowNotification(title, message, duration)
    duration = duration or 3
    
    local NotificationGui = CreateInstance("ScreenGui", {
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local NotificationFrame = CreateInstance("Frame", {
        Parent = NotificationGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 320, 1, -100),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = NotificationFrame,
        CornerRadius = UDim.new(0, 8)
    })

    CreateInstance("UIStroke", {
        Parent = NotificationFrame,
        Color = Theme.Primary,
        Thickness = 2,
        Transparency = 0.3
    })

    local TitleLabel = CreateInstance("TextLabel", {
        Parent = NotificationFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local MessageLabel = CreateInstance("TextLabel", {
        Parent = NotificationFrame,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.DarkText,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    -- Animate in
    Tween(NotificationFrame, {Position = UDim2.new(1, -20, 1, -100)}, 0.5)

    -- Animate out and destroy
    delay(duration, function()
        Tween(NotificationFrame, {Position = UDim2.new(1, 320, 1, -100)}, 0.5)
        wait(0.5)
        NotificationGui:Destroy()
    end)
end

-- Loading Screen
local function ShowLoadingScreen()
    local LoadingGui = CreateInstance("ScreenGui", {
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Name = "LoadingScreen"
    })

    local Background = CreateInstance("Frame", {
        Parent = LoadingGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 5, 20),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    })

    local Container = CreateInstance("Frame", {
        Parent = Background,
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = Container,
        CornerRadius = UDim.new(0, 12)
    })

    CreateInstance("UIStroke", {
        Parent = Container,
        Color = Theme.Primary,
        Thickness = 3
    })

    local Logo = CreateInstance("ImageLabel", {
        Parent = Container,
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, -40, 0.3, -40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072717775",
        ScaleType = Enum.ScaleType.Fit
    })

    local Title = CreateInstance("TextLabel", {
        Parent = Container,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0.6, 0),
        BackgroundTransparency = 1,
        Text = "ANGGAZYY HUB",
        TextColor3 = Theme.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBlack,
        TextStrokeTransparency = 0.8
    })

    local Subtitle = CreateInstance("TextLabel", {
        Parent = Container,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.8, 0),
        BackgroundTransparency = 1,
        Text = "Loading Premium Features...",
        TextColor3 = Theme.DarkText,
        TextSize = 14,
        Font = Enum.Font.Gotham
    })

    -- Animate logo
    spawn(function()
        while LoadingGui.Parent do
            Tween(Logo, {Rotation = 360}, 2)
            wait(2.1)
            Logo.Rotation = 0
        end
    end)

    return LoadingGui
end

-- Coordinate Display
local function CreateCoordinateDisplay()
    if coordinateDisplay then coordinateDisplay:Destroy() end
    
    local CoordGui = CreateInstance("ScreenGui", {
        Parent = game.CoreGui,
        Name = "CoordinateDisplay",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local CoordFrame = CreateInstance("Frame", {
        Parent = CoordGui,
        Size = UDim2.new(0, 150, 0, 40),
        Position = UDim2.new(0.5, -75, 0, 5),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = CoordFrame,
        CornerRadius = UDim.new(0, 8)
    })

    CreateInstance("UIStroke", {
        Parent = CoordFrame,
        Color = Theme.Accent,
        Thickness = 1.5
    })

    local CoordLabel = CreateInstance("TextLabel", {
        Parent = CoordFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "X: 0 | Y: 0 | Z: 0",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium
    })

    coordinateDisplay = CoordGui

    -- Update coordinates
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

-- Auto Fish System
local function ToggleAutoFish()
    autoFishEnabled = not autoFishEnabled
    
    if autoFishEnabled then
        ShowNotification("🎣 Auto Fishing", "Auto Fishing Enabled!")
        if statusLabel then
            statusLabel.Text = "Status: Enabled ✅"
        end

        spawn(function()
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        end)
    else
        ShowNotification("🎣 Auto Fishing", "Auto Fishing Disabled!")
        if statusLabel then
            statusLabel.Text = "Status: Disabled ❌"
        end
        
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Net = require(ReplicatedStorage.Packages.Net)
            local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
            updateFishing:InvokeServer(false)
        end)
    end
end

-- Main UI
local function CreateMainUI()
    if mainUI then mainUI:Destroy() end

    local MainGui = CreateInstance("ScreenGui", {
        Parent = game.CoreGui,
        Name = "AnggazyyHubMain",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Main Window
    local MainWindow = CreateInstance("Frame", {
        Parent = MainGui,
        Size = UDim2.new(0, 450, 0, 350),
        Position = UDim2.new(0.5, -225, 0.5, -175),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Visible = false
    })

    CreateInstance("UICorner", {
        Parent = MainWindow,
        CornerRadius = UDim.new(0, 12)
    })

    CreateInstance("UIStroke", {
        Parent = MainWindow,
        Color = Theme.Primary,
        Thickness = 2
    })

    -- Top Bar
    local TopBar = CreateInstance("Frame", {
        Parent = MainWindow,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 12, 0, 0)
    })

    local Title = CreateInstance("TextLabel", {
        Parent = TopBar,
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "ANGGAZYY HUB",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Version = CreateInstance("TextLabel", {
        Parent = TopBar,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "version 1.0-beta",
        TextColor3 = Theme.DarkText,
        TextSize = 12,
        Font = Enum.Font.Gotham
    })

    -- Close Button
    local CloseButton = CreateInstance("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(255, 60, 60),
        Text = "X",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = CloseButton,
        CornerRadius = UDim.new(0, 6)
    })

    -- Minimize Button
    local MinimizeButton = CreateInstance("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(255, 180, 60),
        Text = "_",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = MinimizeButton,
        CornerRadius = UDim.new(0, 6)
    })

    -- Tab Container
    local TabContainer = CreateInstance("Frame", {
        Parent = MainWindow,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    -- Tab Buttons
    local TabButtons = CreateInstance("Frame", {
        Parent = TabContainer,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    -- Content Area
    local ContentArea = CreateInstance("ScrollingFrame", {
        Parent = TabContainer,
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    -- Auto Fish Tab Content
    local AutoFishContent = CreateInstance("Frame", {
        Parent = ContentArea,
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = true
    })

    local AutoFishTitle = CreateInstance("TextLabel", {
        Parent = AutoFishContent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "🎣 Fish Config",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local ToggleButton = CreateInstance("TextButton", {
        Parent = AutoFishContent,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Primary,
        Text = "Toggle Auto Fishing",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = ToggleButton,
        CornerRadius = UDim.new(0, 8)
    })

    statusLabel = CreateInstance("TextLabel", {
        Parent = AutoFishContent,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 90),
        BackgroundTransparency = 1,
        Text = "Status: Disabled ❌",
        TextColor3 = Theme.DarkText,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Teleport Tab Content
    local TeleportContent = CreateInstance("Frame", {
        Parent = ContentArea,
        Size = UDim2.new(1, 0, 0, 300),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false
    })

    local TeleportTitle = CreateInstance("TextLabel", {
        Parent = TeleportContent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "📍 Teleport Locations",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local teleportLocations = {
        {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
        {"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
        {"🏖️ Beach Side", Vector3.new(300, 15, -200)},
        {"🏙️ City Center", Vector3.new(100, 30, 100)},
    }

    for i, location in ipairs(teleportLocations) do
        local TeleportButton = CreateInstance("TextButton", {
            Parent = TeleportContent,
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.new(0, 0, 0, 40 + (i-1)*45),
            BackgroundColor3 = Theme.Secondary,
            Text = location[1],
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0
        })

        CreateInstance("UICorner", {
            Parent = TeleportButton,
            CornerRadius = UDim.new(0, 6)
        })

        TeleportButton.MouseButton1Click:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                ShowNotification("✨ Teleported!", "Teleported to " .. location[1])
            end
        end)
    end

    local CoordToggle = CreateInstance("TextButton", {
        Parent = TeleportContent,
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 240),
        BackgroundColor3 = Theme.Primary,
        Text = "📍 Toggle Coordinates Display",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    })

    CreateInstance("UICorner", {
        Parent = CoordToggle,
        CornerRadius = UDim.new(0, 6)
    })

    local coordEnabled = false
    CoordToggle.MouseButton1Click:Connect(function()
        coordEnabled = not coordEnabled
        if coordEnabled then
            CreateCoordinateDisplay()
            ShowNotification("📍 Coordinates", "Coordinate display enabled!")
        else
            if coordinateDisplay then
                coordinateDisplay:Destroy()
                coordinateDisplay = nil
            end
            ShowNotification("📍 Coordinates", "Coordinate display disabled!")
        end
    end)

    -- Tab Buttons
    local tabs = {
        {Name = "🎣 Auto Fish", Content = AutoFishContent},
        {Name = "📍 Teleport", Content = TeleportContent}
    }

    for i, tab in ipairs(tabs) do
        local TabButton = CreateInstance("TextButton", {
            Parent = TabButtons,
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, (i-1)*45),
            BackgroundColor3 = i == 1 and Theme.Primary or Theme.Secondary,
            Text = tab.Name,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0
        })

        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 6)
        })

        TabButton.MouseButton1Click:Connect(function()
            -- Hide all content
            for _, t in ipairs(tabs) do
                t.Content.Visible = false
            end
            
            -- Show selected content
            tab.Content.Visible = true
            
            -- Update button colors
            for j, btn in ipairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = j == i and Theme.Primary or Theme.Secondary
                end
            end
        end)
    end

    -- Update ContentArea size
    spawn(function()
        while ContentArea and ContentArea.Parent do
            local maxSize = 0
            for _, child in ipairs(ContentArea:GetChildren()) do
                if child:IsA("Frame") and child.Visible then
                    maxSize = math.max(maxSize, child.Size.Y.Offset)
                end
            end
            ContentArea.CanvasSize = UDim2.new(0, 0, 0, maxSize)
            wait(0.1)
        end
    end)

    -- Button Events
    ToggleButton.MouseButton1Click:Connect(ToggleAutoFish)

    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        MainGui:Destroy()
        mainUI = nil
        uiVisible = false
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        if MainWindow.Size.Y.Offset == 350 then
            Tween(MainWindow, {Size = UDim2.new(0, 450, 0, 40)}, 0.3)
            TabContainer.Visible = false
        else
            Tween(MainWindow, {Size = UDim2.new(0, 450, 0, 350)}, 0.3)
            wait(0.3)
            TabContainer.Visible = true
        end
    end)

    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    mainUI = MainGui
    return MainWindow
end

-- Initialize System
local function InitializeHub()
    -- Show loading screen
    local loadingScreen = ShowLoadingScreen()
    
    -- Show notifications
    delay(1, function()
        ShowNotification("🔧 Initializing", "Loading 1/3 features...")
    end)
    
    delay(2, function()
        ShowNotification("🔄 Fetching", "Fetching new version Anggazyy Hub...")
    end)
    
    delay(3, function()
        ShowNotification("✅ Ready", "Anggazyy Hub v1.0-beta loaded!")
        
        -- Remove loading screen
        loadingScreen:Destroy()
        
        -- Create floating icon
        local floatingIcon = CreateFloatingIcon()
        floatingIcon.Visible = true
        
        -- Create main UI (hidden initially)
        local mainWindow = CreateMainUI()
        
        -- Toggle UI with floating icon
        floatingIcon.MouseButton1Click:Connect(function()
            if not uiVisible then
                mainWindow.Visible = true
                mainWindow.Size = UDim2.new(0, 0, 0, 0)
                Tween(mainWindow, {Size = UDim2.new(0, 450, 0, 350)}, 0.4, Enum.EasingStyle.Back)
                uiVisible = true
            else
                Tween(mainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
                wait(0.3)
                mainWindow.Visible = false
                uiVisible = false
            end
        end)
        
        -- Right shift to toggle UI
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.RightShift then
                if not uiVisible then
                    mainWindow.Visible = true
                    mainWindow.Size = UDim2.new(0, 0, 0, 0)
                    Tween(mainWindow, {Size = UDim2.new(0, 450, 0, 350)}, 0.4, Enum.EasingStyle.Back)
                    uiVisible = true
                else
                    Tween(mainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
                    wait(0.3)
                    mainWindow.Visible = false
                    uiVisible = false
                end
            end
        end)
    end)
end

-- Start the hub
InitializeHub()
