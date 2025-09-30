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
local DivineGraceClient = {}

-- Functions
function DivineGraceClient.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function DivineGraceClient.Removing(...)
	-- pass
end

function DivineGraceClient.Main(...)
	local player, healId, HealingParams: {}, origin: CFrame = ...
	
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
	Debris:AddItem(Speaker, 1)
	
	local HealSFX = script.Heal:Clone()
	HealSFX.Parent = Speaker
	HealSFX:Play()
	Debris:AddItem(HealSFX, 1)
	
	-- (2) Add Arcane Ring FX
	local RingIndicator = script.RingIndicator:Clone()
	RingIndicator.Position = origin.Position - Vector3.new(0, 2.5, 0)
	RingIndicator.Parent = workspace
	Debris:AddItem(RingIndicator, 1)
	
	-- (3) Add Heal Sparkles FX
	RingIndicator.Sparkle:Emit(10)
	
	-- (4) Animate a Fade-In/Fade-Out for the Ring Indicator and a Point Light
	local tweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	
	local fadeInIndicator = TweenService:Create(RingIndicator.Decal, tweenInfo, {Transparency = 0})
	fadeInIndicator:Play()
	
	local brightenTween = TweenService:Create(RingIndicator.PointLight, tweenInfo, {Brightness = 10})
	brightenTween:Play()
	
	task.delay(0.5, function()
		local brightenTween = TweenService:Create(RingIndicator.PointLight, tweenInfo, {Brightness = 0})
		brightenTween:Play()
		
		local fadeOutIndicator = TweenService:Create(RingIndicator.Decal, tweenInfo, {Transparency = 1})
		fadeOutIndicator:Play()
	end)
	
	-- (5) Animate a Spin FX for the Ring Indicator
	while wait() and RingIndicator.Parent ~= nil do
		if not RingIndicator or RingIndicator.Parent == nil then break end
		RingIndicator.CFrame = RingIndicator.CFrame * CFrame.Angles(math.rad(10), 0, 0)
	end
end
return DivineGraceClient
