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
local DivineGrace = {}

-- Functions
function DivineGrace.DetectHit(player: Player, hit: BasePart, velocity: Vector3)
	local target = hit.Parent
	local humanoidRootPart: BasePart =  target.HumanoidRootPart

	-- (1) Play Healing SFX + Animation
	local sound = script.SwordFinalHit:Clone()
	sound.Parent = hit.Parent.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound, 2)
	
	-- (2) Heal Target!
	local humanoid: Humanoid = hit.Parent:FindFirstChild("Humanoid")
	humanoid.Health += 70
end

function DivineGrace.ActivateHitbox(player: Player, region: BasePart)
	local hitboxCooldown = false
	local hitTargets = {}

	region.Touched:Connect(function(hit: BasePart) 
		local target = hit.Parent

		-- (0) Nullify Hitbox Touched if Target has I-Frames + Trigger Possible DivineGraceattack Effects
		if target:FindFirstChild("I-Frame") then return end

		-- (1) Nullify Hitbox if Attacker has been Stunned or Leaves the Game
		if not player.Character then return end
		if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end

		-- (2) Nullify Hitbox from being able to hit Targets, if Attacker has died
		local attackerHumanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
		if not attackerHumanoid then return end
		if attackerHumanoid.Health == 0 then return end

		-- (3) Check if the Target is a Character
		if not target:FindFirstChild("Humanoid") then return end

		-- (4) Only uniquely hit each Character within the Region3 once
		if table.find(hitTargets, target) then return end

		-- (5) Target must be Alive
		if target.Humanoid.Health == 0 then return end

		-- (6) Calculate Direction of where Player will launch the Target
		local distance = 75
		local velocity = Knockback.PlayerToTargetLookVector(player, target) * distance

		-- (7) Apply the Hit Force
		DivineGrace.DetectHit(player, hit, velocity)
		table.insert(hitTargets, target)
	end)
end

function DivineGrace.Main(player: Player, properties: {})
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
	if player.Character:FindFirstChild(`DivineGraceCD`) then return end
	
	Cooldown.SetEndlag(player.Character, "DivineGrace", 0.5)
	if EndLag.EndLagInterrupt(player.Character, "DivineGrace") then return end
	
	Cooldown.SetCooldown(player.Character, "DivineGraceCD", 12)
	
	-- (2) Play Divine Grace effect on the Client-side
	local DivineGraceId = `DivineGrace{time()}`
	Effects.LoadAbility:FireAllClients("DivineGrace", player, DivineGraceId, properties, Origin)
	
	-- (3) Give Player temporarily stun the Player
	Speed.ApplySpeed(player.Character, 0, 0.5)
	
	-- (4) Play Smash SFX
	local sound = script.Spin:Clone()
	sound.Parent = player.Character.PrimaryPart
	sound:Play()
	game.Debris:AddItem(sound, 3)
	
	-- (5) Setup Region3 Area, which will detect available Targets for the Attack
	local offsetMagnitude = -1
	local offset = CFrame.new(0, -3, offsetMagnitude)
	local origin = Origin * offset * CFrame.Angles(0, 0, math.rad(90))
	
	local regionMagnitude = 25
	local regionSize = Vector3.one * regionMagnitude
	regionSize = Vector3.new(3, regionSize.Y, regionSize.Z)
	
	local region = Hitbox.CreateRegion(origin, regionSize, 0.5, "Hitbox", Enum.PartType.Cylinder)
	
	DivineGrace.ActivateHitbox(player, region)
end

return DivineGrace
