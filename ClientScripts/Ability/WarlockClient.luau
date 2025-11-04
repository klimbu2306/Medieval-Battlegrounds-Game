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
local WarlockClient = {}

-- Functions
function WarlockClient.Raycast(origin: CFrame): RaycastResult

end

function WarlockClient.Removing(...)
	-- pass
end

function WarlockClient.ShowCharacter(character: Model)
	for _, v in pairs(character:GetDescendants()) do
		if not v:IsA("BasePart") then continue end
		if v.Name == "HumanoidRootPart" then continue end
		if character:FindFirstChild("DemonHideLegs") and (v.Name == "Left Leg" or v.Name == "Right Leg") then continue end

		local tween = TweenService:Create(v, TweenInfo.new(0.25), {Transparency = 0})
		tween:Play()
	end
	
	pcall(function()
		if not character:FindFirstChild("DemonHideLegs") then
			local face = character:FindFirstChild("Head"):FindFirstChild("face")
			local tween = TweenService:Create(face, TweenInfo.new(0.25), {Transparency = 0})
			tween:Play()
		end
	end)
end

function WarlockClient.HideCharacter(character: Model)
	for _, v in pairs(character:GetDescendants()) do
		if not v:IsA("BasePart") then continue end

		local tween = TweenService:Create(v, TweenInfo.new(0.25), {Transparency = 1})
		tween:Play()
	end
	
	pcall(function()
		if not character:FindFirstChild("DemonHideLegs") then
			local face = character:FindFirstChild("Head"):FindFirstChild("face")
			local tween = TweenService:Create(face, TweenInfo.new(0.25), {Transparency = 1})
			tween:Play()
		end
	end)
end

function WarlockClient.Main(...)
	local player, healId, HealingParams: {}, origin: CFrame = ...
	
	-- (1) Leave an After-Image FX behind
	local Clone = ShadowStepFX:FindFirstChild("ShadowStep"):Clone()
	Clone:SetPrimaryPartCFrame(origin)
	Clone.Parent = workspace
	Debris:AddItem(Clone, 1.5)
	
	task.delay(0.25, function()
		WarlockClient.HideCharacter(Clone)
	end)
	
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
	
	-- (3) Temporarily Hide the Shadow Stepping Player Character
	WarlockClient.HideCharacter(player.Character)
	
	-- (4) Then Unhide them...
	task.delay(1.5, function()
		WarlockClient.ShowCharacter(player.Character)
	end)
end

return WarlockClient
