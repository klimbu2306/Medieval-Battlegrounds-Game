-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Variables
local CRATER_PIECES = 17

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

function Trail.Removing(...)
	-- pass
end

function Trail.Main(...)
	local player, IceTrailId, CraterParams: {}, origin: CFrame = ...
	local Result = Trail.Raycast(origin)
	if not Result then return end
	
	--[[
		[Crater Parameters]:
		{
		Rot: number
		Radius: number
		Duration: number
		}
	--]]
	
	-- (2) Play Fireball SFX
	local speaker = Instance.new("Part")
	speaker.CanCollide, speaker.CanTouch, speaker.CanQuery = false, false, false
	speaker.CFrame = origin
	speaker.Size = Vector3.one
	speaker.Transparency = 1
	speaker.Anchored = true
	speaker.Parent = workspace.FX
	Debris:AddItem(speaker, 2)
	
	local sound = script.Blast:Clone()
	sound.Parent = speaker
	sound:Play() 
	Debris:AddItem(sound, 2)

	local Duration = CraterParams.Duration
	local Offset = CraterParams.Offset
	local LookVector = origin.LookVector
	
	local origin = CFrame.new(origin.Position + origin.RightVector * Offset + origin.LookVector * 10)
	
	local craterPieces = {}
	
	for i = 0, CRATER_PIECES - 1 do
		local y = math.random(0, 360)
		local tilt = math.random(-10, 10)

		local Part = Instance.new("Part", workspace.FX)
		Part.Size = Vector3.new(0, 0, 0)
		Part.Anchored = true
		Part.CFrame = origin * CFrame.new(0, -2.5, 0) * CFrame.new(LookVector * i * 3)
		Part.CanQuery = false
		Part.CanCollide = false
		Part.CanTouch = false
		Part.Color = Color3.fromRGB(138, 255, 247)
		Part.Material = Enum.Material.Neon
		Part.Transparency = 0
		Part.CastShadow = false
		
		local UpVector = Part.CFrame.UpVector
		Part.CFrame = Part.CFrame * CFrame.Angles(math.rad(tilt), math.rad(y), math.rad(0))
		
		local NParams = RaycastParams.new()
		NParams.FilterType = Enum.RaycastFilterType.Include
		NParams.FilterDescendantsInstances = {workspace.Map}
		
		
		Debris:AddItem(Part, 10)
		table.insert(craterPieces, Part)
	end
	
	local offset = Vector3.new(0, -2, 0)
	for _, Part: BasePart in ipairs(craterPieces) do
		local ratio = math.random(7, 10)
		local GenSize = Vector3.new(ratio, math.random(100/100, 200/100), ratio)
		local tween = TweenService:Create(Part, TweenInfo.new(Duration * 3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0), {Size = GenSize})
		tween:Play()
		
		local Smoke = script.Smoke:Clone()
		Smoke.Parent = Part
		Smoke.Enabled = true		
		Debris:AddItem(Smoke, 5)

		task.delay(3, function()
			Smoke.Enabled = false
			
			task.wait(1)
			
			local tween = TweenService:Create(Part, TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {Position = Part.Position + offset, Transparency = 1, Size = Vector3.new(0, 0, 0)})
			tween:Play()
		end)
		
		task.wait()
	end
end


return Trail
