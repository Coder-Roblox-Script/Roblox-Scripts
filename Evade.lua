local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleHighlightESP.lua"))()
local CoreGui = game:GetService('StarterGui')
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


local eventTaunts = {
	"CursedFlashlight",
	"WerewolfHowl",
	"Tombstone",
	"Baghead",
	"DemonHorns",
	"Candlehead",
	"ImpaledHead",
	"WitchHat",
	"DualBoneSwords",
	"LavaLamp",
	"SpiderInfestation",
	"PumpItUp",
	"VampireOutfit",
	"OminousDemise",
	"BlueHallowedFace",
	"GreenHallowedFace",
	"OrangeHallowedFace",
	"GhostCatcher",
	"DemonWings",
	"CandleLamp",
	"FungalOvergrowth",
	"Reanimated",
	"ToxicInferno",
	"Monoculi",
	"WretchedWings",
	"PhantomBlades",
	"AmethystStaff",
	"GhostAbduction",
	"Telespell",
	"Thriller",
	"BluefirePortal",
	"HellfirePortal",
	"SeekingEye",
	"EyeCorruption",
	"Necromonicon",
	"FrightFunk",
	"BlueUFOAbduction",
	"PinkUFOAbduction",
	"Cauldronhead",
	"HellishGrip",
	"HauntedIredescence",
	"CobwebTrap",
	"MechanicalScythe",
	"DragonSkull",
	"GhostFriend",
	"SpilledCauldron",
	"WardingLantern",
	"RockinStride",
	"Rockin'Stride",
	"DarkTendrils",
	"AlchemistBelt",
	"Frankenstein",
	"ElectrifyingGuitar",
	"BatVision",
	"BananaSuit",
	"EyeIllusions",
	"BroomOfDoom",
	"BloodMoon"
}

getgenv().respawning = false
getgenv().flly = false
getgenv().cframespeed = false
getgenv().cfspeed = 0
getgenv().autobuy = false

-- [[ FUNCTIONS ]]

function f()
	UIS = game:GetService("UserInputService")
	while getgenv().cframespeed and task.wait() do
		if getgenv().cfspeed ~= getgenv().cfspeed then
			break
		end
		repeat
			task.wait()
		until game.Players.LocalPlayer.Character or workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
		You = game.Players.LocalPlayer.Character or workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
		hrp = You:WaitForChild("HumanoidRootPart", 0.1)
		if not hrp then
			repeat
				task.wait()
			until You:FindFirstChild('HumanoidRootPart')
		end
		hrp = You.HumanoidRootPart
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			hrp.CFrame =
				hrp.CFrame * CFrame.new(0, 0, -getgenv().cfspeed)
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			hrp.CFrame =
				hrp.CFrame * CFrame.new(-getgenv().cfspeed, 0, 0)
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			hrp.CFrame =
				hrp.CFrame * CFrame.new(0, 0, getgenv().cfspeed)
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			hrp.CFrame =
				hrp.CFrame * CFrame.new(getgenv().cfspeed, 0, 0)
		end
	end
end

function bb()
	while getgenv().breakbots do
		n = math.random(1, 10000000)
		z = math.random(200, 8000)
		x = math.random(1, 10000000)
		if not getgenv().breakbots then
			break
		end
		if game:GetService("Workspace").Game:WaitForChild('Map'):WaitForChild('Parts'):FindFirstChild("KillBricks") then
			game:GetService("Workspace").Game:WaitForChild('Map').KillBricks:Destroy()
		end
		task.wait()
		game.Workspace.Game.Players:WaitForChild(game.Players.LocalPlayer.Name):WaitForChild("HumanoidRootPart").CFrame =
			CFrame.new(0, z, 0)
	end
end

function annoydown()
	if annoydowned then
		CoreGui:SetCore("SendNotification", {
			Title = "Warning",
			Text = "this will most likely break without Auto Respawn",
			Duration = 3
		})
	end
	while task.wait() do
		if not getgenv().annoydowned then
			break
		end
		pcall(
			function()
				game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(250, 250, 250)
				for i, v in next, game:GetService("Workspace").Game.Players:GetDescendants() do
					if
						v.IsA(v, "NumberValue") and v.Name == "Downed" and
						not v.Parent.Parent.Parent:FindFirstChild("CarriedBy") and
						game.Players[v.Parent.Parent.Parent.Name].Settings.CanBeCarried.Value == true
					then
						local holder = v.Parent.Parent.Parent.Name
						local hold = workspace.Game.Players[holder]
						scrip =
							require(
								game:GetService("ReplicatedStorage").ModuleStorage.Interact.Interactions.Revive.Revive
							)
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
							CFrame.new(hold.HumanoidRootPart.Position)
						task.wait(0.3)
						game:GetService("ReplicatedStorage").Events.Revive.CarryPlayer:FireServer(holder)
						task.wait(0.3)
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 3000, 0)
						task.wait(0.2)
						game:GetService("ReplicatedStorage").Events.Revive.CarryPlayer:FireServer(holder, true)
						task.wait(0.3)
					end
				end
			end
		)
	end
