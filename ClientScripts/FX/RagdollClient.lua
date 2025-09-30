-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Root
local RagdollClient = {}

function RagdollClient.Main(...)
	local Character, enabled = ...
	if Player.Character == Character then return end
	
	local Character = Player.Character
	if not Character then return end
	
	local humanoid: Humanoid = Character:WaitForChild("Humanoid")
	if not humanoid then return end
	
	if enabled then
		humanoid.PlatformStand = true
		humanoid.Sit = true
		humanoid.AutoRotate = false
	else
		humanoid.PlatformStand = true
		humanoid.Sit = false
		humanoid.AutoRotate = true
		humanoid.PlatformStand = false
	end
	
end

return RagdollClient
