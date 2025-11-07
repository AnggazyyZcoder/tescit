local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initialize Fluent dengan ukuran lebih kecil
local Window = Fluent:CreateWindow({
    Title = "Anggazyy Hub " .. Fluent.Version,
    SubTitle = "by Anggazyy",
    TabWidth = 120,
    Size = UDim2.fromOffset(400, 320), -- Diperkecil dari 580x460
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Variables
local player = game.Players.LocalPlayer
local autoFishEnabled = false
local coordinateDisplay = nil
local statusText = "Disabled ❌"

-- Options for SaveManager
local Options = Fluent.Options

-- Main Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Auto Fish", Icon = "" }),
    Teleport = Window:AddTab({ Title = "📍 Teleport", Icon = "" }),
    Player = Window:AddTab({ Title = "👤 Player", Icon = "" })
}

-- Auto Fish Section
Tabs.Main:AddParagraph({
    Title = "Auto Fishing System",
    Content = "Automatically fish for you."
})

local Toggle = Tabs.Main:AddToggle("AutoFishToggle", {
    Title = "Enable Auto Fishing",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if autoFishEnabled then
            statusText = "Enabled ✅"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto Fishing enabled!",
                Duration = 2
            })
            
            -- Enable auto fishing
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(true)
            end)
        else
            statusText = "Disabled ❌"
            Fluent:Notify({
                Title = "🎣 Auto Fishing",
                Content = "Auto Fishing disabled!",
                Duration = 2
            })
            
            -- Disable auto fishing
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = require(ReplicatedStorage.Packages.Net)
                local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
                updateFishing:InvokeServer(false)
            end)
        end
        Options.StatusLabel:SetText("Status: " .. statusText)
    end
})

Options.StatusLabel = Tabs.Main:AddParagraph({
    Title = "Status:",
    Content = statusText
})

Tabs.Main:AddButton({
    Title = "Toggle Auto Fishing",
    Description = "Quick toggle",
    Callback = function()
        Toggle:Set(not autoFishEnabled)
    end
})

-- Teleport Section
Tabs.Teleport:AddParagraph({
    Title = "Teleport Locations",
    Content = "Teleport to various locations."
})

local teleportLocations = {
    {"Spawn Point", Vector3.new(0, 10, 0)},
    {"Mountain Top", Vector3.new(200, 150, 200)},
    {"Beach Side", Vector3.new(300, 15, -200)},
    {"City Center", Vector3.new(100, 30, 100)}
}

for i, location in ipairs(teleportLocations) do
    Tabs.Teleport:AddButton({
        Title = location[1],
        Description = "Teleport to " .. location[1],
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(location[2])
                Fluent:Notify({
                    Title = "✨ Teleported!",
                    Content = "To " .. location[1],
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "❌ Error",
                    Content = "Character not found!",
                    Duration = 2
                })
            end
        end
    })
end

-- Coordinate Display Toggle
Tabs.Teleport:AddToggle("CoordToggle", {
    Title = "Show Coordinates",
    Default = false,
    Callback = function(Value)
        if Value then
            CreateCoordinateDisplay()
            Fluent:Notify({
                Title = "📍 Coordinates",
                Content = "Coordinate display enabled!",
                Duration = 2
            })
        else
            if coordinateDisplay then
                coordinateDisplay:Destroy()
                coordinateDisplay = nil
            end
            Fluent:Notify({
                Title = "📍 Coordinates",
                Content = "Coordinate display disabled!",
                Duration = 2
            })
        end
    end
})

-- Player Section (Simplified)
Tabs.Player:AddParagraph({
    Title = "Player Settings",
    Content = "Modify player properties."
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
    Max = 150,
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
        player.Character:BreakJoints()
        Fluent:Notify({
            Title = "🔄 Character Reset",
            Content = "Character has been reset!",
            Duration = 2
        })
    end
})

-- Coordinate Display Function
function CreateCoordinateDisplay()
    if coordinateDisplay then coordinateDisplay:Destroy() end
    
    local CoordGui = Instance.new("ScreenGui")
    local CoordFrame = Instance.new("Frame")
    local CoordLabel = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    CoordGui.Name = "CoordinateDisplay"
    CoordGui.Parent = game.CoreGui
    CoordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    CoordFrame.Parent = CoordGui
    CoordFrame.Size = UDim2.new(0, 140, 0, 35) -- Diperkecil
    CoordFrame.Position = UDim2.new(0.5, -70, 0, 5) -- Diposisikan lebih atas
    CoordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    CoordFrame.BackgroundTransparency = 0.3
    CoordFrame.BorderSizePixel = 0
    
    UICorner.Parent = CoordFrame
    UICorner.CornerRadius = UDim.new(0, 6)
    
    UIStroke.Parent = CoordFrame
    UIStroke.Color = Color3.fromRGB(100, 100, 200)
    UIStroke.Thickness = 1.5
    
    CoordLabel.Parent = CoordFrame
    CoordLabel.Size = UDim2.new(1, 0, 1, 0)
    CoordLabel.BackgroundTransparency = 1
    CoordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CoordLabel.TextSize = 11 -- Diperkecil
    CoordLabel.Font = Enum.Font.GothamMedium
    CoordLabel.TextStrokeTransparency = 0.8
    
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

-- Floating Icon yang lebih kecil
local function CreateFloatingIcon()
    local ScreenGui = Instance.new("ScreenGui")
    local OpenButton = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "AnggazyyHubUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    OpenButton.Parent = ScreenGui
    OpenButton.Size = UDim2.new(0, 40, 0, 40) -- Diperkecil
    OpenButton.Position = UDim2.new(0, 10, 0.5, -20) -- Diposisikan lebih kiri atas
    OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    OpenButton.BackgroundTransparency = 0.1
    OpenButton.AutoButtonColor = false
    OpenButton.Image = "rbxassetid://7072717775"
    OpenButton.ScaleType = Enum.ScaleType.Fit
    OpenButton.BorderSizePixel = 0

    UICorner.Parent = OpenButton
    UICorner.CornerRadius = UDim.new(0.3, 0)
    
    UIStroke.Parent = OpenButton
    UIStroke.Color = Color3.fromRGB(138, 43, 226)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.3

    OpenButton.MouseButton1Click:Connect(function()
        Window:Dialog({
            Title = "Anggazyy Hub",
            Content = "Welcome! Use RightShift to toggle UI.",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function()
                        -- Do nothing, just close
                    end
                }
            }
        })
    end)

    return OpenButton
end

-- Loading notifications yang lebih cepat
task.spawn(function()
    task.wait(1)
    Fluent:Notify({
        Title = "🔧 Initializing",
        Content = "Loading features...",
        Duration = 1.5
    })
    
    task.wait(1.5)
    Fluent:Notify({
        Title = "✅ Ready",
        Content = "Anggazyy Hub loaded!",
        Duration = 2
    })
end)

-- Create floating icon
CreateFloatingIcon()

-- Select first tab
Window:SelectTab(1)

-- Add settings tab (simplified)
Window:AddTab({ Title = "Settings", Icon = "settings" })

-- SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentAnggazyy")
SaveManager:SetFolder("FluentAnggazyy/specific-game")

-- Build interface sections
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Anggazyy Hub",
    Content = "UI Loaded! Size: 400x320",
    Duration = 3
})
