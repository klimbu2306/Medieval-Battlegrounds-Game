-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- References
local ShockwaveFX = Assets:WaitForChild("Shockwave")

-- Root
local Shockwave = {}

-- Functions
function Shockwave.Main(...)
	local properties = ...
	
	--[[
	[PROPERTIES]:
	> Target: Model
	> LookVector: Vector3
	--]]
	
	local Target = properties.Target
	local LookVector = properties.LookVector
	local Duration = properties.Duration
	local TimeDelay = properties.TimeDelay
	
	local velocity = LookVector * 0.1
	local startTime = time()
	local lastTime = startTime
		
	local connection: RBXScriptConnection
	connection = RunService.Heartbeat:Connect(function(dt: number)
		if (time() >= startTime + Duration) then
			connection:Disconnect(); connection = nil
			return
		end
		
		if time() - lastTime >= TimeDelay then
			lastTime = time()
			
			local ring = ShockwaveFX.Ring:Clone()
			ring.CFrame = CFrame.new(Target.PrimaryPart.Position, Target.PrimaryPart.Position + velocity) * CFrame.Angles(math.rad(90), 0, 0)
			ring.Parent = workspace.FX

			local tween = TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = Vector3.new(5, 0.25, 5), Transparency = 1})
			tween:Play()
			Debris:AddItem(ring, 0.5)
		end
	end)
	
	task.delay(Duration, function()
		if not connection then return end
		connection:Disconnect(); connection = nil
	end)
end

return Shockwave
