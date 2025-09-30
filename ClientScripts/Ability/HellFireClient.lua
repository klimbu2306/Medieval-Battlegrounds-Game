-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Modules
local FX = ReplicatedStorage:WaitForChild("FX")
local CraterModule = require(FX:WaitForChild("Crater"))

-- References
local Assets = ReplicatedStorage:WaitForChild("Assets")
local LightningFX = Assets:WaitForChild("Lightning")

-- Variables
local CRATER_PIECES = 17

-- Root
local HellFireClient = {}

-- Functions
function HellFireClient.Raycast(origin: CFrame): RaycastResult
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Map}

	local attackerCFrame: CFrame = origin
	local pointToTarget = CFrame.new(origin.Position, origin.Position - Vector3.new(0, 20, 0)).LookVector * 20
	local Result = workspace:Raycast(origin.Position,  pointToTarget, raycastParams)

	return Result
end

function HellFireClient.Removing(...)
	-- pass
end

function HellFireClient.Main(...)
	local player, healId, HealingParams: {}, origin: CFrame = ...
	
	-- (1) Play Healing VFX + SFX
	local Speaker = Instance.new("Part")
	Speaker.CanCollide = false
	Speaker.CanTouch = false
	Speaker.CanQuery = false
	Speaker.Anchored = true
	Speaker.Size = Vector3.one
	Speaker.Transparency = 1
	Speaker.CFrame = player.Character.PrimaryPart.CFrame
	Speaker.Parent = workspace.FX
	Debris:AddItem(Speaker, 1)
	
	local HealSFX = script.Heal:Clone()
	HealSFX.Parent = Speaker
	HealSFX:Play()
	Debris:AddItem(HealSFX, 1)
	
	local FireTornado = script.FireTornadoFX:Clone()
	FireTornado.Parent = Speaker
	FireTornado.CFrame = origin
	Debris:AddItem(FireTornado, 1)
	
	for _, fx: ParticleEmitter in FireTornado:GetDescendants() do
		if not fx:IsA("ParticleEmitter") then continue end
		fx.Enabled = true
	end
	
	task.delay(0.5, function()
		for _, fx: ParticleEmitter in FireTornado:GetDescendants() do
			if not fx:IsA("ParticleEmitter") then continue end
			fx.Enabled = false
		end
	end)
end


return HellFireClient
