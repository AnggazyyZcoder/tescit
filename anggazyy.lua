--// 🌙 Anggazyy Hub - Fish It | Rayfield Modern Edition
--// Developer: Anggazyy

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Variables
local player = game.Players.LocalPlayer
local coordinateDisplay = nil
local autoFishEnabled = false
local statusLabel = nil

------------------------------------------------------------
-- 🪄 WINDOW CONFIGURATION (Modern)
------------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Anggazyy Hub - Fish It",
    Icon = 0, -- Tidak pakai logo
    LoadingTitle = "Anggazyy Hub",
    LoadingSubtitle = "Fish It Automation System",
    ShowText = "AnggazyyHub",
    Theme = "Ocean", -- Tema modern (bisa ubah: Dark, Default, Light, Ocean, Midnight, Mocha)
    ToggleUIKeybind = "K",

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AnggazyyHubConfig",
        FileName = "FishIt_Modern"
    }
})

------------------------------------------------------------
-- ✨ UI NOTIFICATION STYLE
------------------------------------------------------------
local function Notify(title, text)
	Rayfield:Notify({
		Title = title,
		Content = text,
		Duration = 2
	})
end

------------------------------------------------------------
-- 🎣 AUTO FISH SYSTEM
------------------------------------------------------------
local function toggleAutoFish()
	autoFishEnabled = not autoFishEnabled
	if autoFishEnabled then
		Notify("🎣 Auto Fishing", "Auto Fishing Enabled!")
		statusLabel:Set("Status: ✅ Enabled")

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
		Notify("🎣 Auto Fishing", "Auto Fishing Disabled!")
		statusLabel:Set("Status: ❌ Disabled")
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
-- 📍 COORDINATE SYSTEM
------------------------------------------------------------
local function createCoordinateDisplay()
	if coordinateDisplay then coordinateDisplay:Destroy() end
	local CoordGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local Corner = Instance.new("UICorner")
	local Stroke = Instance.new("UIStroke")
	local Gradient = Instance.new("UIGradient")

	CoordGui.Name = "CoordinateDisplay"
	CoordGui.Parent = game.CoreGui
	Frame.Parent = CoordGui
	Frame.Size = UDim2.new(0, 170, 0, 40)
	Frame.Position = UDim2.new(0.5, -85, 0.05, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
	Corner.Parent = Frame
	Corner.CornerRadius = UDim.new(0.25, 0)
	Stroke.Parent = Frame
	Stroke.Color = Color3.fromRGB(138, 43, 226)
	Stroke.Thickness = 1.8

	Gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 0, 180)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
	}
	Gradient.Rotation = 45
	Gradient.Parent = Frame

	Label.Parent = Frame
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 12
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
-- 📘 TAB 1: INFO & GUIDE
------------------------------------------------------------
local InfoTab = Window:CreateTab("📘 Info & Guide")

InfoTab:CreateParagraph({
	Title = "🌟 Selamat Datang di Anggazyy Hub",
	Content = "UI versi modern dengan efek gradasi & layout smooth. Script ini dibuat khusus untuk game **Fish It!** oleh Anggazyy."
})

InfoTab:CreateParagraph({
	Title = "📋 Fitur Utama",
	Content = "🎣 Auto Fishing\n📍 Koordinat Real-time\n⚡ Player Boost\n🚀 Teleport cepat\n🧭 Tampilan Modern"
})

InfoTab:CreateParagraph({
	Title = "⚠️ Peringatan",
	Content = "Gunakan dengan bijak. Script ini bukan untuk disalahgunakan."
})

------------------------------------------------------------
-- 🎣 TAB 2: AUTO FISH
------------------------------------------------------------
local FishTab = Window:CreateTab("🎣 Auto Fish")

FishTab:CreateSection("Auto Fishing Control")

FishTab:CreateButton({
	Name = "🎣 Toggle Auto Fishing",
	Callback = toggleAutoFish
})

statusLabel = FishTab:CreateParagraph({
	Title = "Status:",
	Content = "Status: ❌ Disabled"
})

FishTab:CreateParagraph({
	Title = "ℹ️ Tentang Fitur",
	Content = "Auto Fishing akan secara otomatis melempar pancing, menunggu, dan menangkap ikan secara berulang tanpa aksi manual."
})

------------------------------------------------------------
-- 📍 TAB 3: TELEPORT
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
				Notify("✨ Teleport Sukses", "Berhasil ke " .. loc[1])
			end
		end
	})
end

TeleportTab:CreateToggle({
	Name = "📍 Tampilkan Koordinat",
	CurrentValue = false,
	Flag = "CoordDisplay",
	Callback = function(Value)
		if Value then
			createCoordinateDisplay()
			Notify("📍 Koordinat", "Tampilan koordinat aktif!")
		else
			if coordinateDisplay then coordinateDisplay:Destroy() end
			Notify("📍 Koordinat", "Tampilan koordinat dimatikan.")
		end
	end
})

------------------------------------------------------------
-- 👤 TAB 4: PLAYER SETTINGS
------------------------------------------------------------
local PlayerTab = Window:CreateTab("👤 Player")

PlayerTab:CreateSection("⚡ Player Boost")

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
-- 🪶 FLOATING BUTTON (Minimalist Style)
------------------------------------------------------------
local FloatUI = Instance.new("ScreenGui", game.CoreGui)
FloatUI.Name = "AnggazyyFloatUI"
local Button = Instance.new("ImageButton", FloatUI)
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(0, 15, 0.5, -25)
Button.Image = "rbxassetid://7072717775"
Button.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
Button.AutoButtonColor = false
local Corner = Instance.new("UICorner", Button)
Corner.CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", Button)
Stroke.Color = Color3.fromRGB(140, 90, 255)
Stroke.Thickness = 2

Button.MouseButton1Click:Connect(function()
	Rayfield:ToggleUI()
end)

------------------------------------------------------------
-- 🚀 LOADING SCREEN (Smooth Fade)
------------------------------------------------------------
local LoadingGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", LoadingGui)
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "ANGGAZYY HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.Position = UDim2.new(0.5, 0, 0.5, 0)

for i = 1, 25 do
	Frame.BackgroundTransparency = i / 25
	Title.TextTransparency = i / 25
	task.wait(0.05)
end

LoadingGui:Destroy()
Rayfield:LoadConfiguration()
