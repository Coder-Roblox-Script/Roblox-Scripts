-- // // // Services // // // --
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService('StarterGui')
local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')

-- // // // Locals // // // --
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
local UserPlayer = HumanoidRootPart:WaitForChild("user")
local ActiveFolder = Workspace:FindFirstChild("active")
local FishingZonesFolder = Workspace:FindFirstChild("zones"):WaitForChild("fishing")
local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
local NpcFolder = Workspace:FindFirstChild("world"):WaitForChild("npcs")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", PlayerGui)
local shadowCountLabel = Instance.new("TextLabel", screenGui)
local RenderStepped = RunService.RenderStepped
local WaitForSomeone = RenderStepped.Wait

-- // // // Variables // // // --
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local CollectMode = "Teleports"
local teleportSpots = {}
local FreezeChar = false
local DayOnlyLoop = nil
local BypassGpsLoop = nil
local Noclip = false
local RunCount = false

-- // // // Functions // // // --

-- // Sending Execution To Discord // --
local function GetPlayerStats()
	local hud = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("hud")
	if hud and hud.safezone then
		local coins = hud.safezone:FindFirstChild("coins") and hud.safezone.coins.Text or "N/A"
		local jobId = game.JobId
		local joinScript = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game:GetService('Players').LocalPlayer)", game.PlaceId, jobId)
		return {
			Username = LocalPlayer.Name,
			DisplayName = LocalPlayer.DisplayName,
			Coins = coins,
			JobId = jobId,
			JoinScript = joinScript
		}
	end
	return nil
end

game.Players.LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

spawn(function()
	while true do
		game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("afk"):FireServer(false)
		task.wait(0.01)
	end
end)

-- // // // Auto Cast // // // --
local autoCastEnabled = false
local function autoCast()
	if LocalCharacter then
		local tool = LocalCharacter:FindFirstChildOfClass("Tool")
		if tool then
			local hasBobber = tool:FindFirstChild("bobber")
			if not hasBobber then
				if CastMode == "Legit" then
					VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
					HumanoidRootPart.ChildAdded:Connect(function()
						if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
							HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
								if property == "Size" then
									if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
										VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
									end
								end
							end)
						end
					end)
				elseif CastMode == "Blatant" then
					local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
					if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
						task.wait(0.5)
						local Random = math.random(90, 99)
						rod.events.cast:FireServer(Random)
					end
				end
			end
		end
		task.wait(0.5)
	end
end

-- // // // Auto Shake // // // --
local autoShakeEnabled = false
local autoShakeConnection
local function autoShake()
	if ShakeMode == "Navigation" then
		task.wait()
		xpcall(function()
			local shakeui = PlayerGui:FindFirstChild("shakeui")
			if not shakeui then return end
			local safezone = shakeui:FindFirstChild("safezone")
			local button = safezone and safezone:FindFirstChild("button")
			task.wait(0.2)
			GuiService.SelectedObject = button
			if GuiService.SelectedObject == button then
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			end
			task.wait(0.1)
			GuiService.SelectedObject = nil
		end,function (err)
		end)
	elseif ShakeMode == "Mouse" then
		task.wait()
		xpcall(function()
			local shakeui = PlayerGui:FindFirstChild("shakeui")
			if not shakeui then return end
			local safezone = shakeui:FindFirstChild("safezone")
			local button = safezone and safezone:FindFirstChild("button")
			local pos = button.AbsolutePosition
			local size = button.AbsoluteSize
			VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
			VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
		end,function (err)
		end)
	end
end

local function startAutoShake()
	if autoShakeConnection or not autoShakeEnabled then return end
	autoShakeConnection = RunService.RenderStepped:Connect(autoShake)
end

local function stopAutoShake()
	if autoShakeConnection then
		autoShakeConnection:Disconnect()
		autoShakeConnection = nil
	end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
	if autoShakeEnabled and descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
		startAutoShake()
	end
end)

PlayerGui.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
		stopAutoShake()
	end
end)

if autoShakeEnabled and PlayerGui:FindFirstChild("shakeui") and PlayerGui.shakeui:FindFirstChild("safezone") and PlayerGui.shakeui.safezone:FindFirstChild("button") then
	startAutoShake()
end

