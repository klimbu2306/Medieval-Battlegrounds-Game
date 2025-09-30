-- Services
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Root
local Highlight = {}

-- Functions
function Highlight.Main(target: Model, color: Color3, tweenTime: number)
	-- (1) Destroy any previous Highlight being Animated on the Target
	local highlight: Highlight = target:FindFirstChild("Outline")
	if highlight then
		highlight:Destroy()
	end
	
	-- (2) Create a new Highlight on the Target
	local highlight = Instance.new("Highlight")
	highlight.Enabled = true
	highlight.Adornee = target
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = target
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1

	-- (3) Animate the Highlight
	local tween = TweenService:Create(highlight, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {FillTransparency = 1})
	tween:Play()
	Debris:AddItem(highlight, tweenTime)
end

return Highlight
