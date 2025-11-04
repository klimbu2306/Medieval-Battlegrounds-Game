-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- References
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Animation = Remotes:WaitForChild("Animation")

-- Root
local AnimateClient = {}

-- Functions
function AnimateClient.GetAnimator(target: Model): Animator
	-- (1) Sanity Check for presence of Humanoid
	local humanoid: Humanoid = target:WaitForChild("Humanoid")
	if not humanoid then warn(`Animation Error: Humanoid in {target.Name} could not be found!`) return end

	-- (2) Sanity Check for presence of Animator
	local animator: Animator = humanoid:WaitForChild("Animator")
	if not animator then warn(`Animation Error: Animator in {target.Name}'s' Humanoid could not be found!`) return end
	
	return animator
end

function AnimateClient.Animate(target: Model, animationObject: Animation, animationSpeed: number?)
	-- (0) Setup Optional Parameters
	animationSpeed = animationSpeed or 1
	
	-- (1) Sanity Check for presence of Animator
	local animator: Animator = AnimateClient.GetAnimator(target)
	if not animator then return end
	
	-- (2) Safely Attempt to Play Animation (incase AnimationService fails)
	local success, fail = pcall(function()
		-- (A) Yield for a Second, to ensure AnimationService will Load in time!
		RunService.Stepped:Wait()
		
		-- (B) Play requested Animation Track!
		local animation: AnimationTrack = animator:LoadAnimation(animationObject)
		animation:Play()
		animation:AdjustSpeed(animationSpeed)
	end)

	if fail then
		warn(`Animation Error: AnimationService could not be Loaded in time for {target.Name}'s Animation to play!`)
	end
end

function AnimateClient.SwitchToolGrip(target: Model, toolGripId: string)
	local function SetToolGrip()
		-- (A) If Character has a Tool Animation playing, :Cancel() it
		RunService.Stepped:Wait()
		
		-- (B) Set New Tool Grip Animation, then force it to :Play()
		local toolNoneAnim: Animation = target.Animate.toolnone.ToolNoneAnim
		if not toolNoneAnim then return end
		
		toolNoneAnim.AnimationId = toolGripId
		AnimateClient.Animate(target, toolNoneAnim)
	end
	
	-- (0) Safely Attempt to Switch Tool Grip Animation (incase AnimationService fails)	
	local MAX_ATTEMPTS = 7
	
	for i = 1, MAX_ATTEMPTS do
		local success, fail = pcall(SetToolGrip)
		
		if success then
			break
		else
			warn(`Animation Error: AnimationService could not be Loaded in time for {target.Name}'s Tool Grip Animation to Switch on Frame {i}!`)
		end
		
		if i < MAX_ATTEMPTS then
			warn(`Animation Error Exception: Animation Handler is Attempting to Equip Tool Again`)
		end
	end
end

function AnimateClient.CancelToolGrip(target: Model)
	-- (1) Sanity Check for presence of Animator
	local animator: Animator = AnimateClient.GetAnimator(target)
	if not animator then return end
	
	-- (2) Check all Playing Animations in Animator and :Cancel() the Tool Grip Animation
	for _, animation: AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
		if animation.Name == "ToolNoneAnim" then
			animation:Stop()
		end
	end
end

function AnimateClient.ActivateToolGrip(target: Model, animationId: string)
	-- (1) Sanity Check for presence of Animator
	local animator: Animator = AnimateClient.GetAnimator(target)
	if not animator then return end

	-- (2) Check all Playing Animations in Animator and :Cancel() the Tool Grip Animation
	for _, animation: AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
		if animation.Name == "ToolNoneAnim" then
			animation:Stop()
			
			local toolNoneAnim: Animation = target.Animate.toolnone.ToolNoneAnim
			if not toolNoneAnim then return end

			toolNoneAnim.AnimationId = animationId
			AnimateClient.Animate(target, toolNoneAnim)
		end
	end
end

function AnimateClient.PreLoadAnimations(player: Player, animations: {Animation})
	local character = player.Character
	if not character then return end
	
	local animator: Animator = AnimateClient.GetAnimator(character)
	if not animator then return end
	
	for _, animation: Animation in pairs(animations) do
		animator:LoadAnimation(animation)
	end
end

return AnimateClient
