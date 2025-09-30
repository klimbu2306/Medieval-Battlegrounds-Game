-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Combat = Remotes:WaitForChild("Combat")

-- Modules
local ServerStorage = game:GetService("ServerStorage")
local Abilities = ServerStorage:WaitForChild("Abilities")

-- Variables
local RemoteFail = {}
local REMOTE_FAIL_COOLDOWN = 5

-- Functions
function DebounceFailedRemote(player: Player)
	local id = player.UserId
	if not id then return end

	RemoteFail[id] = true
	task.delay(REMOTE_FAIL_COOLDOWN, function()
		RemoteFail[id] = nil
	end)
end

function RequestAttack(player: Player, abilityName: string, properties: {})
	-- (0) Type-check & Sanity-check ALL Parameters
	if RemoteFail[player.UserId] then warn(`RequestAttack: {player.Name} is Debounced for Firing RequestAttack Remote Incorrectly!!`) return end

	if (not abilityName) or (typeof(abilityName) ~= typeof("string")) then
		warn(`ParameterType Error: AbilityName DataType passed in was NOT a String value!`)
		DebounceFailedRemote(player)
		return
	end

	if typeof(properties) ~= typeof({}) then
		warn(`ParameterType Error: Properties DataType passed in was NOT a Table value!`)
		DebounceFailedRemote(player)
		return
	end
	
	-- (0.5) Make sure Player is still alive!
	local character: Model = player.Character
	if not character then return end
	
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then return end

	-- (1) Find & play() the requested Ability module
	local Ability: ModuleScript = Abilities:FindFirstChild(abilityName)
	if not Ability then warn("Error: Ability could not be found!") return end

	Ability = require(Ability)
	Ability.Main(player, properties)
end

Combat.RequestAttack.OnServerEvent:Connect(RequestAttack)
Combat.RequestAttackServer.Event:Connect(RequestAttack)
