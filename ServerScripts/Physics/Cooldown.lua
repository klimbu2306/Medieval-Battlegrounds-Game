-- Services
local Debris = game:GetService("Debris")

-- Root
local Cooldown = {}

-- Functions
function Cooldown.SetCooldown(character: Model, abilityName: string, cooldown: number)
	local AbilityMarker = Instance.new("IntValue")
	AbilityMarker.Name = abilityName
	AbilityMarker.Value = cooldown
	AbilityMarker.Parent = character
	
	Debris:AddItem(AbilityMarker, cooldown)
end

function Cooldown.SetEndlag(character: Model, abilityName: string, cooldown: number)
	local AbilityMarker = Instance.new("StringValue")
	AbilityMarker.Name = "EndLag"
	AbilityMarker.Value = abilityName
	AbilityMarker.Parent = character
 
	Debris:AddItem(AbilityMarker, cooldown)
end

return Cooldown