end

function makeNotification(type, head, body)
	notifs.new(type, head, body, true, 5)
end

function Simple_Create(base, name, trackername, studs)
	local bb = Instance.new("BillboardGui", game.CoreGui)
	bb.Adornee = base
	bb.ExtentsOffset = Vector3.new(0, 1, 0)
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 6, 0, 6)
	bb.StudsOffset = Vector3.new(0, 1, 0)
	bb.Name = trackername
	local frame = Instance.new("Frame", bb)
	frame.ZIndex = 10
	frame.BackgroundTransparency = 0.3
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	local txtlbl = Instance.new("TextLabel", bb)
	txtlbl.ZIndex = 10
	txtlbl.BackgroundTransparency = 1
	txtlbl.Position = UDim2.new(0, 0, 0, -48)
	txtlbl.Size = UDim2.new(1, 0, 10, 0)
	txtlbl.Font = "ArialBold"
	txtlbl.FontSize = "Size12"
	txtlbl.Text = name
	txtlbl.TextStrokeTransparency = 0.5
	txtlbl.TextColor3 = Color3.fromRGB(255, 255, 255)
end

function ClearESP(espname)
	for _, v in pairs(game.CoreGui:GetChildren()) do
		if v.Name == espname and v:isA("BillboardGui") then
			v:Destroy()
		end
	end
end

function nowaterdmg(t)
	for i, v in next, t:GetChildren() do
		if v.IsA(v, 'BasePart') then
			v.CanTouch = false
		end
	end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	if flly then
		repeat
			task.wait()
		until char:FindFirstChild('HumanoidRootPart')
		task.wait(3)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/CF-Trail/random/main/bypassedfly.lua"))()
	end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name.." | Quantum Hub", "BloodTheme")

local HomeTab = Window:NewTab("Home")
local MainTab = Window:NewTab("Main")
local MapTab = Window:NewTab("Map")
local TrollingTab = Window:NewTab("Troll")
local MiscTab = Window:NewTab("Misc")

local SettingsSection = MainTab:NewSection("Settings")
local PlayerSection = MainTab:NewSection("Player")
local MapSection = MapTab:NewSection("Map")
local HomeSection = HomeTab:NewSection("Home")
local AutoFarmsSection = MainTab:NewSection("Auto Farms")
local TrollingSection = TrollingTab:NewSection("Trolling")
local MiscSection = MiscTab:NewSection("Misc")

local ScripterLabel = HomeSection:NewLabel("Scripter: CoderQuantum") -- Replace YOUR NAME HERE
local GameLabel = HomeSection:NewLabel("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local PlaceIdLabel = HomeSection:NewLabel("Place ID: " .. game.PlaceId)

PlayerSection:NewToggle("Auto Respawn", "Auto Respawn", function(x)
	getgenv().respawning = x
	while task.wait(1) and respawning do
		if not getgenv().respawning then
			break
		end
		local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
		local stats = char:WaitForChild("StatChanges", 3)
		if stats == nil then
			return
		end
		if stats:FindFirstChild("Speed") and stats:FindFirstChild("Speed"):FindFirstChild("Downed") then
			game:GetService("ReplicatedStorage").Events.Respawn:FireServer()
		end
	end
end)

PlayerSection:NewToggle("Fly", "Fly", function(flly	)
	getgenv().flly = flyy
	if getgenv().flly then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/CF-Trail/random/main/bypassedfly.lua"))()
	else
		for i, v in next, workspace:GetChildren() do
			if v.IsA(v, "BasePart") and v.Name ~= "Terrain" then
				v:Destroy()
			end
		end
	end
end)

PlayerSection:NewToggle("Toggle Walkspeed", "Boost your speed", function(c)
	getgenv().cframespeed = c
	f()
end)

PlayerSection:NewToggle("Fast Revive", "Revive people faster", function(fastrev)
	getgenv().far = fastrev
	if getgenv().far then
		workspace.Game.Settings:SetAttribute("ReviveTime", 2.25)
	else
		workspace.Game.Settings:SetAttribute('ReviveTime', 3)
	end
end)

PlayerSection:NewToggle("No Water Damage", "Water will not damage you", function(nodmg)
	getgenv().nodmg = nodmg
	if getgenv().nodmg then
		return
	end
	getgenv().nodmg = true
	nowaterdmg(game.Players.LocalPlayer.Character)
	game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		repeat
			task.wait()
		until char:FindFirstChild('HumanoidRootPart')
		nowaterdmg(char)
	end)
end)

