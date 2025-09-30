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
local LightningFX = Assets:WaitForChild("Lunge")

-- Variables
local CRATER_PIECES = 17

-- Root
local AfterImage = {}
local BodyParts = {"Head", "Torso", "Right Arm", "Right Leg", "Left Arm", "Left Leg", "HumanoidRootPart", "AnimeHair"}

-- Functions
function AfterImage.Removing(...)
	-- pass
end

function AfterImage.FadeOut(player: Player, shadow: Model)
	for _, part: BasePart in pairs(player.Character:GetChildren()) do
		if not part:IsA("BasePart") then continue end
		if not table.find(BodyParts, part.Name) then continue end
				
		local rigCFrame: CFrame = part.CFrame
		local bodyPart: Part = shadow:FindFirstChild(part.Name)
		
		if not bodyPart then continue end
		bodyPart.CFrame = rigCFrame
		bodyPart.CanCollide = false
	end
	
	for _, part: BasePart in pairs(shadow:GetChildren())  do
		if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then continue end
		local fadeOutTween: Tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1})
		fadeOutTween:Play()
	end
end

function AfterImage.Main(...)
	local player = ...
	
	-- (1) Summon Lightning Bolt VFX
	local Shadow = LightningFX:WaitForChild("Shadow")
	
	local startTime = time()
	local lastTime = startTime
	local TIME_STEP = 0.15
	local DURATION = 1
	
	local connection
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if not player then return end
		if not player.Character or player.Character.Parent == nil then return end
		
		if time() > startTime + DURATION then
			connection:Disconnect()
			return
		end
		
		if time() > lastTime + TIME_STEP then
			lastTime = time()
			
			local clone = Shadow:Clone()
			clone.Parent = workspace.FX
			Debris:AddItem(clone, 0.2)

			AfterImage.FadeOut(player, clone)
		end
	end)
	
	task.delay(1, function()
		connection:Disconnect()
	end)
end
return AfterImage
