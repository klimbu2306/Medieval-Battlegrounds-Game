-- Services
local DebrisService = game:GetService("Debris")

-- Root
local GiveItemFX = {}

-- Functions
function GiveItemFX.GetVFXAttachment(): Attachment
	for _, attachment: Attachment in script:GetDescendants() do
		if not attachment:IsA("Attachment") then continue end
		return attachment
	end
end

function GiveItemFX.EnableVFX(attachment: Attachment, value: boolean)
	for _, vfx: ParticleEmitter in attachment:GetDescendants() do
		if not vfx:IsA("ParticleEmitter") then continue end
		vfx.Enabled = value
	end
end

function GiveItemFX.PlaySFX(model: Model)
	local cloneSFX = script.SFX:Clone()
	cloneSFX.Parent = model.PrimaryPart
	
	DebrisService:AddItem(cloneSFX, cloneSFX.TimeLength)
	cloneSFX:Play()
end

function GiveItemFX.Main(parameters: {})
	local model = parameters.Model
	
	-- Playing effect
	local newFX = GiveItemFX.GetVFXAttachment():Clone()
	newFX.Parent = model.PrimaryPart
	GiveItemFX.EnableVFX(newFX, true)
	GiveItemFX.PlaySFX(model)

	DebrisService:AddItem(newFX, 1)

	task.delay(0.5, function()
		GiveItemFX.EnableVFX(newFX, false)
	end)
end

return GiveItemFX
