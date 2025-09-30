-- Services
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Effects = Remotes:WaitForChild("Effects")

-- Modules
local Physics = ServerStorage:WaitForChild("Physics")
local Knockback = require(Physics:WaitForChild("Knockback"))
local Stun = require(Physics:WaitForChild("Stun"))
local Ragdoll = require(Physics:WaitForChild("Ragdoll"))
local Cooldown = require(Physics:WaitForChild("Cooldown"))
local Speed = require(Physics:WaitForChild("Speed"))
local PlayerTag = require(Physics:WaitForChild("PlayerTag"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local RoyalArcherModule = {}

-- Variables
local LIFE_TIME = 2
local SPEED = 175

-- Functions
function RoyalArcherModule.Main(player: Player, properties: {})
	--[[
	[PROPERTIES]
	> Origin: CFrame
	--]]
	
	-- (0) Type-check & Sanity-check ALL Parameters
	if typeof(properties) ~= typeof({}) then warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`) return end
	
	local Origin = properties.Origin
	if (not Origin) or (typeof(Origin) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: Origin DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - Origin.Position).Magnitude > 10 then warn(`ExtremeValue Error: Origin DataType's value is too far from Humanoid's Actual Origin!`) return end

	-- (1) Cancel Attack if (A) Player has been Stunned, (B) Character has died, or (C) Ability is still on Cooldown
	if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end
	if player.Character:FindFirstChild(`RoyalArcherCD`) then return end
		
	--Cooldown.SetEndlag(player.Character, "RoyalArcher", 0.25)
	if EndLag.EndLagInterrupt(player.Character, "RoyalArcher") then return end
	
	Cooldown.SetCooldown(player.Character, "RoyalArcherCD", 6)
	--Speed.ApplySpeed(player.Character, 0, 0.25)
	
	-- (2) Play Fireball effect on the Client-side
	local RoyalArcherId = `RoyalArcher{time()}`
	Effects.LoadAbility:FireAllClients("RoyalArcher", player, RoyalArcherId, properties)

	-- (3) Setup Fireball
	local velocity = (Origin.LookVector) * SPEED 
	local Fireball = {CFrame = CFrame.new(Origin.Position, Origin.Position + velocity) * CFrame.new(0, 1, 0) + Origin.LookVector * 15}
	local startTime = time()
	
	-- (4) Setup Fireball Hitbox Parameters
	local FParams = OverlapParams.new()
	FParams.FilterType = Enum.RaycastFilterType.Exclude
	FParams.FilterDescendantsInstances = {workspace.FX, player.Character, workspace.Map, workspace.Hitbox}

	-- (5) Move Fireball Hitbox
	local HitTargets = {}
		
	local connection
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			connection:Disconnect(); connection = nil
			return
		end
		
		local deltaVelocity = velocity * DT
		local hitParts = workspace:GetPartBoundsInBox(Fireball.CFrame, Vector3.new(4, 4, 4), FParams)
		
		if #hitParts > 0 then
			for _, hit: BasePart in hitParts do
				-- (A) Search for a Humanoid 
				local model: Model = hit:FindFirstAncestorWhichIsA("Model")
				if not model then continue end
				
				if model:FindFirstChild("I-Frame") then	 continue end
				if model:FindFirstChildWhichIsA("ForceField") then continue end
				
				local humanoid: Humanoid = model:FindFirstChild("Humanoid")
				
				if humanoid and not table.find(HitTargets, humanoid) then
					-- (B) Deal Damage to the Target, if it has not been hit yet
					local target = model
					humanoid:TakeDamage(20)
					PlayerTag.Tag(player, target, 20)
					
					Speed.ApplySpeed(target, 2, nil, "ResetByEvent")
					Stun.ApplyStun(target, 1)
					
					-- (D) Play a Ragdoll Animation and Damage Indicator Animation on the Target
					Effects.LoadEffect:FireAllClients("Highlight", target, Color3.fromRGB(255, 0, 0), 0.5)
					Effects.LoadEffect:FireAllClients("ShockwaveII", {Origin = target.PrimaryPart.CFrame, Size = 15, Duration = 0.5})
					Ragdoll.Main(target, 2)
					
					-- (E) Make the Target Play a Knockback Animation during Ragdolling
					local KnockbackAnim = target.Humanoid:LoadAnimation(script.KnockbackAnimation[`Hit`])
					KnockbackAnim:Play()
					game.Debris:AddItem(KnockbackAnim, 1)
					
					table.insert(HitTargets, humanoid)
				end
			end
						
			-- (F) Leave a Crater and Rubble, wherever the Fireball Hits
			local origin = Fireball.CFrame
			--Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 8, Duration = 0.25}, origin)
			--Effects.LoadEffect:FireAllClients("Crater", {Rotation = -3, Radius = 7.5, Duration = 0.25}, origin)
			Effects.LoadEffect:FireAllClients("Rubble", origin)
			
			-- (E) Play the Explosion Effect on the Fireball
			Effects.EffectRemoving:FireAllClients("RoyalArcher", RoyalArcherId)
			
			connection:Disconnect(); connection = nil
			return
		else
			Fireball.CFrame = CFrame.new(Fireball.CFrame.Position, Fireball.CFrame.Position + deltaVelocity) + deltaVelocity
		end
	end)
end

return RoyalArcherModule
