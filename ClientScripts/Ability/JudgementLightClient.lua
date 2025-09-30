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
local LightningFX = Assets:WaitForChild("Lightning")

-- Variables
local CRATER_PIECES = 17

-- Root
local JudgementLightClient = {}

-- Functions
function JudgementLightClient.Removing(...)
	-- pass
end

function JudgementLightClient.Main(...)
	local player, LightningId, LightningParams: {}, origin: CFrame = ...
	
	local JudgementLightOrigin = LightningParams.JudgementLightOrigin.Position
		
	-- (1) Summon Judgement Ring Bolt VFX
	local TWEEN_TIME = 0.5
	
	local JudgementRing = script.JudgementRing:Clone()
	JudgementRing.Parent = workspace
	JudgementRing.Position = JudgementLightOrigin
	Debris:AddItem(JudgementRing, 2)
	
	local JudgementBeam = script.Beam:Clone()
	JudgementBeam.Parent = workspace
	JudgementBeam.Position = JudgementLightOrigin
	Debris:AddItem(JudgementBeam, 2)
	
	-- (4) Animate a Fade-In/Fade-Out for the Judgement Ring and a Point Light
	local tweenInfo: TweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

	local fadeInIndicator = TweenService:Create(JudgementRing.Decal, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 0})
	fadeInIndicator:Play()
	
	task.delay(0.25, function()
		local brightenTween = TweenService:Create(JudgementRing.Light, tweenInfo, {Brightness = 50})
		brightenTween:Play()

		local beamTween = TweenService:Create(JudgementBeam, tweenInfo, {Transparency = 0.5})
		beamTween:Play()
	end)
	
	task.delay(1, function()
		local brightenTween = TweenService:Create(JudgementRing.Light, tweenInfo, {Brightness = 0})
		brightenTween:Play()

		local fadeOutIndicator = TweenService:Create(JudgementRing.Decal, tweenInfo, {Transparency = 1})
		fadeOutIndicator:Play()
		
		local beamTween = TweenService:Create(JudgementBeam, tweenInfo, {Transparency = 1})
		beamTween:Play()
	end)

	-- (4) Play Judgement Ring SFX
	local Blast = script.Blast:Clone()
	Blast.Parent = JudgementRing
	Blast:Play()
	Debris:AddItem(Blast, 2)
	
	-- (5) Animate a Spin FX for the Judgement Light
	while wait() and JudgementRing.Parent ~= nil do
		if not JudgementRing or JudgementRing.Parent == nil then break end
		JudgementRing.CFrame = JudgementRing.CFrame * CFrame.Angles(math.rad(10), 0, 0)
	end
end


return JudgementLightClient
