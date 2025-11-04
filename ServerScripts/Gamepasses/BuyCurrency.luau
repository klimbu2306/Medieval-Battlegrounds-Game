-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- // References //
local Currency = {
	{2669957477, 5_000},
	{2669987093, 10_000},
	{2669987342, 25_000},
	{2669987632, 50_000},
	{2669987629, 100_000},
	{2669987630, 250_000}
}

-- // Functions //
function PurchaseProduct(receipt: {})
	local userId = receipt.PlayerId
	local productId = receipt.ProductId
	
	local player: Player = Players:GetPlayerByUserId(userId)
	
	for _, currency: {} in Currency do
		if productId == currency[1] then
			player.leaderstats.Cash.Value += currency[2]
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- // Runtime Environment //
MarketplaceService.ProcessReceipt = PurchaseProduct
