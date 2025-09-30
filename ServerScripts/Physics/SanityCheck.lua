-- Root
local SanityCheck = {}

-- Functions
function SanityCheck.PositionIsValid(character: Model, clientOrigin: CFrame, maxDistance: number)
	local humanoidRootPart: BasePart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local discrepency = (clientOrigin.Position - humanoidRootPart.CFrame.Position).Magnitude
	if discrepency < maxDistance then
		print("Position is Sane!")
	else
		warn("Position is Insane!")
	end
end

return SanityCheck