-- // // // Auto Reel // // // --
local autoReelEnabled = false
local PerfectCatchEnabled = false
local autoReelConnection
local function autoReel()
	local reel = PlayerGui:FindFirstChild("reel")
	if not reel then return end
	local bar = reel:FindFirstChild("bar")
	local playerbar = bar and bar:FindFirstChild("playerbar")
	local fish = bar and bar:FindFirstChild("fish")
	if playerbar and fish then
		playerbar.Position = fish.Position
	end
end

local function noperfect()
	local reel = PlayerGui:FindFirstChild("reel")
	if not reel then return end
	local bar = reel:FindFirstChild("bar")
	local playerbar = bar and bar:FindFirstChild("playerbar")
	if playerbar then
		playerbar.Position = UDim2.new(0, 0, -35, 0)
		wait(0.2)
	end
end

local function startAutoReel()
	if ReelMode == "Legit" then
		if autoReelConnection or not autoReelEnabled then return end
		noperfect()
		task.wait(2)
		autoReelConnection = RunService.RenderStepped:Connect(autoReel)
	elseif ReelMode == "Blatant" then
		local reel = PlayerGui:FindFirstChild("reel")
		if not reel then return end
		local bar = reel:FindFirstChild("bar")
		local playerbar = bar and bar:FindFirstChild("playerbar")
		playerbar:GetPropertyChangedSignal('Position'):Wait()
		game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
	end
end

local function stopAutoReel()
	if autoReelConnection then
		autoReelConnection:Disconnect()
		autoReelConnection = nil
	end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
	if autoReelEnabled and descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
		startAutoReel()
	end
end)

PlayerGui.DescendantRemoving:Connect(function(descendant)
	if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
		stopAutoReel()
		if autoCastEnabled then
			task.wait(1)
			autoCast()
		end
	end
end)

if autoReelEnabled and PlayerGui:FindFirstChild("reel") and 
	PlayerGui.reel:FindFirstChild("bar") and 
	PlayerGui.reel.bar:FindFirstChild("playerbar") then
	startAutoReel()
end

-- // // // Zone Cast // // // --
ZoneConnection = LocalCharacter.ChildAdded:Connect(function(child)
	if ZoneCast and child:IsA("Tool") and FishingZonesFolder:FindFirstChild(Zone) ~= nil then
		child.ChildAdded:Connect(function(blehh)
			if blehh.Name == "bobber" then
				local RopeConstraint = blehh:FindFirstChildOfClass("RopeConstraint")
				if ZoneCast and RopeConstraint ~= nil then
					RopeConstraint.Changed:Connect(function(property)
						if property == "Length" then
							RopeConstraint.Length = math.huge
						end
					end)
					RopeConstraint.Length = math.huge
				end
				task.wait(1)
				while WaitForSomeone(RenderStepped) do
					if ZoneCast and blehh.Parent ~= nil then
						task.wait()
						blehh.CFrame = FishingZonesFolder[Zone].CFrame
					else
						break
					end
				end
			end
		end)
	end
end)

-- // Find TpSpots // --
local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
for i, v in pairs(TpSpotsFolder:GetChildren()) do
	if table.find(teleportSpots, v.Name) == nil then
		table.insert(teleportSpots, v.Name)
	end
end

-- // // // Get Position // // // --
function GetPosition()
	if not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return {
			Vector3.new(0,0,0),
			Vector3.new(0,0,0),
			Vector3.new(0,0,0)
		}
	end
	return {
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.X,
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Y,
		game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Z
	}
end

function ExportValue(arg1, arg2)
	return tonumber(string.format("%."..(arg2 or 1)..'f', arg1))
end

-- // // // Sell Item // // // --
function rememberPosition()
	spawn(function()
		local initialCFrame = HumanoidRootPart.CFrame

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = HumanoidRootPart

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 100
		bodyGyro.P = 10000
		bodyGyro.CFrame = initialCFrame
		bodyGyro.Parent = HumanoidRootPart

		while AutoFreeze do
			HumanoidRootPart.CFrame = initialCFrame
			task.wait(0.01)
		end
		if bodyVelocity then
			bodyVelocity:Destroy()
		end
		if bodyGyro then
			bodyGyro:Destroy()
		end
	end)
end
function SellHand()
	local currentPosition = HumanoidRootPart.CFrame
	local sellPosition = CFrame.new(464, 151, 232)
	local wasAutoFreezeActive = false
	if AutoFreeze then
		wasAutoFreezeActive = true
		AutoFreeze = false
	end
	HumanoidRootPart.CFrame = sellPosition
	task.wait(0.5)
	workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sell"):InvokeServer()
	task.wait(1)
	HumanoidRootPart.CFrame = currentPosition
	if wasAutoFreezeActive then
		AutoFreeze = true
		rememberPosition()
	end
