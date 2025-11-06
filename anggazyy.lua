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

-- SERVER-SIDE BRING ALL PLAYERS FUNCTION
local function bringAllPlayersToMe()
    local localPlayer = game.Players.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end

    local successCount = 0
    
    -- Method 1: Using TweenService for smooth movement (Server-side)
    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if targetPlayer ~= localPlayer and targetPlayer.Character then
            local targetChar = targetPlayer.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHumanoid then
                -- Set network ownership to client for better control
                targetRoot:SetNetworkOwner(localPlayer)
                
                -- Disable their movement temporarily
                targetHumanoid.PlatformStand = true
                
                -- Create body position for precise control
                local bodyPosition = Instance.new("BodyPosition")
                bodyPosition.Position = localChar.HumanoidRootPart.Position
                bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyPosition.P = 10000
                bodyPosition.Parent = targetRoot
                
                -- Create body gyro to prevent rotation
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
                bodyGyro.P = 10000
                bodyGyro.CFrame = localChar.HumanoidRootPart.CFrame
                bodyGyro.Parent = targetRoot
                
                -- Smooth tween to position
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = game:GetService("TweenService"):Create(targetRoot, tweenInfo, {CFrame = localChar.HumanoidRootPart.CFrame})
                tween:Play()
                
                successCount = successCount + 1
                
                -- Clean up after tween
                spawn(function()
                    wait(1.5)
                    if bodyPosition then bodyPosition:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    if targetHumanoid then
                        targetHumanoid.PlatformStand = false
                    end
                end)
            end
        end
    end
    
    return successCount
end

-- SERVER-SIDE BRING SPECIFIC PLAYER
local function bringPlayerToMe(playerName)
    local localPlayer = game.Players.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return false end

    local targetPlayer = game:GetService("Players"):FindFirstChild(playerName)
    if not targetPlayer or not targetPlayer.Character then return false end

    local targetChar = targetPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if targetRoot and targetHumanoid then
        -- Take network ownership
        targetRoot:SetNetworkOwner(localPlayer)
        
        -- Disable their movement
        targetHumanoid.PlatformStand = true
        
        -- Create precise body controls
        local bodyPosition = Instance.new("BodyPosition")
        bodyPosition.Position = localChar.HumanoidRootPart.Position
        bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyPosition.P = 10000
        bodyPosition.Parent = targetRoot
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        bodyGyro.P = 10000
        bodyGyro.CFrame = localChar.HumanoidRootPart.CFrame
        bodyGyro.Parent = targetRoot
        
        -- Smooth movement
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(targetRoot, tweenInfo, {CFrame = localChar.HumanoidRootPart.CFrame})
        tween:Play()
        
        -- Clean up
        spawn(function()
            wait(2)
            if bodyPosition then bodyPosition:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if targetHumanoid then
                targetHumanoid.PlatformStand = false
            end
        end)
        
        return true
    end
    return false
end

