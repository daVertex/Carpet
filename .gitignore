-- =================================
-- SERVICES
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =================================
-- PLAYER / WORLD
-- =================================
local player = Players.LocalPlayer
local mine = workspace:WaitForChild("Mine")

-- =================================
-- HC REMOTE (auto supports RemoteEvent/RemoteFunction)
-- =================================
local HCRemote = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("ItemAbilityRemotes")
	:WaitForChild("HollowCornucopia_Activation")

local function callHC()
	if HCRemote:IsA("RemoteEvent") then
		HCRemote:FireServer()
		return true
	elseif HCRemote:IsA("RemoteFunction") then
		HCRemote:InvokeServer()
		return true
	else
		warn("[HC] HollowCornucopia_Activation is not RemoteEvent/RemoteFunction. It is:", HCRemote.ClassName)
		return false
	end
end

-- =================================
-- ORE CONFIG (lowercase)
-- =================================
local oreNames = {
	"inclemetite","bulbalescense","cybernetium","glacielle","azuryl","nauticalis",
	"snoblintium","freon","nuummite","nocturnite","elysian","tanzanite",
	"cobalt","bluesteel","lavendulan",
}

local oreColors = {
	inclemetite = Color3.fromRGB(255, 120, 120),
	bulbalescense = Color3.fromRGB(255, 200, 80),
	cybernetium = Color3.fromRGB(80, 200, 255),
	glacielle = Color3.fromRGB(180, 220, 255),
	azuryl = Color3.fromRGB(70, 120, 255),
	nauticalis = Color3.fromRGB(80, 255, 200),
	snoblintium = Color3.fromRGB(240, 240, 240),
	freon = Color3.fromRGB(150, 255, 255),
	nuummite = Color3.fromRGB(120, 80, 200),
	nocturnite = Color3.fromRGB(80, 80, 120),
	elysian = Color3.fromRGB(255, 180, 255),
	tanzanite = Color3.fromRGB(140, 90, 255),
	cobalt = Color3.fromRGB(60, 110, 255),
	bluesteel = Color3.fromRGB(100, 160, 200),
	lavendulan = Color3.fromRGB(200, 140, 255),
}

local oreSet = {}
for _, n in ipairs(oreNames) do oreSet[n] = true end

-- =================================
-- UI (compact + clean)
-- =================================
local gui = Instance.new("ScreenGui")
gui.Name = "OreToolsUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -20, 0, 80)
frame.Size = UDim2.fromOffset(260, 340)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 8)
title.Size = UDim2.new(1, -50, 0, 22)
title.Text = "Ore Scanner"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame

local list = Instance.new("ScrollingFrame")
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.Position = UDim2.fromOffset(10, 34)
list.Size = UDim2.new(1, -20, 1, -86)
list.ScrollBarImageTransparency = 0.5
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 6)
end)

-- Bottom row (TP + HC)
local row = Instance.new("Frame")
row.BackgroundTransparency = 1
row.Position = UDim2.new(0, 10, 1, -46)
row.Size = UDim2.new(1, -20, 0, 36)
row.Parent = frame

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.Padding = UDim.new(0, 8)
rowLayout.Parent = row

local function makeBtn(text, wScale)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, 0, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 235, 235)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.Parent = row

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b

	return b
end

local tpButton = makeBtn("Start TP", 0.55)
local hcButton = makeBtn("HC : OFF", 0.45)

-- Reopen mini button
local reopen = Instance.new("TextButton")
reopen.AnchorPoint = Vector2.new(1, 0)
reopen.Position = UDim2.new(1, -20, 0, 20)
reopen.Size = UDim2.fromOffset(80, 28)
reopen.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
reopen.BorderSizePixel = 0
reopen.Text = "Open"
reopen.TextColor3 = Color3.fromRGB(235, 235, 235)
reopen.Font = Enum.Font.GothamSemibold
reopen.TextSize = 13
reopen.Visible = false
reopen.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 8)
reopenCorner.Parent = reopen

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
	frame.Visible = true
	reopen.Visible = false
end)

