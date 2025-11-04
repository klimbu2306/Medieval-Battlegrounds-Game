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
local Speed = require(Physics:WaitForChild("Speed"))
local Hitbox = require(Physics:WaitForChild("Hitbox"))
local Ragdoll = require(Physics:WaitForChild("Ragdoll"))
local Cooldown = require(Physics:WaitForChild("Cooldown"))
local IFrames = require(Physics:WaitForChild("IFrame"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local PhantomCharge = {}

-- Functions
function PhantomCharge.DetectHit(player: Player, hit: BasePart, velocity: Vector3)
	local target = hit.Parent
	local humanoidRootPart: BasePart =  target.HumanoidRootPart

	-- (1) Play Melee SFX + Animation
	local sound = script.SwordFinalHit:Clone()
	sound.Parent = hit.Parent.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	-- (2) Apply Knockback Physics on the Target based on the Combo Hit #
	local KNOCKBACK_DURATION = 0.75
	local lastHitLaunch = target.PrimaryPart.Position + velocity + Vector3.new(0, 25, 0)
	
	-- (Vary Knockback Force based on whether the hit is the last one in the combo or not)
	Knockback.ApplyFixedForce(player, target, lastHitLaunch, KNOCKBACK_DURATION)

	-- (3) Apply Damage to Target
	hit.Parent:FindFirstChild("Humanoid"):TakeDamage(15)
	
	-- (4) Apply Stun and Slowdown to Target for Combo Extension
	local stunDuration = KNOCKBACK_DURATION * 1.75
	Stun.ApplyStun(target, stunDuration)

	-- (5) Play Knockback Animation on the Target
	local KnockbackAnim = target.Humanoid:LoadAnimation(script.Animations[`Hit`])
	KnockbackAnim:Play()
	game.Debris:AddItem(KnockbackAnim, 1)
		
	-- (7) Play Highlight Anbimation on Hit
	Effects.LoadEffect:FireAllClients("Highlight", target, Color3.fromRGB(255, 0, 0), 0.5)
	
	local origin = player.Character.PrimaryPart.CFrame
	Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 6, Duration = 0.25}, origin)
	Effects.LoadEffect:FireAllClients("Crater", {Rotation = -3, Radius = 5.5, Duration = 0.25}, origin)
	Effects.LoadEffect:FireAllClients("Rubble", origin)
	
	-- (8) Play Rubble SFX
	local sound = script.Rubble:Clone()
	sound.Parent = hit.Parent.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	-- (9) Play Shockwave Effect for Last Hit
	Effects.LoadEffect:FireAllClients("Shockwave", 
		{
			Target = hit.Parent, 
			LookVector = CFrame.new(hit.Parent.PrimaryPart.Position, lastHitLaunch).LookVector,
			Duration = 0.5,
			TimeDelay = 0.1
		}
	)
end

function PhantomCharge.ActivateHitbox(player: Player, region: BasePart)
	local hitboxCooldown = false
	local hitTargets = {}

	region.Touched:Connect(function(hit: BasePart) 
		local target = hit.Parent

		-- (0) Nullify Hitbox Touched if Target has I-Frames + Trigger Possible PhantomChargeattack Effects
		if target:FindFirstChild("I-Frame") then return end

		-- (1) Nullify Hitbox if Attacker has been Stunned or Leaves the Game
		if not player.Character then return end
		if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end

		-- (2) Nullify Hitbox from being able to hit Targets, if Attacker has died
		local attackerHumanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
		if not attackerHumanoid then return end
		if attackerHumanoid.Health == 0 then return end

		-- (3) Check if the Target is a Character AND is not the Player's Character
		if target.Name == player.Name then 	return end
		if not target:FindFirstChild("Humanoid") then return end

		-- (4) Only uniquely hit each Character within the Region3 once
		if table.find(hitTargets, target) then return end

		-- (5) Target must be Alive
		if target.Humanoid.Health == 0 then return end

		-- (6) Calculate Direction of where Player will launch the Target
		local distance = 75
		local velocity = Knockback.PlayerToTargetLookVector(player, target) * distance

		-- (7) Apply the Hit Force
		PhantomCharge.DetectHit(player, hit, velocity)
		table.insert(hitTargets, target)
		
		if #hitTargets > 0 then
			Effects.LoadEffect:FireAllClients("ShockwaveII", {Origin = player.Character.PrimaryPart.CFrame, Size = 25})
		end
	end)
