-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- // References //
local DropperTemplate = game.ServerStorage:WaitForChild("DropperTemplate")

-- // Variables //
local DOUBLE_CASH_GAMEPASS = 985639119

-- // Root //
local DropperScript = {}

-- // Functions //
function DropperScript.DoubleCashGamepass(_self: Model)
	local Plot = _self:FindFirstAncestor("Plot")
	if not Plot then warn(`No Plot`) return end

	local PlotOwnerUserId = Plot:GetAttribute(`Owner`)
	if not PlotOwnerUserId then warn (`No Plot Owner User Id`) return end
	
	-- found the plot owner
	local PlayerObject = game.Players:GetPlayerByUserId(PlotOwnerUserId)
	if not PlayerObject then warn (`No Plot Owner Player Object found!`) return end
	
	-- check if they own 2x cash gamepass
	if MarketplaceService:UserOwnsGamePassAsync(PlayerObject.UserId, DOUBLE_CASH_GAMEPASS) then
		_self:SetAttribute("2xGamepass", true)
	end
end

function DropperScript.Drop(_self: Model)
	local CashPerDrop = _self:GetAttribute("CashPerDrop")
		
	local newDropperPart = DropperTemplate:Clone()
	newDropperPart.BrickColor = BrickColor.new("Light blue")
	newDropperPart.CFrame = _self.Drop.CFrame - Vector3.new(0, 2, 0)
	newDropperPart:SetAttribute("CashToGive", CashPerDrop)
	newDropperPart.Parent = _self.DropperParts
	
	if _self:GetAttribute("2xGamepass") then
		newDropperPart.BrickColor = BrickColor.new("Gold")
		newDropperPart:SetAttribute("CashToGive", CashPerDrop * 2)
	end
end

function DropperScript.Main(_self: Model)
	pcall(function() DropperScript.DoubleCashGamepass(_self) end)
	while task.wait(2) or (_self ~= nil and _self.Parent ~= nil) do
		DropperScript.Drop(_self)
	end
end

return DropperScript
