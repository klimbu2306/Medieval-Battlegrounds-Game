-- Services
local Debris = game:GetService("Debris")

-- Root
local LockPosition = {}

-- Function
function LockPosition.LockRotation(character: Model, duration: number)
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	humanoid.AutoRotate = false

	task.delay(duration, function()
		humanoid.AutoRotate = true
	end)
end

function LockPosition.Lock(character: Model, origin: CFrame, duration: number, rotation: boolean?)
	local BodyGyro = Instance.new("BodyGyro", character.HumanoidRootPart)
	BodyGyro.CFrame = CFrame.new(character.HumanoidRootPart.Position, origin.Position)
	BodyGyro.MaxTorque = Vector3.one * 9999
	BodyGyro.P = 12_500
	BodyGyro.D = 12_500
	BodyGyro.Name = "Align"

	local BodyPosition = Instance.new("BodyPosition", character.HumanoidRootPart)
	BodyPosition.Position = character.HumanoidRootPart.Position
	BodyPosition.MaxForce = Vector3.one * 9999
	BodyPosition.P = 12_500
	BodyPosition.D = 12_500
	BodyPosition.Name = "Position"
	
	Debris:AddItem(BodyGyro, duration)
	Debris:AddItem(BodyPosition, duration)
	
	if rotation then LockPosition.LockRotation(character, duration) end
end

return LockPosition
