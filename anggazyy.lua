--// 🧭 Anggazyy Hub - Fish It (Rayfield Ultimate UI)
--// Dibuat & disempurnakan oleh Anggazyy

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

------------------------------------------------------------
-- 🧩 VARIABLES
------------------------------------------------------------
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local autoFishEnabled = false
local coordinateDisplay
local statusParagraph

------------------------------------------------------------
-- 💥 HAPUS LOGO 100 MONEY
------------------------------------------------------------
task.spawn(function()
	while task.wait(1) do
		for _, v in ipairs(game:GetService("CoreGui"):GetDescendants()) do
			if v:IsA("ImageLabel") or v:IsA("ImageButton") or v:IsA("TextLabel") then
				if string.find(string.lower(v.Name), "money") or string.find(string.lower(v.Text or ""), "money") then
					v.Visible = false
				end
			end
		end
	end
end)

------------------------------------------------------------
-- ⚙️ WINDOW SETUP
------------------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "Anggazyy Hub - Fish It",
	Icon = 0,
	LoadingTitle = "Anggazyy Hub",
	LoadingSubtitle = "Rayfield UI by Anggazyy",
	Theme = "Dark",
	ShowText = "AnggazyyHub",
	ToggleUIKeybind = Enum.KeyCode.K,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AnggazyyHubConfig",
		FileName = "FishIt"
	}
})

------------------------------------------------------------
-- 🎣 AUTO FISHING FUNCTION
------------------------------------------------------------
local function startAutoFish()
	autoFishEnabled = true
	statusParagraph:Set("Status: ✅ Enabled")
	Rayfield:Notify({
		Title = "🎣 Auto Fishing",
		Content = "Auto Fishing has been activated.",
		Duration = 2
	})

	task.spawn(function()
		while autoFishEnabled do
			pcall(function()
				local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
				local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
				updateFishing:InvokeServer(true)
			end)
			task.wait(4)
		end
	end)
end

local function stopAutoFish()
	autoFishEnabled = false
	statusParagraph:Set("Status: ⛔ Disabled")
	Rayfield:Notify({
		Title = "🎣 Auto Fishing",
		Content = "Auto Fishing stopped.",
		Duration = 2
	})
	pcall(function()
		local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
		local updateFishing = Net:RemoteFunction("UpdateAutoFishingState")
		updateFishing:InvokeServer(false)
	end)
end

------------------------------------------------------------
-- 📋 TAB: INFO & GUIDE
------------------------------------------------------------
local InfoTab = Window:CreateTab("📘 Info & Guide")

InfoTab:CreateParagraph({
	Title = "🌟 FITUR UTAMA",
	Content = [[
🎣 Auto Fishing (No Error)
📍 Coordinate Display
⚡ Player Boost
🚀 Quick Teleport
🧭 Modern UI with Animation
]]
})

InfoTab:CreateParagraph({
	Title = "🧠 PETUNJUK",
	Content = [[
1. Klik tab 🎣 Auto Fish → tekan Toggle
2. Gunakan Teleport dan Boost sesuai kebutuhan
3. Tekan [K] untuk hide/show UI
4. Gunakan versi ini untuk stabilitas maksimum
]]
})

------------------------------------------------------------
-- 🎣 TAB: AUTO FISH
------------------------------------------------------------
local FishTab = Window:CreateTab("🎣 Auto Fish")

FishTab:CreateToggle({
	Name = "🎣 Enable Auto Fishing",
	CurrentValue = false,
	Flag = "AutoFishToggle",
	Callback = function(Value)
		if Value then
			startAutoFish()
		else
			stopAutoFish()
		end
	end
})

statusParagraph = FishTab:CreateParagraph({Title = "Status:", Content = "Status: ⛔ Disabled"})

------------------------------------------------------------
-- 📍 TAB: TELEPORT
------------------------------------------------------------
local TeleportTab = Window:CreateTab("📍 Teleport")

local teleportList = {
	{"🏠 Spawn", Vector3.new(0, 10, 0)},
	{"🌴 Beach", Vector3.new(320, 15, -200)},
	{"🌋 Volcano", Vector3.new(500, 180, 200)},
	{"🌆 City Center", Vector3.new(100, 40, 100)},
}

for _, loc in ipairs(teleportList) do
	TeleportTab:CreateButton({
		Name = loc[1],
		Callback = function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc[2])
				Rayfield:Notify({
					Title = "📍 Teleport",
					Content = "Moved to " .. loc[1],
					Duration = 2
				})
			end
		end
	})
end

TeleportTab:CreateToggle({
	Name = "🧭 Show Coordinates",
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			if coordinateDisplay then coordinateDisplay:Destroy() end
			local gui = Instance.new("ScreenGui", game.CoreGui)
			local label = Instance.new("TextLabel", gui)
			label.Size = UDim2.new(0, 160, 0, 25)
			label.Position = UDim2.new(0.5, -80, 0, 10)
			label.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 12
			label.Text = "X: 0 | Y: 0 | Z: 0"
			Instance.new("UICorner", label).CornerRadius = UDim.new(0.2, 0)
			coordinateDisplay = gui

			task.spawn(function()
				while gui and gui.Parent do
					local char = player.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						local pos = char.HumanoidRootPart.Position
						label.Text = string.format("X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
					end
					task.wait(0.1)
				end
			end)
		else
			if coordinateDisplay then coordinateDisplay:Destroy() end
		end
	end
})

------------------------------------------------------------
-- 👤 TAB: PLAYER
------------------------------------------------------------
local PlayerTab = Window:CreateTab("👤 Player")

PlayerTab:CreateSlider({
	Name = "🏃 Walk Speed",
	Range = {16, 120},
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
	Range = {50, 250},
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
-- 🌈 EXTRA MODERN DESIGN (LAYOUT + GRADIENT)
------------------------------------------------------------
local TweenService = game:GetService("TweenService")
task.spawn(function()
	while true do
		local color1 = Color3.fromRGB(85, 0, 255)
		local color2 = Color3.fromRGB(150, 0, 255)
		local tween = TweenService:Create(Window.UIElements.MainFrame.Background, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = color2})
		tween:Play()
		task.wait(6)
	end
end)

------------------------------------------------------------
-- ✅ LOAD CONFIG
------------------------------------------------------------
Rayfield:LoadConfiguration()
