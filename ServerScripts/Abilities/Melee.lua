-- Services
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local PlayerTag = require(Physics:WaitForChild("PlayerTag"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local Melee = {}

-- Functions
function Melee.GetHitSound(player: Player, combo: number, weaponType: "Sword" | "Fist")
	local sound: Sound
	
	if weaponType == "Sword" then
		sound = if combo == 5 then "SwordFinalHit" else "SwordHit"
	else
		sound = if combo == 5 then "FinalHit" else "Hit"
	end
	
	return sound
end

function Melee.DetectHit(player: Player, hit: BasePart, velocity: Vector3, combo: number, weaponType: "Sword" | "Fist")
	local target = hit:FindFirstAncestorWhichIsA("Model")
	local humanoidRootPart: BasePart =  target.HumanoidRootPart

	-- (1) Play Melee SFX
	local sound: string = Melee.GetHitSound(player, combo, weaponType)
	Remotes.Effects.LoadAbility:FireAllClients("Melee", player, {HitSound = sound})

	-- (2) Apply Knockback Physics on the Target based on the Combo Hit #
	local KNOCKBACK_DURATION = if combo ~= 5 then 0.3 else 0.75
	local lastHitLaunch = target.PrimaryPart.Position + velocity + Vector3.new(0, 25, 0)
	
	-- (Vary Knockback Force based on whether the hit is the last one in the combo or not)
	if combo ~= 5 then Knockback.ApplyForce(player, target, velocity, KNOCKBACK_DURATION) else Knockback.ApplyFixedForce(player, target, lastHitLaunch, KNOCKBACK_DURATION) end
	if combo ~= 5 then Knockback.ApplyForce(player, player.Character, velocity, KNOCKBACK_DURATION) end

	-- (3) Apply Damage to Target
	target:FindFirstChild("Humanoid"):TakeDamage(5)
	PlayerTag.Tag(player, target, 5)
	
	-- (4) Apply Stun and Slowdown to Target for Combo Extension
	local stunDuration = KNOCKBACK_DURATION * 1.75 + 0.15
	Speed.ApplySpeed(target, 2, nil, "ResetByEvent")
	Stun.ApplyStun(target, stunDuration)

	-- (5) Play Knockback Animation on the Target
	local KnockbackAnim = target.Humanoid:LoadAnimation(script.KnockbackAnimation[`M{combo}`])
	KnockbackAnim:Play()
	game.Debris:AddItem(KnockbackAnim, 1)
		
	-- (7) Play Highlight Anbimation on Hit
	Effects.LoadEffect:FireAllClients("Highlight", target, Color3.fromRGB(255, 0, 0), 0.5)
	
	-- (8) Ragdoll Target on Last Hit of Combo
	if combo == 5 then Ragdoll.Main(target, 2) end
	
	-- (9) Play Rubble FX on Client
	if combo ~= 5 then return end
	local origin = player.Character.PrimaryPart.CFrame
	Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 6, Duration = 0.25}, origin)
	Effects.LoadEffect:FireAllClients("Crater", {Rotation = -3, Radius = 5.5, Duration = 0.25}, origin)
	Effects.LoadEffect:FireAllClients("Rubble", origin)
	
	-- (10) Play Rubble SFX
	local sound = script.Rubble:Clone()
	sound.Parent = target.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	-- (11) Play Shockwave Effect for Last Hit
	Effects.LoadEffect:FireAllClients("Shockwave", 
		{
			Target = target, 
			LookVector = CFrame.new(target.PrimaryPart.Position, lastHitLaunch).LookVector,
			Duration = 0.5,
			TimeDelay = 0.1
		}
	)
	
	-- (12) Play Camera Shake
	--[[
	pcall(function()
		if player.Parent ~= game.Players then return end
		Effects.ShakeCamera:FireClient(player, "Bump")
	end)
	--]]
end

function Melee.ActivateHitbox(player: Player, region: BasePart, combo: number, weaponType: "Sword" | "Fist")
	local hitboxCooldown = false
	local hitTargets = {}

	region.Touched:Connect(function(hit: BasePart) 
		local target = hit:FindFirstAncestorWhichIsA("Model")
		if not target then return end
		
		-- (0) Nullify Hitbox Touched if Target has I-Frames + ForceField Protection
		if target:FindFirstChild("I-Frame") then return end
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
		local distance = if combo == 5 then 75 else 10
		local velocity = Knockback.PlayerToTargetLookVector(player, target) * distance

		-- (7) Apply the Hit Force
		Melee.DetectHit(player, hit, velocity, combo, weaponType)
		table.insert(hitTargets, target)
	end)
end

function Melee.Main(player: Player, properties: {})
	--[[
	[PROPERTIES]
	> Combo: number
	> Origin: CFrame
	--]]
	
	-- (0) Type-check & Sanity-check ALL Parameters
	if typeof(properties) ~= typeof({}) then warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`) return end
	
	local combo = properties.Combo
	if (not combo) or (typeof(combo) ~= typeof(123)) then warn(`ParameterType Error: Combo DataType passed in was NOT a Number value!`) return end
	if (not table.find({1, 2, 3, 4, 5}, combo)) then warn(`ParameterBoundary Error: Combos DataType's value is not within a specified range!`) return end
	
	local Origin = properties.Origin
	if (not Origin) or (typeof(Origin) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: Origin DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - Origin.Position).Magnitude > 10 then warn(`ExtremeValue Error: Origin DataType's value is too far from Humanoid's Actual Origin!`) return end
	
	local Weapon = properties.Weapon
	if (not Weapon) or (typeof(Weapon) ~= typeof("String")) then warn(`ParameterType Error: Weapon DataType passed in was NOT a String value!`) return end
	if not table.find({"Fist", "Sword"}, Weapon) then warn(`ParameterType Error: Weapon DataType passed in was NOT a Valid Weapon DataType!`) return end
	
	-- (1) Cancel Attack if Player has been Stunned or Character died, whilst trying to perform an Attack
	if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end
	
	Cooldown.SetEndlag(player.Character, "Melee", 0.25)
	if EndLag.EndLagInterrupt(player.Character, "Melee") then return end
	
	-- (2) Slow down the Attacking Player, whilst they are trying to Punch
	Speed.ApplySpeed(player.Character, 16, 0.25)
	
	-- (3) Setup Region3 Area, which will detect available Targets for the Attack
	local HITBOX_DURATION = 0.3
	
	local offsetMagnitude = -5
	local offset = if combo == 5 then CFrame.new(0, 0, offsetMagnitude) else CFrame.new(0, 0, offsetMagnitude)
	local origin = Origin * offset
	
	local regionMagnitude = 13
	local regionSize = if combo == 5 then Vector3.one * regionMagnitude else  Vector3.one * regionMagnitude
	
	local region = Hitbox.CreateRegion(origin, regionSize, HITBOX_DURATION, "MeleeHitbox", Enum.PartType.Ball)
	
	local CharacterMarker: ObjectValue = Instance.new("ObjectValue")
	CharacterMarker.Name = "CharacterMarker"
	CharacterMarker.Value = player.Character
	CharacterMarker.Parent = region
	Debris:AddItem(CharacterMarker, HITBOX_DURATION)
	
	local weaponType: string = properties.Weapon
	Melee.ActivateHitbox(player, region, combo, weaponType)
end

return Melee
