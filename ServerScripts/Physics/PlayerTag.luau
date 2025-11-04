-- // Root //
local PlayerTag = {}

-- // Functions //
function PlayerTag.Tag(player: Player, target: Model, damage: number?)
	damage = damage or 0
	
	-- (1) Check whether Target is tracking the last Player who hit them
	local lastHitBy: ObjectValue = target:FindFirstChild("LastHitBy")
	if not lastHitBy then return end
	
	-- (2) Make sure LastHitBy is not an NPC
	local success, fail = pcall(function() return player.IsAnNPC end)
	if success then return end
	
	-- (3) If they do then set attribute to Player
	lastHitBy.Value = player
	lastHitBy:SetAttribute("Damage", damage)
end

return PlayerTag
