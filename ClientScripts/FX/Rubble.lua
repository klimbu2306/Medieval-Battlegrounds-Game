-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- References
local Assets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Fireball")

-- Variables
local MAX_DEBRIS = 20

-- Root
local Rubble = {}

-- Functions
function Rubble.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 10, 0)).LookVector * 10
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)
	
	return Result
end

function Rubble.Main(...)
	local origin = ...
	local Result = Rubble.Raycast(origin)
	if not Result then return end
	
	for i = 1, math.random(MAX_DEBRIS/2, MAX_DEBRIS) do
		local Rubble = Assets.Rubble:Clone()
		Rubble.Size = Vector3.new(math.random(5, 20)/10, math.random(5, 20)/10, math.random(5, 20)/10)
		Rubble.Parent = workspace.FX
		Rubble.Position = Result.Position + Result.Normal * 4
		Rubble.Name = "Rubble"
		Rubble.Material = Result.Instance.Material
		Rubble.Color = Result.Instance.Color

		local BV = Instance.new("BodyVelocity", Rubble)
		BV.Velocity = Vector3.new(math.random(-40, 40), 10, math.random(-40, 40))
		BV.MaxForce = Vector3.new(99_999, 99_999, 99_999)
		BV.Name = "Velocity"
		Debris:AddItem(BV, 0.1)

		task.delay(0.5, function()
			for i, P in pairs(Rubble.AMain:GetChildren()) do
				P.Enabled = false
			end
			task.wait(1.5)
			TweenService:Create(Rubble, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Transparency = 1}):Play()
			Debris:AddItem(Rubble, 1)
		end)

		Rubble.Transparency = Result.Instance.Transparency
	end
end

return Rubble
