local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Floating Open/Close Button
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "FloatHub"

OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 100, 0, 40)
OpenButton.Position = UDim2.new(0, 10, 0.5, -20)
OpenButton.Text = "🔥 OPEN MENU"
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.BorderSizePixel = 0
OpenButton.AutoButtonColor = true

local MainWindow = OrionLib:MakeWindow({
    Name = "🔥 Ultimate Hub V2",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionConfig",
    IntroEnabled = true,
    IntroText = "ULTIMATE HUB"
})

-- Main Tab
local MainTab = MainWindow:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Player Tab  
local PlayerTab = MainWindow:MakeTab({
    Name = "Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Server Tab
local ServerTab = MainWindow:MakeTab({
    Name = "Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Auto Close window on init
MainWindow:Hide()

-- Toggle Window Function
local WindowVisible = false

OpenButton.MouseButton1Click:Connect(function()
    if WindowVisible then
        MainWindow:Hide()
        OpenButton.Text = "🔥 OPEN MENU"
        WindowVisible = false
    else
        MainWindow:Show()
        OpenButton.Text = "❌ CLOSE MENU"
        WindowVisible = true
    end
end)

-- MAIN TAB CONTENT
MainTab:AddButton({
    Name = "Fly Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGui/main/FlyGui.lua"))()
    end
})

MainTab:AddButton({
    Name = "Infinite Yield FE",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

MainTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        getgenv().Noclip = Value
        game:GetService('RunService').Stepped:Connect(function()
            if Noclip and game.Players.LocalPlayer.Character then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
})

-- PLAYER TAB CONTENT
local SelectedPlayer = "None"
local PlayerDropdown = PlayerTab:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = {"None"},
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

-- Update Players Function
local function UpdatePlayerList()
    local Players = {}
    table.insert(Players, "None")
    
    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= game.Players.LocalPlayer then
            table.insert(Players, v.Name)
        end
    end
    
    PlayerDropdown:Refresh(Players, true)
end

UpdatePlayerList()
game:GetService("Players").PlayerAdded:Connect(UpdatePlayerList)
game:GetService("Players").PlayerRemoving:Connect(UpdatePlayerList)

PlayerTab:AddButton({
    Name = "🔫 Flood Ping Player",
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "None" then
            for i = 1, 200 do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                    "/w " .. SelectedPlayer .. " PING " .. string.rep("FLOOD ", 10),
                    "All"
                )
                wait(0.05)
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "🚀 Bring All To Me",
    Callback = function()
        local LocalPlayer = game.Players.LocalPlayer
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
})

-- SERVER TAB CONTENT
ServerTab:AddButton({
    Name = "💥 Crash Server (Heavy)",
    Callback = function()
        for i = 1, 500 do
            local Part = Instance.new("Part")
            Part.Parent = workspace
            Part.Size = Vector3.new(50, 50, 50)
            Part.Position = Vector3.new(math.random(-500, 500), math.random(100, 500), math.random(-500, 500))
            Part.Anchored = true
            Part.Material = Enum.Material.Neon
        end
    end
})

ServerTab:AddButton({
    Name = "🌪️ Server Lag",
    Callback = function()
        for i = 1, 300 do
            local Body = Instance.new("BodyPosition")
            Body.Parent = workspace
            Body.Position = Vector3.new(0, 10000, 0)
            wait(0.01)
        end
    end
})

ServerTab:AddButton({
    Name = "🗑️ Clear Workspace",
    Callback = function()
        for i, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") then
                v:Destroy()
            end
        end
    end
})

OrionLib:Init()

-- Make floating button draggable
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
