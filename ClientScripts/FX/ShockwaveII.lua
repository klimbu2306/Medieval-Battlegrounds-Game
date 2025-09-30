-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- References
local Assets = ReplicatedStorage:WaitForChild("Assets")
local LightningFX = Assets:WaitForChild("Lightning")

-- Root
local ShockwaveII = {}

-- Functions
function ShockwaveII.Main(...)
	local properties = ...
	
	--[[
	[PROPERTIES]:
	> Target: Model
	> LookVector: Vector3
	--]]
	
	local Origin: CFrame = properties.Origin
	local Size: number = properties.Size
	local Duration: number = properties.Duration or 1
	
	-- (1) Summon Lightning Shockwave VFX
	local Shockwave = LightningFX:WaitForChild("Ring"):Clone()
	Shockwave.Position = Origin.Position
	Shockwave.Parent = workspace.FX
	Debris:AddItem(Shockwave, Duration)

	-- (2) Play Lightning Shockwave Animation
	local DEFAULT_SIZE = Vector3.new(1, 0.05, 1)
	local NEW_SIZE = DEFAULT_SIZE * Size

	Shockwave.Size = DEFAULT_SIZE
	local ShockwaveTween = TweenService:Create(Shockwave, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1, Size = NEW_SIZE})
	ShockwaveTween:Play()
end

return ShockwaveII