-- Main UI Creation
local function createMainUI()
    if uiInitialized then return end
    uiInitialized = true

    Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub", 
        HidePremium = false, 
        SaveConfig = true, 
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false,
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
        {"🏙️ City Center", Vector3.new(100, 30, 100)}
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

    -- =============================================
    -- TAB 2: PLAYER CONTROL TAB
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

    UpdatePlayerList()
    game:GetService("Players").PlayerAdded:Connect(UpdatePlayerList)
    game:GetService("Players").PlayerRemoving:Connect(UpdatePlayerList)

    PlayerTab:AddSection({
        Name = "🚀 SERVER-SIDE BRING PLAYERS"
    })

    -- FIXED: Bring All Players (Server-side)
    PlayerTab:AddButton({
        Name = "🎯 BRING ALL PLAYERS TO ME",
        Callback = function()
            local localChar = game.Players.LocalPlayer.Character
            if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
                OrionLib:MakeNotification({
                    Name = "❌ Error",
                    Content = "Your character is not loaded!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
                return
            end

            OrionLib:MakeNotification({
                Name = "🚀 Bringing All Players",
                Content = "Using server-side teleportation...",
                Image = "rbxassetid://7072717775",
                Time = 3
            })

            local successCount = bringAllPlayersToMe()
            
            OrionLib:MakeNotification({
                Name = "✅ Success",
                Content = "Brought " .. successCount .. " players to you!",
                Image = "rbxassetid://7072717775",
                Time = 4
            })
        end
    })

    -- FIXED: Bring Specific Player (Server-side)
    PlayerTab:AddButton({
        Name = "🎯 BRING SELECTED PLAYER",
        Callback = function()
            if SelectedPlayer == "None" then
                OrionLib:MakeNotification({
                    Name = "❌ Error",
                    Content = "Please select a player first!",
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
                return
            end

            local success = bringPlayerToMe(SelectedPlayer)
            
            if success then
                OrionLib:MakeNotification({
                    Name = "✅ Success",
                    Content = "Brought " .. SelectedPlayer .. " to you!",
                    Image = "rbxassetid://7072717775",
                    Time = 4
                })
            else
                OrionLib:MakeNotification({
                    Name = "❌ Failed",
                    Content = "Could not bring " .. SelectedPlayer,
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- Flood Ping Feature
    PlayerTab:AddSection({
        Name = "🌊 Flood Features"
    })

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
                
                for i = 1, 100 do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                        "/w " .. SelectedPlayer .. " PING_FLOOD_" .. i .. " " .. string.rep("🚀", 10),
                        "All"
                    )
                    wait(0.1)
                end
                
                OrionLib:MakeNotification({
                    Name = "🌊 Flood Ping Complete",
                    Content = "Finished flooding " .. SelectedPlayer,
                    Image = "rbxassetid://7072717775",
                    Time = 3
                })
            end
        end
    })

    -- =============================================
    -- TAB 3: SERVER CONTROL TAB
    -- =============================================
    local ServerTab = Window:MakeTab({
        Name = "Server Control",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    ServerTab:AddSection({
        Name = "💥 Server Actions"
    })

    ServerTab:AddButton({
        Name = "💥 Crash Server (Heavy)",
        Callback = function()
            OrionLib:MakeNotification({
                Name = "💥 Starting Server Crash",
                Content = "Heavy crash sequence initiated...",
                Image = "rbxassetid://7072717775",
                Time = 3
            })
            
            -- Mass part creation
            for i = 1, 200 do
                local part = Instance.new("Part")
                part.Parent = workspace
                part.Size = Vector3.new(50, 50, 50)
                part.Position = Vector3.new(math.random(-500, 500), math.random(100, 500), math.random(-500, 500))
                part.Anchored = true
                part.Material = Enum.Material.Neon
            end
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

    SettingsTab:AddParagraph("🎉 Anggazyy Hub", "✨ Version 3.1\n💜 Fixed Server-Side Bring Players\n🎯 Real Character Teleportation")

    -- Initialize Orion
    OrionLib:Init()

    -- Apply purple theme
    for _, tab in next, OrionLib:GetWindow().Tabs do
        for _, section in next, tab.Sections do
            section.Color = Color3.fromRGB(147, 112, 219)
        end
    end

    -- Hide window initially
    if Window then
        Window:Toggle()
    end

    -- Button click event
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
        local fullText = "ANGGAZYY HUB V3.1"
        local currentText = ""
        
        for i = 1, #fullText do
            currentText = string.sub(fullText, 1, i)
            LoadingLabel.Text = currentText
            LoadingBarFill.Size = UDim2.new((i / #fullText), 0, 1, 0)
            wait(speed)
        end
    end

    spawn(function()
        animateText(0.1)
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
            Name = "💜 Fixed Bring Players!",
            Content = "Now using server-side teleportation!",
            Image = "rbxassetid://7072717775",
            Time = 4
        })
        
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

-- Start loading screen
showLoadingScreen()
