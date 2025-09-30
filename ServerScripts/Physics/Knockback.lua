-- Services
local Debris = game:GetService("Debris")

-- Root
local Knockback = {}

-- Functions
function Knockback.ApplyForce(player: Player, character: Character, velocity: Vector3, duration: number?)
	duration = duration or 0.16
	
	-- (1) Add Body Gyro to character, to force them Upright at all times
	local BodyGyro = script.UprightGyro:Clone()
	BodyGyro.Parent = character.HumanoidRootPart
	Debris:AddItem(BodyGyro, duration)
	
	-- (2) Apply Force to Character
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(2.5e4, 2.5e4, 2.5e4)
	BodyVelocity.Velocity = velocity
	BodyVelocity.Parent = character.HumanoidRootPart
	
	Debris:AddItem(BodyVelocity, duration)
	
	-- (3) Set Network Ownership if the Target is an NPC (and NOT another Player!!)
	if character:FindFirstChild("MarkerForNPC") then
		pcall(function()
			local primaryPart: BasePart = character.PrimaryPart
			primaryPart:SetNetworkOwner(player)
		end)
	end
end

function Knockback.ApplyFixedForce(player: Player, character: Model, position: Vector3, duration: number?, properties: {}?): AlignPosition
	duration = duration or 0.5
	properties = properties or {}
	
	-- (1) Add Align Position to Target
	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	AlignPosition.Attachment0 = character.HumanoidRootPart.RootAttachment
	AlignPosition.MaxForce = properties.MaxForce or 5e4
	AlignPosition.Position = position
	AlignPosition.Parent = character
	if properties.MaxVelocity then AlignPosition.MaxVelocity = properties.MaxVelocity end
	Debris:AddItem(AlignPosition, duration * 1.1)
	
	-- (2) Set Network Ownership if the Target is an NPC (and NOT another Player!!)
	if character:FindFirstChild("MarkerForNPC") then
		pcall(function()
			local primaryPart: BasePart = character.PrimaryPart
			primaryPart:SetNetworkOwner(player)
		end)
	end
		
	return AlignPosition
end

function Knockback.PlayerToTargetLookVector(player: Player, target: Model): Vector3
	-- (1) Get XZ Coordinates of Target and Player
	local playerXYPos = Vector3.new(player.Character.HumanoidRootPart.Position.X, 0, player.Character.HumanoidRootPart.Position.Z)
	local targetXYPos = Vector3.new(target.HumanoidRootPart.Position.X, 0, target.HumanoidRootPart.Position.Z)
	
	-- (2) Then, get their direction towards each other on a XZ Axis/Flat Plane
	local pointTowardsTarget = CFrame.new(playerXYPos, targetXYPos).LookVector
	
	return pointTowardsTarget
end

return Knockback