-- =================================
-- ORE SCANNER (numbers ALWAYS shown)
-- =================================
local function rgb(c)
	return math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
end

local function scanCounts()
	local oreCount = {}
	for _, name in ipairs(oreNames) do
		oreCount[name] = 0
	end

	for _, obj in ipairs(mine:GetDescendants()) do
		local n = string.lower(obj.Name)
		if oreCount[n] ~= nil then
			oreCount[n] += 1
		end
	end

	return oreCount
end

local function clearRows()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refreshScannerUI()
	clearRows()
	local counts = scanCounts()

	for _, oreName in ipairs(oreNames) do
		local c = oreColors[oreName] or Color3.fromRGB(235, 235, 235)
		local r, g, b = rgb(c)
		local count = counts[oreName] or 0

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, 0, 0, 20)
		lbl.RichText = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.Text = string.format(
			'<font color="rgb(%d,%d,%d)">%s</font> <font color="rgb(200,200,200)">%d</font>',
			r, g, b, oreName, count
		)
		lbl.Parent = list
	end
end

task.spawn(function()
	while true do
		if frame.Visible then
			refreshScannerUI()
		end
		task.wait(2)
	end
end)

-- =================================
-- ORE TELEPORT (fixed)
-- =================================
local runningTP = false

local function getValidOres()
	local ores = {}
	for _, obj in ipairs(mine:GetChildren()) do
		local n = string.lower(obj.Name)
		if oreSet[n] then
			table.insert(ores, obj)
		end
	end
	return ores
end

local function getOreCFrame(ore)
	if ore:IsA("BasePart") then
		return ore.CFrame
	elseif ore:IsA("Model") then
		if ore.PrimaryPart then
			return ore.PrimaryPart.CFrame
		end
		local p = ore:FindFirstChildWhichIsA("BasePart", true)
		if p then return p.CFrame end
	end
	return nil
end

local function createPlatform()
	local p = Instance.new("Part")
	p.Name = "LocalOrePlatform"
	p.Size = Vector3.new(16, 1, 16)
	p.Anchored = true
	p.CanCollide = true
	p.Transparency = 0.4
	p.Parent = workspace
	return p
end

local function teleportToOre(ore, platform)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local cf = getOreCFrame(ore)
	if not cf then return false end

	platform.CFrame = cf * CFrame.new(0, -3, 0)
	hrp.CFrame = cf * CFrame.new(0, 4, 0)
	return true
end

local function waitUntilOreGone(ore, maxSeconds)
	local t0 = os.clock()
	while os.clock() - t0 < maxSeconds do
		if ore == nil or ore.Parent == nil or not ore:IsDescendantOf(mine) then
			return true
		end
		RunService.Heartbeat:Wait()
	end
	return false
end

local function runOreLoop()
	if runningTP then return end
	runningTP = true
	tpButton.Text = "TP : RUN"

	local platform = createPlatform()

	task.spawn(function()
		while true do
			local ores = getValidOres()
			if #ores == 0 then break end

			local ore = ores[1]
			local ok = teleportToOre(ore, platform)

			if ok then
				waitUntilOreGone(ore, 30)
			else
				task.wait(0.2)
			end
		end

		if platform then platform:Destroy() end
		tpButton.Text = "Start TP"
		runningTP = false
	end)
end

tpButton.MouseButton1Click:Connect(runOreLoop)

-- =================================
-- HC TOGGLE (fires every 5s while ON)
-- =================================
local hcOn = false
local hcLoopRunning = false

local function updateHC()
	hcButton.Text = hcOn and "HC : ON" or "HC : OFF"
	hcButton.TextColor3 = hcOn and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 90, 90)
end

local function startHCLoop()
	if hcLoopRunning then return end
	hcLoopRunning = true

	task.spawn(function()
		while hcOn do
			pcall(callHC)
			task.wait(5)
		end
		hcLoopRunning = false
	end)
end

hcButton.MouseButton1Click:Connect(function()
	hcOn = not hcOn
	updateHC()
	if hcOn then
		startHCLoop()
	end
end)

updateHC()
