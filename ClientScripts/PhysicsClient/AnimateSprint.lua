-- Services
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Modules
local PhysicsClient = ReplicatedStorage:WaitForChild("PhysicsClient")
local AnimateClient = require(PhysicsClient.AnimateClient)

-- References
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local DEFAULT_FOV = 70
local tween: Tween

-- Root
local AnimateSprint = {}

function AnimateSprint.ToggleSprint()
	if tween then tween:Cancel() end
	
	if Player.Character.Humanoid.WalkSpeed <= 16 then
		tween = TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {FieldOfView = 85})
		tween:Play()
	else
		tween = TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {FieldOfView = DEFAULT_FOV})
		tween:Play()
	end
end

Player.CharacterAdded:Connect(function()
	if tween then tween:Cancel() end
	
	tween = TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {FieldOfView = DEFAULT_FOV})
	tween:Play()
end)


return AnimateSprint
