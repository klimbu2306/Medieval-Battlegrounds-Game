-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Variables
local CRATER_PIECES = 16

-- Root
local Trail = {}

-- Functions
function Trail.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function Trail.Main(...)
	local CraterParams: {}, origin: CFrame = ...
	local Result = Trail.Raycast(origin)
	if not Result then return end
	
	--[[
		[Crater Parameters]:
		{
		AnimationTime: number
		Offset: number
		SizeRange: {number1, number2}
		Radius: number
		Duration: number
		}
	--]]
	
	local AnimationTime = CraterParams.AnimationTime
	local Offset = CraterParams.Offset
	local LookVector = origin.LookVector
	local Duration = CraterParams.Duration
	local SizeRange = CraterParams.SizeRange
	
	local origin = CFrame.new(origin.Position + origin.RightVector * Offset)
		
	local x = math.random(0, 360)
	local y = math.random(0, 360)
	local z = math.random(0, 360)

	local Part = Instance.new("Part", workspace.FX)
	Part.Size = Vector3.one * math.random(SizeRange[1], SizeRange[2])
	Part.Anchored = true
	Part.CFrame = origin * CFrame.new(0, -2.5, 0)
	Part.CanQuery = false
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CastShadow = false
	
	local UpVector = Part.CFrame.UpVector
	Part.CFrame = Part.CFrame * CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
	
	local NParams = RaycastParams.new()
	NParams.FilterType = Enum.RaycastFilterType.Include
	NParams.FilterDescendantsInstances = {workspace.Map}
	
	--local Detect = workspace:Raycast(Part.Position + Result.Normal * 4, Result.Normal * -5, NParams)
	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Detect = workspace:Raycast(origin.Position,  pointToTarget, NParams)

	if Detect then
		Part.Position = Vector3.new(Part.Position.X, Detect.Position.Y, Part.Position.Z)
		Part.Material = Detect.Material
		Part.Color = Detect.Instance.Color
		
		Debris:AddItem(Part, AnimationTime + Duration)
	else
		Part:Destroy()
	end
		
	local offset = Vector3.new(0, -2.5, 0)
	task.delay(Duration, function()
		local tween = TweenService:Create(Part, TweenInfo.new(AnimationTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Position = Part.Position + offset, Transparency = 1})
		tween:Play()
	end)
end



return Trail
