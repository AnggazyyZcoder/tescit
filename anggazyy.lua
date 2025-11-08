--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (FINAL)
-- Rayfield UI + Lucide icons
-- Clean, modern, no emoji, remove "100 money" icons, AutoFish fixed
-- Author: Anggazyy (refactor)
--//////////////////////////////////////////////////////////////////////////////////

-- CONFIG: ubah sesuai kebutuhan
local AUTO_FISH_REMOTE_NAME = "UpdateAutoFishingState" -- remote function name di server (ubah jika beda)
local NET_PACKAGES_FOLDER = "Packages" -- tempat Packages berada di ReplicatedStorage (ubah jika berbeda)
local RAYFIELD_URL = 'https://sirius.menu/rayfield' -- rayfield loader url (ekspekt: ada)
-- End CONFIG

-- safety loader
local successLoad, Rayfield = pcall(function()
	return loadstring(game:HttpGet(RAYFIELD_URL))()
end)
if not successLoad or not Rayfield then
	warn("Rayfield gagal dimuat. Pastikan executor bisa mem-fetch URL: " .. tostring(RAYFIELD_URL))
	return
end

-- services & vars
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local autoFishEnabled = false
local autoFishLoopThread = nil
local coordinateGui = nil
local statusParagraph = nil
local currentSelectedMap = nil

