--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (REFINED FINAL)
-- Rayfield UI + Lucide icons
-- Clean, modern, informative wording, AutoFish fixed & stable
-- Author: Anggazyy (UI & Logic refinement)
--//////////////////////////////////////////////////////////////////////////////////

-- CONFIGURATION
local AUTO_FISH_REMOTE_NAME = "UpdateAutoFishingState"
local NET_PACKAGES_FOLDER = "Packages"
local RAYFIELD_URL = 'https://sirius.menu/rayfield'
-- END CONFIG

-- SAFE LOAD RAYFIELD
local successLoad, Rayfield = pcall(function()
	return loadstring(game:HttpGet(RAYFIELD_URL))()
end)
if not successLoad or not Rayfield then
	warn("Rayfield gagal dimuat. Pastikan URL Rayfield dapat diakses.")
	return
end

-- SERVICES & VARS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local autoFishEnabled = false
local autoFishLoopThread
local coordinateGui
local statusParagraph
local currentSelectedMap

-- AUTO-HIDE UI "MONEY" ELEMENTS
task.spawn(function()
	while task.wait(1) do
		for _, obj in ipairs(CoreGui:GetDescendants()) do
			if obj and (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel")) then
				local nameLower = (obj.Name or ""):lower()
				local textLower = (obj.Text or ""):lower()
				if string.find(nameLower, "money") or string.find(textLower, "money") or string.find(nameLower, "100") or string.find(textLower, "100money") then
					pcall(function()
						obj.Visible = false
						if obj:IsA("GuiObject") then
							obj.Active = false
							obj.ZIndex = 0
						end
					end)
				end
			end
		end
	end
end)

-- NOTIFY WRAPPER
local function Notify(opts)
	pcall(function()
		Rayfield:Notify({
			Title = opts.Title or "Notification",
			Content = opts.Content or "",
			Duration = opts.Duration or 3
		})
	end)
end

-- REMOTE FETCHER
local function GetAutoFishRemote()
	local ok, NetModule = pcall(function()
		local folder = ReplicatedStorage:WaitForChild(NET_PACKAGES_FOLDER, 5)
		if folder then
			local netCandidate = folder:FindFirstChild("Net")
			if netCandidate and netCandidate:IsA("ModuleScript") then
				return require(netCandidate)
			end
		end
		if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
			local m = ReplicatedStorage.Packages.Net
			if m:IsA("ModuleScript") then return require(m) end
		end
		if ReplicatedStorage:FindFirstChild("Net") and ReplicatedStorage.Net:IsA("ModuleScript") then
			return require(ReplicatedStorage.Net)
		end
	end)
	return ok and NetModule or nil
end

-- SAFE REMOTE INVOKE
local function SafeInvokeAutoFishing(state)
	pcall(function()
		local Net = GetAutoFishRemote()
		if Net and type(Net.RemoteFunction) == "function" then
			local ok, rf = pcall(function() return Net:RemoteFunction(AUTO_FISH_REMOTE_NAME) end)
			if ok and rf then
				pcall(function() rf:InvokeServer(state) end)
				return
			end
		end
		local rfObj = ReplicatedStorage:FindFirstChild(AUTO_FISH_REMOTE_NAME)
			or (ReplicatedStorage:FindFirstChild("RemoteFunctions") and ReplicatedStorage.RemoteFunctions:FindFirstChild(AUTO_FISH_REMOTE_NAME))
		if rfObj and rfObj:IsA("RemoteFunction") then
			pcall(function() rfObj:InvokeServer(state) end)
			return
		end
		local reObj = ReplicatedStorage:FindFirstChild(AUTO_FISH_REMOTE_NAME)
			or (ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(AUTO_FISH_REMOTE_NAME))
		if reObj and reObj:IsA("RemoteEvent") then
			pcall(function() reObj:FireServer(state) end)
		end
	end)
end

-- AUTO FISH SYSTEM
local function StartAutoFish()
	if autoFishEnabled then return end
	autoFishEnabled = true
	if statusParagraph then pcall(function() statusParagraph:Set("Status: Active") end) end
	Notify({Title = "Auto Fishing", Content = "System enabled. Fishing will run automatically.", Duration = 3})

	autoFishLoopThread = task.spawn(function()
		while autoFishEnabled do
			pcall(function()
				SafeInvokeAutoFishing(true)
				if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Replion") then
					local Replion = require(ReplicatedStorage.Packages.Replion)
					if Replion and Replion.Client and type(Replion.Client.WaitReplion) == "function" then
						Replion.Client:WaitReplion("Data")
					end
				end
			end)
			task.wait(4)
		end
	end)
end

local function StopAutoFish()
	if not autoFishEnabled then return end
	autoFishEnabled = false
	if statusParagraph then pcall(function() statusParagraph:Set("Status: Inactive") end) end
	Notify({Title = "Auto Fishing", Content = "System stopped.", Duration = 3})
	pcall(function() SafeInvokeAutoFishing(false) end)
end

-- COORDINATE DISPLAY
local function CreateCoordinateDisplay()
	if coordinateGui and coordinateGui.Parent then coordinateGui:Destroy() end
	local sg = Instance.new("ScreenGui", CoreGui)
	sg.Name = "Anggazyy_Coordinates"
	sg.ResetOnSpawn = false

	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(0, 200, 0, 36)
	frame.Position = UDim2.new(0.5, -100, 0, 12)
	frame.BackgroundColor3 = Color3.fromRGB(30, 22, 45)
	frame.BorderSizePixel = 0
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0.35, 0)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(120, 85, 255)
	stroke.Thickness = 1.5

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -12, 1, 0)
	label.Position = UDim2.new(0, 6, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "X: 0 | Y: 0 | Z: 0"

	coordinateGui = sg
	task.spawn(function()
		while coordinateGui and coordinateGui.Parent do
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local pos = char.HumanoidRootPart.Position
				label.Text = string.format("X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
			else
				label.Text = "X: - | Y: - | Z: -"
			end
			task.wait(0.12)
		end
	end)
end

local function DestroyCoordinateDisplay()
	if coordinateGui and coordinateGui.Parent then coordinateGui:Destroy() end
	coordinateGui = nil
end

-- WINDOW SETUP
local Window = Rayfield:CreateWindow({
	Name = "Anggazyy Hub - Fish It",
	Icon = "fish",
	LoadingTitle = "Anggazyy Hub",
	LoadingSubtitle = "Advanced Fishing Automation",
	Theme = "Dark",
	ShowText = "AnggazyyHub",
	ToggleUIKeybind = Enum.KeyCode.K,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AnggazyyHubConfig",
		FileName = "FishIt_Config"
	}
})

-- INFO TAB
local InfoTab = Window:CreateTab("Information", "info")
InfoTab:CreateParagraph({
	Title = "Welcome to Anggazyy Hub",
	Content = "A professional automation hub for Fish It. This version uses Lucide icons, refined layout, and modern UI language."
})
InfoTab:CreateParagraph({
	Title = "Overview",
	Content = "Includes: Auto Fishing, Teleport System, Player Boosts, Live Coordinates, and Configurable Settings."
})

-- AUTO SYSTEM TAB
local AutoTab = Window:CreateTab("Automation", "fish")
AutoTab:CreateParagraph({
	Title = "Auto Fishing Engine",
	Content = "Automatically casts and reels fish using secure remote calls. Ensure the game remotes are available before enabling."
})

statusParagraph = AutoTab:CreateParagraph({
	Title = "System Status",
	Content = "Status: Inactive"
})

AutoTab:CreateToggle({
	Name = "Enable Auto Fishing",
	CurrentValue = false,
	Flag = "AutoFishToggle",
	Callback = function(state)
		if not LocalPlayer then
			return Notify({Title = "Auto Fishing", Content = "Local player not found.", Duration = 3})
		end
		local ok, err = pcall(function()
			if state then StartAutoFish() else StopAutoFish() end
		end)
		if not ok then
			Notify({Title = "Auto Fishing Error", Content = tostring(err), Duration = 4})
		end
	end
})

AutoTab:CreateParagraph({
	Title = "Operation Notes",
	Content = "The system runs every few seconds and syncs with the server to maintain a stable auto-fishing cycle."
})

-- TELEPORT TAB
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
TeleportTab:CreateParagraph({
	Title = "Map Selection",
	Content = "Select a fishing zone and instantly teleport there. You can also enable coordinate display for position tracking."
})

local maps = {
	{Label = "Coral Bay", Value = "Coral Bay", Pos = Vector3.new(0, 10, 0)},
	{Label = "Ocean Depths", Value = "Ocean Depths", Pos = Vector3.new(200, 12, 300)},
	{Label = "Ice Lake", Value = "Ice Lake", Pos = Vector3.new(-150, 8, -400)},
	{Label = "City Center", Value = "City Center", Pos = Vector3.new(100, 30, 100)}
}
local defaultMap = maps[1].Value

TeleportTab:CreateDropdown({
	Name = "Select Destination",
	Options = (function() local o = {}; for _, m in ipairs(maps) do table.insert(o, m.Value) end; return o end)(),
	CurrentOption = defaultMap,
	Flag = "MapSelect",
	Callback = function(selected)
		currentSelectedMap = selected
		Notify({Title = "Map Updated", Content = selected .. " selected.", Duration = 2})
	end
})

TeleportTab:CreateButton({
	Name = "Teleport to Selected Map",
	Callback = function()
		local chosen
		for _, m in ipairs(maps) do if m.Value == currentSelectedMap then chosen = m end end
		if chosen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(chosen.Pos)
			Notify({Title = "Teleport", Content = "Teleported to " .. chosen.Value, Duration = 2})
		else
			Notify({Title = "Teleport Error", Content = "Unable to teleport. Try again.", Duration = 3})
		end
	end
})

TeleportTab:CreateToggle({
	Name = "Show Coordinates",
	CurrentValue = false,
	Flag = "ShowCoords",
	Callback = function(v)
		if v then
			CreateCoordinateDisplay()
			Notify({Title = "Coordinates", Content = "Display enabled.", Duration = 2})
		else
			DestroyCoordinateDisplay()
			Notify({Title = "Coordinates", Content = "Display hidden.", Duration = 2})
		end
	end
})

-- PLAYER TAB
local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateParagraph({
	Title = "Player Modifiers",
	Content = "Adjust your walk speed or jump power safely. Restoring defaults is possible anytime."
})
PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 200},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(val)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if h then h.WalkSpeed = val end
	end
})
PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 350},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(val)
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if h then h.JumpPower = val end
	end
})
PlayerTab:CreateButton({
	Name = "Reset Player Attributes",
	Callback = function()
		local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if h then
			h.WalkSpeed = 16
			h.JumpPower = 50
			Notify({Title = "Player", Content = "Attributes restored to default.", Duration = 2})
		end
	end
})

-- SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateParagraph({
	Title = "General Options",
	Content = "Manage UI visibility, configuration saving, and utility commands below."
})
SettingsTab:CreateButton({
	Name = "Unload Script & Close UI",
	Callback = function()
		pcall(function() StopAutoFish() end)
		pcall(function() Rayfield:Destroy() end)
		DestroyCoordinateDisplay()
		Notify({Title = "Unload", Content = "All UI closed and scripts stopped.", Duration = 3})
	end
})
SettingsTab:CreateButton({
	Name = "Force Hide Money Icons",
	Callback = function()
		task.spawn(function()
			for _, obj in ipairs(CoreGui:GetDescendants()) do
				pcall(function()
					if (obj:IsA("ImageLabel") or obj:IsA("TextLabel")) then
						local n, t = obj.Name:lower(), (obj.Text or ""):lower()
						if string.find(n, "money") or string.find(t, "money") then obj.Visible = false end
					end
				end)
			end
		end)
		Notify({Title = "UI Cleanup", Content = "Money-related icons hidden.", Duration = 2})
	end
})
SettingsTab:CreateParagraph({
	Title = "Credits",
	Content = "Developed by Anggazyy | Rayfield UI + Lucide Icons | Stable Automation v3.0"
})

-- BACKGROUND ANIMATION
pcall(function()
	local bg = Window.UIElements and Window.UIElements.MainFrame and Window.UIElements.MainFrame.Background
	if bg then
		task.spawn(function()
			local colors = {
				Color3.fromRGB(25, 20, 40),
				Color3.fromRGB(35, 25, 55),
				Color3.fromRGB(30, 22, 50)
			}
			local i = 1
			while task.wait(6) and bg.Parent do
				local nextI = (i % #colors) + 1
				local tween = TweenService:Create(bg, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = colors[nextI]})
				tween:Play()
				i = nextI
			end
		end)
	end
end)

-- LOAD CONFIG & INIT
pcall(function() Rayfield:LoadConfiguration() end)
Notify({Title = "Anggazyy Hub", Content = "Loaded successfully. Press [K] to toggle the UI.", Duration = 4})
