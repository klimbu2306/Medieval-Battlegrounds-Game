-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Root
local MeleeClient = {}

-- Functions

function MeleeClient.Removing(...)
	-- pass
end

function MeleeClient.Main(...)
	local player, MeleeParams: {}, origin: CFrame = ...
	
	local LIFE_TIME = 2
	
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
	Debris:AddItem(Speaker, LIFE_TIME)
	
	local HitSFX = script.HitSounds:FindFirstChild(MeleeParams.HitSound):Clone()
	HitSFX.Parent = Speaker
	HitSFX:Play()
	Debris:AddItem(HitSFX, LIFE_TIME)
end


return MeleeClient
