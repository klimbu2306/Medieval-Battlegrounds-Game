-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- References
local FireballFX = Assets:WaitForChild("Meteor")

-- Variables
local LIFE_TIME = 4
local SPEED = 120

-- Root
local MeteorShowerClient = {}

-- Functions
function MeteorShowerClient.Disconnect(connection: RBXScriptSignal, fireball: BasePart)
	-- (1) :Disconnect() Fireball from Moving + Remove Fireball
	connection:Disconnect()
	Debris:AddItem(fireball, 2)
	
	-- (2) Clear all Fireball VFX
	for _, p: ParticleEmitter in fireball:GetDescendants() do
		if p:IsA("ParticleEmitter") then
			p.Enabled = false
		end
	end
end

function MeteorShowerClient.Explode(origin: CFrame, i: number)
	-- (1) Fetch Explosion :Clone()
	local explosion = FireballFX.Explode:Clone()
	explosion.CFrame = origin
	explosion.Parent = workspace
	
	-- (2) Play Explosion VFX
	for _, v in explosion:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
	
	Debris:AddItem(explosion, 4)
	
	if i == 1 then
		local sound = script.Explosion:Clone()
		sound.Parent = explosion
		sound.Name = "ExplosionSFX"
		sound:Play()
		Debris:AddItem(sound, 2)
	end
end

function MeteorShowerClient.Removing(fireballId, i)
	-- (1) Track Fireball
	local Fireball: BasePart = workspace.FX:FindFirstChild(fireballId)
	if not Fireball then return end
	
	-- (2) :Disconnect() Fireball from Moving, and Explode Fireball
	Fireball:SetAttribute("active", false)
	
	local origin = Fireball.CFrame
	MeteorShowerClient.Explode(origin, i)
end

function MeteorShowerClient.SummonFireball(Origin: CFrame, i: number, radius: number, facingAngle: number, fireballId: string)
	local angle = facingAngle + math.rad(45 * i) -- Convert degrees to radians
	local offsetX = math.cos(angle) * radius
	local offsetZ = math.sin(angle) * radius

	-- (1) Setup Fireball Hitbox
	local Fireball = FireballFX.Fireball:Clone()
	Fireball.Name = `{fireballId}{i}`
	Fireball.Parent = workspace.FX
	Fireball.CFrame = CFrame.new(Origin.Position) * CFrame.new(0, 75, 0) + Vector3.new(offsetX, 0, offsetZ)

	-- (2) Play Fireball SFX
	if i == 1 then
		local sound = script.Fire:Clone()
		sound.Parent = Fireball
		sound:Play() 
		Debris:AddItem(sound, 2)
	end

	local startTime = time()
	local velocity = Vector3.new(0, -SPEED, 0) 

	-- (3) Move Fireball FX
	Fireball:SetAttribute("active", true)

	local connection	
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			Fireball:SetAttribute("active", false)
			MeteorShowerClient.Disconnect(connection, Fireball)
			return
		end

		if not Fireball:GetAttribute("active") then
			MeteorShowerClient.Disconnect(connection, Fireball)
			return
		end

		local deltaVelocity = velocity * DT
		Fireball.CFrame = CFrame.new(Fireball.CFrame.Position) + deltaVelocity
	end)

	-- (4) Every Second, Play a Ring Effect around the Fireball
	--[[
	while Fireball:GetAttribute("active") do
		task.wait(0.5)

		local ring = FireballFX.Ring:Clone()
		ring.CFrame = CFrame.new(Fireball.Position, Fireball.Position + velocity) * CFrame.Angles(math.rad(90), 0, 0)
		ring.Parent = workspace.FX

		local tween = TweenService:Create(ring, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = Vector3.new(10, 0.5, 10), Transparency = 1})
		tween:Play()
		Debris:AddItem(ring, 1)
	end
	--]]
end

function MeteorShowerClient.Main(player, fireballId, properties: {})
		--[[
	[PROPERTIES]
	> Origin: CFrame
	> MouseHit: CFrame
	--]]
	
	-- (0) Load Parameters recieved from Server
	local Origin = properties.Origin
	
	local radius = 15 -- Distance from the player to each meteor
	local numMeteors = 8 -- Number of meteors in the hexagon
	local facingAngle = math.atan2(Origin.LookVector.Z, Origin.LookVector.X)

	for i = 1, numMeteors, 1 do
		task.spawn(function()
			MeteorShowerClient.SummonFireball(Origin, i, radius, math.atan2(Origin.LookVector.Z, Origin.LookVector.X), fireballId)
		end)
	end
end

return MeteorShowerClient
