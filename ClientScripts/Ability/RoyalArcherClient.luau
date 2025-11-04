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
local SPEED = 175

-- Root
local RoyalArcherClient = {}

-- Functions
function RoyalArcherClient.Disconnect(connection: RBXScriptSignal, fireball: BasePart)
	-- (1) :Disconnect() Fireball from Moving + Remove Fireball
	connection:Disconnect()
	Debris:AddItem(fireball, 2)	

	-- (2) Clear all Energy Slash VFX
	for _, p: ParticleEmitter in fireball:GetDescendants() do
		if p:IsA("ParticleEmitter") or p:IsA("Beam") then
			p.Enabled = false
		end
	end
end

function RoyalArcherClient.Removing(energySlashId)
	-- (1) Track Fireball
	local EnergySlash: BasePart = workspace.FX:FindFirstChild(energySlashId)
	if not EnergySlash then return end
	
	-- (2) Play Energy Slash SFX
	local speaker = Instance.new("Part")
	speaker.CanCollide, speaker.CanTouch, speaker.CanQuery = false, false, false
	speaker.CFrame = EnergySlash.PrimaryPart.CFrame
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

function RoyalArcherClient.Shadow(EnergySlash: BasePart)
	if not EnergySlash or EnergySlash.Parent == nil then return end

	local shadow = script.Shadow:Clone()
	shadow.CFrame = EnergySlash.CFrame
	shadow.Parent = workspace.FX
	Debris:AddItem(shadow, 0.1)

	local fadeTween: Tween = TweenService:Create(shadow, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1})
	fadeTween:Play()
end

function RoyalArcherClient.FireAnimation(model: Model)
	local humanoid: Humanoid = model:FindFirstChild("Humanoid")
	local animator: Animator = humanoid:FindFirstChild("Animator")

	local animation: AnimationTrack =  animator:LoadAnimation(script.FireAnimation)
	animation:Play()
end

function RoyalArcherClient.Main(player, energySlashId, properties: {})
		--[[
	[PROPERTIES]
	> Origin: CFrame
	> MouseHit: CFrame
	--]]
	
	-- (0) Load Parameters recieved from Server
	local Origin: CFrame = properties.Origin
	
	-- (0A) Leave an After-Image FX behind
	local Clone = script.Archer:Clone()
	Clone:SetPrimaryPartCFrame(Origin + Origin.LookVector * 7)
	Clone.Parent = workspace.FX
	Debris:AddItem(Clone, 2)

	RoyalArcherClient.FireAnimation(Clone)

	-- (1) Setup Fireball Hitbox
	local LightArrow: Model = script.LightArrowProjectile:Clone()
	LightArrow.Name = energySlashId
	LightArrow.Parent = workspace.FX
	LightArrow:PivotTo(Origin * CFrame.new(0, 1, 0) + Origin.LookVector * 15)
	--LightArrow.PrimaryPart.CFrame = Origin * CFrame.new(0, 1, 0)
	
	-- (2) Play Fireball SFX
	local sound = script.Fire:Clone()
	sound.Parent = LightArrow.PrimaryPart
	sound:Play() 
	Debris:AddItem(sound, 2)
	
	local startTime = time()
	local velocity = (Origin.LookVector) * SPEED
	
	-- (3) Move Fireball FX
	LightArrow:SetAttribute("active", true)

	local connection	
	connection = RunService.Heartbeat:Connect(function(DT: number)
		if time() >= startTime + LIFE_TIME then
			LightArrow:SetAttribute("active", false)
			RoyalArcherClient.Disconnect(connection, LightArrow)
			return
		end
		
		if not LightArrow:GetAttribute("active") then
			RoyalArcherClient.Disconnect(connection, LightArrow)
			return
		end
		
		local deltaVelocity = velocity * DT
		local newPosition = CFrame.new(LightArrow.PrimaryPart.CFrame.Position, LightArrow.PrimaryPart.CFrame.Position + velocity) * CFrame.Angles(0, 0, math.rad(90)) + deltaVelocity
		LightArrow:PivotTo(newPosition)
		
		RoyalArcherClient.Shadow(LightArrow.PrimaryPart)
		
		TrailSeperate.Main({Offset = 0, SizeRange = {200/100, 300/100}, Duration = 0.5, AnimationTime = 1}, CFrame.new(LightArrow.PrimaryPart.CFrame.Position, LightArrow.PrimaryPart.CFrame.Position + velocity))
	end)
end

return RoyalArcherClient
