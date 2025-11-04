-- // Services //
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GUI = Remotes:WaitForChild("GUI")

-- // Variables //
local RED_COLOUR = Color3.fromRGB(247, 65, 65)
local GREEN_COLOUR = Color3.fromRGB(91, 247, 8)

-- // Root //
local Notification = {}

-- // Functions //
function Notification.Notify(player: Player, message: string, colour: "Green" | "Red"?, duration: number?)
	colour = if colour == "Red" then RED_COLOUR else GREEN_COLOUR
	duration = duration or 1
	GUI.Notification:FireClient(player, message, duration, colour)
end

function Notification.NotifyEvent(title: string, subtitle: string)
	GUI.EventNotification:FireAllClients(title, subtitle)
end

return Notification
