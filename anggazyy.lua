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
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0, 20, 0.5, -30)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
OpenButton.BackgroundTransparency = 0.1
OpenButton.AutoButtonColor = false
OpenButton.Image = "rbxassetid://7072717775" -- Logo Hub
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.BorderSizePixel = 0
OpenButton.Visible = false

-- Corner radius
UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.2, 0)

-- Border effect
UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(100, 100, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3

-- Variables
local isUIOpen = false
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local Window = nil

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
    CoordFrame.Size = UDim2.new(0, 200, 0, 60)
    CoordFrame.Position = UDim2.new(0.5, -100, 0, 20)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    CoordFrame.BackgroundTransparency = 0.1
    CoordFrame.BorderSizePixel = 0

    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0.1, 0)

    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(100, 100, 255)
    UIStroke.Thickness = 2

    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 14
    CoordLabel.Font = Enum.Font.GothamBold
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
    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false
    })

    -- Main Tab
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    -- Player Section
    MainTab:AddSection({
        Name = "Player Features"
    })

    MainTab:AddButton({
        Name = "Fly Script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGui/main/FlyGui.txt"))()
            OrionLib:MakeNotification({
                Name = "Fly Activated!",
                Content = "Press E to fly",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
        end
    })

    MainTab:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 200,
        Default = 16,
        Color = Color3.fromRGB(100, 100, 255),
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

    MainTab:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 200,
        Default = 50,
        Color = Color3.fromRGB(100, 255, 100),
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

    -- Game Section
    MainTab:AddSection({
        Name = "Game Features"
    })

    MainTab:AddButton({
        Name = "Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            OrionLib:MakeNotification({
                Name = "Infinite Yield Loaded!",
                Content = "FE Admin Commands activated",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
        end
    })

    local noclipToggle = MainTab:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(Value)
            getgenv().Noclip = Value
            OrionLib:MakeNotification({
                Name = "Noclip " .. (Value and "Enabled" or "Disabled"),
                Content = "Noclip feature " .. (Value and "activated" or "deactivated"),
                Image = "rbxassetid://7072717775",
                Time = 2
            })
        end
    })

    -- Visual Section
    MainTab:AddSection({
        Name = "Visual Features"
    })

    local espToggle = MainTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(Value)
            OrionLib:MakeNotification({
                Name = "ESP " .. (Value and "Enabled" or "Disabled"),
                Content = "Player ESP " .. (Value and "activated" or "deactivated"),
                Image = "rbxassetid://7072717775",
                Time = 2
            })
        end
    })

    local coordinateToggle = MainTab:AddToggle({
        Name = "Show Coordinates",
        Default = false,
        Callback = function(Value)
            if Value then
                createCoordinateDisplay()
                OrionLib:MakeNotification({
                    Name = "Coordinates Enabled",
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

    -- Teleport Section (untuk nanti)
    MainTab:AddSection({
        Name = "Teleport"
    })

    MainTab:AddParagraph("Teleport Menu", "Teleport features will be added soon!")

    -- Settings Tab
    local SettingsTab = Window:MakeTab({
        Name = "Settings",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    SettingsTab:AddButton({
        Name = "Destroy UI",
        Callback = function()
            OrionLib:Destroy()
            ScreenGui:Destroy()
            if coordinateDisplay then
                coordinateDisplay:Destroy()
            end
        end
    })

    SettingsTab:AddBind({
        Name = "Toggle UI",
        Default = Enum.KeyCode.RightShift,
        Hold = false,
        Callback = function()
            if Window then
                Window:Toggle()
            end
        end
    })

    SettingsTab:AddParagraph("Credits", "✨ Anggazyy Hub v2.0\n🌟 Premium Roblox Script Hub\n💫 Created by Anggazyy")

    -- Initialize Orion
    OrionLib:Init()

    -- Hide window initially
    if Window then
        Window:Toggle()
    end

    -- Button click event - hanya toggle UI, tidak buka tab
    OpenButton.MouseButton1Click:Connect(function()
        if Window then
            Window:Toggle()
            isUIOpen = not isUIOpen
            
            -- Simple scale animation
            spawn(function()
                OpenButton.Size = UDim2.new(0, 55, 0, 55)
                wait(0.1)
                OpenButton.Size = UDim2.new(0, 60, 0, 60)
            end)
        end
    end)

    -- Make floating icon visible
    OpenButton.Visible = true

    -- Show welcome notification
    OrionLib:MakeNotification({
        Name = "Welcome to Anggazyy Hub!",
        Content = "UI successfully loaded! Click the floating icon to open.",
        Image = "rbxassetid://7072717775",
        Time = 5
    })
end

-- Loading Screen Function
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
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0
    Background.ZIndex = 10

    LoadingFrame.Parent = Background
    LoadingFrame.Size = UDim2.new(0, 400, 0, 150)
    LoadingFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 11

    UICorner1.Parent = LoadingFrame
    UICorner1.CornerRadius = UDim.new(0.1, 0)

    LoadingLabel.Parent = LoadingFrame
    LoadingLabel.Size = UDim2.new(1, 0, 0.6, 0)
    LoadingLabel.Position = UDim2.new(0, 0, 0.1, 0)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = ""
    LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingLabel.TextSize = 24
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.ZIndex = 12

    LoadingBar.Parent = LoadingFrame
    LoadingBar.Size = UDim2.new(0.8, 0, 0.1, 0)
    LoadingBar.Position = UDim2.new(0.1, 0, 0.8, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    LoadingBar.BorderSizePixel = 0
    LoadingBar.ZIndex = 12

    UICorner2.Parent = LoadingBar
    UICorner2.CornerRadius = UDim.new(0.5, 0)

    LoadingBarFill.Parent = LoadingBar
    LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingBarFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    LoadingBarFill.BorderSizePixel = 0
    LoadingBarFill.ZIndex = 13

    UICorner3.Parent = LoadingBarFill
    UICorner3.CornerRadius = UDim.new(0.5, 0)

    -- Animated text function
    local function animateText(speed)
        local fullText = "A N G G A Z Y Y  H U B"
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
        animateText(0.08)
        wait(0.5)
        
        -- Fade out animation
        for i = 0, 1, 0.05 do
            Background.BackgroundTransparency = i
            LoadingFrame.BackgroundTransparency = i
            LoadingLabel.TextTransparency = i
            LoadingBar.BackgroundTransparency = i
            LoadingBarFill.BackgroundTransparency = i
            wait(0.02)
        end
        
        LoadingGui:Destroy()
        -- Create main UI setelah loading selesai
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
