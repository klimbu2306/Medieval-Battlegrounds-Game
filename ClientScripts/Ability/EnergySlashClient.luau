-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- References
local FireballFX = Assets:WaitForChild("Fireball")
local FX = ReplicatedStorage:WaitForChild("FX")
local TrailSeperate = require(FX:WaitForChild("TrailSeperate"))

-- Variables
local LIFE_TIME = 2
local SPEED = 100

-- Root
local EnergySlashClient = {}

-- Functions
function EnergySlashClient.Disconnect(connection: RBXScriptSignal, fireball: BasePart)
	-- (1) :Disconnect() Fireball from Moving + Remove Fireball
	connection:Disconnect()
	Debris:AddItem(fireball, 2)	

	-- (2) Fade the white part of the Energy Slash
	local fadeTween: Tween = TweenService:Create(fireball, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1})
	fadeTween:Play()

	-- (2) Clear all Energy Slash VFX
	for _, p: ParticleEmitter in fireball:GetDescendants() do
		if p:IsA("ParticleEmitter") or p:IsA("Beam") then
			p.Enabled = false
		end
	end
end

function EnergySlashClient.Removing(energySlashId)
	-- (1) Track Fireball
	local EnergySlash: BasePart = workspace.FX:FindFirstChild(energySlashId)
	if not EnergySlash then return end
	
	-- (2) Play Energy Slash SFX
	local speaker = Instance.new("Part")
	speaker.CanCollide, speaker.CanTouch, speaker.CanQuery = false, false, false
	speaker.CFrame = EnergySlash.CFrame
	speaker.Size = Vector3.one
	speaker.Transparency = 1
	speaker.Anchored = true
	speaker.Parent = workspace.FX
	Debris:AddItem(speaker, 2)
	
	-- (3) Play Lightning SFX
	local Blast = script.Blast:Clone()
	Blast.Parent = speaker
	Blast:Play()
	Debris:AddItem(Blast, 2)

	-- (4) :Disconnect() Fireball from Moving, and Explode Fireball
	EnergySlash:SetAttribute("active", false)
end

function EnergySlashClient.Shadow(EnergySlash: BasePart)
	if not EnergySlash or EnergySlash.Parent == nil then return end

	local shadow = script.Shadow:Clone()
	shadow.CFrame = EnergySlash.CFrame
	shadow.Parent = workspace.FX
	Debris:AddItem(shadow, 0.1)

	local fadeTween: Tween = TweenService:Create(shadow, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1})
	fadeTween:Play()
end

function EnergySlashClient.Main(player, energySlashId, properties: {})
		--[[
	[PROPERTIES]
	> Origin: CFrame
	> MouseHit: CFrame
	--]]
	
	-- (0) Load Parameters recieved from Server
	local Origin: CFrame = properties.Origin

	-- (1) Setup Fireball Hitbox
	local EnergySlash = script.EnergySlash:Clone()
	EnergySlash.Name = energySlashId
	EnergySlash.Parent = workspace.FX
	EnergySlash.CFrame = Origin * CFrame.new(0, 1, 0)
	
	-- (2) Play Fireball SFX
	local sound = script.Fire:Clone()
	sound.Parent = EnergySlash
	sound:Play() 
	Debris:AddItem(sound, 2)
	
	local startTime = time()
	local velocity = (Origin.LookVector) * SPEED
	local TRAIL_SPACING = 7
	
	-- (3) Move Fireball FX
	EnergySlash:SetAttribute("active", true)

	local connection	
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			EnergySlash:SetAttribute("active", false)
			EnergySlashClient.Disconnect(connection, EnergySlash)
			return
		end
		
		if not EnergySlash:GetAttribute("active") then
			EnergySlashClient.Disconnect(connection, EnergySlash)
			return
		end
		
		local deltaVelocity = velocity * DT
		EnergySlash.CFrame = CFrame.new(EnergySlash.CFrame.Position, EnergySlash.CFrame.Position + velocity) * CFrame.Angles(0, 0, math.rad(90)) + deltaVelocity
		
		EnergySlashClient.Shadow(EnergySlash)
		
		TrailSeperate.Main({Offset = TRAIL_SPACING, SizeRange = {200/100, 300/100}, Duration = 0.5, AnimationTime = 1}, CFrame.new(EnergySlash.CFrame.Position, EnergySlash.CFrame.Position + velocity))
		TrailSeperate.Main({Offset = -TRAIL_SPACING, SizeRange = {200/100, 300/100}, Duration = 0.5, AnimationTime = 1},  CFrame.new(EnergySlash.CFrame.Position, EnergySlash.CFrame.Position + velocity))
	end)
end

return EnergySlashClient
