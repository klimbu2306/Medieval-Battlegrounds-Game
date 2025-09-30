-- Services
local Players = game:GetService("Players")

-- Root
local PlatformStand = {}

-- Functions
function PlatformStand.IsPlayerStanding(character: Model): boolean
	local humanoid: Humanoid = character.Humanoid
	local hipHeight = humanoid.HipHeight
	
	local rayOrigin = character.HumanoidRootPart.Position
	local rayDirection = Vector3.new(0, -hipHeight - 5, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character, workspace.Hitbox, workspace.FX, workspace.CounterHitbox}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if not raycastResult then return false end
	
	local TouchingGround: boolean = (raycastResult.Instance:IsDescendantOf(workspace.Map) == true)  or (raycastResult.Instance:IsDescendantOf(workspace.TycoonHitbox.Floor) == true)
	if TouchingGround then
		return true
	end
	
	warn("Error! Could not detect a Floor!")
	return false
end

return PlatformStand
