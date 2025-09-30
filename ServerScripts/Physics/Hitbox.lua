-- Services
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Root
local Hitbox = {}

-- Functions
function Hitbox.CreateRegion(origin: CFrame, regionSize: Vector3, duration: number?, name: string?, partType: Enum.PartType?): BasePart
	-- (0) Set default parameters for Region3 Hitbox
	name = name or "Hitbox"
	duration = duration or 0.25
	
	-- (1) Create a Temporary Region3
	local regionSize = regionSize
	local region = Instance.new("Part")
	region.Shape = partType or Enum.PartType.Block
	region.Name = name
	region.CanCollide, region.Anchored = false, true
	region.BrickColor, region.Transparency = BrickColor.new("Really red"), 1
	region.CFrame, region.Size = origin, regionSize
	region.Parent = if region.Name ~= "CounterHitbox" then workspace.Hitbox else workspace.CounterHitbox
	
	-- (2) Schedule :Destroy of Region3
	region:SetAttribute("CreatedTime", tick())
	Debris:AddItem(region, duration)
	
	return region
end

return Hitbox