SettingsSection:NewSlider("Walkspeed Boost", "Walkspeed Boost", 2, 0, function(ws) -- 500 (MaxValue) | 0 (MinValue)
	getgenv().cfspeed = ws
end)

MapSection:NewButton("Remove Barriers", "Remove Barriers", function()
	workspace.Game.Map.InvisParts:ClearAllChildren()
end)

MapSection:NewButton("Teleport to objective", "Teleport to objective", function()
	hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
	if workspace.Game.Map.Parts:FindFirstChild("Objectives") then
		for i, v in next, workspace.Game.Map.Parts.Objectives:GetChildren() do
			if v.IsA(v, "Model") then
				hrp.CFrame = CFrame.new(v:FindFirstChildWhichIsA("BasePart").Position)
			end
		end
	end
end)

MapSection:NewButton("Teleport to downed", "Teleport to downed player", function()
	for i, v in next, workspace.Game.Players:GetChildren() do
		if v:GetAttribute('Downed') then
			pcall(function()
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.HumanoidRootPart.Position)
			end)
		end
	end
end)

MapSection:NewButton("Show Round End Time", "Show Round End Tim", function()
	CoreGui:SetCore("SendNotification", {
		Title = "Info",
		Text = "Round will end in " .. game.Players.LocalPlayer.PlayerGui:WaitForChild("HUD").Center.Vote.Info.Read.Timer.Text,
		Duration = 5
	})
end)

AutoFarmsSection:NewToggle("Autofarm Wins", "Autofarm Wins", function(bbb)
	getgenv().breakbots = bbb
	bb()
end)

TrollingSection:NewToggle("Annoy downed", "Annoy downed player", function(down)
	getgenv().annoydowned = down
	annoydown()
end)

TrollingSection:NewToggle("Tools Spammer", "Annoy downed player", function(callback)
	getgenv().tspam = callback
	while tspam and task.wait() do
		if not tspam then
			break
		end
		for i, v in next, workspace.Game.Players:GetChildren() do
			if v and v:FindFirstChild('Equip') then
				v:FindFirstChild('Equip'):InvokeServer(2)
				continue
			else
				continue
			end
		end
	end
end)

MiscSection:NewToggle("Bot ESP", "See where bot are", function(besp)
	getgenv().botesp = besp
	task.spawn(
		function()
			while task.wait() do
				ClearESP('AI_Tracker')
				if not getgenv().botesp then
					break
				end
				pcall(function()
					local GamePlayers = workspace.Game.Players
					for i, v in pairs(GamePlayers:GetChildren()) do
						if not game.Players:FindFirstChild(v.Name) then
							Simple_Create(v.HumanoidRootPart, v.Name, "AI_Tracker")
						end
					end
				end)
			end
		end)
end)

MiscSection:NewToggle("Downed ESP", "See where downed player are", function(desp)
	getgenv().downesp = desp
	while task.wait() do
		ClearESP('Downed_ESP')
		if not getgenv().downesp then
			break
		end
		pcall(function()
			local GamePlayers = workspace:WaitForChild("Game", 1337).Players
			for i, v in pairs(GamePlayers:GetChildren()) do
				if v:GetAttribute('Downed') then
					Simple_Create(v.HumanoidRootPart, 'DOWNED PLR: ' .. v.Name, "Downed_ESP")
				end
			end
		end)
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

workspace.Game.ChildAdded:Connect(function(v)
	if v.Name == 'Map' and tspam then
		task.wait(32) -- waits for map to start
		while tspam and task.wait() do
			if not tspam then
				break
			end
			for i, v in next, workspace.Game.Players:GetChildren() do
				if v and v:FindFirstChild('Equip') then
					v:FindFirstChild('Equip'):InvokeServer(2)
					continue
				else
					continue
				end
			end
		end
	end
end)
