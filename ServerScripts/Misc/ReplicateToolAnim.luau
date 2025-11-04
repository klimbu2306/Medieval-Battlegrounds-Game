-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Animation = Remotes:WaitForChild("Animation")

-- Functions
Animation.SwitchToolGrip.OnServerEvent:connect(function(player: Player, grip: CFrame)
	-- (0) Type-check & Sanity-check ALL Parameters
	if (not grip) or (typeof(grip) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: AbilityName DataType passed in was NOT a CFrame value!`) return end
	
	-- (1) Switch Character's Tool Grip
	local character = player.Character
	if not character then return end
	
	local rightArm = character:FindFirstChild("Right Arm"); if not rightArm then return end
	local grip = rightArm:FindFirstChild("RightGrip"); if not grip then return end
	local leftArm = character:FindFirstChild("Left Arm"); if not leftArm then return end
	
	grip.Name = "LeftGrip"
	grip.Parent = leftArm
	grip.Part0 = leftArm
end)
