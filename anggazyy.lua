-- FULL SCRIPT CIT ROBLOX BY ANGGAZYY DEVELOPER V4
getgenv().Aimbot = true
getgenv().Wallhack = true
getgenv().InfStamina = true
getgenv().ServerLag = false
getgenv().Noclip = false

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
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
OpenButton.BackgroundTransparency = 0.1
OpenButton.AutoButtonColor = false
OpenButton.Image = "rbxassetid://7072717775"
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.BorderSizePixel = 0
OpenButton.Visible = false

UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.3, 0)

UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(138, 43, 226)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3

-- Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local Window = nil
local uiInitialized = false

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
    CoordLabel.TextStrokeTransparency = 0.8

    coordinateDisplay = CoordGui

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
    if uiInitialized then
        return
    end
    
    uiInitialized = true

    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub V4", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false,
        Center = true
    })

    -- TAB 1: TELEPORT TAB
    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    TeleportTab:AddSection({
        Name = "📍 Teleport Locations"
    })

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
    }

    TeleportTab:AddSection({
        Name = "🎯 Custom Teleport"
    })

    local xInput = TeleportTab:AddTextbox({
        Name = "X Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value) end
    })

    local yInput = TeleportTab:AddTextbox({
        Name = "Y Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value) end
    })

    local zInput = TeleportTab:AddTextbox({
        Name = "Z Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value) end
    })

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

    TeleportTab:AddSection({
        Name = "⚡ Player Utilities"
    })

    TeleportTab:AddSlider({
        Name = "🎯 WalkSpeed",
        Min = 16,
        Max = 150,
        Default = 16,
        Color = Color3.fromRGB(147, 112, 219),
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
        Max = 150,
        Default = 50,
        Color = Color3.fromRGB(186, 85, 211),
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

    -- TAB 2: SERVER LAG TAB
    local LagTab = Window:MakeTab({
        Name = "💥 Server Lag",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    LagTab:AddSection({
        Name = "☠️ Server Destruction Tools"
    })

    LagTab:AddButton({
        Name = "💣 Mass Part Spam (5000 Parts)",
        Callback = function()
            for i = 1, 5000 do
                local part = Instance.new("Part")
                part.Parent = workspace
                part.Size = Vector3.new(5, 5, 5)
                part.Position = Vector3.new(math.random(-500, 500), math.random(10, 100), math.random(-500, 500))
                part.Anchored = true
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.random()
                wait(0.001)
            end
        end
    })

    LagTab:AddButton({
        Name = "📡 Network Flood Attack",
        Callback = function()
            spawn(function()
                while true do
                    for i = 1, 100 do
                        local remote = Instance.new("RemoteEvent")
                        remote.Parent = game:GetService("ReplicatedStorage")
                        remote.Name = "LagEvent_" .. i
                    end
                    wait(0.01)
                end
            end)
        end
    })

    LagTab:AddButton({
        Name = "🧠 Memory Leak Attack",
        Callback = function()
            local strings = {}
            spawn(function()
                while true do
                    local hugeString = string.rep("LAG", 1000000)
                    table.insert(strings, hugeString)
                    wait(0.05)
                end
            end)
        end
    })

    LagTab:AddButton({
        Name = "✨ Particle Effect Spam",
        Callback = function()
            for i = 1, 200 do
                local fire = Instance.new("Fire")
                fire.Parent = workspace
                fire.Size = 50
                fire.Heat = 25
                
                local smoke = Instance.new("Smoke")
                smoke.Parent = workspace
                smoke.Size = 20
                smoke.Opacity = 1
                
                local explosion = Instance.new("Explosion")
                explosion.Parent = workspace
                explosion.Position = Vector3.new(math.random(-200, 200), math.random(10, 50), math.random(-200, 200))
                explosion.BlastPressure = 0
            end
        end
    })

    LagTab:AddButton({
        Name = "⚡ Script Injection Massal",
        Callback = function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") then
                    local script = Instance.new("Script", obj)
                    script.Source = [[
                        while true do
                            for i = 1, 10000 do
                                local x = math.random(1, 1000000)
                            end
                            wait()
                        end
                    ]]
                end
            end
        end
    })

    LagTab:AddButton({
        Name = "🌐 Ping Bomb Attack",
        Callback = function()
            spawn(function()
                for i = 1, 500 do
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                    wait(0.01)
                end
            end)
        end
    })

    LagTab:AddButton({
        Name = "⏰ Instant Server Crash",
        Callback = function()
            spawn(function()
                while true do
                    for i = 1, 500 do
                        Instance.new("Part", workspace)
                        Instance.new("Fire", workspace)
                        Instance.new("Smoke", workspace)
                        Instance.new("Sparkles", workspace)
                    end
                    wait()
                end
            end)
        end
    })

    LagTab:AddToggle({
        Name = "💀 Enable Auto Server Lag",
        Default = false,
        Callback = function(Value)
            getgenv().ServerLag = Value
            if Value then
                spawn(function()
                    while getgenv().ServerLag do
                        for i = 1, 200 do
                            local part = Instance.new("Part")
                            part.Parent = workspace
                            part.Size = Vector3.new(2, 2, 2)
                            part.Position = Vector3.new(math.random(-1000, 1000), math.random(0, 500), math.random(-1000, 1000))
                            part.Anchored = true
                        end
                        
                        for i = 1, 100 do
                            local remote = Instance.new("RemoteEvent")
                            remote.Parent = game:GetService("ReplicatedStorage")
                        end
                        
                        wait(0.3)
                    end
                end)
            end
        end
    })

    LagTab:AddSection({
        Name = "⚠️ Warning: Fitur ini bisa bikin server down permanent!"
    })

    -- TAB 3: SETTINGS TAB
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

    SettingsTab:AddParagraph("🎉 Anggazyy Hub V4", "✨ Complete Server Control\n💜 Premium Cheat Hub\n🎯 Created by Anggazyy Developer\n☠️ Server Lag Features Included")

    OrionLib:Init()

    for _, tab in next, OrionLib:GetWindow().Tabs do
        for _, section in next, tab.Sections do
            section.Color = Color3.fromRGB(147, 112, 219)
        end
    end

    if Window then
        Window:Toggle()
    end

    OpenButton.MouseButton1Click:Connect(function()
        if Window then
            Window:Toggle()
            
            spawn(function()
                OpenButton.Size = UDim2.new(0, 45, 0, 45)
                wait(0.1)
                OpenButton.Size = UDim2.new(0, 50, 0, 50)
            end)
        end
    end)

    OpenButton.Visible = true
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
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
    Background.BackgroundTransparency = 0
    Background.ZIndex = 10

    LoadingFrame.Parent = Background
    LoadingFrame.Size = UDim2.new(0, 280, 0, 100)
    LoadingFrame.Position = UDim2.new(0.5, -140, 0.5, -50)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
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
    LoadingLabel.TextSize = 16
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.ZIndex = 12

    LoadingBar.Parent = LoadingFrame
    LoadingBar.Size = UDim2.new(0.8, 0, 0.15, 0)
    LoadingBar.Position = UDim2.new(0.1, 0, 0.75, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(60, 35, 85)
    LoadingBar.BorderSizePixel = 0
    LoadingBar.ZIndex = 12

    UICorner2.Parent = LoadingBar
    UICorner2.CornerRadius = UDim.new(0.5, 0)

    LoadingBarFill.Parent = LoadingBar
    LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingBarFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    LoadingBarFill.BorderSizePixel = 0
    LoadingBarFill.ZIndex = 13

    UICorner3.Parent = LoadingBarFill
    UICorner3.CornerRadius = UDim.new(0.5, 0)

    local function animateText(speed)
        local fullText = "ANGGAZYY HUB V4 LOADING"
        local currentText = ""
        
        for i = 1, #fullText do
            currentText = string.sub(fullText, 1, i)
            LoadingLabel.Text = currentText
            LoadingBarFill.Size = UDim2.new((i / #fullText), 0, 1, 0)
            wait(speed)
        end
    end

    spawn(function()
        animateText(0.08)
        wait(0.3)
        
        for i = 0, 1, 0.08 do
            Background.BackgroundTransparency = i
            LoadingFrame.BackgroundTransparency = i
            LoadingLabel.TextTransparency = i
            LoadingBar.BackgroundTransparency = i
            LoadingBarFill.BackgroundTransparency = i
            wait(0.02)
        end
        
        LoadingGui:Destroy()
        
        OrionLib:MakeNotification({
            Name = "💜 Anggazyy Hub V4 Ready!",
            Content = "Server Lag Features Activated! Click purple icon!",
            Image = "rbxassetid://7072717775",
            Time = 5
        })
        
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

-- Start loading screen
showLoadingScreen()

-- Auto-execute features
spawn(function()
    wait(3)
    if getgenv().Aimbot then
        OrionLib:MakeNotification({
            Name = "🎯 Aimbot Activated",
            Content = "Aimbot feature is now active",
            Image = "rbxassetid://7072717775",
            Time = 3
        })
    end
    if getgenv().Wallhack then
        OrionLib:MakeNotification({
            Name = "👁️ Wallhack Activated",
            Content = "Wallhack feature is now active",
            Image = "rbxassetid://7072717775",
            Time = 3
        })
    end
end)
