-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Controls = Remotes:WaitForChild("Controls")

-- Variables
local DEFAULT_RUN_SPEED = 20
local DEFAULT_WALKSPEED = 16

-- Functions
function ToggleRunAnimation(humanoid: Humanoid, animationType: "Walk" | "Run")
	local animator: Animator = humanoid:FindFirstChild("Animator")
	if not animator then return end
	
	if animationType == "Walk" then
		for _, animation: AnimationTrack in animator:GetPlayingAnimationTracks() do
			if animation.Animation == script.Run then
				animation:Stop()
			end
		end
	elseif animationType == "Run" then
		local animation: AnimationTrack = animator:LoadAnimation(script.Run)
		animation:Play()
	end
end

Controls.Sprint.OnServerEvent:Connect(function(player: Player)
	-- (1) Check Character's Player hasn't died shortly before sending a Sprint Request
	local character = player.Character
	if not character then return end
	
	-- (2) If Player's Character is stunned, then prevent them from changing their WalkSpeed
	if character:FindFirstChild("Stunned") then return end
	
	-- (3) Check whether Player is Sprinting already or not
	local isSprinting = character:FindFirstChild("Sprinting")
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	
	if isSprinting then
		-- (A) If they are Sprinting, then reset WalkSpeed to DEFAULT_WALKSPEED
		local SprintingObject = isSprinting
		SprintingObject:Destroy()
		
		humanoid.WalkSpeed = DEFAULT_WALKSPEED
		--ToggleRunAnimation(humanoid, "Walk")
	else
		-- (B) If not, then set WalkSpeed to DEFAULT_RUN_SPEED
		local SprintingObject = Instance.new("ObjectValue")
		SprintingObject.Name = "Sprinting"
		SprintingObject.Parent = character
		humanoid.WalkSpeed = DEFAULT_RUN_SPEED
		--ToggleRunAnimation(humanoid, "Run")
	end
end)
