-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")

-- // Modules //
local Physics = ServerStorage:WaitForChild("Physics")
local Notification = require(Physics:WaitForChild("Notification"))

-- // Variables //
local DOUBLE_CASH_GAMEPASS = 985639119

-- // Root //
local GiveCashOnDeath = {}

-- // Functions
function GiveCashOnDeath.Main(humanoid: Humanoid, cash: number)
	local LastHitBy = humanoid.Parent:FindFirstChild("LastHitBy")
	if not LastHitBy then return end

	local player: Player = LastHitBy.Value
	if not player then return end
	
	pcall(function()
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, DOUBLE_CASH_GAMEPASS) then
			cash *= 2
		end
	end)

	if table.find(Players:GetChildren(), player) then
		player.leaderstats.Cash.Value += cash
		
		local MarkerForNoob: ObjectValue = humanoid.Parent:FindFirstChild("MarkerForNoob")
		if MarkerForNoob then
			Notification.Notify(player, `You recieved ${cash} Cash!`, "Green", 2)
		end
	end
end

return GiveCashOnDeath
