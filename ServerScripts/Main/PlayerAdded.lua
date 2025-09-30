-- Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Functions
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		-- (1) Set CollisionGroup of Player's charater to "Player"
		for _, part: BasePart in character:GetDescendants() do
			if not part:IsA("BasePart") then continue end
			part.CollisionGroup = "Player"
		end
		
		-- (2) Add Spawn Protection to Player if they haven't been added to a Team
		local team: Team = player.Team
		if team == Teams.Selecting and not player:FindFirstChild("DisableSpawnProtection") then	
			local SpawnProtection = Instance.new("ForceField")
			SpawnProtection.Name = "SpawnProtection"
			SpawnProtection.Parent = player.Character
		end
	end)
	
	player.CharacterAppearanceLoaded:Connect(function(character: Model)
		if not character then return end
		
		for _ , part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("MeshPart") then
				part.CastShadow = false
			end
		end
	end)
end)
