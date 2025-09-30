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
local ExcaliburClient = {}

-- Functions
function ExcaliburClient.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function ExcaliburClient.Removing(...)
	-- pass
end

function ExcaliburClient.Main(...)
	local player, healId, HealingParams: {}, origin: CFrame = ...
	
	local character: Model = player.Character
	if not character then return end
	
	-- (1) Create Excalibur Sword
	local LIFE_TIME = 2

	local ExcaliburSword: Model = script.Sword:Clone()
	ExcaliburSword:PivotTo(character["Right Arm"].CFrame)
	ExcaliburSword.Parent = workspace.FX
	Debris:AddItem(ExcaliburSword, LIFE_TIME)
	
	-- (2) Tween Excalibur Sword Fade
	local FADE_TIME = 0.5
	for _, part: BasePart in ExcaliburSword:GetChildren() do
		local fadeIn: Tween = TweenService:Create(part, TweenInfo.new(FADE_TIME), {Transparency = 0})
		fadeIn:Play()
	end
	
	task.delay(FADE_TIME, function()
		for _, part: BasePart in ExcaliburSword:GetChildren() do
			local fadeIn: Tween = TweenService:Create(part, TweenInfo.new(FADE_TIME), {Transparency = 1})
			fadeIn:Play()
		end
	end)
	
	-- (3) Animate Excalibur Sword onto Player's Arm
	local startTime = time()
	
	local connection: RBXScriptSignal
	connection = RunService.RenderStepped:Connect(function(dt: number)
		if time() >= startTime + LIFE_TIME then
			connection:Disconnect(); connection = nil
			return
		end
		
		local armCFrame: CFrame = character["Right Arm"].CFrame 
		local newPosition = armCFrame + armCFrame.UpVector * -1.25 + armCFrame.LookVector * 4
		newPosition *= CFrame.Angles(math.rad(-90), 0, 0)
		ExcaliburSword:PivotTo(newPosition)
	end)
end


return ExcaliburClient
