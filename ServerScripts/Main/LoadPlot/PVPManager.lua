-- // Services //
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Physics = ServerStorage:WaitForChild("Physics")
local RunService = game:GetService("RunService")

-- // Modules //
local PlotRegion = require(Physics:WaitForChild("PlotRegion"))
local Notification = require(Physics:WaitForChild("Notification"))

-- // Variables //
local SYSTEM_MESSAGE = "System Message: PVP was Enabled!"

-- // Root //
local PVPManager = {}

-- // Runtime Environment //
function PVPManager.TrackPlayer(plot: BasePart, player: Player)
	local connection: RBXScriptSignal, playerConnection: RBXScriptSignal

	connection = RunService.Heartbeat:Connect(function(dt: number)
		if not player or player.Parent == nil then
			connection:Disconnect(); connection = nil
			playerConnection:Disconnect(); playerConnection = nil
			return
		end

		local character: Model = player.Character
		if not character then return end

		if not PlotRegion.WithinRegion(plot, character) then
			local ProtectionPVP: ForceField = character:FindFirstChild("ProtectionPVP") 
			if ProtectionPVP then
				ProtectionPVP:Destroy()

				Notification.Notify(player, SYSTEM_MESSAGE, "Green", 2)
				return
			end
		end
	end)

	playerConnection = Players.PlayerRemoving:Connect(function(leavingPlayer: Player)
		if player == leavingPlayer then
			connection:Disconnect(); connection = nil
			playerConnection:Disconnect(); playerConnection = nil
			return
		end
	end)
end

return PVPManager
