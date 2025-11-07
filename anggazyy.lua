-- FULL SCRIPT (dengan AutoFish yang diperbaiki)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Floating Icon (tetap seperti sebelumnya)
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
-- 🐟 AUTO FISH - Robust Implementation
------------------------------------------------------------
local autoFishEnabled = false
local autoFishLoop = nil
local statusParagraph = nil

-- Helper: safe-get Replion Data client (if available)
local function getReplionData()
    local success, Replion = pcall(function()
        return require(game:GetService("ReplicatedStorage").Packages.Replion)
    end)
    if not success or not Replion or not Replion.Client then
        return nil
    end
    local ok, data = pcall(function() return Replion.Client:WaitReplion("Data", 2) end)
    if ok then return data end
    return nil
end

-- Helper: attempt to toggle via RemoteFunction name
local function tryInvokeRemoteFunction(name, value)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ok, Net = pcall(function() return require(ReplicatedStorage.Packages.Net) end)
    if not ok or not Net then return false, "no Net package" end
    local success, err = pcall(function()
        local rf = Net:RemoteFunction(name)
        if rf then
            rf:InvokeServer(value)
            return true
        end
    end)
    if success then return true end
    return false, err
end

-- Helper: attempt to fire RemoteEvent with given name
local function tryFireRemoteEvent(name, value)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ok, Net = pcall(function() return require(ReplicatedStorage.Packages.Net) end)
    if not ok or not Net then return false, "no Net package" end
    local success, err = pcall(function()
        local re = Net:RemoteEvent(name)
        if re then
            re:FireServer(value)
            return true
        end
    end)
    if success then return true end
    return false, err
end

-- Helper: try click the in-game Auto GUI button if present
local function tryClickAutoGui()
    -- common path used earlier in decompiled: PlayerGui.HUD.Frame.Small Buttons.Auto
    local char = player.Character
    local ok, res = pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return false end
        local hud = gui:FindFirstChild("HUD")
        if not hud then return false end
        local frame = hud:FindFirstChild("Frame")
        if not frame then return false end
        local small = frame:FindFirstChild("Small Buttons")
        if not small then return false end
        local auto = small:FindFirstChild("Auto")
        if not auto then return false end
        -- if it's a TextButton/ImageButton, we can simulate click by firing MouseButton1Click
        local btn = auto:FindFirstChildWhichIsA("ImageButton") or auto:FindFirstChildWhichIsA("TextButton") or auto
        if btn and btn:IsA("GuiButton") then
            -- fire click
            pcall(function() btn.MouseButton1Click:Fire() end)
            return true
        end
        return false
    end)
    if ok and res then return true end
    return false
end

-- Update Orion status via Paragraph API (safe)
local function setStatusUI(enabled)
    if not statusParagraph then return end
    local content = enabled and "🟢 Enabled" or "🔴 Disabled"
    -- Orion paragraph widgets usually expose :Set or :Update; many variants exist.
    -- We'll try common methods safely:
    pcall(function()
        if statusParagraph.Set then
            statusParagraph:Set({ Title = "Status:", Content = content })
            return
        end
        if statusParagraph.SetText then
            statusParagraph:SetText(content)
            return
        end
        if statusParagraph.Update then
            statusParagraph:Update(content)
            return
        end
        -- fallback: try raw property if underlying object available
        if statusParagraph.Instance and statusParagraph.Instance:IsA("TextLabel") then
            statusParagraph.Instance.Text = content
        end
    end)
end

