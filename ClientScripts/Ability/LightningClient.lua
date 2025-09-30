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
local LightningModule = {}

-- Functions
function LightningModule.Removing(...)
	-- pass
end

function LightningModule.Main(...)
	local player, LightningId, LightningParams: {}, origin: CFrame = ...
	
	-- (1) Summon Lightning Bolt VFX
	local LIFE_TIME = 1
	
	local LightningBolt = script.Lightning:Clone()
	LightningBolt.Position = LightningParams.LightningOrigin.Position
	LightningBolt.Parent = workspace.FX
	Debris:AddItem(LightningBolt, LIFE_TIME)
	
	-- (2) Summon Lightning Shockwave VFX
	local Shockwave = LightningFX:WaitForChild("Ring"):Clone()
	Shockwave.Position = LightningParams.LightningOrigin.Position
	Shockwave.Parent = workspace.FX
	Debris:AddItem(Shockwave, 2)
	
	-- (3) Play Lightning Shockwave Animation
	local DEFAULT_SIZE = Vector3.new(1, 0.05, 1)
	local NEW_SIZE = DEFAULT_SIZE * 100
	
	Shockwave.Size = DEFAULT_SIZE
	local ShockwaveTween = TweenService:Create(Shockwave, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1, Size = NEW_SIZE})
	ShockwaveTween:Play()

	-- (4) Play Lightning SFX
	local Blast = script.Blast:Clone()
	Blast.Parent = LightningBolt
	Blast:Play()
	Debris:AddItem(Blast, 3)
end


return LightningModule
