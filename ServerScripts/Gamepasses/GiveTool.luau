-- // Services //
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Gamepasses = ServerStorage:WaitForChild("Gamepasses")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Tycoon = Remotes:WaitForChild("Tycoon")
local RequestItem = Tycoon:WaitForChild("RequestItem")


-- // References //
local Tools = {
	{987168634, Gamepasses.RainbowMagicCarpet},
	{982860220, Gamepasses.RocketLauncher},
	{986519551, Gamepasses.SpeedCoil},
	{986401590, Gamepasses.GravityCoil},
	{983002164, Gamepasses.JetPack},
	{986076978, Gamepasses.MeteorShower}
}

-- // Functions //
function GetToolFromId(id: number)
	for _, toolInfo: {} in Tools do
		if toolInfo[1] == id then
			return toolInfo[2]
		end
	end
end

function GiveTool(player: Player, id: number)
	if not id or typeof(id) ~= typeof(123) then return end
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) then
		local gamepass: Tool = GetToolFromId(id)
		local tool: Tool = gamepass:Clone()
		tool.Parent = player.Backpack
		pcall(function() tool:SetAttribute("added", time()) end)
	end
end

function PurchaseGamepass(player: Player, id: number, wasPurchased: boolean)
	if not wasPurchased then return end
	
	for _, toolInfo: {} in Tools do
		if toolInfo[1] == id then
			GiveTool(player, toolInfo[1], toolInfo[2])
		end
	end
end

-- // Runtime Environment //
RequestItem.OnServerEvent:Connect(GiveTool)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(PurchaseGamepass)
