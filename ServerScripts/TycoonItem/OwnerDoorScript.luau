-- Services
local Players = game:GetService("Players")

-- Variables
local CONSTRUCTION_TIME = 2

-- Root
local OwnerDoorScript = {}

-- Functions
function OwnerDoorScript.EnableLasers(_self: Model, value: boolean)
	local lasers = _self.Lasers

	local laserLight = lasers:WaitForChild("Light")
	if not laserLight then warn("Error: No Laser found!") return end
	
	laserLight.Transparency = if value then 0 else 1

	_self:SetAttribute("Activated", value)

	if value then
		OwnerDoorScript.LaserHitRegion(_self)
	end
end

function OwnerDoorScript.DetectLaserHit(_self: Model, hit: BasePart)
	local lasers = _self.Lasers
	local plot = _self.Parent.Parent

	-- (1) Check whether a Player has hit the Laser
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	-- (2) Check that that Player is not the Plot Owner
	local ownerId = plot:GetAttribute("Owner")
	local isOwner = (player.UserId == ownerId)
	if isOwner then return end

	-- (3) Kill the Player, if Lasers are Enabled
	if not _self:GetAttribute("Activated") then return end
	player.Character.Humanoid.Health = 0
end

function OwnerDoorScript.LaserHitRegion(_self: Model)
	local lasers = _self.Lasers
	local touchingParts = workspace:GetPartBoundsInBox(lasers.PrimaryPart.CFrame, lasers.PrimaryPart.Size)
	for _, hit: BasePart in touchingParts do
		OwnerDoorScript.DetectLaserHit(_self, hit)
	end
end

function OwnerDoorScript.SetupLaserHitbox(_self: Model)
	local lasers: Model = _self.Lasers
	local plot = _self.Parent.Parent

	lasers.PrimaryPart.Touched:Connect(function(hit)
		OwnerDoorScript.DetectLaserHit(_self, hit)
	end)
end

function OwnerDoorScript.Main(_self: Model)
	local button: ClickDetector = _self.Button.PrimaryPart:WaitForChild("ClickDetector")

	task.wait(CONSTRUCTION_TIME)
	if not button or button.Parent == nil then return end
	
	-- (1) Setup Button so it can Toggle Lasers
	button.MouseClick:Connect(function(player: Player)
		local plot: BasePart = button:FindFirstAncestor("Plot")
		local plotOwnerId: number = plot:GetAttribute("Owner")
		if player.UserId ~= plotOwnerId then return end
		
		OwnerDoorScript.EnableLasers(_self, not _self:GetAttribute("Activated"))
	end)
	
	-- (2) Setup Kill Damage on Lasers
	OwnerDoorScript.SetupLaserHitbox(_self)
	OwnerDoorScript.EnableLasers(_self, false)
end

return OwnerDoorScript
