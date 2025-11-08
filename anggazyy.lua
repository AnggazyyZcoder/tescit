--//////////////////////////////////////////////////////////////////////////////////
-- Anggazyy Hub - Fish It (REFINED FINAL - Rayfield)
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
local statusLabelObject -- Rayfield label object for status
local currentSelectedMap
local startTime = tick()
local playtimeLabelObject

-- AUTO-HIDE UI "MONEY" ELEMENTS (background)
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

-- REMOTE FETCHER (robust)
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

-- helper: update status text & color (tries multiple Rayfield label APIs)
local function updateStatusLabel(text, color3)
	-- try Rayfield label API if available
	pcall(function()
		if statusLabelObject then
			-- many Rayfield label objects support :Set(text)
			if pcall(function() statusLabelObject.Set end) then
				pcall(function() statusLabelObject:Set(text) end)
			else
				-- fallback: try SetTitle / SetText
				pcall(function() statusLabelObject:SetTitle and statusLabelObject:SetTitle(text) end)
				pcall(function() statusLabelObject:SetText and statusLabelObject:SetText(text) end)
			end
			-- attempt color setters (varies by Rayfield version)
			pcall(function() statusLabelObject:SetColor and statusLabelObject:SetColor(color3) end)
			pcall(function() statusLabelObject:SetTextColor and statusLabelObject:SetTextColor(color3) end)
			-- if label object exposes .Label or .TextLabel, try set property
			if pcall(function() return statusLabelObject.Label end) and statusLabelObject.Label and statusLabelObject.Label.TextColor3 then
				pcall(function() statusLabelObject.Label.TextColor3 = color3 end)
			end
			if pcall(function() return statusLabelObject.TextLabel end) and statusLabelObject.TextLabel and statusLabelObject.TextLabel.TextColor3 then
				pcall(function() statusLabelObject.TextLabel.TextColor3 = color3 end)
			end
		end
	end)
	-- as fallback: also show a small notification color-coded (non-intrusive)
	pcall(function()
		-- no color in Rayfield: use Notify
		Notify({Title = "Status Update", Content = text, Duration = 1.5})
	end)
end

