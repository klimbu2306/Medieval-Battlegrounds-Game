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
local MeteorClient = {}

-- Functions
function MeteorClient.Disconnect(connection: RBXScriptSignal, fireball: BasePart)
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

function MeteorClient.Explode(origin: CFrame)
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
	
	Debris:AddItem(explosion, 2)
	
	-- (3) Play Explosion SFX
	local sound = script.Explosion:Clone()
	sound.Parent = explosion
	sound.Name = "ExplosionSFX"
	sound:Play()
	Debris:AddItem(sound, 2)
end

function MeteorClient.Removing(fireballId)
	-- (1) Track Fireball
	local Fireball: BasePart = workspace.FX:FindFirstChild(fireballId)
	if not Fireball then return end
	
	-- (2) :Disconnect() Fireball from Moving, and Explode Fireball
	Fireball:SetAttribute("active", false)
	
	local origin = Fireball.CFrame
	MeteorClient.Explode(origin)
end

function MeteorClient.Main(player, fireballId, properties: {})
		--[[
	[PROPERTIES]
	> Origin: CFrame
	> MouseHit: CFrame
	--]]
	
	-- (0) Load Parameters recieved from Server
	local Origin = properties.Origin

	-- (1) Setup Fireball Hitbox
	local Fireball = FireballFX.Fireball:Clone()
	Fireball.Name = fireballId
	Fireball.Parent = workspace.FX
	Fireball.CFrame = Origin * CFrame.new(0, 100, 0)
	
	-- (2) Play Fireball SFX
	local sound = script.Fire:Clone()
	sound.Parent = Fireball
	sound:Play() 
	Debris:AddItem(sound, 2)
	
	local startTime = time()
	local velocity = Vector3.new(0, -SPEED, 0) 
	
	-- (3) Move Fireball FX
	Fireball:SetAttribute("active", true)

	local connection	
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			Fireball:SetAttribute("active", false)
			MeteorClient.Disconnect(connection, Fireball)
			return
		end
		
		if not Fireball:GetAttribute("active") then
			MeteorClient.Disconnect(connection, Fireball)
			return
		end
		
		local deltaVelocity = velocity * DT
		Fireball.CFrame = CFrame.new(Fireball.CFrame.Position) + deltaVelocity
	end)
	
	-- (4) Every Second, Play a Ring Effect around the Fireball
	--[[
	while Fireball:GetAttribute("active") do
		task.wait(0.1)

		local ring = FireballFX.Ring:Clone()
		ring.CFrame = CFrame.new(Fireball.Position, Fireball.Position + velocity) * CFrame.Angles(math.rad(90), 0, 0)
		ring.Parent = workspace.FX
		
		local tween = TweenService:Create(ring, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = Vector3.new(10, 0.5, 10), Transparency = 1})
		tween:Play()
		Debris:AddItem(ring, 1)
	end
	--]]
end

return MeteorClient
