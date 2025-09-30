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
local Speed = require(Physics:WaitForChild("Speed"))
local Stun = require(Physics:WaitForChild("Stun"))
local Ragdoll = require(Physics:WaitForChild("Ragdoll"))
local Cooldown = require(Physics:WaitForChild("Cooldown"))
local PlayerTag = require(Physics:WaitForChild("PlayerTag"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local MeteorModule = {}

-- Variables
local LIFE_TIME = 4
local SPEED = 120

-- Functions
function MeteorModule.SearchForGround(origin: CFrame, mouseHit: CFrame): RaycastResult
	-- (1) Search for where Lightning Strike can connect with the Ground
	local searchHeight = Vector3.new(0, 30, 0)
	local searchDepth = -(searchHeight) - (Vector3.new(0, 1, 0) * (origin.Position.Y + 5))
	local searchOrigin = Vector3.new(mouseHit.Position.X, origin.Position.Y, mouseHit.Position.Z) + searchHeight

	-- (2) Setup Raycast Params
	local Parameters = RaycastParams.new()
	Parameters.FilterType = Enum.RaycastFilterType.Include
	Parameters.FilterDescendantsInstances = {workspace.Map}

	-- (3) Return Raycast Result
	local Result = workspace:Raycast(searchOrigin, searchDepth, Parameters)
	return Result
end

function MeteorModule.Main(player: Player, properties: {})
	--[[
	[PROPERTIES]
	> Origin: CFrame
	--]]
	
	-- (0) Type-check & Sanity-check ALL Parameters
	if typeof(properties) ~= typeof({}) then warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`) return end
	
	local Origin = properties.Origin
	if (not Origin) or (typeof(Origin) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: Origin DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - Origin.Position).Magnitude > 10 then warn(`ExtremeValue Error: Origin DataType's value is too far from Humanoid's Actual Origin!`) return end
	
	local MouseHit = properties.MouseHit
	if (not MouseHit) or typeof(MouseHit) ~= typeof(CFrame.new(0, 0, 0)) then warn(`ParameterType Error: MouseHit DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - MouseHit.Position).Magnitude > 125 then warn(`ExtremeValue Error: MouseHit's value is too extreme!`) return end

	-- (1) Cancel Attack if (A) Player has been Stunned, (B) Character has died, or (C) Ability is still on Cooldown
	if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end
	if player.Character:FindFirstChild(`MeteorCD`) then return end
	
	-- (2) Search for the "Highest Point" on the Ground where the Lightning can strike
	local Result: RaycastResult = MeteorModule.SearchForGround(Origin, MouseHit)
	if not Result then warn("Error: Lightning Strike could not find Ground nearby!!") return end

	-- (3) Lightning Strike ability will be used, now there is a "Highest Point" for a Lightning Bolt
	Cooldown.SetEndlag(player.Character, "Meteor", 1)
	if EndLag.EndLagInterrupt(player.Character, "Meteor") then return end

	Cooldown.SetCooldown(player.Character, "MeteorCD", 8)

	-- (4) Play Fireball effect on the Client-side
	local FireballId = `Meteor{time()}`
	Effects.LoadAbility:FireAllClients("Meteor", player, FireballId, {Duration = 0.25, Offset = 0, Origin = CFrame.new(Result.Position)})

	-- (5) Setup Fireball
	local Fireball = {CFrame = CFrame.new(Result.Position) * CFrame.new(0, 100, 0)}
	local startTime = time()
	local velocity = Vector3.new(0, -SPEED, 0) 
	
	-- (6) Setup Fireball Hitbox Parameters
	local FParams = OverlapParams.new()
	FParams.FilterType = Enum.RaycastFilterType.Exclude
	FParams.FilterDescendantsInstances = {workspace.FX, player.Character, workspace.Hitbox}

	-- (7) Move Fireball Hitbox
	local HitTargets = {}
		
	local connection
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			connection:Disconnect(); connection = nil
			return
		end
		
		local deltaVelocity = velocity * DT
		local hitParts = workspace:GetPartBoundsInRadius(Fireball.CFrame.Position, 4, FParams)
		
		if #hitParts > 0 then
			local hitParts = workspace:GetPartBoundsInRadius(Fireball.CFrame.Position, 12, FParams)
			
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
					humanoid:TakeDamage(30)
					PlayerTag.Tag(player, target, 30)
					
					Speed.ApplySpeed(target, 0, nil, "ResetByEvent")
					Stun.ApplyStun(target, 1)	
					
					-- (C) Apply a Knockback Force
					--local destination = target.PrimaryPart.Position + Vector3.new(velocity.X, 25, velocity.Z)
					--Knockback.ApplyFixedForce(player, target, destination, 1)
					
					-- (D) Play a Ragdoll Animation and Damage Indicator Animation on the Target
					Effects.LoadEffect:FireAllClients("Highlight", target, Color3.fromRGB(255, 0, 0), 0.5)
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
			Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 8, Duration = 0.25}, origin)
			Effects.LoadEffect:FireAllClients("Crater", {Rotation = -3, Radius = 7.5, Duration = 0.25}, origin)
			--Effects.LoadEffect:FireAllClients("Rubble", origin)
			
			-- (E) Play the Explosion Effect on the Fireball
			Effects.EffectRemoving:FireAllClients("Meteor", FireballId)
			
			connection:Disconnect(); connection = nil
			return
		else
			Fireball.CFrame = CFrame.new(Fireball.CFrame.Position) + deltaVelocity
		end
	end)
end

return MeteorModule
