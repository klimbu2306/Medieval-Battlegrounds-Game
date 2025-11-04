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
local ShadowStepFX = Assets:WaitForChild("ShadowStep")

-- Variables
local CRATER_PIECES = 17

-- Root
local RoyalGuard = {}

-- Functions
function RoyalGuard.Removing(...)
	-- pass
end

function RoyalGuard.Swing(model: Model)
	local humanoid: Humanoid = model:FindFirstChild("Humanoid")
	local animator: Animator = humanoid:FindFirstChild("Animator")
	
	local animation: AnimationTrack =  animator:LoadAnimation(script.Swing)
	animation:Play()
end

function RoyalGuard.Main(...)
	local player, RoyalGuardId, RoyalGuardParams: {}, origin: CFrame = ...
	
	local RoyalGuardCFrame: CFrame = origin + origin.LookVector * 10
	
	-- (1) Leave an After-Image FX behind
	local Clone = script.General:Clone()
	Clone:SetPrimaryPartCFrame(RoyalGuardCFrame)
	Clone.Parent = workspace.FX
	Debris:AddItem(Clone, 2)
	
	RoyalGuard.Swing(Clone)
	
	-- (2) Play Shadow Step SFX
	local Speaker = Instance.new("Part")
	Speaker.CanCollide = false
	Speaker.CanTouch = false
	Speaker.CanQuery = false
	Speaker.Anchored = true
	Speaker.Size = Vector3.one
	Speaker.Transparency = 1
	Speaker.CFrame = origin
	Speaker.Parent = workspace.FX
	Debris:AddItem(Speaker, 1)
	
	local HealSFX = script.Phase:Clone()
	HealSFX.Parent = Speaker
	HealSFX:Play()
	Debris:AddItem(HealSFX, 1)
end

return RoyalGuard
