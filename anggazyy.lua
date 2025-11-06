local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Floating Icon
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("ImageButton")
local UIScale = Instance.new("UIScale")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AnggazyyHubUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0, 20, 0.5, -30)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenButton.BackgroundTransparency = 0.2
OpenButton.AutoButtonColor = false
OpenButton.Image = "rbxassetid://7072717775" -- Ganti dengan asset ID logo yang bagus
OpenButton.ScaleType = Enum.ScaleType.Crop
OpenButton.BorderSizePixel = 0
OpenButton.ClipsDescendants = true

-- Corner radius
local UICorner = Instance.new("UICorner")
UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.3, 0)

-- Shadow effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(100, 100, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5

-- Animation variables
local isOpen = false
local isAnimating = false

-- Floating animation
spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            if OpenButton then
                OpenButton.Position = UDim2.new(0, 20, 0.5, -30 + math.sin(tick() * 3) * 5)
                OpenButton.Rotation = math.sin(tick() * 2) * 3
            end
            wait(0.03)
        end
    end
end)

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
    local function animateText(text, speed)
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
        animateText("A N G G A Z Y Y  H U B", 0.1)
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
        createMainUI()
    end)
end

-- Main UI Creation
local function createMainUI()
    local Window = OrionLib:MakeWindow({
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
        Name = "Player"
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
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
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
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    })

    -- Game Section
    MainTab:AddSection({
        Name = "Game"
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
        end
    })

    -- Visual Section
    MainTab:AddSection({
        Name = "Visual"
    })

    MainTab:AddToggle({
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
        end
    })

    SettingsTab:AddBind({
        Name = "Toggle UI",
        Default = Enum.KeyCode.RightShift,
        Hold = false,
        Callback = function()
            OrionLib:Toggle()
        end
    })

    SettingsTab:AddParagraph("Credits", "✨ Anggazyy Hub v2.0\n🌟 Premium Roblox Script Hub\n💫 Created by Anggazyy")

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

    -- Initialize Orion
    OrionLib:Init()

    -- Hide window initially
    OrionLib:Toggle()

    -- Button click event
    OpenButton.MouseButton1Click:Connect(function()
        if not isAnimating then
            isAnimating = true
            OrionLib:Toggle()
            
            -- Button animation
            spawn(function()
                for i = 1, 10 do
                    OpenButton.Rotation = OpenButton.Rotation + 36
                    wait(0.01)
                end
                OpenButton.Rotation = 0
                isAnimating = false
            end)
        end
    end)
end

-- Start loading screen when script executes
showLoadingScreen()

-- Make floating icon visible after loading
spawn(function()
    wait(3) -- Wait for loading screen to complete
    OpenButton.Visible = true
end)