end
function SellAll()
	local currentPosition = HumanoidRootPart.CFrame
	local sellPosition = CFrame.new(464, 151, 232)
	local wasAutoFreezeActive = false
	if AutoFreeze then
		wasAutoFreezeActive = true
		AutoFreeze = false
	end
	HumanoidRootPart.CFrame = sellPosition
	task.wait(0.5)
	workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sellall"):InvokeServer()
	task.wait(1)
	HumanoidRootPart.CFrame = currentPosition
	if wasAutoFreezeActive then
		AutoFreeze = true
		rememberPosition()
	end
end

-- // // // Noclip Stepped // // // --
NoclipConnection = RunService.Stepped:Connect(function()
	if Noclip == true then
		if LocalCharacter ~= nil then
			for i, v in pairs(LocalCharacter:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide == true then
					v.CanCollide = false
				end
			end
		end
	end
end)

-- // // // Dupe // // // --
local DupeEnabled = false
local DupeConnection
local function autoDupe()
	local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
	if hud then
		local safezone = hud:FindFirstChild("safezone")
		if safezone then
			local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
			if bodyAnnouncements then
				local offerFrame = bodyAnnouncements:FindFirstChild("offer")
				if offerFrame and offerFrame:FindFirstChild("confirm") then
					firesignal(offerFrame.confirm.MouseButton1Click)
				end
			end
		end
	end
end

local function startAutoDupe()
	if DupeConnection or not DupeEnabled then return end
	DupeConnection = RunService.RenderStepped:Connect(autoDupe)
end

local function stopAutoDupe()
	if DupeConnection then
		DupeConnection:Disconnect()
		DupeConnection = nil
	end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
	if DupeEnabled and descendant.Name == "confirm" and descendant.Parent and descendant.Parent.Name == "offer" then
		local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
		if hud then
			local safezone = hud:FindFirstChild("safezone")
			if safezone then
				local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
				if bodyAnnouncements then
					local offerFrame = bodyAnnouncements:FindFirstChild("offer")
					if offerFrame and offerFrame:FindFirstChild("confirm") then
						firesignal(offerFrame.confirm.MouseButton1Click)
					end
				end
			end
		end
	end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name.." | Quantum Hub", "BloodTheme")

-- Creating Tabs
local HomeTab = Window:NewTab("Home")
local MainTab = Window:NewTab("Main")
local ItemsTab = Window:NewTab("Items")
local TeleportsTab = Window:NewTab("Teleports")
local MiscTab = Window:NewTab("Misc")


-- Creating Sections

-- Home Tab
local HomeSection = HomeTab:NewSection("Home")

-- Main Tab
local AutoFishingSection = MainTab:NewSection("Auto Fishing")
local ModeFishingSection = MainTab:NewSection("Mode Fishing")

-- Items Tab
local SellItemsSection = ItemsTab:NewSection("Sell Items")
local TreasureSection = ItemsTab:NewSection("Treasure")

-- Teleports Tab
local TeleportsSection = TeleportsTab:NewSection("Teleports")

-- Misc Tab
local CharacterSection = MiscTab:NewSection("Character")
local MiscSection = MiscTab:NewSection("Misc")
local LoadScriptsSection = MiscTab:NewSection("Load Scripts")

-- Home
local ScripterLabel = HomeSection:NewLabel("Scripter: CoderQuantum") -- Replace YOUR NAME HERE
local GameLabel = HomeSection:NewLabel("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local PlaceIdLabel = HomeSection:NewLabel("Place ID: " .. game.PlaceId)

local AutoCastToggle = AutoFishingSection:NewToggle("Auto Cast", "Automatically casts your fishing rod", function(state)
	local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
	if state then
		autoCastEnabled = true
		if LocalPlayer.Backpack:FindFirstChild(RodName) then
			LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
		end
		if LocalCharacter then
			local tool = LocalCharacter:FindFirstChildOfClass("Tool")
			if tool then
				local hasBobber = tool:FindFirstChild("bobber")
				if not hasBobber then
					if CastMode == "Legit" then
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
						HumanoidRootPart.ChildAdded:Connect(function()
							if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
								HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
									if property == "Size" then
										if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
											VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
										end
									end
								end)
							end
						end)
					elseif CastMode == "Blatant" then
						local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
						if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
							task.wait(0.5)
							local Random = math.random(90, 99)
							rod.events.cast:FireServer(Random)
						end
					end
				end
			end
			task.wait(1)
		end
	else
		autoCastEnabled = false
	end
end)

