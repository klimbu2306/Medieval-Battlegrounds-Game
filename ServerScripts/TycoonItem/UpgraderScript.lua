-- Root
local UpgraderScript = {}

-- Functions
function UpgraderScript.Main(_self: Model)
	local Gate = _self.Gate

	Gate.Touched:Connect(function(hit)
		local isDropper = hit.Parent.Name == "DropperParts"
		if not isDropper then return end
		
		hit.Material = "Neon"
	end)
end

return UpgraderScript
