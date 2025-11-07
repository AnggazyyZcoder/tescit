local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

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
OpenButton.Visible = true  -- Langsung visible

-- Corner radius
UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.3, 0)

-- Border effect
UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(138, 43, 226)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3

-- Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local Window = nil
local uiInitialized = false

-- Auto Fishing Variables
local AutoFishingEnabled = false
local AutoFishingLoop = nil

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

-- Auto Fishing Functions
local function toggleAutoFishing()
    local success, result = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        -- Cari tombol Auto
        local autoButton = LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("Frame"):WaitForChild("Small Buttons"):WaitForChild("Auto")
        
        -- Coba click tombol
        for _, v in pairs(getconnections(autoButton.MouseButton1Click)) do
            v:Fire()
        end
        
        return true
    end)
    
    return success
end

local function getAutoFishingStatus()
    local success, result = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local dataReplicator = Replion.Client:WaitReplion("Data")
        return dataReplicator:GetExpect("AutoFishing")
    end)
    
    return success and result or false
end

local function startAutoFishingLoop()
    if AutoFishingLoop then
        AutoFishingLoop:Disconnect()
        AutoFishingLoop = nil
    end
    
    AutoFishingLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if AutoFishingEnabled then
            -- Simple auto fishing logic
            local success = toggleAutoFishing()
            if not success then
                AutoFishingEnabled = false
                if Window then
                    OrionLib:MakeNotification({
                        Name = "🎣 Auto Fishing",
                        Content = "Failed to toggle auto fishing!",
                        Image = "rbxassetid://7072717775",
                        Time = 3
                    })
                end
            end
        end
    end)
end

-- Main UI Creation
local function createMainUI()
    if uiInitialized then
        if Window then
            Window:Toggle()
        end
        return
    end
    
    uiInitialized = true

    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub", 
        HidePremium = false, 
        SaveConfig = false,
        IntroEnabled = false,
    })

    -- =============================================
    -- TAB 1: MAIN TAB
    -- =============================================
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    MainTab:AddSection({
        Name = "🎮 Player Utilities"
    })

    MainTab:AddSlider({
        Name = "🎯 WalkSpeed",
        Min = 16,
        Max = 200,
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

    MainTab:AddSlider({
        Name = "🦘 JumpPower",
        Min = 50,
        Max = 200,
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

    -- Visual Features
    MainTab:AddSection({
        Name = "👁️ Visual Features"
    })

    local noclipToggle = MainTab:AddToggle({
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

    local coordinateToggle = MainTab:AddToggle({
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
    -- TAB 2: TELEPORT TAB
    -- =============================================
    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    TeleportTab:AddSection({
        Name = "📍 Teleport Locations"
    })

    -- Simple teleport locations
    local teleportLocations = {
        {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
        {"🚀 High Platform", Vector3.new(0, 100, 0)},
        {"🕳️ Underground", Vector3.new(0, -50, 0)},
        {"☁️ Sky Island", Vector3.new(0, 500, 0)},
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
    end

    TeleportTab:AddSection({
        Name = "🎯 Custom Teleport"
    })

    local xInput, yInput, zInput

    xInput = TeleportTab:AddTextbox({
        Name = "X Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value) end
    })

    yInput = TeleportTab:AddTextbox({
        Name = "Y Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value) end
    })

    zInput = TeleportTab:AddTextbox({
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

    -- =============================================
    -- TAB 3: AUTO FISHING TAB
    -- =============================================
    local AutoFishingTab = Window:MakeTab({
        Name = "🎣 Auto Fishing",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    AutoFishingTab:AddSection({
        Name = "🤖 Auto Fishing Features"
    })

    local autoFishToggle = AutoFishingTab:AddToggle({
        Name = "🎣 Enable Auto Fishing",
        Default = false,
        Callback = function(Value)
            AutoFishingEnabled = Value
            if Value then
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

    AutoFishingTab:AddButton({
        Name = "🔄 Toggle Auto Fishing Once",
        Callback = function()
            local success = toggleAutoFishing()
            if success then
                local status = getAutoFishingStatus()
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing",
                    Content = "Auto Fishing toggled! Current: " .. (status and "ON" or "OFF"),
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "🎣 Auto Fishing Error",
                    Content = "Failed to toggle auto fishing!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

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
        "1. Make sure you have a fishing rod equipped\n" ..
        "2. Enable Auto Fishing toggle\n" ..
        "3. Stand near water\n" ..
        "4. System will automatically fish for you!")

    -- =============================================
    -- TAB 4: SETTINGS TAB
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

    SettingsTab:AddParagraph("🎉 Anggazyy Hub", 
        "✨ Version 2.0\n" ..
        "💜 Premium Script Hub\n" ..
        "🎣 Auto Fishing Feature\n" ..
        "🎯 Created by Anggazyy")

    -- Initialize Orion
    OrionLib:Init()

    -- Apply purple theme
    for _, tab in next, OrionLib:GetWindow().Tabs do
        for _, section in next, tab.Sections do
            section.Color = Color3.fromRGB(147, 112, 219)
        end
    end

    -- Show notification
    OrionLib:MakeNotification({
        Name = "💜 Anggazyy Hub Loaded!",
        Content = "Welcome to Anggazyy Hub!",
        Image = "rbxassetid://7072717775",
        Time = 5
    })
end

-- Simple loading function
local function initializeHub()
    -- Create main UI immediately
    createMainUI()
    
    -- Show welcome message
    wait(1)
    OrionLib:MakeNotification({
        Name = "🚀 Hub Ready!",
        Content = "Anggazyy Hub successfully loaded!\nClick the purple icon to open!",
        Image = "rbxassetid://7072717775",
        Time = 5
    })
end

-- Button click event
OpenButton.MouseButton1Click:Connect(function()
    createMainUI()
    
    -- Simple scale animation
    spawn(function()
        OpenButton.Size = UDim2.new(0, 45, 0, 45)
        wait(0.1)
        OpenButton.Size = UDim2.new(0, 50, 0, 50)
    end)
end)

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

-- Start the hub
initializeHub()

-- Make sure floating icon is always visible
OpenButton.Visible = true
