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
local Ragdoll = require(Physics:WaitForChild("Ragdoll"))
local Cooldown = require(Physics:WaitForChild("Cooldown"))

local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local EndLag = require(PhysicsClient:WaitForChild("EndLag"))

-- Root
local HealModule = {}

-- Variables
local LIFE_TIME = 0.4
local SPEED = 150

-- Functions
function HealModule.Main(player: Player, properties: {})
	--[[
	[PROPERTIES]
	> Origin: CFrame
	> MouseHit: CFrame
	--]]
	
	-- (0) Type-check & Sanity-check ALL Parameters
	if typeof(properties) ~= typeof({}) then warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`) return end
	
	local Origin = properties.Origin
	if (not Origin) or (typeof(Origin) ~= typeof(CFrame.new(0, 0, 0))) then warn(`ParameterType Error: Origin DataType passed in was NOT a CFrame value!`) return end
	if (player.Character.PrimaryPart.Position - Origin.Position).Magnitude > 10 then warn(`ExtremeValue Error: Origin DataType's value is too far from Humanoid's Actual Origin!`) return end

	-- (1) Cancel Attack if (A) Player has been Stunned, (B) Character has died, or (C) Ability is still on Cooldown
	if player.Character:FindFirstChild("Stunned") or player.Character:FindFirstChild("RagdollState") then return end
	if player.Character:FindFirstChild(`HealCD`) then return end
	
	Cooldown.SetEndlag(player.Character, "Heal", 0.25)
	if EndLag.EndLagInterrupt(player.Character, "Heal") then return end

	Cooldown.SetCooldown(player.Character, "HealCD", 15)
	
	-- (2) Heal Player
	local HEAL_AMOUNT = 25
	player.Character.Humanoid.Health += HEAL_AMOUNT
	
	-- (3) Play Highlight Animation on Player
	Effects.LoadEffect:FireAllClients("Highlight", player.Character, Color3.fromRGB(0, 255, 0), 0.5)

	-- (4) Play Particle effect on the Client-side
	local HealId = `Heal{time()}`
	Effects.LoadAbility:FireAllClients("Heal", player, HealId, {}, Origin)
end

return HealModule
