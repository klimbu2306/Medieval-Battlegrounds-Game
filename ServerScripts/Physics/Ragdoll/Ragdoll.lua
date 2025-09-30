-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Modules
local RagdollData = require(script.RagdollData)

-- References
local Effects = Remotes:WaitForChild("Effects")

-- Variables
local BODYPARTS = {"Head", "Left Arm", "Left Leg", "Right Leg", "Left Leg", "Torso"}

-- Root
local Ragdoll = {}

-- Functions
function Ragdoll.BuildCollisionParts(character: Model)
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			local p = v:Clone()
			p.Parent = v
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.Massless = true
			p.Size = v.Size
			p.Name = "Collide"
			p.Transparency = 1
			p:ClearAllChildren()
			
			local weld = Instance.new("Weld")
			weld.Parent = p
			weld.Part0 = v
			weld.Part1 = p
		end
	end
	
	local RagdollReady = Instance.new("ObjectValue")
	RagdollReady.Name = "RagdollReady"
	RagdollReady.Parent = character
	
	return
end

function Ragdoll.EnableCollisions(character: Model, enabled: boolean)	
	for _, v in pairs(character:GetChildren()) do
		if not v:IsA("BasePart") or v.Name == "HumanoidRootPart" then continue end
		
		local collide: BasePart = v:FindFirstChild("Collide")
		if not collide then continue end
				
		collide.CanCollide = enabled
	end
	
	return
end

function Ragdoll.EnableRagdollState(character: Model, enabled: boolean)
	local player = Players:GetPlayerFromCharacter(character)
	
	if enabled then
		local RagdollMarker = Instance.new("ObjectValue")
		RagdollMarker.Name = "RagdollState"
		RagdollMarker.Parent = character
		
		character.PrimaryPart:SetNetworkOwner(nil)
		
		if player then
			Effects.RagdollClient:FireClient(player, true)
		else
			local humanoid: Humanoid = character:FindFirstChild("Humanoid")
			humanoid.PlatformStand = true
			humanoid.AutoRotate = false
		end

	else
		local RagdollState = character:FindFirstChild("RagdollState")
		if not RagdollState then return end
		
		RagdollState:Destroy()
		
		if character:FindFirstChild("RagdollState") then return end
		
		if player then
			Effects.RagdollClient:FireClient(player, false)
		else
			local humanoid: Humanoid = character:FindFirstChild("Humanoid")
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true

			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end

	end
	
	return
end

function Ragdoll.Activate(humanoid: Humanoid)
	local character: Model = humanoid.Parent
	
	if not character:FindFirstChild("RagdollReady") then
		Ragdoll.BuildCollisionParts(character)
	end
	
	Ragdoll.EnableCollisions(character, true)	
	Ragdoll.EnableRagdollState(character, true)
	
	for index, joint:Motor6D in pairs(humanoid.Parent:GetDescendants()) do
		if joint:IsA("Motor6D") then						
			local a1: Attachment, a2: Attachment = Instance.new("Attachment"), Instance.new("Attachment")
			a1.Name, a2.Name = "RagdollAttachment", "RagdollAttachment"
			a1.Parent, a2.Parent = joint.Part0, joint.Part1

			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "RagdollAttachment"
			socket.Parent = joint.Parent
			socket.Attachment0, socket.Attachment1 = a1, a2
						
			--local bodyPart = RagdollData.GetBodyPartFromJoint(joint.Name)
			a1.CFrame = joint.C0 -- if bodyPart then RagdollData.Offsets[bodyPart].CFrame[2] else joint.C0
			a2.CFrame = joint.C1 -- if bodyPart then RagdollData.Offsets[bodyPart].CFrame[1] else joint.C1

			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true

			joint.Enabled = false
		end
	end
end

function Ragdoll.Disable(humanoid: Humanoid)
	local character: Model = humanoid.Parent
	if character:FindFirstChild("RagdollState") then return end
		
	Ragdoll.EnableCollisions(character, false)
	
	for _, attachment: Attachment in pairs(humanoid.Parent:GetDescendants()) do
		if attachment.Name == "RagdollAttachment" then
			attachment:Destroy()
		end
	end
	
	local animator: Animator = humanoid.Parent.Humanoid.Animator
	local filter =  {Enum.AnimationPriority.Idle, Enum.AnimationPriority.Movement}
	for _, v: AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
		if table.find(filter, v.Priority) then continue end
		v:Stop()
	end

	for index, joint:Motor6D in pairs(humanoid.Parent:GetDescendants()) do
		if joint:IsA("Motor6D") then
			joint.Enabled = true
		end
	end
end

function Ragdoll.Main(target: Model, duration: number)
	-- pass
end

return Ragdoll
