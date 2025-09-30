-- Services
local ServerStorage = game:GetService("ServerStorage")
local CharactersFolder = ServerStorage:WaitForChild("Characters")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- References
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local VFX = Remotes:WaitForChild("VFX")

-- Root
local MorphScript = {}

-- Functions
function MorphScript.MorphPlayer(player: Player, character: string)
	local TemporaryFolder = Instance.new("Folder")
	TemporaryFolder.Name = "TemporaryBackpack"
	TemporaryFolder.Parent = player
	Debris:AddItem(TemporaryFolder, 5)
	
	local GamepassFolder = Instance.new("Folder")
	GamepassFolder.Name = "GamepassBackpack"
	GamepassFolder.Parent = player
	Debris:AddItem(GamepassFolder, 5)

	local humanoid: Humanoid = player.Character.Humanoid
	humanoid:UnequipTools()
	
	for i, tool: Tool in ipairs(player.Backpack:GetChildren()) do
		if tool:GetAttribute("Gamepass") == true then
			tool.Parent = GamepassFolder; continue
		end
		
		tool.Parent = TemporaryFolder
	end
	
	local model = CharactersFolder[character].Model --This is the model that the player respawns as
	local oldModel = player.Character
	local newModel = model:Clone()
	newModel.Name = player.Name
	
	for _ , part in pairs(newModel:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("MeshPart") then
			part.CastShadow = false
		end
	end
	
	player.Character = newModel
	
	local itemsToAdd = TemporaryFolder:GetChildren()
	local gamepassesToAdd = GamepassFolder:GetChildren()
	
	table.sort(itemsToAdd, function(a, b)
		if not a:GetAttribute("added") or not b:GetAttribute("added") then return false end
		if a:GetAttribute("added") < b:GetAttribute("added") then return true else return false end
	end)
	
	table.sort(gamepassesToAdd, function(a, b)
		if not a:GetAttribute("added") or not b:GetAttribute("added") then return false end
		if a:GetAttribute("added") < b:GetAttribute("added") then return true else return false end
	end)
	
	for _, tool: Tool in ipairs(itemsToAdd) do
		tool.Parent = player.Backpack
	end
	
	for _, tool: Tool in ipairs(gamepassesToAdd) do
		tool.Parent = player.Backpack
	end

	local origin: CFrame = oldModel.PrimaryPart.CFrame
	newModel.Parent = game.Workspace 
	newModel:SetPrimaryPartCFrame(origin) -- replace Spawn with the respawing part location

	for _, object in ipairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do -- this just copies all the scripts from startercharacterscripts, you can do this with player scripts too.
		local newObject = object:Clone()
		newObject.Parent = newModel
	end
	oldModel:Destroy()

	local animator: Animator = Instance.new("Animator")
	animator.Parent = player.Character.Humanoid

	--[[
	player.Backpack:ClearAllChildren()

	local tools = CharactersFolder[character].Moveset

	for i = 1, 5 do
		local tool = tools[{i}]
		local cloneTool = tool.Value:Clone()
		cloneTool.Parent = player.Backpack
	end
	--]]
end

function MorphScript.Main(_self: BasePart, character: string)
	local debounce = false
	
	_self.Touched:Connect(function(hit: BasePart)	
		local target: Model = hit:FindFirstAncestorWhichIsA("Model")
		if not target then return end
		
		if not target:FindFirstChild("Humanoid") then return end

		local player: Player = Players:GetPlayerFromCharacter(target)
		if not player then return end

		if debounce then return end

		debounce = true

		task.delay(5, function()
			debounce = false
		end)

		MorphScript.MorphPlayer(player, character)
	end)
end

return MorphScript