local AutoShakeToggle = AutoFishingSection:NewToggle("Auto Shake", "Automatically shakes when fish bites", function(state)
	if state then
		autoShakeEnabled = true
		startAutoShake()
	else
		autoShakeEnabled = false
		stopAutoShake()
	end
end)

local AutoReelToggle = AutoFishingSection:NewToggle("Auto Reel", "Automatically reels in fish", function(state)
	if state then
		autoReelEnabled = true
		startAutoReel()
	else
		autoReelEnabled = false
		stopAutoReel()
	end
end)

local FreezeToggle = AutoFishingSection:NewToggle("Freeze Character", "Freezes your character in place", function(state)
	local oldpos = HumanoidRootPart.CFrame
	FreezeChar = state
	task.wait()
	while WaitForSomeone(RenderStepped) do
		if FreezeChar and HumanoidRootPart ~= nil then
			task.wait()
			HumanoidRootPart.CFrame = oldpos
		else
			break
		end
	end
end)


local CastModeDropdown = ModeFishingSection:NewDropdown("Auto Cast Mode", "Select casting mode", {"Legit", "Blatant"}, function(value)
	CastMode = value
end)

local ShakeModeDropdown = ModeFishingSection:NewDropdown("Auto Shake Mode", "Select shaking mode", {"Navigation", "Mouse"}, function(value)
	ShakeMode = value
end)

local ReelModeDropdown = ModeFishingSection:NewDropdown("Auto Reel Mode", "Select reeling mode", {"Legit", "Blatant"}, function(value)
	ReelMode = value
end)

SellItemsSection:NewButton("Sell Hand", "Sells items in hand", function()
	SellHand()
end)

SellItemsSection:NewButton("Sell All", "Sells all items", function()
	SellAll()
end)

TreasureSection:NewButton("Teleport to Jack Marrow", "Teleports to Jack Marrow", function()
	HumanoidRootPart.CFrame = CFrame.new(-2824.359, 214.311, 1518.130)
end)

TreasureSection:NewButton("Repair Map", "Repairs your treasure map", function()
	for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
		if v.Name == "Treasure Map" then
			game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
			workspace.world.npcs["Jack Marrow"].treasure.repairmap:InvokeServer()
		end
	end
end)

TreasureSection:NewButton("Collect Treasure", "Collects available treasure", function()
	for i, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
		if v.ClassName == "ProximityPrompt" then
			v.HoldDuration = 0
		end
	end
	for i, v in pairs(workspace.world.chests:GetDescendants()) do
		if v:IsA("Part") and v:FindFirstChild("ChestSetup") then 
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
			for _, v in pairs(workspace.world.chests:GetDescendants()) do
				if v.Name == "ProximityPrompt" then
					fireproximityprompt(v)
				end
			end
			task.wait(1)
		end 
	end
end)

local IslandTPDropdown = TeleportsSection:NewDropdown("Area Teleport", "Teleport to different areas", teleportSpots, function(value)
	if teleportSpots ~= nil and HumanoidRootPart ~= nil then
		xpcall(function()
			HumanoidRootPart.CFrame = TpSpotsFolder:FindFirstChild(value).CFrame + Vector3.new(0, 5, 0)
		end, function(err)
		end)
	end
end)

local TotemTPDropdown = TeleportsSection:NewDropdown("Select Totem", "Teleport to different totems", {"Aurora", "Sundial", "Windset", "Smokescreen", "Tempest"}, function(value)
	if value == "Aurora" then
		HumanoidRootPart.CFrame = CFrame.new(-1811, -137, -3282)
	elseif value == "Sundial" then
		HumanoidRootPart.CFrame = CFrame.new(-1148, 135, -1075)
	elseif value == "Windset" then
		HumanoidRootPart.CFrame = CFrame.new(2849, 178, 2702)
	elseif value == "Smokescreen" then
		HumanoidRootPart.CFrame = CFrame.new(2789, 140, -625)
	elseif value == "Tempest" then
		HumanoidRootPart.CFrame = CFrame.new(35, 133, 1943)
	end
end)

