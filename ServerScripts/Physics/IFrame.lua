-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Root
local IFrames = {}

-- Functions
function IFrames.ApplyIFrames(character: Model, duration: number?)	
	-- (1) Setup Temporary stun marker
	duration = duration or 1
	
	local iFrameMarker = Instance.new("ObjectValue")
	iFrameMarker.Name = "I-Frame"
	iFrameMarker.Parent = character
	
	-- (2) Schedule :Destroy() on stun marker & Reset Character Speed back to Normal
	Debris:AddItem(iFrameMarker, duration)
end

return IFrames
