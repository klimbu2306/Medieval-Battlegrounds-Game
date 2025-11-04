-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Gamepasses = ServerStorage:WaitForChild("Gamepasses")
local RunService = game:GetService("RunService")

-- // References //
local GAMEPASS_ID = 986017023

-- // Functions //
function AutoCollect(player: Player)
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_ID) then
		local StoredCash = player:WaitForChild("StoredCash")
		
		local connection: RBXScriptSignal
		connection = StoredCash.Changed:Connect(function()
			player.leaderstats.Cash.Value += StoredCash.Value
			StoredCash.Value = 0
		end)
		
		local playerConnection: RBXScriptSignal
		playerConnection = Players.PlayerRemoving:Connect(function(leavingPlayer: Player)
			if player == leavingPlayer then
				connection:Disconnect(); connection = nil
				playerConnection:Disconnect(); playerConnection = nil
			end
		end)
	end
end

function PurchaseGamepass(player: Player, id: number, wasPurchased: boolean)
	if not wasPurchased then return end

	if id == GAMEPASS_ID then
		AutoCollect(player)
	end
end

-- // Runtime Environment //
Players.PlayerAdded:Connect(AutoCollect)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(PurchaseGamepass)