local WorldEventTPDropdown = TeleportsSection:NewDropdown("Select World Event", "Teleport to world events", {
	"Strange Whirlpool", 
	"Great Hammerhead Shark", 
	"Great White Shark", 
	"Whale Shark", 
	"The Depths - Serpent"
}, function(value)
	if value == "Strange Whirlpool" then
		local offset = Vector3.new(25, 135, 25)
		local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Isonade")
		if not WorldEvent then 
			CoreGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Not found Strange Whirlpool",
				Duration = 3
			})
			return 
		end
		HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing.Isonade.Position + offset)
	elseif value == "Great Hammerhead Shark" then
		local offset = Vector3.new(0, 135, 0)
		local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great Hammerhead Shark")
		if not WorldEvent then 
			CoreGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Not found Great Hammerhead Shark",
				Duration = 3
			})
			return 
		end
		HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great Hammerhead Shark"].Position + offset)
	elseif value == "Great White Shark" then
		local offset = Vector3.new(0, 135, 0)
		local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great White Shark")
		if not WorldEvent then 
			CoreGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Not found Great White Shark",
				Duration = 3
			})
			return 
		end
		HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great White Shark"].Position + offset)
	elseif value == "Whale Shark" then
		local offset = Vector3.new(0, 135, 0)
		local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Whale Shark")
		if not WorldEvent then 
			CoreGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Not found Whale Shark",
				Duration = 3
			})
			return 
		end
		HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Whale Shark"].Position + offset)
	elseif value == "The Depths - Serpent" then
		local offset = Vector3.new(0, 50, 0)
		local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("The Depths - Serpent")
		if not WorldEvent then 
			CoreGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Not found The Depths - Serpent",
				Duration = 3
			})
			return 
		end
		HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["The Depths - Serpent"].Position + offset)
	end
end)

TeleportsSection:NewButton("Teleport to Traveler Merchant", "Teleports to the Traveler Merchant", function()
	local Merchant = game.Workspace.active:FindFirstChild("Merchant Boat")
	if not Merchant then 
		CoreGui:SetCore("SendNotification", {
			Title = "Error",
			Text = "Merchant not found",
			Duration = 3
		})
		return 
	end
	HumanoidRootPart.CFrame = CFrame.new(game.Workspace.active["Merchant Boat"].Boat["Merchant Boat"].r.HandlesR.Position)
end)

TeleportsSection:NewButton("Create Safe Zone", "Creates a safe zone and teleports you to it", function()
	local SafeZone = Instance.new("Part")
	SafeZone.Size = Vector3.new(30, 1, 30)
	SafeZone.Position = Vector3.new(math.random(-2000,2000), math.random(50000,90000), math.random(-2000,2000))
	SafeZone.Anchored = true
	SafeZone.BrickColor = BrickColor.new("Bright purple")
	SafeZone.Material = Enum.Material.ForceField
	SafeZone.Parent = game.Workspace
	HumanoidRootPart.CFrame = SafeZone.CFrame + Vector3.new(0, 5, 0)
end)

local WalkZone = "Ocean"

local WalkOnWaterToggle = CharacterSection:NewToggle("Walk On Water", "Enables walking on water", function(state)
	for i,v in pairs(workspace.zones.fishing:GetChildren()) do
		if v.Name == WalkZone then
			v.CanCollide = state
			if v.Name == "Ocean" then
				for i,v in pairs(workspace.zones.fishing:GetChildren()) do
					if v.Name == "Deep Ocean" then
						v.CanCollide = state
					end
				end
			end
		end
	end
end)

local WalkOnWaterZoneDropdown = CharacterSection:NewDropdown("Walk On Water Zone", "Select water zone to walk on", 
	{"Ocean", "Desolate Deep", "The Depths"}, 
	function(value)
		WalkZone = value
	end
)

