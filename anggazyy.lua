local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Animation function untuk text
local function animateText(label, text, speed)
    local currentText = ""
    for i = 1, #text do
        currentText = string.sub(text, 1, i)
        label:SetText(currentText)
        wait(speed)
    end
end

-- Animation function untuk window
local function smoothOpen(window)
    for i = 0, 1, 0.05 do
        window.Transparency = 1 - i
        wait(0.01)
    end
end

-- Create main window dengan animasi
local Window = OrionLib:MakeWindow({
    Name = "Anggazyy Hub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "AnggazyyConfig",
    IntroEnabled = false -- Kita buat custom intro
})

-- Custom intro animation
local IntroTab = Window:MakeTab({
    Name = "Intro",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Label untuk animasi text
local introLabel = IntroTab:AddLabel("")
local loadingLabel = IntroTab:AddLabel("")

-- Animasi intro
spawn(function()
    animateText(introLabel, "Welcome to Anggazyy Hub", 0.05)
    wait(0.5)
    animateText(loadingLabel, "Loading awesome features...", 0.03)
    wait(1)
    
    -- Pindah ke tab utama setelah animasi selesai
    Window:SelectTab(1)
end)

-- Main Tab dengan animasi smooth
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Section untuk Player
local PlayerSection = MainTab:AddSection({
    Name = "Player"
})

PlayerSection:AddButton({
    Name = "Fly Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGui/main/FlyGui.txt"))()
        OrionLib:MakeNotification({
            Name = "Fly Activated!",
            Content = "Fly script has been executed",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

PlayerSection:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

PlayerSection:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "power",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

-- Section untuk Game
local GameSection = MainTab:AddSection({
    Name = "Game"
})

GameSection:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        OrionLib:MakeNotification({
            Name = "Infinite Yield Loaded!",
            Content = "FE Admin Commands activated",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

GameSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        getgenv().Noclip = Value
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Value and 11 or 1)
            end
        end
    end
})

-- Section untuk Visual
local VisualSection = MainTab:AddSection({
    Name = "Visual"
})

VisualSection:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        -- ESP color change logic here
    end
})

VisualSection:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            -- ESP activation logic
            OrionLib:MakeNotification({
                Name = "ESP Activated",
                Content = "Player ESP is now enabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            -- ESP deactivation logic
            OrionLib:MakeNotification({
                Name = "ESP Deactivated",
                Content = "Player ESP is now disabled",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
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

SettingsTab:AddParagraph("Credits", "Anggazyy Hub v1.0\nCreated with ❤️ by Anggazyy")

-- Custom minimize function
local function setupMinimizeButton()
    -- This would require modifying the Orion library directly
    -- For now, we'll use the built-in toggle bind
end

-- Initialize dengan efek smooth
spawn(function()
    wait(0.5)
    OrionLib:Init()
    
    -- Notification welcome
    OrionLib:MakeNotification({
        Name = "Welcome!",
        Content = "Anggazyy Hub successfully loaded!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end)

-- Auto noclip loop
spawn(function()
    while wait(0.1) do
        if getgenv().Noclip then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)
