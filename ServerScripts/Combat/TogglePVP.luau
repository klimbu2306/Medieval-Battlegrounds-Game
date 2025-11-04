-- // Services //
local ServerScriptService = game:GetService("ServerScriptService")
local Main = ServerScriptService:WaitForChild("Main")
local LoadPlot = Main:WaitForChild("LoadPlot")

local ServerStorage = game:GetService("ServerStorage")
local Physics = ServerStorage:WaitForChild("Physics")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Combat = Remotes:WaitForChild("Combat")

-- // Modules //
local PlotRegion = require(Physics:WaitForChild("PlotRegion"))
local PlotInfo = require(LoadPlot:WaitForChild("PlotInfo"))
local Notification = require(Physics:WaitForChild("Notification"))

-- // Variables //
local ERROR_MESSAGE_1 = "System Message: You must first own a Plot to Disable PVP!"
local ERROR_MESSAGE_2 = "System Message: You must be within your Plot to Disable PVP!"
local SUCCESS_MESSAGE_1 = "System Message: PVP was Enabled!"
local SUCCESS_MESSAGE_2 = "System Message: PVP was Disabled!"

-- // Runtime Environment //
Combat.RequestTogglePVP.OnServerEvent:Connect(function(player: Player)
	-- (1) Make sure Player still has a Character
	local character = player.Character
	if not character then return end
	
	-- (2) Get Player's Plot
	local plot: BasePart = PlotInfo.GetPlot(player)
	if not plot then Notification.Notify(player, ERROR_MESSAGE_1, "Red", 2) return end
	
	-- (3) Calculate whether Player is Toggling PVP ON or OFF
	local protectionPVP: ForceField = character:FindFirstChild("ProtectionPVP")
	if protectionPVP then
		-- (3A) Player wants to Toggle PVP ON
		Notification.Notify(player, SUCCESS_MESSAGE_1, "Green")
		protectionPVP:Destroy()
	else
		-- (3B) Player wants to Toggle PVP OFF 
		if not PlotRegion.WithinRegion(plot, character) then Notification.Notify(player, ERROR_MESSAGE_2, "Red", 2) return end
		
		Notification.Notify(player, SUCCESS_MESSAGE_2, "Red")
		local protectionPVP = Instance.new("ForceField")
		protectionPVP.Name = "ProtectionPVP"
		protectionPVP.Parent = character
	end
end)
