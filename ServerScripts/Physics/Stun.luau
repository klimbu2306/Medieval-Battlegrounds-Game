-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Modules
local Speed = require(script.Parent.Speed)

-- Root
local Stun = {}

-- Functions
function Stun.InterruptAllAnimations(character: Model)
	-- (0) Find Animator Object of Target
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local animator: Animator = humanoid:FindFirstChild("Animator")
	if not animator then return end
	
	-- (1) Interrupt playing Target Animations
	local getPlayingAnimationTracks = animator:GetPlayingAnimationTracks()
	
	local PriorityAnimations = {Enum.AnimationPriority.Action, Enum.AnimationPriority.Action2, Enum.AnimationPriority.Action3}
	
	-- (2) Only Stop All "Action" priority tracks of the Target, to filter out Core or Walk Animations
	for _, animTrack: AnimationTrack in getPlayingAnimationTracks do
		if table.find(PriorityAnimations, animTrack.Priority) then
			animTrack:Stop()
		end
	end
end

function Stun.ApplyStun(character: Model, duration: number?)
	-- (0) Interrupt all Target's animations so that a Stun Animation can :Play()
	Stun.InterruptAllAnimations(character)
	
	-- (1) Setup Temporary stun marker
	duration = duration or 1
	
	local stunMarker = Instance.new("ObjectValue")
	stunMarker.Name = "Stunned"
	stunMarker.Parent = character
	
	-- (2) Schedule :Destroy() on stun marker & Reset Character Speed back to Normal
	Debris:AddItem(stunMarker, duration)
	Speed.ResetSpeedOnDestroy(character, stunMarker)
	
	return stunMarker
end

return Stun
