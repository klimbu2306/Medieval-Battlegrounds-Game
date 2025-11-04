-- // Services //
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local VFX = Remotes:WaitForChild("VFX")
local ServerStorage = game:GetService("ServerStorage")

-- // Modules //
local Physics = ServerStorage:WaitForChild("Physics")
local Notification = require(Physics:WaitForChild("Notification"))

-- // Root //
local AbilityScript = {}

-- // Functions //
function AbilityScript.GetRingIndicator(_self: Model): BasePart
	for _, part: BasePart in _self:GetDescendants() do
		if part.Name ~= "Ring Indicator" then continue end
		return part
	end
end

function AbilityScript.SpinRingIndicator(_self: Model)
	local ringIndicator = AbilityScript.GetRingIndicator(_self)

	while wait() do
		ringIndicator.CFrame = ringIndicator.CFrame * CFrame.Angles(1, 0, 0)
	end
end

function AbilityScript.PlayerOwnsToolAlready(player: Player, tool: Tool): boolean
	-- (1) Check whether Tool is stored away in the Player's Backpack
	local backpack = player.Backpack

	for _, _tool: Tool in backpack:GetChildren() do
		if not _tool then continue end
		if _tool.Name == tool.Name then
			return true
		end
	end

	-- (2) Check whether Tool is out of Backpack, but physically equipped on their Character
	local character = player.Character

	for _, _tool: Tool in character:GetDescendants() do
		if not _tool:IsA("Tool") then continue end
		if _tool.Name == tool.Name then
			return true
		end
	end
end

function AbilityScript.RemoveSpawnProtection(_self: Model, player: Player)
	pcall(function()
		local Character: Model = player.Character
		local SpawnProtection: ForceField = Character:FindFirstChild("SpawnProtection")
		if SpawnProtection then
			SpawnProtection:Destroy()
			Notification.Notify(player, "System Message: Spawn Protection has been Removed", "Red", 2)
		end
	end)
end

function AbilityScript.DetectHit(_self: Model, hit: BasePart)
	-- (0) Try to Get Character from Hit
	local character: Model = hit:FindFirstAncestorWhichIsA("Model")
	if not character then return end
	
	-- (1) Check Hitbox has been touched by a Player
	local player: Player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	local plot = _self.Parent.Parent
	local plotOwner = plot:GetAttribute("Owner")

	-- (2) Remove any Spawn Protection that the Player might have
	AbilityScript.RemoveSpawnProtection(_self, player)

	-- (3) Give the Item to the Owner of the Plot, if they do not have it in their Backpack or Character
	local tool = _self.Tool.Value
	if AbilityScript.PlayerOwnsToolAlready(player, tool) then return end

	local cloneTool = tool:Clone()
	cloneTool.Parent = player.Backpack
	cloneTool:SetAttribute("added", time())

	-- (4) Player the Give Item VFX on the Player
	VFX.ApplyVFX:FireAllClients({Model = player.Character}, "GiveItem")
end

function AbilityScript.SetupHitbox(_self: Model)
	local hitbox: BasePart = _self.ToolGiver.Hitbox.PrimaryPart
	local debounce = false
		
	hitbox.Touched:Connect(function(hit: BasePart)
		-- (0) Debounce the Tool Giver
		if debounce then return end
		debounce = true
		task.delay(1, function()
			debounce = false
		end)
		
		AbilityScript.DetectHit(_self, hit)
	end)
end


function AbilityScript.Main(_self: Model)
	task.spawn(function()
		AbilityScript.SpinRingIndicator(_self)
	end)

	AbilityScript.SetupHitbox(_self)
end

return AbilityScript