local WalkSpeedSlider = CharacterSection:NewSlider("Walk Speed", "Adjust walk speed", 200, 16, function(value)
	LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

local JumpHeightSlider = CharacterSection:NewSlider("Jump Height", "Adjust jump height", 200, 50, function(value)
	LocalPlayer.Character.Humanoid.JumpPower = value
end)

local NoclipToggle = CharacterSection:NewToggle("Noclip", "Enables noclip", function(state)
	Noclip = state
end)

local BypassRadarToggle = MiscSection:NewToggle("Bypass Fish Radar", "Enables/disables fish radar bypass", function(state)
	for _, v in pairs(game:GetService("CollectionService"):GetTagged("radarTag")) do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v.Enabled = state
		end
	end
end)

local BypassGPSToggle = MiscSection:NewToggle("Bypass GPS", "Enables/disables GPS bypass", function(state)
	if state then
		local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
		XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
		local Pos = GetPosition()
		local StringInput = string.format("%s, %s, %s", ExportValue(Pos[1]), ExportValue(Pos[2]), ExportValue(Pos[3]))
		XyzClone.Text = "<font color='#ff4949'>X</font><font color = '#a3ff81'>Y</font><font color = '#626aff'>Z</font>: "..StringInput
		BypassGpsLoop = game:GetService("RunService").Heartbeat:Connect(function()
			local Pos = GetPosition()
			StringInput = string.format("%s, %s, %s", ExportValue(Pos[1]), ExportValue(Pos[2]), ExportValue(Pos[3]))
			XyzClone.Text = "<font color='#ff4949'>X</font><font color = '#a3ff81'>Y</font><font color = '#626aff'>Z</font> : "..StringInput
		end)
	else
		if PlayerGui.hud.safezone.backpack:FindFirstChild("xyz") then
			PlayerGui.hud.safezone.backpack:FindFirstChild("xyz"):Destroy()
		end
		if BypassGpsLoop then
			BypassGpsLoop:Disconnect()
			BypassGpsLoop = nil
		end
	end
end)

local RemoveFogToggle = MiscSection:NewToggle("Remove Fog", "Removes fog from the game", function(state)
	if state then
		if game:GetService("Lighting"):FindFirstChild("Sky") then
			game:GetService("Lighting"):FindFirstChild("Sky").Parent = game:GetService("Lighting").bloom
		end
	else
		if game:GetService("Lighting").bloom:FindFirstChild("Sky") then
			game:GetService("Lighting").bloom:FindFirstChild("Sky").Parent = game:GetService("Lighting")
		end
	end
end)

local DayOnlyToggle = MiscSection:NewToggle("Day Only", "Makes it always daytime", function(state)
	if state then
		DayOnlyLoop = RunService.Heartbeat:Connect(function()
			game:GetService("Lighting").TimeOfDay = "12:00:00"
		end)
	else
		if DayOnlyLoop then
			DayOnlyLoop:Disconnect()
			DayOnlyLoop = nil
		end
	end
end)

local HoldDurationToggle = MiscSection:NewToggle("Hold Duration 0 sec", "Sets hold duration to 0", function(state)
	if state then
		for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
			if v.ClassName == "ProximityPrompt" then
				v.HoldDuration = 0
			end
		end
	end
end)

local DisableOxygenToggle = MiscSection:NewToggle("Disable Oxygen", "Disables oxygen system", function(state)
	LocalPlayer.Character.client.oxygen.Disabled = state
end)

MiscSection:NewButton("Copy XYZ", "Copies current position to clipboard", function()
	local XYZ = tostring(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
	setclipboard("game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(" .. XYZ .. ")")
end)

local ShowUIToggle = MiscSection:NewToggle("Show/Hide UIs", "Toggles UI visibility", function(state)
	PlayerGui.hud.safezone.Visible = state
end)

local IdentityHiderToggle = MiscSection:NewToggle("Protect Identity", "Hides personal information", function(state)
	spawn(function()
		while state do
			if UserPlayer:FindFirstChild("streak") then UserPlayer.streak.Text = "HIDDEN" end
			if UserPlayer:FindFirstChild("level") then UserPlayer.level.Text = "Level: HIDDEN" end
			if UserPlayer:FindFirstChild("level") then UserPlayer.user.Text = "HIDDEN" end
			local hud = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone")
			if hud:FindFirstChild("coins") then hud.coins.Text = "HIDDEN$" end
			if hud:FindFirstChild("lvl") then hud.lvl.Text = "HIDDEN LVL" end
			task.wait(0.01)
		end
	end)
end)

LoadScriptsSection:NewButton("Load Infinite-Yield FE", "Loads Infinite Yield admin commands", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

LoadScriptsSection:NewButton("Load RemoteSpy", "Loads Remote Spy tool", function()
    loadstring(game:HttpGetAsync("https://github.com/richie0866/remote-spy/releases/latest/download/RemoteSpy.lua"))()
end)