-- AUTO FISH SYSTEM
local function StartAutoFish()
	if autoFishEnabled then return end
	autoFishEnabled = true
	updateStatusLabel("Status: Active", Color3.fromRGB(100, 220, 120)) -- smooth green
	Notify({Title = "Auto Fishing", Content = "System enabled. Fishing will run automatically.", Duration = 3})

	autoFishLoopThread = task.spawn(function()
		while autoFishEnabled do
			pcall(function()
				SafeInvokeAutoFishing(true)
				-- try to sync Replion if present (no-op if not)
				if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Replion") then
					local ok, Replion = pcall(function() return require(ReplicatedStorage.Packages.Replion) end)
					if ok and Replion and Replion.Client and type(Replion.Client.WaitReplion) == "function" then
						pcall(function() Replion.Client:WaitReplion("Data") end)
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
	updateStatusLabel("Status: Inactive", Color3.fromRGB(230, 90, 90)) -- smooth red
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
				label.Text = string.format("X: %d | Y: %d | Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
			else
				label.Text = "X: - | Y: - | Z: -"
			end
			task.wait(0.12)
		end
	end)
end

local function DestroyCoordinateDisplay()
	if coordinateGui and coordinateGui.Parent then pcall(function() coordinateGui:Destroy() end) end
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

-- ================= INFO TAB (Player Info) =================
local InfoTab = Window:CreateTab("Player Info", "user")
InfoTab:CreateParagraph({
	Title = "Welcome",
	Content = "Selamat datang di Anggazyy Hub. Panel ini menampilkan informasi akun singkat dan tombol utilitas."
})

-- Username label (Rayfield label)
InfoTab:CreateLabel("Username: " .. tostring(LocalPlayer.Name))

-- Playtime label (live)
playtimeLabelObject = InfoTab:CreateLabel("Playing Time: 00m 00s")
task.spawn(function()
	while task.wait(1) do
		local elapsed = math.floor(tick() - startTime)
		local minutes = math.floor(elapsed / 60)
		local seconds = elapsed % 60
		pcall(function() playtimeLabelObject:Set("Playing Time: " .. string.format("%02dm %02ds", minutes, seconds)) end)
	end
end)

-- Avatar display: try to fetch thumbnail and create an ImageLabel in CoreGui near top-right for a subtle avatar (non-invasive)
pcall(function()
	local userId = LocalPlayer.UserId
	local thumbUrl = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
	-- Create small avatar GUI (will be placed top-left of screen)
	local sg = Instance.new("ScreenGui", CoreGui)
	sg.Name = "Anggazyy_Avatar"
	sg.ResetOnSpawn = false
	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(0, 110, 0, 110)
	frame.Position = UDim2.new(0, 12, 0, 12)
	frame.BackgroundTransparency = 1
	local img = Instance.new("ImageLabel", frame)
	img.Size = UDim2.new(1, 0, 1, 0)
	img.Position = UDim2.new(0, 0, 0, 0)
	img.Image = thumbUrl
	img.BackgroundTransparency = 1
	img.ScaleType = Enum.ScaleType.Fit
	local corner = Instance.new("UICorner", img)
	corner.CornerRadius = UDim.new(0.2, 0)
end)

-- Copy server link button
local serverId = tostring(game.JobId or "")
InfoTab:CreateButton({
	Name = "Copy Server Link",
	Callback = function()
		if serverId ~= "" then
			pcall(function() setclipboard(serverId) end)
			Notify({Title = "Server Copied", Content = "Server ID telah disalin ke clipboard.", Duration = 2})
		else
			Notify({Title = "Copy Failed", Content = "Server ID tidak tersedia.", Duration = 2})
		end
	end
})

InfoTab:CreateParagraph({
	Title = "Notes",
	Content = "Gunakan tombol salin apabila ingin membagikan server ke teman. Avatar disajikan sebagai informasi cepat."
})

-- ================= AUTO SYSTEM TAB =================
local AutoTab = Window:CreateTab("Automation", "fish")
AutoTab:CreateParagraph({
	Title = "Auto Fishing Engine",
	Content = "Sistem ini mencoba melakukan pemanggilan remote dengan metode paling kompatibel. Jika game menggunakan nama remote berbeda, sesuaikan AUTO_FISH_REMOTE_NAME."
})

-- Create status label using CreateLabel (so we can call :Set and attempt color set)
statusLabelObject = AutoTab:CreateLabel("Status: Inactive")
-- initialize visual to inactive
updateStatusLabel("Status: Inactive", Color3.fromRGB(230, 90, 90))

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
	Content = "Sistem memanggil server setiap beberapa detik. Pastikan jaringan stabil. Jika remote tidak ditemukan, fitur akan mencoba metode fallback."
})

-- ================= TELEPORT TAB (Mount Hallow only) =================
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
TeleportTab:CreateParagraph({
	Title = "Teleport - Mount Hallow",
	Content = "Gunakan tombol di bawah untuk langsung berpindah ke area Mount Hallow."
})

TeleportTab:CreateButton({
	Name = "Teleport to Mount Hallow (1819, 12, 3043)",
	Callback = function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		if character and character:FindFirstChild("HumanoidRootPart") then
			pcall(function()
				character:MoveTo(Vector3.new(1819, 12, 3043))
			end)
			Notify({Title = "Teleport Successful", Content = "Berpindah ke Mount Hallow.", Duration = 3})
		else
			Notify({Title = "Teleport Failed", Content = "Karakter belum siap. Coba setelah spawn.", Duration = 3})
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

-- ================= PLAYER TAB =================
local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateParagraph({
	Title = "Player Modifiers",
	Content = "Sesuaikan atribut pemain dengan aman. Nilai disimpan pada sesi lokal."
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

-- ================= SETTINGS TAB =================
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateParagraph({
	Title = "General Options",
	Content = "Kelola UI, konfigurasi penyimpanan, dan utilitas lainnya."
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
						local n, t = (obj.Name or ""):lower(), (obj.Text or ""):lower()
						if string.find(n, "money") or string.find(t, "money") or string.find(n, "100") then
							obj.Visible = false
						end
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

-- BACKGROUND ANIMATION (subtle)
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

--//////////////////////////////////////////////////////////////////////////////////
-- End of script
--//////////////////////////////////////////////////////////////////////////////////
