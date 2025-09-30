-- Root
local BeltScript = {}
local DEFAULT_SPEED = 5

-- Functions
function BeltScript.Main(_self: Model)
	local lookDirection = _self.CFrame.LookVector * DEFAULT_SPEED
	_self.Velocity = lookDirection
end

return BeltScript
