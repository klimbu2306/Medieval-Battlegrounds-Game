-- // Services //
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- // Variables //
local BEAM_TIME = 1
local TRANSITION_TIME = 0.25

-- // Root //
local EventBeam = {}

-- // Functions //
function EventBeam.Main(...)
	local properties = ...
	
	local EventBeam: BasePart = script.Beam:Clone()
	EventBeam.Position = Vector3.new(0, 100, 0)
	EventBeam.Parent = workspace.FX
	Debris:AddItem(EventBeam, BEAM_TIME + TRANSITION_TIME)
	
	local TweenOut: Tween = TweenService:Create(EventBeam, TweenInfo.new(TRANSITION_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		["Transparency"] = 1
	})
	task.delay(BEAM_TIME, function()
		TweenOut:Play()
	end)
end

return EventBeam