-- Main toggle function: tries multiple ways to enable/disable auto fishing
local function toggleAutoFish()
    autoFishEnabled = not autoFishEnabled
    setStatusUI(autoFishEnabled)

    if autoFishEnabled then
        OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Attempting to enable...", Time = 2 })
        -- Start loop that will attempt to keep auto enabled
        if autoFishLoop then
            -- stop previous loop
            autoFishLoop = nil
        end
        autoFishLoop = task.spawn(function()
            while autoFishEnabled do
                local did = false

                -- 1) Try RemoteFunction "UpdateAutoFishingState"
                local ok1, e1 = pcall(function()
                    did = tryInvokeRemoteFunction("UpdateAutoFishingState", true) or did
                end)

                -- 2) Try RemoteEvent with common names (server implementers vary)
                if not did then
                    local names = {"UpdateAutoFishingState", "ToggleAutoFishing", "SetAutoFishing", "AutoFishing"}
                    for _, nm in ipairs(names) do
                        local ok, res = pcall(function() return tryFireRemoteEvent(nm, true) end)
                        if ok and res then
                            did = true
                            break
                        end
                    end
                end

                -- 3) Try clicking in-game GUI Auto button (client GUI)
                if not did then
                    local ok, res = pcall(function() return tryClickAutoGui() end)
                    if ok and res then did = true end
                end

                -- 4) If Replion Data available, try to call UpdateAutoFishingState via RemoteFunction again referencing package
                if not did then
                    pcall(function()
                        local data = getReplionData()
                        if data then
                            -- attempt again via Net package invocation
                            did = tryInvokeRemoteFunction("UpdateAutoFishingState", true) or did
                        end
                    end)
                end

                -- Feedback
                if did then
                    OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Enable request sent", Time = 2 })
                else
                    OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Enable request failed (see console)", Time = 3 })
                    warn("[AutoFish] All enable attempts failed. Remote names tried: UpdateAutoFishingState, ToggleAutoFishing, SetAutoFishing, AutoFishing. Also tried clicking GUI.")
                end

                -- wait to avoid spam (server may rate-limit)
                task.wait(4)
            end
            -- on loop end, ensure disabling request sent
            pcall(function()
                tryInvokeRemoteFunction("UpdateAutoFishingState", false)
                for _, nm in ipairs({"UpdateAutoFishingState", "ToggleAutoFishing", "SetAutoFishing", "AutoFishing"}) do
                    tryFireRemoteEvent(nm, false)
                end
                tryClickAutoGui()
            end)
        end)
    else
        OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Attempting to disable...", Time = 2 })
        -- stop loop
        autoFishEnabled = false
        -- autoFishLoop will exit by checking flag
        -- send a disable request once
        task.spawn(function()
            local did = false
            pcall(function() did = tryInvokeRemoteFunction("UpdateAutoFishingState", false) or did end)
            if not did then
                for _, nm in ipairs({"UpdateAutoFishingState", "ToggleAutoFishing", "SetAutoFishing", "AutoFishing"}) do
                    pcall(function() if tryFireRemoteEvent(nm, false) then did = true end end)
                end
            end
            pcall(function() tryClickAutoGui() end)
            if did then
                OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Disable request sent", Time = 2 })
            else
                OrionLib:MakeNotification({ Name = "🎣 Auto Fishing", Content = "Disable request may have failed", Time = 3 })
                warn("[AutoFish] Disable attempts may have failed.")
            end
        end)
    end
end

------------------------------------------------------------
-- KOORDINAT (sama seperti sebelumnya)
------------------------------------------------------------
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

------------------------------------------------------------
-- UI CREATION (Orion)
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

    -- Auto Fish Tab
    local AutoTab = Window:MakeTab({
        Name = "🎣 Auto Fish",
        Icon = "rbxassetid://7072717775",
        PremiumOnly = false
    })

    AutoTab:AddSection({ Name = "Auto Fishing Control" })

    AutoTab:AddButton({
        Name = "🎣 Toggle Auto Fishing",
        Callback = function()
            toggleAutoFish()
        end
    })

    -- Add paragraph and keep reference
    statusParagraph = AutoTab:AddParagraph("Status:", "🔴 Disabled")

    -- Teleport tab (ringkas)
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
-- LOADING SCREEN (ringkas)
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

    task.wait(1.2)
    LoadingGui:Destroy()
    createMainUI()
end

-- Start
showLoadingScreen()
