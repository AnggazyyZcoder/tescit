-- // 🔮 Anggazyy Hub - Fish It (Rayfield Version)
-- // UI by Rayfield, Remade by Anggazyy

-- // Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local autoFishEnabled = false
local statusLabel = nil

------------------------------------------------------------
-- ⚙️ WINDOW SETUP
------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Anggazyy Hub - Fish It",
   Icon = 0,
   LoadingTitle = "Anggazyy Hub",
   LoadingSubtitle = "Fish It Automation",
   ShowText = "AnggazyyHub",
   Theme = "Dark", -- Bisa ganti ke "Default", "Light", "Ocean", dll
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AnggazyyHubConfig",
      FileName = "FishIt"
   }
})

------------------------------------------------------------
-- 🎣 AUTO FISHING
------------------------------------------------------------
local function toggleAutoFish()
	autoFishEnabled = not autoFishEnabled
	if autoFishEnabled then
		Rayfield:Notify({
			Title = "🎣 Auto Fishing",
			Content = "Auto Fishing Enabled!",
			Duration = 2
		})
		statusLabel:Set("Status: Enabled")

		task.spawn(function()
			while autoFishEnabled do
				pcall(function()
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local Replion = require(ReplicatedStorage.Packages.Replion)
					local Net = require(ReplicatedStorage.Packages.Net)
					local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
					updateFishing:InvokeServer(true)
				end)
				task.wait(5)
			end
		end)
	else
		Rayfield:Notify({
			Title = "🎣 Auto Fishing",
			Content = "Auto Fishing Disabled!",
			Duration = 2
		})
		statusLabel:Set("Status: Disabled")
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Replion = require(ReplicatedStorage.Packages.Replion)
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
	local Frame = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local Corner = Instance.new("UICorner")
	local Stroke = Instance.new("UIStroke")

	CoordGui.Name = "CoordinateDisplay"
	CoordGui.Parent = game.CoreGui
	Frame.Parent = CoordGui
	Frame.Size = UDim2.new(0, 150, 0, 40)
	Frame.Position = UDim2.new(0.5, -75, 0, 10)
	Frame.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
	Corner.Parent = Frame
	Corner.CornerRadius = UDim.new(0.2, 0)
	Stroke.Parent = Frame
	Stroke.Color = Color3.fromRGB(138, 43, 226)
	Stroke.Thickness = 1.5

	Label.Parent = Frame
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 11
	Label.Text = "X: 0 | Y: 0 | Z: 0"

	coordinateDisplay = CoordGui

	task.spawn(function()
		while CoordGui and CoordGui.Parent do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local pos = char.HumanoidRootPart.Position
				Label.Text = string.format("X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
			end
			task.wait(0.1)
		end
	end)
end

------------------------------------------------------------
-- 🧭 TAB: INFO
------------------------------------------------------------
local InfoTab = Window:CreateTab("📋 Info & Guide")

InfoTab:CreateParagraph({Title = "🌟 FITUR UTAMA", Content = [[
🎣 Auto Fishing
📍 Coordinate Display
⚡ Player Boost
🚀 Quick Teleport
]]})

InfoTab:CreateParagraph({Title = "📝 CARA PAKAI", Content = [[
1. Aktifkan Auto Fishing di Tab '🎣 Auto Fish'
2. Lihat koordinat di Tab '📍 Teleport'
3. Boost Player di Tab '👤 Player'
4. Teleport ke lokasi di Tab '📍 Teleport'
]]})

InfoTab:CreateParagraph({Title = "⚠️ PERINGATAN", Content = "Gunakan dengan bijak! Risiko ditanggung pengguna."})

------------------------------------------------------------
-- 🎣 TAB: AUTO FISH
------------------------------------------------------------
local FishTab = Window:CreateTab("🎣 Auto Fish")

FishTab:CreateButton({
	Name = "🎣 Toggle Auto Fishing",
	Callback = toggleAutoFish
})

statusLabel = FishTab:CreateParagraph({Title = "Status:", Content = "Status: Disabled"})

------------------------------------------------------------
-- 📍 TAB: TELEPORT
------------------------------------------------------------
local TeleportTab = Window:CreateTab("📍 Teleport")

local teleportLocations = {
	{"🏠 Spawn Point", Vector3.new(0, 10, 0)},
	{"⛰️ Mountain Top", Vector3.new(200, 150, 200)},
	{"🏖️ Beach Side", Vector3.new(300, 15, -200)},
	{"🏙️ City Center", Vector3.new(100, 30, 100)},
}

for _, loc in ipairs(teleportLocations) do
	TeleportTab:CreateButton({
		Name = loc[1],
		Callback = function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc[2])
				Rayfield:Notify({
					Title = "✨ Teleported!",
					Content = "Teleported to " .. loc[1],
					Duration = 2
				})
			end
		end
	})
end

TeleportTab:CreateToggle({
	Name = "📍 Show Coordinates",
	CurrentValue = false,
	Flag = "CoordDisplay",
	Callback = function(Value)
		if Value then
			createCoordinateDisplay()
			Rayfield:Notify({
				Title = "📍 Coordinates",
				Content = "Coordinate display enabled!",
				Duration = 2
			})
		else
			if coordinateDisplay then coordinateDisplay:Destroy() end
			Rayfield:Notify({
				Title = "📍 Coordinates",
				Content = "Coordinate display disabled!",
				Duration = 2
			})
		end
	end
})

------------------------------------------------------------
-- 👤 TAB: PLAYER
------------------------------------------------------------
local PlayerTab = Window:CreateTab("👤 Player")

PlayerTab:CreateSlider({
	Name = "🏃 Walk Speed",
	Range = {16, 100},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(Value)
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = Value
		end
	end
})

PlayerTab:CreateSlider({
	Name = "🦘 Jump Power",
	Range = {50, 200},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(Value)
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = Value
		end
	end
})

------------------------------------------------------------
-- ✨ FLOATING BUTTON (MINIMIZE / SHOW UI)
------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AnggazyyHubFloat"

local OpenButton = Instance.new("ImageButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
OpenButton.Image = "rbxassetid://7072717775"
OpenButton.AutoButtonColor = false
local Corner = Instance.new("UICorner", OpenButton)
Corner.CornerRadius = UDim.new(0.3, 0)

OpenButton.MouseButton1Click:Connect(function()
	Rayfield:ToggleUI()
end)

------------------------------------------------------------
-- 🚀 LOADING SCREEN
------------------------------------------------------------
local LoadingGui = Instance.new("ScreenGui", game.CoreGui)
local BG = Instance.new("Frame", LoadingGui)
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
local Label = Instance.new("TextLabel", BG)
Label.Size = UDim2.new(1, 0, 1, 0)
Label.Text = "ANGGAZYY HUB - FISH IT"
Label.Font = Enum.Font.GothamBold
Label.TextColor3 = Color3.new(1, 1, 1)
Label.TextScaled = true

task.wait(2)
LoadingGui:Destroy()
Rayfield:LoadConfiguration()
