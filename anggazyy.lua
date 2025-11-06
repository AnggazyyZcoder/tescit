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
OpenButton.Size = UDim2.new(0, 50, 0, 50) -- Lebih kecil
OpenButton.Position = UDim2.new(0, 15, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
OpenButton.BackgroundTransparency = 0.1
OpenButton.AutoButtonColor = false
OpenButton.Image = "rbxassetid://7072717775"
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.BorderSizePixel = 0
OpenButton.Visible = false

-- Corner radius
UICorner.Parent = OpenButton
UICorner.CornerRadius = UDim.new(0.3, 0)

-- Border effect
UIStroke.Parent = OpenButton
UIStroke.Color = Color3.fromRGB(138, 43, 226) -- Ungu
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
    CoordFrame.Size = UDim2.new(0, 150, 0, 40) -- Lebih kecil
    CoordFrame.Position = UDim2.new(0.5, -75, 0, 5)
    CoordFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
    CoordFrame.BackgroundTransparency = 0.1
    CoordFrame.BorderSizePixel = 0

    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0.2, 0)

    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(147, 112, 219) -- Ungu medium
    UIStroke.Thickness = 1.5

    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 11 -- Lebih kecil
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

-- Main UI Creation
local function createMainUI()
    -- Cek jika UI sudah dibuat, jangan buat duplikat
    if uiInitialized then
        return
    end
    
    uiInitialized = true

    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false,
        -- Ukuran window lebih kecil dan responsive
        Center = true
    })

    -- =============================================
    -- TAB 1: TELEPORT TAB
    -- =============================================
    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    -- Section untuk Teleport Lokasi
    TeleportTab:AddSection({
        Name = "📍 Teleport Locations"
    })

    -- Contoh teleport points dengan warna ungu
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

    -- Loop untuk membuat button teleport dengan warna ungu
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

    -- Section untuk Custom Teleport
    TeleportTab:AddSection({
        Name = "🎯 Custom Teleport"
    })

    -- Input untuk custom coordinates
    local xInput = TeleportTab:AddTextbox({
        Name = "X Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    local yInput = TeleportTab:AddTextbox({
        Name = "Y Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    local zInput = TeleportTab:AddTextbox({
        Name = "Z Coordinate",
        Default = "0",
        TextDisappear = false,
        Callback = function(Value)
            -- Value akan digunakan di teleport function
        end
    })

    -- Button untuk execute custom teleport
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

    -- Player Utilities Section
    TeleportTab:AddSection({
        Name = "⚡ Player Utilities"
    })

    TeleportTab:AddSlider({
        Name = "🎯 WalkSpeed",
        Min = 16,
        Max = 150, -- Max lebih rendah untuk balance
        Default = 16,
        Color = Color3.fromRGB(147, 112, 219), -- Ungu
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
        Max = 150, -- Max lebih rendah untuk balance
        Default = 50,
        Color = Color3.fromRGB(186, 85, 211), -- Ungu muda
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

    -- =============================================
    -- TAB 2: PLAYER CONTROL TAB (NEW)
    -- =============================================
    local PlayerTab = Window:MakeTab({
        Name = "Player Control",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    PlayerTab:AddSection({
        Name = "🎯 Player Selection"
    })

    local SelectedPlayer = "None"
    local PlayerDropdown = PlayerTab:AddDropdown({
        Name = "Select Player",
        Default = "None",
        Options = {"None"},
        Callback = function(Value)
            SelectedPlayer = Value
        end
    })

    -- Update player list function
    local function UpdatePlayerList()
        local players = {"None"}
        for i, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= game.Players.LocalPlayer then
                table.insert(players, v.Name)
            end
        end
        PlayerDropdown:Refresh(players, true)
    end

    -- Initial update and connect events
    UpdatePlayerList()
    game:GetService("Players").PlayerAdded:Connect(UpdatePlayerList)
    game:GetService("Players").PlayerRemoving:Connect(UpdatePlayerList)

    PlayerTab:AddSection({
        Name = "🌊 Flood & Control"
    })

    -- Flood Ping Player Feature
    PlayerTab:AddButton({
        Name = "🌊 Flood Ping Player",
        Callback = function()
            if SelectedPlayer and SelectedPlayer ~= "None" then
                OrionLib:MakeNotification({
                    Name = "🌊 Flood Ping Started",
                    Content = "Flooding " .. SelectedPlayer .. " with pings...",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
                
                for i = 1, 150 do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                        "/w " .. SelectedPlayer .. " PING_FLOOD_" .. i .. " " .. string.rep("🚀", 20),
                        "All"
                    )
                    wait(0.05)
                end
                
                OrionLib:MakeNotification({
                    Name = "🌊 Flood Ping Complete",
                    Content = "Finished flooding " .. SelectedPlayer,
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "❌ Error",
                    Content = "Please select a player first!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Bring All Players Feature
    PlayerTab:AddButton({
        Name = "🚀 Bring All Players To Me",
        Callback = function()
            local LocalPlayer = game.Players.LocalPlayer
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local broughtCount = 0
                
                for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        v.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        broughtCount = broughtCount + 1
                    end
                end
                
                OrionLib:MakeNotification({
                    Name = "🚀 Players Brought",
                    Content = "Successfully brought " .. broughtCount .. " players to you!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Teleport to Player Feature
    PlayerTab:AddButton({
        Name = "📍 Teleport To Player",
        Callback = function()
            if SelectedPlayer and SelectedPlayer ~= "None" then
                local targetPlayer = game:GetService("Players"):FindFirstChild(SelectedPlayer)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    
                    OrionLib:MakeNotification({
                        Name = "📍 Teleported",
                        Content = "Teleported to " .. SelectedPlayer,
                        Image = "rbxassetid://7072717775",
                        Time = 3
                    })
                end
            end
        end
    })

    -- =============================================
    -- TAB 3: SERVER CONTROL TAB (NEW)
    -- =============================================
    local ServerTab = Window:MakeTab({
        Name = "Server Control",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    ServerTab:AddSection({
        Name = "💥 Server Actions"
    })

    -- Crash Server Feature
    ServerTab:AddButton({
        Name = "💥 Crash Server (Heavy)",
        Callback = function()
            OrionLib:MakeNotification({
                Name = "💥 Starting Server Crash",
                Content = "Heavy crash sequence initiated...",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
            
            -- Method 1: Mass part creation
            for i = 1, 300 do
                local part = Instance.new("Part")
                part.Parent = workspace
                part.Size = Vector3.new(100, 100, 100)
                part.Position = Vector3.new(math.random(-500, 500), math.random(100, 1000), math.random(-500, 500))
                part.Anchored = true
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.Random()
            end
            
            -- Method 2: Body positions
            for i = 1, 200 do
                local body = Instance.new("BodyPosition")
                body.Parent = workspace
                body.Position = Vector3.new(0, 10000, 0)
                body.MaxForce = Vector3.new(100000, 100000, 100000)
            end
            
            -- Method 3: Script injection attempt
            spawn(function()
                while true do
                    for i = 1, 50 do
                        local s = Instance.new("Script")
                        s.Parent = workspace
                    end
                    wait()
                end
            end)
        end
    })

    -- Server Lag Feature
    ServerTab:AddButton({
        Name = "🌪️ Create Server Lag",
        Callback = function()
            OrionLib:MakeNotification({
                Name = "🌪️ Generating Lag",
                Content = "Creating server lag spikes...",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
            
            for i = 1, 100 do
                local part = Instance.new("Part")
                part.Parent = workspace
                part.Size = Vector3.new(50, 50, 50)
                part.Position = Vector3.new(math.random(-1000, 1000), math.random(500, 2000), math.random(-1000, 1000))
                part.Anchored = true
                
                -- Add welds to increase processing
                local weld = Instance.new("Weld")
                weld.Parent = part
            end
        end
    })

    -- Clear Workspace Feature
    ServerTab:AddButton({
        Name = "🗑️ Clear Workspace Parts",
        Callback = function()
            local count = 0
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") then
                    v:Destroy()
                    count = count + 1
                end
            end
            
            OrionLib:MakeNotification({
                Name = "🗑️ Workspace Cleared",
                Content = "Removed " .. count .. " parts from workspace",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
        end
    })

    ServerTab:AddSection({
        Name = "⚡ Server Utilities"
    })

    -- Freeze All Players
    ServerTab:AddButton({
        Name = "❄️ Freeze All Players",
        Callback = function()
            local frozenCount = 0
            for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= game.Players.LocalPlayer and v.Character then
                    local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 0
                        humanoid.JumpPower = 0
                        frozenCount = frozenCount + 1
                    end
                end
            end
            
            OrionLib:MakeNotification({
                Name = "❄️ Players Frozen",
                Content = "Frozen " .. frozenCount .. " players",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
        end
    })

    -- Unfreeze All Players
    ServerTab:AddButton({
        Name = "🔥 Unfreeze All Players",
        Callback = function()
            local unfrozenCount = 0
            for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Character then
                    local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 16
                        humanoid.JumpPower = 50
                        unfrozenCount = unfrozenCount + 1
                    end
                end
            end
            
            OrionLib:MakeNotification({
                Name = "🔥 Players Unfrozen",
                Content = "Unfrozen " .. unfrozenCount .. " players",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
        end
    })

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

    SettingsTab:AddParagraph("🎉 Anggazyy Hub", "✨ Version 3.0\n💜 Premium Control Hub\n🎯 Created by Anggazyy\n🌊 Added: Flood Ping, Server Crash, Player Control")

    -- Initialize Orion dengan theme ungu
    OrionLib:Init()

    -- Apply purple theme to existing elements
    for _, tab in next, OrionLib:GetWindow().Tabs do
        for _, section in next, tab.Sections do
            section.Color = Color3.fromRGB(147, 112, 219)
        end
    end

    -- Hide window initially
    if Window then
        Window:Toggle()
    end

    -- Button click event dengan animasi sederhana
    OpenButton.MouseButton1Click:Connect(function()
        if Window then
            Window:Toggle()
            
            -- Simple scale animation
            spawn(function()
                OpenButton.Size = UDim2.new(0, 45, 0, 45)
                wait(0.1)
                OpenButton.Size = UDim2.new(0, 50, 0, 50)
            end)
        end
    end)

    -- Make floating icon draggable
    local Dragging = false
    local DragInput, DragStart, StartPos

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = OpenButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    OpenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            OpenButton.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Make floating icon visible
    OpenButton.Visible = true
end

-- Loading Screen Function yang lebih kecil
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
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30) -- Background ungu gelap
    Background.BackgroundTransparency = 0
    Background.ZIndex = 10

    -- Ukuran lebih kecil untuk mobile
    LoadingFrame.Parent = Background
    LoadingFrame.Size = UDim2.new(0, 280, 0, 100) -- Lebih kecil
    LoadingFrame.Position = UDim2.new(0.5, -140, 0.5, -50)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 65) -- Ungu gelap
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
    LoadingLabel.TextSize = 16  -- Ukuran lebih kecil
    LoadingLabel.Font = Enum.Font.GothamBold
    LoadingLabel.ZIndex = 12

    LoadingBar.Parent = LoadingFrame
    LoadingBar.Size = UDim2.new(0.8, 0, 0.15, 0) -- Lebih tipis
    LoadingBar.Position = UDim2.new(0.1, 0, 0.75, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(60, 35, 85) -- Ungu medium gelap
    LoadingBar.BorderSizePixel = 0
    LoadingBar.ZIndex = 12

    UICorner2.Parent = LoadingBar
    UICorner2.CornerRadius = UDim.new(0.5, 0)

    LoadingBarFill.Parent = LoadingBar
    LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingBarFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219) -- Ungu terang
    LoadingBarFill.BorderSizePixel = 0
    LoadingBarFill.ZIndex = 13

    UICorner3.Parent = LoadingBarFill
    UICorner3.CornerRadius = UDim.new(0.5, 0)

    -- Animated text function
    local function animateText(speed)
        local fullText = "ANGGAZYY HUB V3"
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
        animateText(0.1)
        wait(0.3)
        
        -- Fade out animation
        for i = 0, 1, 0.08 do
            Background.BackgroundTransparency = i
            LoadingFrame.BackgroundTransparency = i
            LoadingLabel.TextTransparency = i
            LoadingBar.BackgroundTransparency = i
            LoadingBarFill.BackgroundTransparency = i
            wait(0.02)
        end
        
        LoadingGui:Destroy()
        
        -- Show notification dulu sebelum buka UI
        OrionLib:MakeNotification({
            Name = "💜 Anggazyy Hub V3 Ready!",
            Content = "New Features: Flood Ping, Server Crash, Player Control!",
            Image = "rbxassetid://7072717775",
            Time = 4
        })
        
        -- Tunggu sebentar lalu buat UI
        wait(5.1)
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