end

function PhantomCharge.Main(player: Player, properties: {})
	--[[
	[PROPERTIES]
	> Combo: number
	> Origin: CFrame
	--]]
	
	-- (0) Type-check & Sanity-check ALL Parameters
	if typeof(properties) ~= typeof({}) then warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`) return end

	local Origin = properties.Origin
	if (not Origin) or (typeof(Origin) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: Origin DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - Origin.Position).Magnitude > 10 then warn(`ExtremeValue Error: Origin DataType's value is too far from Humanoid's Actual Origin!`) return end

	-- (1) Cancel Attack if Player has been Stunned or Character died, whilst trying to perform an Attack
	if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end
	if player.Character:FindFirstChild(`PhantomChargeCD`) then return end
	
	Cooldown.SetEndlag(player.Character, "PhantomCharge", 0.5)
	if EndLag.EndLagInterrupt(player.Character, "PhantomCharge") then return end
	
	Cooldown.SetCooldown(player.Character, "PhantomChargeCD", 3)
	
	-- (2) Play PhantomCharge SFX
	local sound = script.Spin:Clone()
	sound.Parent = player.Character.PrimaryPart
	sound:Play()
	game.Debris:AddItem(sound, 3)
	Effects.LoadEffect:FireAllClients("Highlight", player.Character, Color3.fromRGB(255, 200, 0), 0.5)
	
	-- (3) Give Player temporary I-Frames & Stun the Player
	IFrames.ApplyIFrames(player.Character, 0.5)
	Speed.ApplySpeed(player.Character, 0, 0.5)
	
	-- (4) Make Player Lunge Forwards!
	local Params: OverlapParams = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {workspace.FX, player.Character, workspace.Map, workspace.Hitbox, workspace.PhantomChargeHitbox}
			
	local startTime = time()
	local LIFE_TIME = 1
	
	local initialStepSize = 5
	local decayRate = 2 -- Adjust this rate to control how quickly the step size decays
	
	local AlignPosition: AlignPosition = Knockback.ApplyFixedForce(player, player.Character, Origin.Position, LIFE_TIME)
	
	local connection: RBXScriptSignal
	connection = RunService.Heartbeat:Connect(function(dt: number)
		if time() >= startTime + LIFE_TIME then
			connection:Disconnect(); connection = nil
			return
		end
		
		local hitParts = workspace:GetPartBoundsInRadius(player.Character.HumanoidRootPart.Position, 6, Params)
		
		if #hitParts > 0 then
			print("destroy!")
			Debris:AddItem(AlignPosition)
			connection:Disconnect(); connection = nil
			return
		end
		
		--AlignPosition.Position += Origin.LookVector * 0.5
	end)
	
	--[[
	-- (4) Setup Region3 Area, which will detect available Targets for the Attack
	local offsetMagnitude = -1
	local offset = CFrame.new(0, 0, offsetMagnitude)
	local origin = Origin * offset
	
	local regionMagnitude = 16
	local regionSize = Vector3.one * regionMagnitude
	
	local region = Hitbox.CreateRegion(origin, regionSize, 0.25, "MeleeHitbox", Enum.PartType.Ball)
	
	local CharacterMarker: ObjectValue = Instance.new("ObjectValue")
	CharacterMarker.Name = "CharacterMarker"
	CharacterMarker.Value = player.Character
	CharacterMarker.Parent = region
	Debris:AddItem(CharacterMarker, 0.25)
	
	PhantomCharge.ActivateHitbox(player, region)
	--]]
end

return PhantomCharge