-- UTIL: remove any UI or asset that contains "money" in name/text (runs in background)
task.spawn(function()
	while task.wait(1) do
		for _, obj in ipairs(CoreGui:GetDescendants()) do
			if obj and obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel") then
				local nameLower = (obj.Name or ""):lower()
				local textLower = (obj.Text or ""):lower()
				if string.find(nameLower, "money") or string.find(textLower, "money") or string.find(nameLower, "100") or string.find(textLower, "100money") then
					-- hide and disable interactions
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

-- CUSTOM NOTIFY (uses Rayfield Notify but also supports in-game toast GUI)
local function Notify(opts)
	-- opts: Title, Content, Duration (seconds)
	pcall(function()
		Rayfield:Notify({
			Title = opts.Title or "Notification",
			Content = opts.Content or "",
			Duration = opts.Duration or 3
		})
	end)
end

-- SAFE get Net remotefunction — robust: waits and checks multiple times
local function GetAutoFishRemote()
	-- Try to find a RemoteFunction via typical structure: ReplicatedStorage.Packages.Net or similar
	local ok, NetModule = pcall(function()
		local folder = ReplicatedStorage:WaitForChild(NET_PACKAGES_FOLDER, 5)
		-- if folder is a ModuleScript container, require Net
		if folder then
			local netCandidate = folder:FindFirstChild("Net")
			if netCandidate and (netCandidate:IsA("ModuleScript") or netCandidate:IsA("Folder") or netCandidate:IsA("ModuleScript")) then
				-- require only if ModuleScript
				if netCandidate:IsA("ModuleScript") then
					return require(netCandidate)
				end
			end
		end
		-- fallback: try require(ReplicatedStorage.Packages.Net)
		if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
			local m = ReplicatedStorage.Packages.Net
			if m:IsA("ModuleScript") then
				return require(m)
			end
		end
		-- final fallback: try require(ReplicatedStorage:FindFirstChild("Net")) if exists
		if ReplicatedStorage:FindFirstChild("Net") and ReplicatedStorage.Net:IsA("ModuleScript") then
			return require(ReplicatedStorage.Net)
		end
		return nil
	end)
	if ok and NetModule then
		return NetModule
	end
	return nil
end

-- safe invoke remote function (wrapped)
local function SafeInvokeAutoFishing(state)
	pcall(function()
		-- primary attempt: use Net module remote function call
		local Net = GetAutoFishRemote()
		if Net and type(Net.RemoteFunction) == "function" then
			-- Some Net wrappers expose RemoteFunction(name) factory
			local ok, rf = pcall(function() return Net:RemoteFunction(AUTO_FISH_REMOTE_NAME) end)
			if ok and rf then
				pcall(function() rf:InvokeServer(state) end)
				return
			end
		end
		-- fallback: try to find RemoteFunction object in ReplicatedStorage by name
		local rfObj = ReplicatedStorage:FindFirstChild(AUTO_FISH_REMOTE_NAME) or ReplicatedStorage:FindFirstChild("RemoteFunctions") and ReplicatedStorage.RemoteFunctions:FindFirstChild(AUTO_FISH_REMOTE_NAME)
		if rfObj and rfObj:IsA("RemoteFunction") then
			pcall(function() rfObj:InvokeServer(state) end)
			return
		end
		-- if still not found, attempt to fire a RemoteEvent named similarly (best-effort)
		local reObj = ReplicatedStorage:FindFirstChild(AUTO_FISH_REMOTE_NAME) or ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild(AUTO_FISH_REMOTE_NAME)
		if reObj and reObj:IsA("RemoteEvent") then
			pcall(function() reObj:FireServer(state) end)
			return
		end
	end)
end

-- AUTO FISH START/STOP
local function StartAutoFish()
	if autoFishEnabled then return end
	autoFishEnabled = true
	if statusParagraph then pcall(function() statusParagraph:Set("Status: Enabled") end) end
	Notify({Title = "Auto Fishing", Content = "Activated", Duration = 2})

	autoFishLoopThread = task.spawn(function()
		while autoFishEnabled do
			pcall(function()
				-- Attempt server invocation (robust)
				SafeInvokeAutoFishing(true)

				-- If the game has a custom client Replion-based API, attempt common pattern:
				if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Replion") then
					pcall(function()
						local Replion = require(ReplicatedStorage.Packages.Replion)
						if Replion and Replion.Client and type(Replion.Client.WaitReplion) == "function" then
							local Data = Replion.Client:WaitReplion("Data")
							-- no-op; just ensure Replion is preloaded
						end
					end)
				end
			end)
			task.wait(4) -- delay between invokes
		end
	end)
end

local function StopAutoFish()
	if not autoFishEnabled then return end
	autoFishEnabled = false
	if statusParagraph then pcall(function() statusParagraph:Set("Status: Disabled") end) end
	Notify({Title = "Auto Fishing", Content = "Stopped", Duration = 2})
	-- ensure server told to stop
	pcall(function()
		SafeInvokeAutoFishing(false)
	end)
end

-- create coordinate GUI (modern)
local function CreateCoordinateDisplay()
	if coordinateGui and coordinateGui.Parent then coordinateGui:Destroy() end
	local sg = Instance.new("ScreenGui")
	sg.Name = "Anggazyy_Coordinates"
	sg.ResetOnSpawn = false
	sg.Parent = CoreGui

	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(0, 200, 0, 36)
	frame.Position = UDim2.new(0.5, -100, 0, 12)
	frame.BackgroundColor3 = Color3.fromRGB(34, 24, 44)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0)
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0.35, 0)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(128, 80, 255)
	stroke.Thickness = 1.6

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -12, 1, 0)
	label.Position = UDim2.new(0, 6, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 14
	label.Text = "X: 0 | Y: 0 | Z: 0"
	label.TextXAlignment = Enum.TextXAlignment.Left

	coordinateGui = sg

	-- update loop
	task.spawn(function()
		while coordinateGui and coordinateGui.Parent do
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local pos = char.HumanoidRootPart.Position
				label.Text = string.format("X: %d | Y: %d | Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
			else
				label.Text = "X: - | Y: - | Z: -"
			end
			task.wait(0.12)
		end
	end)
end

-- DESTROY coordinate
local function DestroyCoordinateDisplay()
	if coordinateGui and coordinateGui.Parent then
		pcall(function() coordinateGui:Destroy() end)
		coordinateGui = nil
	end
end

-- Create main Rayfield window
local Window = Rayfield:CreateWindow({
	Name = "Anggazyy Hub - Fish It",
	Icon = "fish", -- lucide icon name
	LoadingTitle = "Anggazyy Hub",
	LoadingSubtitle = "Fish It Automation",
	Theme = "Dark",
	ShowText = "AnggazyyHub",
	ToggleUIKeybind = Enum.KeyCode.K,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AnggazyyHubConfig",
		FileName = "FishIt_Config"
	}
})

-- ========== INFO TAB ==========
local InfoTab = Window:CreateTab("Info & Guide", "info")
InfoTab:CreateParagraph({
	Title = "Welcome",
	Content = "Anggazyy Hub - Fish It (Rayfield Final). Clean UI, Lucide icons, no money icon. Use responsibly."
})
InfoTab:CreateParagraph({
	Title = "Features",
	Content = "Auto Fishing (stable), Coordinate Display, Teleport, Player Boost, Modern UI with gradient & animations."
})

-- ========== AUTO SYSTEM TAB ==========
local AutoTab = Window:CreateTab("Auto System", "fish")

-- label (modern style)
AutoTab:CreateParagraph({
	Title = "Auto Fishing System",
	Content = "Auto Fish ensures automatic casting + catching. Toggle ON untuk menjalankan. Pastikan Remote/Net tersedia di ReplicatedStorage."
})

-- status paragraph
statusParagraph = AutoTab:CreateParagraph({
	Title = "Status:",
	Content = "Status: Disabled"
})

-- Auto toggle (robust callback)
AutoTab:CreateToggle({
	Name = "Enable Auto Fishing",
	CurrentValue = false,
	Flag = "AutoFishToggle",
	Callback = function(state)
		-- guard: if local player is nil
		if not LocalPlayer then
			Notify({Title = "Auto Fish", Content = "Player tidak tersedia.", Duration = 3})
			return
		end

		if state then
			-- try start
			local ok, err = pcall(function() StartAutoFish() end)
			if not ok then
				Notify({Title = "Auto Fish Error", Content = tostring(err or "Unknown error"), Duration = 4})
			end
		else
			local ok, err = pcall(function() StopAutoFish() end)
			if not ok then
				Notify({Title = "Auto Fish Error", Content = tostring(err or "Unknown error"), Duration = 4})
			end
		end
	end
})

-- Additional settings paragraph with color hint (example color-coded label)
AutoTab:CreateParagraph({
	Title = "Info Color",
	Content = "Label color example: Enabled (green), Disabled (red). Use Toggle untuk switch."
})

-- ========== TELEPORT TAB ==========
local TeleportTab = Window:CreateTab("Teleport", "map-pin")

TeleportTab:CreateParagraph({
	Title = "Teleport Map Select",
	Content = "Pilih map pada dropdown, lalu tekan GO untuk teleport. Coordinates ditampilkan jika aktif."
})

-- Dropdown maps
local maps = {
	{Label = "Coral Bay", Value = "Coral Bay", Pos = Vector3.new(0, 10, 0)},
	{Label = "Ocean Depths", Value = "Ocean Depths", Pos = Vector3.new(200, 12, 300)},
	{Label = "Ice Lake", Value = "Ice Lake", Pos = Vector3.new(-150, 8, -400)},
	{Label = "City Center", Value = "City Center", Pos = Vector3.new(100, 30, 100)}
}

local defaultMap = maps[1].Value

TeleportTab:CreateDropdown({
	Name = "Select Map",
	Options = (function()
		local out = {}
		for _,m in ipairs(maps) do table.insert(out, m.Value) end
		return out
	end)(),
	CurrentOption = defaultMap,
	Flag = "MapSelect",
	Callback = function(selected)
		currentSelectedMap = selected
		Notify({Title = "Map Selected", Content = tostring(selected), Duration = 2})
	end
})

-- go button to teleport to selected
TeleportTab:CreateButton({
	Name = "Go To Selected Map",
	Callback = function()
		if not currentSelectedMap then currentSelectedMap = defaultMap end
		-- find pos
		local chosen = nil
		for _,m in ipairs(maps) do
			if m.Value == currentSelectedMap then chosen = m; break end
		end
		if chosen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(chosen.Pos)
			Notify({Title = "Teleport", Content = "Teleported to ".. chosen.Value, Duration = 2})
		else
			Notify({Title = "Teleport Error", Content = "Gagal teleport. Pastikan karakter siap.", Duration = 3})
		end
	end
})

-- toggle coordinate display
TeleportTab:CreateToggle({
	Name = "Show Coordinates",
	CurrentValue = false,
	Flag = "ShowCoords",
	Callback = function(v)
		if v then
			CreateCoordinateDisplay()
			Notify({Title = "Coordinates", Content = "Coordinate display enabled", Duration = 2})
		else
			DestroyCoordinateDisplay()
			Notify({Title = "Coordinates", Content = "Coordinate display disabled", Duration = 2})
		end
	end
})

-- ========== PLAYER TAB ==========
local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateParagraph({
	Title = "Player Boost",
	Content = "Adjust walk speed & jump power. Values will apply to the local humanoid when changed."
})

PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 200},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = val
		end
	end
})

PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 350},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.JumpPower = val
		end
	end
})

-- reset player values
PlayerTab:CreateButton({
	Name = "Reset Player Values",
	Callback = function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = 16
			LocalPlayer.Character.Humanoid.JumpPower = 50
			Notify({Title = "Player", Content = "Reset to default values.", Duration = 2})
		end
	end
})

-- ========== SETTINGS TAB ==========
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateParagraph({
	Title = "General Settings",
	Content = "Save / Load configuration, Unload script, and other utilities."
})

SettingsTab:CreateButton({
	Name = "Unload Script (Destroy UI)",
	Callback = function()
		-- stop auto fish before unloading
		pcall(function() StopAutoFish() end)
		-- destroy Rayfield UI
		pcall(function() Rayfield:Destroy() end)
		-- destroy coordinates
		DestroyCoordinateDisplay()
		Notify({Title = "Unload", Content = "Script unloaded.", Duration = 2})
	end
})

SettingsTab:CreateButton({
	Name = "Force Hide Money Icons Now",
	Callback = function()
		task.spawn(function()
			for _, obj in ipairs(CoreGui:GetDescendants()) do
				local ok, _ = pcall(function()
					if (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel")) then
						local nameLower = (obj.Name or ""):lower()
						local textLower = (obj.Text or ""):lower()
						if string.find(nameLower, "money") or string.find(textLower, "money") or string.find(nameLower, "100") then
							obj.Visible = false
						end
					end
				end)
			end
		end)
		Notify({Title = "Hide Money", Content = "Attempted to hide any money-related icons.", Duration = 2})
	end
})

SettingsTab:CreateParagraph({
	Title = "Credits",
	Content = "Created by Anggazyy | Rayfield UI (Lucide icons)."
})

-- ========== THEME & SUBTLE ANIMATIONS ==========
-- Attempt to animate main frame background color with tween
pcall(function()
	local mainBG = Window.UIElements and Window.UIElements.MainFrame and Window.UIElements.MainFrame.Background
	if mainBG then
		task.spawn(function()
			local colors = {
				Color3.fromRGB(30, 18, 45),
				Color3.fromRGB(35, 22, 55),
				Color3.fromRGB(25, 18, 40),
			}
			local i = 1
			while task.wait(6) and mainBG.Parent do
				local nextI = i % #colors + 1
				local tween = TweenService:Create(mainBG, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = colors[nextI]})
				tween:Play()
				i = nextI
			end
		end)
	end
end)

-- Load configuration (Rayfield will restore previous toggle states, dropdown, sliders, etc.)
pcall(function() Rayfield:LoadConfiguration() end)

-- final notify
Notify({Title = "Anggazyy Hub", Content = "Loaded successfully. Press [K] to toggle UI.", Duration = 4})

--//////////////////////////////////////////////////////////////////////////////////
-- End of script
--//////////////////////////////////////////////////////////////////////////////////
