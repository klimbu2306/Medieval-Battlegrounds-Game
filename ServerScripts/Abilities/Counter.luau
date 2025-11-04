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
local PlayerTag = require(Physics:WaitForChild("PlayerTag"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local Counter = {}

-- Functions
function Counter.PlayCounterAnimation(player: Player, animationName: "CounterAttack" | "Trigger")
	local character = player.Character
	
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local animator: Animator = humanoid:FindFirstChild("Animator")
	if not animator then return end
	
	local animation: AnimationTrack = animator:LoadAnimation(script.Animations[animationName])
	animation:Play()
	
	return animation
end

function Counter.InterruptCounterAnimation(player: Player)
	local character = player.Character

	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local animator: Animator = humanoid:FindFirstChild("Animator")
	if not animator then return end
	
	for _, animation: AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
		print(animation.Name, animation.Animation.AnimationId)
		if animation.Animation.AnimationId == "rbxassetid://73081684998501" then
			print(`stopped animation with id {animation.Animation.AnimationId}`)
			animation:Stop()
		end
	end
end

function Counter.DetectHit(player: Player, hit: BasePart, velocity: Vector3)
	local target = hit.Parent
	local humanoidRootPart: BasePart =  target.HumanoidRootPart

	-- (1) Play Melee SFX + Animation
	local sound = script.SwordFinalHit:Clone()
	sound.Parent = hit.Parent.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	Counter.PlayCounterAnimation(player, "CounterAttack")

	-- (2) Apply Knockback Physics on the Target based on the Combo Hit #
	local KNOCKBACK_DURATION = 0.75
	local lastHitLaunch = target.PrimaryPart.Position + velocity + Vector3.new(0, 25, 0)
	
	-- (Vary Knockback Force based on whether the hit is the last one in the combo or not)
	Knockback.ApplyFixedForce(player, target, lastHitLaunch, KNOCKBACK_DURATION)

	-- (3) Apply Damage to Target
	hit.Parent:FindFirstChild("Humanoid"):TakeDamage(35)
	PlayerTag.Tag(player, target, 35)
	
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

function Counter.ActivateHitbox(player: Player, hit: BasePart)
	print("TRIGGER COUNTER")
	local hitboxCooldown = false
	local hitTargets = {}
	
	local target = hit.Parent
	
	-- (0) Ignore whether Target has I-Frames or ForceField Protection
	-- if target:FindFirstChild("I-Frame") then return end
	if target:FindFirstChildOfClass("ForceField") then return end
	
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
	Counter.DetectHit(player, hit, velocity)
	table.insert(hitTargets, target)
end

function Counter.Main(player: Player, properties: {})
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
	if player.Character:FindFirstChild(`CounterCD`) then return end
	
	Cooldown.SetEndlag(player.Character, "Counter", 1)
	if EndLag.EndLagInterrupt(player.Character, "Counter") then return end
	
	Cooldown.SetCooldown(player.Character, "CounterCD", 5)
	
	-- (2) Play Counter SFX + Highlight VFX
	local COUNTER_ACTIVATION_TIME = 0.5
	local COUNTER_END_LAG_TIME = 1
	local COUNTER_STRIKE_TIME = 0.5
	
	local sound = script.CounterStart:Clone()
	sound.Parent = player.Character.PrimaryPart
	sound:Play()
	game.Debris:AddItem(sound, COUNTER_ACTIVATION_TIME)
	Effects.LoadEffect:FireAllClients("Highlight", player.Character, Color3.fromRGB(255, 200, 0), COUNTER_END_LAG_TIME/2)
	
	local triggerAnimation: AnimationTrack = Counter.PlayCounterAnimation(player, "Trigger")
	
	-- (3) Give Player temporary I-Frames & Stun the Player
	IFrames.ApplyIFrames(player.Character, COUNTER_ACTIVATION_TIME)
	Speed.ApplySpeed(player.Character, 0, COUNTER_END_LAG_TIME)
	
	-- (4) Setup Region3 Area, which will detect available Targets for the Attack
	local offsetMagnitude = -1
	local offset = CFrame.new(0, 0, offsetMagnitude)
	local origin = Origin * offset
	
	local regionMagnitude = 15
	local regionSize = Vector3.one * regionMagnitude
	
	local region = Hitbox.CreateRegion(origin, regionSize, COUNTER_ACTIVATION_TIME, "CounterHitbox", Enum.PartType.Ball)
	
	-- (5) Only Activate Counter if Interacting with Melee Hitbox
	local ActivateCounter: BindableEvent = Instance.new("BindableEvent")
	ActivateCounter.Name = "Event"
	ActivateCounter.Parent = region
	Debris:AddItem(ActivateCounter, COUNTER_ACTIVATION_TIME)
	
	local connection: RBXScriptSignal
	local bindableConnection: RBXScriptSignal
	
	local HitParams = OverlapParams.new()
	HitParams.FilterType = Enum.RaycastFilterType.Exclude
	HitParams.FilterDescendantsInstances = {workspace.Map, workspace.Hitbox, workspace.CounterHitbox, player.Character}
	
	bindableConnection = ActivateCounter.Event:Connect(function(hit: BasePart)
		-- (A) Trace MeleeHitbox back to it's Owner's Character
		local CharacterMarker: ObjectValue = hit:FindFirstChild("CharacterMarker")
		if not CharacterMarker then return end
		
		-- (B) Type-Check the Owner's Character that we are about to counterattack
		local character: Model = CharacterMarker.Value
		if not character:FindFirstChild("Humanoid") then return end
		
		-- (C) Remove End-Lag + give I-Frames and Speed Boost for Countering Player
		Debris:AddItem(region, 0.5)
		IFrames.ApplyIFrames(player.Character, COUNTER_STRIKE_TIME)
		Cooldown.SetEndlag(player.Character, "Counter", COUNTER_STRIKE_TIME)
		Speed.ResetSpeed(player.Character)
		triggerAnimation:Stop()
		
		-- (D) Activate Counterattack Hitbox
		Counter.ActivateHitbox(player, character.PrimaryPart)
		
		ActivateCounter:Destroy()
		bindableConnection:Disconnect(); bindableConnection = nil
	end)
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Hitbox}
	
	local StartTime = time()
	connection = RunService.Stepped:Connect(function(DT: number)
		if time() >= StartTime + COUNTER_ACTIVATION_TIME then
			connection:Disconnect(); connection = nil
			bindableConnection:Disconnect(); bindableConnection = nil
			return
		end
		
		local GetTouchingParts = workspace:GetPartBoundsInRadius(region.Position, 15, Params)
		
		if #GetTouchingParts > 0 then
			for _, hit: BasePart in pairs(GetTouchingParts) do
				ActivateCounter:Fire(hit)
			end
			
			connection:Disconnect(); connection = nil
			return
		end
	end)
	
	task.delay(COUNTER_ACTIVATION_TIME, function()
		if connection then connection:Disconnect(); connection = nil end
		if bindableConnection then bindableConnection:Disconnect(); bindableConnection = nil end
	end)
	
	task.delay(COUNTER_END_LAG_TIME, function()
		triggerAnimation:Stop()
	end)
end

return Counter
