-- Root
local Speed = {}

-- Functions
function Speed.ResetSpeed(model: Model)	
	-- (0) Do not reset WalkSpeed if the Character has been Stunned by another attack
	local stunned = model:FindFirstChild("Stunned")
	if stunned then return end
	if not model:FindFirstChild("Humanoid") then return end
		
	-- (1) Reset Human WalkSpeed
	local resetSpeed = if model:FindFirstChild("Sprinting") then 20 else 16
	model.Humanoid.WalkSpeed = resetSpeed
	model.Humanoid.JumpPower = 50
end

function Speed.ResetSpeedOnDestroy(model: Model, instance: Instance)
	local connection: RBXScriptSignal
	connection = instance.Destroying:Connect(function()
		Speed.ResetSpeed(model)
		connection:Disconnect()
		return
	end)
end

function Speed.ApplySpeed(model: Model, speed: number, duration: number, mode: "ResetByTime" | "ResetByEvent"?)
	mode = mode or "ResetByTime"
	
	-- (0) Check Model is a Human
	if not model:FindFirstChild("Humanoid") then return end
	
	-- (1) Set WalkSpeed of Human, temporarily
	model.Humanoid.WalkSpeed = speed
	model.Humanoid.JumpPower = 0
	
	if mode == "ResetByEvent" then return end
	task.delay(duration, function() Speed.ResetSpeed(model) end)
end

return Speed
