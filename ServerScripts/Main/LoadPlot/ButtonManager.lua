-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- References
local Plots = workspace.Map.Plots

-- Modules
local PlotInfo = require(script.Parent.PlotInfo)
local ItemManager = require(script.Parent.ItemManager)

-- Root
local ButtonManager = {}

-- Functions (Buttons)
function ButtonManager.GetButtonByIdOfItemToUnlock(player: Player, itemId: number): BasePart
	-- fetch player plot
	local plot = PlotInfo.GetPlot(player)
	if not plot then warn("Player Plot not found!") return end

	-- return the button which will unlock the nth item, specified by its item ID
	for _, Button in plot.Buttons:GetChildren() do		
		local IdOfItemToUnlock = Button:GetAttribute("IdOfItemToUnlock")
		if not IdOfItemToUnlock then continue end		
		
		if itemId == IdOfItemToUnlock then return Button end
	end
end


function ButtonManager.UnlockOtherButtons(player: Player, Button: BasePart)
	-- string contains a list of other item ID's, which can only be unlocked after the current button has been bought
	local ItemIdsToAppearOnceBought = Button:GetAttribute("UnlockButtons")

	if ItemIdsToAppearOnceBought then
		local ItemIds = string.split(ItemIdsToAppearOnceBought, ",")
		
		-- unlock buttons that will unlock the items which can now be bought
		for _, ItemId in ItemIds do
			ItemId = tonumber(ItemId)

			local Button = ButtonManager.GetButtonByIdOfItemToUnlock(player, ItemId)
			if not Button then continue end

			-- make button visible
			Button:SetAttribute("Hidden", nil)
			Button.Transparency = 0
			Button.BillboardGui.Enabled = true
			Button.CanCollide = true
			
			-- make green part of button and glowing effect invisible (if there is one)
			for _, part: BasePart in Button:GetDescendants() do
				if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "Glow" then
					part.Transparency = 0
				end
			end
		end
	end
end


function ButtonManager.PositionButton(plot: BasePart, Button: BasePart)
	-- posiiton button relative to where it should be on the plot
	local TemplatePlot = PlotInfo.GetPlotTemplate(plot)
	local RelativeCFrame = TemplatePlot.CFrame:ToObjectSpace(Button.CFrame)
	Button.CFrame = plot.CFrame:ToWorldSpace(RelativeCFrame)
	
	-- hide button, if it should not appear immediately
	if Button:GetAttribute("Hidden") then
		Button.Transparency = 1
		Button.BillboardGui.Enabled = false
		Button.CanCollide = false
		
		for _, part: BasePart in Button:GetDescendants() do
			if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "Glow" then
				part.Transparency = 1
			end
		end
	end
end


function ButtonManager.SetupButtonGUI(plot: BasePart, Button: BasePart)
	-- fetch item it will unlock, and price if there is one
	local itemId = Button:GetAttribute("IdOfItemToUnlock")
	local itemToUnlock = ItemManager.GetItemFromTemplatePlot(plot, itemId)
	local itemName = if itemToUnlock then itemToUnlock.Name else ""
	local price = Button:GetAttribute(`Price`)
	
	if Button:GetAttribute("GamepassIdToUnlock") ~= nil then return end
	Button.BillboardGui.TextLabel.Text = if price then `Unlock {itemName} (${price})` else `Unlock {itemName}`
end


function ButtonManager.RegisterButtonPress(plot: BasePart, Button: BasePart, hit: BasePart)
	-- [Registering a Button Press...]
	-- (1) Button only registers press if it is visible and only if the plot owner touches it
	if Button:GetAttribute("Hidden") then return end

	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	if plot:GetAttribute("Owner") ~= player.UserId then return end

	-- (2) Debounce Button so it can only be pressed every 2 seconds
	if Button:GetAttribute("Debounce") == true then return end
	Button:SetAttribute("Debounce", true)
	task.delay(2, function()
		if Button then
			Button:SetAttribute("Debounce", false)
		end
	end)


	-- (3) Force player to buy the item, if the button has a price
	local price = Button:GetAttribute(`Price`)

	if price then
		if player.leaderstats.Cash.Value < price then
			warn(`You cannot afford this item!`)
			return
		end

		-- if we get to this point, we know the player can afford the 
		player.leaderstats.Cash.Value -= price
	end


	-- (4) Player can afford button, so unlock the item and the buttons after this one
	ButtonManager.UnlockOtherButtons(player, Button)

	local itemToUnlockId = Button:GetAttribute("IdOfItemToUnlock")
	if not itemToUnlockId then warn(`You forgot to add an IdOfItemUnlock attribute`) return end
	
	local TemplatePlot = PlotInfo.GetPlotTemplate(plot)
	local templateItems = TemplatePlot.Items

	for _, item in templateItems:GetDescendants() do
		if not item.Parent:IsA("Folder") then continue end
		if item:GetAttribute("Id") ~= itemToUnlockId then continue end
		
		ItemManager.LoadItem(plot, itemToUnlockId)
		Button:Destroy()
		
		game.ServerScriptService.Main.Leaderboard.ItemUnlocked:Fire(player, itemToUnlockId)
	end
end

function ButtonManager.RegisterGamepassPrompt(plot: BasePart, Button: BasePart, hit: BasePart)
	-- [Registering a Gamepass Button Press...]
	-- (1) Button only registers press if it is visible and only if the plot owner touches it
	local character: Model = hit:FindFirstAncestorWhichIsA("Model")
	if not character then return end
	
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then return end

	if plot:GetAttribute("Owner") ~= player.UserId then return end
	
	-- (2) Prompt Player to buy the Gamepass
	local gamepassId: number = Button:GetAttribute("GamepassIdToUnlock")
	MarketplaceService:PromptGamePassPurchase(player, gamepassId)
end

function ButtonManager.LoadButton(player: Player, Button: BasePart, plot: BasePart, itemIdsTable: {}?)
	itemIdsTable = itemIdsTable or {}
	
	-- (1) If button has already been unlocked, then don't bother trying to load the button
	if table.find(itemIdsTable, Button:GetAttribute("IdOfItemToUnlock")) then
		-- load the other buttons it would've unlocked
		ButtonManager.UnlockOtherButtons(player, Button)
		return
	end
	
	-- (2) Load button onto plot and  Setup its GUI
	ButtonManager.PositionButton(plot, Button)
	ButtonManager.SetupButtonGUI(plot, Button)

	-- (3) Setup button functionality
	if Button:GetAttribute("GamepassIdToUnlock") == nil then
		Button.Touched:Connect(function(hit) ButtonManager.RegisterButtonPress(plot, Button, hit) end)
	else
		Button.Touched:Connect(function(hit) ButtonManager.RegisterGamepassPrompt(plot, Button, hit) end)
	end
	
	-- (4) place button inside of plot's button folder
	Button.Parent = plot:WaitForChild("Buttons")
end

return ButtonManager
