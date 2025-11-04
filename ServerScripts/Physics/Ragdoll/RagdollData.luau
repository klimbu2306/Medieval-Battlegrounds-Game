-- Variables
local BODYPARTS = {
	["Neck"] = "Head",
	["Right Shoulder"] = "Right Arm",
	["Left Shoulder"] = "Left Arm",
	["Right Hip"] = "Right Leg",
	["Left Hip"] = "Left Leg",
}

-- Roots
local RagdollData = {}

-- Data
RagdollData.Offsets = {
	Head = {
		CFrame = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)}
	},
	HumanoidRootPart = {
		CFrame = {CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)}
	},
	["Right Arm"] = {
		CFrame = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
	},
	["Left Arm"] = {
		CFrame = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)}
	},
	["Right Leg"] = {
		CFrame = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)}
	},
	["Left Leg"] = {
		CFrame = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)}
	}
}

-- Functions
function RagdollData.GetBodyPartFromJoint(jointName: string)
	return BODYPARTS[jointName]
end

return RagdollData
