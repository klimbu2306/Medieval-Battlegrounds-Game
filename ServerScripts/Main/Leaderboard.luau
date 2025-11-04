-- // Services //
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Events = ServerStorage:WaitForChild("Events")

-- // References //
local VIP_GAMEPASS = 986076978
local INFINITE_MONEY_GAMEPASS = 985529846

-- // Variables //
local TEST_PLAYERS = {117144414,944774416, -1, -2}

-- // Runtime Environment //
-- When a player joins the game
game.Players.PlayerAdded:Connect(function(player)
	-- (1) Track Money Leaderstats
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = folder
	
	local storedCash = Instance.new("IntValue")
	storedCash.Name = "StoredCash"
	storedCash.Value = 0
	storedCash.Parent = player
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS) then
		cash.Value += 2_500
	end
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, INFINITE_MONEY_GAMEPASS) then
		cash.Value += 100_000_000
	end
	
	if player.MembershipType == Enum.MembershipType.Premium then
		cash.Value += 1_000
	end
	
	if table.find(TEST_PLAYERS, player.UserId) then
		cash.Value += 999_999_999
	end
end)
