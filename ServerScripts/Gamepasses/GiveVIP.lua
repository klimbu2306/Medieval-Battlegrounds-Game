-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Gamepasses = ServerStorage:WaitForChild("Gamepasses")
local Teams = game:GetService("Teams")

-- // References //
local VIP_GAMEPASS_ID = 986076978

-- // Functions //
function GiveVIP(player: Player)
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID) then
		local VIP = Instance.new("ObjectValue")
		VIP.Name = "ChatVIP"
		VIP.Parent = player
	end
end

function PurchaseGamepass(player: Player, id: number, wasPurchased: boolean)
	if not wasPurchased then return end
	
	if id == VIP_GAMEPASS_ID then
		GiveVIP(player)
	end
end

function GiveHealthBoost(player: Player, character: Model)
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID) then
		local humanoid: Humanoid = character:WaitForChild("Humanoid")

		local HEALTH_BOOST = 25
		humanoid.MaxHealth = humanoid.MaxHealth + HEALTH_BOOST
		humanoid.Health = humanoid.MaxHealth
	end
end

-- // Runtime Environment //
Players.PlayerAdded:Connect(function(player: Player)
	GiveVIP(player)
	
	pcall(function()
		GiveHealthBoost(player, player.Character)
	end)
	
	player.CharacterAdded:Connect(function(character: Character)
		GiveHealthBoost(player, character)
	end)
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(PurchaseGamepass)
