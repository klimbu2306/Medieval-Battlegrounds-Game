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
local Notification = require(Physics:WaitForChild("Notification"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local MeteorShowerModule = {}

-- Variables
local LIFE_TIME = 4
local SPEED = 120

-- Functions
function MeteorShowerModule.SearchForGround(origin: CFrame, mouseHit: CFrame): RaycastResult
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

function MeteorShowerModule.Main(player: Player, properties: {})
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
	if player.Character:FindFirstChild(`MeteorShowerCD`) then return end
	
	pcall(function()
		local SpawnProtection: ForceField = player.Character:FindFirstChild("SpawnProtection")
		if SpawnProtection then
			SpawnProtection:Destroy()

			local DisableSpawnProtection = Instance.new("ObjectValue")
			DisableSpawnProtection.Name = "DisableSpawnProtection"
			DisableSpawnProtection.Parent = player

			Notification.Notify(player, "System Message: Spawn Protection has been Disabled", "Red", 2)
		end
	end)
	
	-- (2) Search for the "Highest Point" on the Ground where the Lightning can strike
	local LookForward = Origin.LookVector * 0
	local ForwardOrigin =  Origin + LookForward
	local Result: RaycastResult = MeteorShowerModule.SearchForGround(Origin, ForwardOrigin)
	if not Result then warn("Error: Lightning Strike could not find Ground nearby!!") return end
	
	-- (3) Lightning Strike ability will be used, now there is a "Highest Point" for a Lightning Bolt
	Cooldown.SetEndlag(player.Character, "MeteorShower", 1)
	if EndLag.EndLagInterrupt(player.Character, "MeteorShower") then return end
	
	if player.Character:FindFirstChild("MarkerForNPC") then
		Cooldown.SetCooldown(player.Character, "MeteorShowerCD", 7)
	else
		Cooldown.SetCooldown(player.Character, "MeteorShowerCD", 15)
	end

	-- (4) Play Fireball effect on the Client-side
	local FireballId = `MeteorShower{time()}`
	Effects.LoadAbility:FireAllClients("MeteorShower", player, FireballId, {Duration = 0.25, Offset = 0, Origin = CFrame.new(Result.Position)})
	
	-- (6) Setup Fireball Hitbox Parameters
	local FParams = OverlapParams.new()
	FParams.FilterType = Enum.RaycastFilterType.Exclude
	FParams.FilterDescendantsInstances = {workspace.FX, player.Character, workspace.Hitbox, workspace.TycoonHitbox.Floor}
	
	-- (7) Move Fireball Hitbox
	local HitTargets = {}
	
	local radius = 15 -- Distance from the player to each meteor
	local numMeteors = 8 -- Number of meteors in the hexagon
	local facingAngle = math.atan2(Origin.LookVector.Z, Origin.LookVector.X)
	
	for i = 1, numMeteors, 1 do
		-- (5) Setup Fireball
		local angle = facingAngle + math.rad(45 * i) -- Convert degrees to radians
		local offsetX = math.cos(angle) * radius
		local offsetZ = math.sin(angle) * radius
		
		local Fireball = {CFrame = CFrame.new(Result.Position) * CFrame.new(0, 75, 0) + Vector3.new(offsetX, 0, offsetZ)}
		local startTime = time()
		local velocity = Vector3.new(0, -SPEED, 0) 
		
		local connection
		connection = RunService.Heartbeat:Connect(function(DT: number)
			if time() >= startTime + LIFE_TIME then
				connection:Disconnect(); connection = nil
				return
			end
			
			local deltaVelocity = velocity * DT
			local hitParts = workspace:GetPartBoundsInRadius(Fireball.CFrame.Position, 4, FParams)
			
			if #hitParts > 0 then
				local hitParts = workspace:GetPartBoundsInRadius(Fireball.CFrame.Position, 5, FParams)
				
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
						humanoid:TakeDamage(35)
						PlayerTag.Tag(player, target, 35)
						
						-- (C) Apply a Knockback Force
						local knockbackVelocity: Vector3 = (Origin.LookVector) * 50
						local destination = target.PrimaryPart.Position + Vector3.new(knockbackVelocity.X, 25, knockbackVelocity.Z)
						Knockback.ApplyFixedForce(player, target, destination, 1)
						
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
				Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 4, Duration = 0.25}, origin)
				--Effects.LoadEffect:FireAllClients("Crater", {Rotation = -3, Radius = 4.5, Duration = 0.25}, origin)
				--Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 5, Duration = 0.25}, origin)
				--Effects.LoadEffect:FireAllClients("Rubble", origin)
				
				-- (E) Play the Explosion Effect on the Fireball
				Effects.EffectRemoving:FireAllClients("MeteorShower",`{FireballId}{i}`, i)
				
				connection:Disconnect(); connection = nil
				return
			else
				Fireball.CFrame = CFrame.new(Fireball.CFrame.Position) + deltaVelocity
			end
		end)
	end
end

return MeteorShowerModule
