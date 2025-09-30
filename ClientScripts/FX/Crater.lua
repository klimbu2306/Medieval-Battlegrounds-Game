-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- References
local Assets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Fireball")

-- Variables
local CRATER_PIECES = 16

-- Root
local Crater = {}

-- Functions
function Crater.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function Crater.Main(...)
	local CraterParams, origin = ...
	local Result = Crater.Raycast(origin)
	if not Result then return end
	
	--[[
		[Crater Parameters]:
		{
		Rot: number
		Radius: number
		Duration: number
		}
	--]]

	local Rot, Radius, Duration = CraterParams.Rotation, CraterParams.Radius, CraterParams.Duration
	
	for i = 0, CRATER_PIECES - 1 do
		local x = (2 * math.pi * Radius)/CRATER_PIECES
		local y = math.random(Radius * .1 * 10, Radius * 0.3 * 10)/10
		local z = math.random(Radius * .1 * 10, Radius * 0.3 * 10)/10

		local Part = Instance.new("Part", workspace.FX)
		Part.Size = Vector3.new(x, y, z)
		Part.Anchored = true
		Part.CFrame = CFrame.new(Result.Position, Result.Position + Result.Normal)
		Part.CFrame = Part.CFrame * CFrame.Angles(math.rad(90), math.rad(i - 1) * 360/CRATER_PIECES, 0) * CFrame.new(0, 0, -Radius) * CFrame.Angles(math.rad(Rot), 0, 0)
		Part.CanQuery = false
		Part.CanCollide = false
		Part.CanTouch = false
		Part.CastShadow = false

		local NParams = RaycastParams.new()
		NParams.FilterType = Enum.RaycastFilterType.Include
		NParams.FilterDescendantsInstances = {workspace.Map}

		local Detect = workspace:Raycast(Part.Position + Result.Normal * 4, Result.Normal * -7, NParams)
		if Detect then
			Part.Position = Detect.Position
			Part.Material = Detect.Material
			Part.Color = Detect.Instance.Color
			Part.Position = Part.Position + Result.Normal * -4
			TweenService:Create(Part, TweenInfo.new(Duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Position = Part.Position + Result.Normal * 4}):Play()

			task.spawn(function()
				Debris:AddItem(Part, 4)
				task.wait(4)
				TweenService:Create(Part, TweenInfo.new(Duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Position = Part.Position + Result.Normal * -8}):Play()
			end)
		else
			Part:Destroy()
		end
	end
end

return Crater
