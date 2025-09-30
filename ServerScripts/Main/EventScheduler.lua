-- // Services //
local ServerStorage = game:GetService("ServerStorage")
local NPC = ServerStorage:WaitForChild("NPCs")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Effects = Remotes:WaitForChild("Effects")
local Debris = game:GetService("Debris")

-- // Modules //
local Physics = ServerStorage:WaitForChild("Physics")
local Notification = require(Physics:WaitForChild("Notification"))

-- // Variables //
local RANDOM_SEED = Random.new()
local EVENT_DURATION = 120
local INTERMISSION_TIME = 180

local Events = {
	["Boss"] = {
		["Weight"] = 3,
		["Model"] = NPC["OverlordessBoss"],
		["Title"] = "Event: Boss Battle",
		["Subtitle"] = "- Kill the Boss for a Temporary Cash Boost -"
	},
	["Pinata"] = {
		["Weight"] = 2,
		["Model"] = NPC["Pinata"],
		["Title"] = "Event: Pinata",
		["Subtitle"] = "- Destroy the Pinata for a Temporary Cash Boost -"
	}
}

-- // Functions //
function ChooseNextEvent(): string
	local chosenEvent: string
	local totalWeight = 0
	
	for event: string, eventInfo: {} in Events do
		totalWeight += eventInfo.Weight
	end
	
	local randomWeight = RANDOM_SEED:NextInteger(1, totalWeight)
	local currentWeight = 0
	
	for event: string, eventInfo: {} in Events do
		currentWeight += eventInfo.Weight
		if randomWeight <= currentWeight then
			chosenEvent = event
			break
		end
	end
	
	chosenEvent = chosenEvent or "Boss"
	
	return 	chosenEvent
end

function SummonEvent(event: string): boolean	
	local Model: Model = Events[event].Model:Clone()
	Model.Parent = workspace.NPC
	Model:SetAttribute("Active", false)
	
	Effects.LoadEffect:FireAllClients("EventBeam", {})
	Notification.NotifyEvent(Events[event].Title, Events[event].Subtitle)
	
	local StartTime = time()
	
	repeat
		task.wait()
	until (time() >= StartTime + EVENT_DURATION) and 
		(Model and Model:GetAttribute("Active") == false or Model.Parent == nil or not Model)
	
	if Model then Model:Destroy() end
	
	return
end

-- // Runtime Environment //
while task.wait(INTERMISSION_TIME) do	
	local event: string = ChooseNextEvent()
	SummonEvent(event)
end
