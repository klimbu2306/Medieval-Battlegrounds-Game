-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Modules
local FX = ReplicatedStorage:WaitForChild("FX")
local CraterModule = require(FX:WaitForChild("Crater"))

-- References
local Assets = ReplicatedStorage:WaitForChild("Assets")
local LightningFX = Assets:WaitForChild("Lightning")

-- Variables
local CRATER_PIECES = 17

-- Root
local AegisGuardClient = {}

-- Functions
function AegisGuardClient.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function AegisGuardClient.Removing(...)
	-- pass
end

function AegisGuardClient.Main(...)
	local player, healId, HealingParams: {}, origin: CFrame = ...
	
	local LIFE_TIME = 2
	
	-- (1) Play Healing VFX + SFX
	local Speaker = Instance.new("Part")
	Speaker.CanCollide = false
	Speaker.CanTouch = false
	Speaker.CanQuery = false
	Speaker.Anchored = true
	Speaker.Size = Vector3.one
	Speaker.Transparency = 1
	Speaker.CFrame = origin --player.Character.PrimaryPart.CFrame
	Speaker.Parent = workspace.FX
	Debris:AddItem(Speaker, LIFE_TIME)
	
	local HealSFX = script.Heal:Clone()
	HealSFX.Parent = Speaker
	HealSFX:Play()
	Debris:AddItem(HealSFX, LIFE_TIME)
	
	-- (2) Add Arcane Ring FX + Aegis Shield FX
	local RingIndicator = script.RingIndicator:Clone()
	RingIndicator.Position = origin.Position - Vector3.new(0, 2.5, 0)
	RingIndicator.Parent = workspace
	Debris:AddItem(RingIndicator, LIFE_TIME)
	
	local AegisShield = script.Shield:Clone()
	AegisShield.Position = origin.Position
	AegisShield.Parent = workspace
	Debris:AddItem(AegisShield, LIFE_TIME)
	
	-- (3) Animate a Fade-In/Fade-Out for the Ring Indicator and a Point Light
	local tweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	
	local fadeInIndicator = TweenService:Create(RingIndicator.Decal, tweenInfo, {Transparency = 0})
	fadeInIndicator:Play()
	
	local brightenTween = TweenService:Create(RingIndicator.PointLight, tweenInfo, {Brightness = 3})
	brightenTween:Play()
	
	local fadeInShield = TweenService:Create(AegisShield, tweenInfo, {Transparency = 0})
	fadeInShield:Play()
	
	task.delay(1, function()
		local brightenTween = TweenService:Create(RingIndicator.PointLight, tweenInfo, {Brightness = 0})
		brightenTween:Play()
		
		local fadeOutIndicator = TweenService:Create(RingIndicator.Decal, tweenInfo, {Transparency = 1})
		fadeOutIndicator:Play()
		
		local fadeOutShield = TweenService:Create(AegisShield, tweenInfo, {Transparency = 1})
		fadeOutShield:Play()
	end)
	
	-- (4) Animate a Spin FX for the Ring Indicator
	local connection: RBXScriptSignal
	local startTime = time()
	
	connection = RunService.RenderStepped:Connect(function()
		if time() >= startTime + LIFE_TIME
			or (not RingIndicator or RingIndicator.Parent == nil) then
			connection:Disconnect(); connection = nil
			return
		end
		
		RingIndicator.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, -2.5, 0)
		RingIndicator.CFrame = RingIndicator.CFrame * CFrame.Angles(math.rad(1), 0, 0)
		AegisShield.Position = player.Character.HumanoidRootPart.Position
	end)
	
	task.delay(LIFE_TIME, function()
		if not connection then return end
		connection:Disconnect(); connection = nil
	end)
end


return AegisGuardClient
