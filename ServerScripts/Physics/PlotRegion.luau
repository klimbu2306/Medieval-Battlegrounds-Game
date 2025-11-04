-- // Variables // 
local DEFAULT_REGION_SIZE = Vector3.new(100, 100, 100)

-- // Root //
local PlotRegion = {}

-- // Functions //
function PlotRegion.WithinRegion(plot: BasePart, target: Model): boolean
	-- (0) Ensure the target has a PrimaryPart
	if not target.PrimaryPart then return false end
	local targetPosition = target.PrimaryPart.Position

	-- (1) Get the plot's CFrame and region size
	local plotCFrame = plot.CFrame -- Accounts for both position and rotation

	-- (2) Transform the target's position to the plot's local space
	local localPosition = plotCFrame:PointToObjectSpace(targetPosition)

	-- (3) Define bounds in local space
	local halfSize = DEFAULT_REGION_SIZE / 2
	local minBounds = Vector3.new(-halfSize.X, 0, -halfSize.Z)
	local maxBounds = Vector3.new(halfSize.X, DEFAULT_REGION_SIZE.Y, halfSize.Z)

	-- (4) Check if the local position is within bounds
	return localPosition.X >= minBounds.X and localPosition.X <= maxBounds.X
		and localPosition.Y >= minBounds.Y and localPosition.Y <= maxBounds.Y
		and localPosition.Z >= minBounds.Z and localPosition.Z <= maxBounds.Z
end

return PlotRegion
