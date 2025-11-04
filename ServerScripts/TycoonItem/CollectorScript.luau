-- // Services //
local MarketplaceService = game:GetService("MarketplaceService")

-- // Root //
local CollectorScript = {}

-- // Functions //
function CollectorScript.Main(_self: Model)
	_self.Touched:Connect(function(hit)
		if hit:GetAttribute("CashToGive") then
			local Plot = _self.Parent.Parent.Parent
			if not Plot then warn(`No Plot`) return end

			local PlotOwnerUserId = Plot:GetAttribute(`Owner`)

			if not PlotOwnerUserId then warn (`No Plot Owner User Id`) return end

			local cashToGive = hit:GetAttribute(`CashToGive`)
			local isUpgraded = (hit.Material == Enum.Material.Neon)
			hit:Destroy()

			-- found the plot owner
			local PlayerObject = game.Players:GetPlayerByUserId(PlotOwnerUserId)
			if not PlayerObject then return end

			-- check if cube is upgraded
			if isUpgraded then
				cashToGive *= 2
			end
			
			pcall(function()
				local boost = 1
				
				if PlayerObject:FindFirstChild("PinataBoost") then
					boost += 0.25
				end
				
				if PlayerObject:FindFirstChild("BossBoost") then
					boost += 0.25
				end
				
				if PlayerObject:FindFirstChild("KingOfTheHill") then
					boost += 0.5
				end
				
				if boost > 1 then
					cashToGive *= boost
				end
			end)
			
			PlayerObject.StoredCash.Value += cashToGive
		end
	end)
end

return CollectorScript
