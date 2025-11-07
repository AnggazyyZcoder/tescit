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

------------------------------------------------------------
-- 🐟 AUTO FISH SYSTEM
------------------------------------------------------------
local autoFishEnabled = false
local autoFishConnection = nil
local statusLabel = nil

local function toggleAutoFish()
    autoFishEnabled = not autoFishEnabled
    if autoFishEnabled then
        OrionLib:MakeNotification({
            Name = "🎣 Auto Fishing",
            Content = "Auto Fishing Enabled!",
            Image = "rbxassetid://7072717775",
            Time = 2
        })
        if statusLabel then
            statusLabel.Text = "Status: Enabled"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end

        -- Jalankan fungsi auto fish
        task.spawn(function()
            while autoFishEnabled do
                pcall(function()
                    -- panggil event fishing sesuai sistem Replion bawaan Fish It
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Replion = require(ReplicatedStorage.Packages.Replion)
                    local Data = Replion.Client:WaitReplion("Data")
                    local Net = require(ReplicatedStorage.Packages.Net)
                    local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                    updateFishing:InvokeServer(true)
                end)
                task.wait(5) -- delay agar tidak spam, bisa ubah sesuai kebutuhan
            end
        end)
    else
        OrionLib:MakeNotification({
            Name = "🎣 Auto Fishing",
            Content = "Auto Fishing Disabled!",
            Image = "rbxassetid://7072717775",
            Time = 2
        })
        if statusLabel then
            statusLabel.Text = "Status: Disabled"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end

        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Replion = require(ReplicatedStorage.Packages.Replion)
            local Data = Replion.Client:WaitReplion("Data")
            local Net = require(ReplicatedStorage.Packages.Net)
            local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
            updateFishing:InvokeServer(false)
        end)
    end
end

------------------------------------------------------------
-- 📍 KOORDINAT
------------------------------------------------------------
local function createCoordinateDisplay()
    if coordinateDisplay then coordinateDisplay:Destroy() end
    local CoordGui = Instance.new("ScreenGui")
    local CoordFrame = Instance.new("Frame")
    local CoordLabel = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
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
    coordinateDisplay = CoordGui

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

------------------------------------------------------------
-- 💜 MAIN UI
------------------------------------------------------------
local function createMainUI()
    if uiInitialized then return end
    uiInitialized = true

    local Window = OrionLib:MakeWindow({
        Name = "Anggazyy Hub",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "AnggazyyConfig",
        IntroEnabled = false,
        Center = true
    })

    -- TAB AUTO FISH
    local AutoTab = Window:MakeTab({
        Name = "🎣 Auto Fish",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    AutoTab:AddSection({
        Name = "Auto Fishing Control"
    })

    AutoTab:AddButton({
        Name = "🎣 Toggle Auto Fishing",
        Callback = function()
            toggleAutoFish()
        end
    })

    statusLabel = AutoTab:AddParagraph("Status:", "Status: Disabled")
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

    -- TAB TELEPORT (seperti sebelumnya)
    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    TeleportTab:AddSection({Name = "📍 Teleport Locations"})
    local teleportLocations = {
        {"🏠 Spawn Point", Vector3.new(0, 10, 0)},
        {"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
        {"🏖️ Beach Side", Vector3.new(300, 15, -200)},
        {"🏙️ City Center", Vector3.new(100, 30, 100)},
    }
    for _, location in ipairs(teleportLocations) do
        TeleportTab:AddButton({
            Name = location[1],
            Callback = function()
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(location[2])
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

    TeleportTab:AddSection({Name = "⚙️ Utility"})
    TeleportTab:AddToggle({
        Name = "📍 Show Coordinates",
        Default = false,
        Callback = function(Value)
            if Value then
                createCoordinateDisplay()
            else
                if coordinateDisplay then coordinateDisplay:Destroy() end
            end
        end
    })

    OrionLib:Init()
    if Window then Window:Toggle() end
    OpenButton.Visible = true

    OpenButton.MouseButton1Click:Connect(function()
        if Window then Window:Toggle() end
    end)
end

------------------------------------------------------------
-- LOADING SCREEN
------------------------------------------------------------
local function showLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui", game.CoreGui)
    local Background = Instance.new("Frame", LoadingGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(20, 10, 30)

    local Label = Instance.new("TextLabel", Background)
    Label.Text = "ANGGAZYY HUB"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 24
    Label.AnchorPoint = Vector2.new(0.5, 0.5)
    Label.Position = UDim2.new(0.5, 0, 0.5, 0)

    task.wait(2)
    LoadingGui:Destroy()
    createMainUI()
end

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------
showLoadingScreen()
