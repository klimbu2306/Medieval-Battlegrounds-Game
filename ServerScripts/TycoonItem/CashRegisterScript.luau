-- Services
local Players = game:GetService("Players")

-- Functions
local CashRegisterScript = {}

function CashRegisterScript.Main(_self: Model)
	local displayCash = _self.Screen.SurfaceGui.Title
	local plot = _self.Parent.Parent

	local button = _self.Step.Button
	local debounce = false
	
	button.Touched:Connect(function(hit)
		local isPlayer = Players:GetPlayerFromCharacter(hit.Parent)
		if not isPlayer then return end
		
		local plot: BasePart = _self:FindFirstAncestor("Plot")
		local owner: number = plot:GetAttribute("Owner")
		if isPlayer.UserId ~= owner then return end

		if debounce then return end
		debounce = true

		task.delay(1,function()
			debounce = false
		end)

		task.spawn(function()
			button.BrickColor = BrickColor.new("Really red")
			task.wait(1)
			button.BrickColor = BrickColor.new("Lime green")
		end)

		local storedCash = isPlayer.StoredCash.Value
		if storedCash > 0 then
			_self.PrimaryPart.SFX:Play()
		end

		isPlayer.leaderstats.Cash.Value += storedCash
		isPlayer.StoredCash.Value = 0
	end)

	while task.wait(0.25) do
		local ownerId = plot:GetAttribute("Owner")
		if not ownerId then
			displayCash.Text = `$0`
			continue
		end

		local player = Players:GetPlayerByUserId(ownerId)
		if not player then return end

		local storedCash = player.StoredCash.Value
		displayCash.Text = `${storedCash}`
	end

	displayCash.Text = `$0`
end

return CashRegisterScript
