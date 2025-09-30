-- // Services //
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Events = ServerStorage:WaitForChild("Events")
local ServerScriptStorage = game:GetService("ServerScriptService")
local Main = ServerScriptStorage:WaitForChild("Main")
local LoadPlot = Main:WaitForChild("LoadPlot")

-- // Modules // 
local PlotInfo = require(LoadPlot:WaitForChild("PlotInfo"))

-- // Root //
local ClaimTycoonScript = {}

-- // Functions //
function ClaimTycoonScript.Main(_self: Model)
	local plot = _self.Parent
	local claimTycoonGUI = _self.Hitbox.ClaimTycoon
	
	_self.PrimaryPart.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end

		local ownedPlot: BasePart = PlotInfo.GetPlot(player)
		if ownedPlot then return end

		local ownerExists = plot:GetAttribute("Owner")
		if ownerExists then return end

		Events:WaitForChild("CreatePlot"):Fire(player, plot, {})
		claimTycoonGUI.Enabled = false
		
		local character: Model = player.Character
		if not character then return end
		
		local spawnProtection: ForceField = character:FindFirstChild("SpawnProtection")
		if spawnProtection then
			spawnProtection:Destroy()
		end
	end)

	plot:GetAttributeChangedSignal("Owner"):Connect(function(value: boolean)
		local ownerId = plot:GetAttribute("Owner")
		if ownerId then return end

		claimTycoonGUI.Enabled = true
	end)
end

return ClaimTycoonScript
