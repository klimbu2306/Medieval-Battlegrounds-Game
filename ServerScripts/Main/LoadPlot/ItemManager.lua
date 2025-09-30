-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Tycoon = Remotes:WaitForChild("Tycoon")
local Debris = game:GetService("Debris")

-- References
local Plots = workspace.Map.Plots

-- Modules
local PlotInfo = require(script.Parent.PlotInfo)

-- Root
local ItemsManager = {}

-- Functions
function ItemsManager.GetItemFromTemplatePlot(plot: BasePart, itemId: number): Model
	-- fetch item id of requested item
	local TemplatePlot = PlotInfo.GetPlotTemplate(plot)
	
	for _, item in TemplatePlot.Items:GetDescendants() do
		if not item.Parent:IsA("Folder") then continue end
		
		if item:GetAttribute("Id") == itemId then
			return item
		end
	end
end


function ItemsManager.PositionItem(plot: BasePart, originalItem: Model, clone: Model)
	-- get item cframe of template item, then retrieve it's relative cframe posiiton
	local itemCFrame = if clone:IsA("Model") then originalItem:GetPivot() else originalItem.CFrame

	local TemplatePlot = PlotInfo.GetPlotTemplate(plot)
	local relativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
	local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(relativeItemCFrame)

	-- move item to relative position on the player's plot
	if clone:IsA("Model") then
		clone:PivotTo(worldCFrameOfNewPlot)
	else
		clone.CFrame = worldCFrameOfNewPlot
	end
	
	-- enable any scripts inside the item/infrastructure to be added
	for _, scriptObject in clone:GetDescendants() do
		if scriptObject:IsA("BaseScript") then
			scriptObject.Enabled = true
		end
	end
	
	-- by default items are non-collidable, unless a server-side hitbox is available
	if clone:FindFirstChild("Hitbox") then
		local hitbox: Model = clone.Hitbox.Value:Clone()
		hitbox:PivotTo(worldCFrameOfNewPlot)
		
		local hitboxType: string = `{hitbox:GetAttribute("HitboxType")}Hitbox`
		hitbox.Parent = plot[hitboxType].Value
	end
end

function ItemsManager.PrepareItemForAnimation(itemClone: Model)
	for _, part: BasePart in itemClone:GetDescendants() do
		if not part:IsA("BasePart") then continue end
		part:SetAttribute("OriginalTransparency", part.Transparency)
		part.Transparency = 1
	end
	
	task.delay(2.25, function()
		for _, part: BasePart in itemClone:GetDescendants() do
			if not part:IsA("BasePart") then continue end
			if not part:GetAttribute("OriginalTransparency") then continue end
			part.Transparency = part:GetAttribute("OriginalTransparency")
			part.CollisionGroup = "Default"
		end
	end)
	
	return
end

function ItemsManager.LoadItem(plot: BasePart, itemId: number)
	-- check item exists
	local item = ItemsManager.GetItemFromTemplatePlot(plot, itemId)
	if not item then return end

	-- load item, then position it
	local itemClone = item:Clone()
	ItemsManager.PositionItem(plot, item, itemClone)
	itemClone.Parent = plot:WaitForChild("Items")
	
	-- force clients to animate the item/infrastructure being added:
	local owner = plot:GetAttribute("Owner")
	if not owner then return end
	
	ItemsManager.PrepareItemForAnimation(itemClone)
	Tycoon.AnimateItem:FireAllClients(owner, itemClone)
end


function ItemsManager.LoadItems(plot: BasePart, player: Player, itemIdsTable: {}?)
	itemIdsTable = itemIdsTable or {}
	
	local plot = PlotInfo.GetPlot(player)
	
	-- load any previously saved plot items/infrastructure
	for _, itemId in itemIdsTable do
		ItemsManager.LoadItem(itemId)
	end
end


function ItemsManager.ClearAllItems(player: Player)
	-- clear all buttons, infrastructure and items from the specified plot
	local plot = PlotInfo.GetPlot(player)
	
	local itemsFolder: Folder = plot.Items
	local buttonsFolder: Folder = plot.Buttons
	
	itemsFolder:Destroy()
	buttonsFolder:Destroy()
	
	-- clear all hitboxes for the Tycoon
	local floorFolder: Folder = plot.FloorHitbox.Value
	if not floorFolder then return end
	floorFolder:ClearAllChildren()
	
	local wallFolder: Folder = plot.WallHitbox.Value
	if not wallFolder then return end
	wallFolder:ClearAllChildren()
	
	return
end


return ItemsManager
