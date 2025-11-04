-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Events = ServerStorage:WaitForChild("Events")
local Teams = game:GetService("Teams")

-- References
local Plots = workspace.Map.Plots

-- Modules
local PlotInfo = require(script.PlotInfo)
local ItemManager = require(script.ItemManager)
local ButtonManager = require(script.ButtonManager)
local PVPManager = require(script.PVPManager)

-- Functions
function LoadPlot(player: Player, plot: BasePart, itemIdsTable: {})
	if plot:GetAttribute("Taken") then return end
	
	-- (0) Identify Template Plot + Assign Player to Team
	local TemplatePlot = PlotInfo.GetPlotTemplate(plot)
	
	local teamName = TemplatePlot:GetAttribute("Team")
	player.Team = Teams:FindFirstChild(teamName)
	
	-- (1) Give Plot to player
	plot:SetAttribute("Taken", true)
	plot:SetAttribute("Owner", player.UserId)
	
	pcall(function()
		PVPManager.TrackPlayer(plot, player)
	end)

	print(`Plot has been given to {player.Name}!`)
	
	-- (2) Create Folder for Plot Items to be placed in
	local itemsFolder = Instance.new("Folder")
	itemsFolder.Name = "Items"
	itemsFolder.Parent = plot
	
	-- (3) Init load all previously loaded items + Load ATM Machine
	ItemManager.LoadItems(player, itemIdsTable)
	ItemManager.LoadItem(plot, -1)
	
	-- (4) Init and load all previously loaded buttons
	local templateButtons = TemplatePlot.Buttons:Clone()
	templateButtons.Parent = plot
	
	for _, Button in templateButtons:GetChildren() do
		 ButtonManager.LoadButton(player, Button, plot)
	end
end

function RemovePlot(player: Player)
	for _, plot in Plots:GetChildren() do
		-- (1) Search for a Plot, which is (A) not empty, (B) matches the player's ID
		if not plot:GetAttribute("Owner") then continue end
		if plot:GetAttribute("Owner") ~= player.UserId then continue end

		-- (2) Clear all items from plot, so that it may be used by another player
		ItemManager.ClearAllItems(player)
		
		-- (3) Clean owner ID of plot
		plot:SetAttribute("Taken", nil)
		plot:SetAttribute("Owner", nil)

		print(`Plot has been removed from {player.Name}!`)

	end
end


Players.PlayerRemoving:Connect(RemovePlot)
Events:WaitForChild("CreatePlot").Event:Connect(LoadPlot)
