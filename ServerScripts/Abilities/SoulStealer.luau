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
local SoulStealerModule = {}

-- Functions
function SoulStealerModule.DetectHit(player: Player, hit: BasePart, velocity: Vector3)
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
	hit.Parent:FindFirstChild("Humanoid"):TakeDamage(40)
	PlayerTag.Tag(player, target, 40)
	
	-- (4) Apply Stun and Slowdown to Target for Combo Extension
	local stunDuration = KNOCKBACK_DURATION * 1.75
	Stun.ApplyStun(target, stunDuration)
	Speed.ApplySpeed(target, 0, nil, "ResetByEvent")

	-- (5) Play Knockback Animation on the Target
	local KnockbackAnim = target.Humanoid:LoadAnimation(script.Animations[`Hit`])
	KnockbackAnim:Play()
	game.Debris:AddItem(KnockbackAnim, 1)
		
	-- (7) Play Highlight Anbimation on Hit
	Effects.LoadEffect:FireAllClients("Highlight", target, Color3.fromRGB(255, 0, 0), 0.5)
	
	local origin = player.Character.PrimaryPart.CFrame
	Effects.LoadEffect:FireAllClients("Crater", {Rotation = 3, Radius = 6, Duration = 0.25}, humanoidRootPart.CFrame)
	
	-- (8) Play Rubble SFX
	local sound = script.Rubble:Clone()
	sound.Parent = hit.Parent.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	-- (9) Heal the Attacking Player
	local HEAL_AMOUNT = 20
	local attackHumanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	attackHumanoid.Health += HEAL_AMOUNT
end

function SoulStealerModule.ActivateHitbox(player: Player, region: BasePart)
	local hitboxCooldown = false
	local hitTargets = {}

	region.Touched:Connect(function(hit: BasePart) 
		local target = hit.Parent

		-- (0) Nullify Hitbox Touched if Target has I-Frames + ForceField Protection
		if target:FindFirstChild("I-Frame") then return end
		if target:FindFirstChildOfClass("ForceField") then return end

		-- (1) Nullify Hitbox if Attacker has been Stunned or Leaves the Game
		if not player.Character then return end
		--if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end

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
		SoulStealerModule.DetectHit(player, hit, velocity)
		table.insert(hitTargets, target)
		
		if #hitTargets == 1 then
			Effects.LoadEffect:FireAllClients("Highlight", player.Character, Color3.fromRGB(100, 0, 255), 0.5)
		end
	end)
end

function SoulStealerModule.Main(player: Player, properties: {})
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
	if player.Character:FindFirstChild(`SoulStealerCD`) then return end
	
	Cooldown.SetEndlag(player.Character, "SoulStealer", 0.75)
	if EndLag.EndLagInterrupt(player.Character, "SoulStealer") then return end
	
	Cooldown.SetCooldown(player.Character, "SoulStealerCD", 3)
	
	local SoulStealerId = `SoulStealer{time()}`
	Effects.LoadAbility:FireAllClients("SoulStealer", player, SoulStealerId, {}, Origin)
	
	-- (2) Give Player temporary I-Frames & Stun the Player
	Speed.ApplySpeed(player.Character, 0, 0.75)
	
	task.wait(0.35)
	
	-- (3) Play SoulStealerModule SFX
	local sound = script.Spin:Clone()
	sound.Parent = player.Character.PrimaryPart
	sound:Play()
	game.Debris:AddItem(sound, 3)

	-- (4) Setup Region3 Area, which will detect available Targets for the Attack
	local offsetMagnitude = -1
	local offset = CFrame.new(0, 0, offsetMagnitude)
	local origin = Origin * offset
	
	local regionMagnitude = 16
	local regionSize = Vector3.one * regionMagnitude
	
	local region = Hitbox.CreateRegion(origin + origin.LookVector * 10, regionSize, 0.25, "MeleeHitbox", Enum.PartType.Ball)
	
	local CharacterMarker: ObjectValue = Instance.new("ObjectValue")
	CharacterMarker.Name = "CharacterMarker"
	CharacterMarker.Value = player.Character
	CharacterMarker.Parent = region
	Debris:AddItem(CharacterMarker, 0.25)
	
	SoulStealerModule.ActivateHitbox(player, region)
end

return SoulStealerModule
