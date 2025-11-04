-- Root
local EndLag = {}

-- Functions
function EndLag.EndLagInterrupt(character: Model, abilityName: string)
	for _, obj: StringValue in pairs(character:GetChildren()) do
		if obj.Name ~= "EndLag" then continue end
				
		-- (1) End Lag must exist from a given attack
		if obj.Value ~= abilityName then return true end
	end
	
	return false
end

return EndLag
