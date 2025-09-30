-- References
local Plots = workspace.Map.Plots

-- Root
local PlotInfo = {}

-- Functions (Plot Info)
function PlotInfo.GetPlot(player: Player): BasePart
	for _, plot in Plots:GetChildren() do
		-- return the first plot which has the specified player as an owner
		local owner = plot:GetAttribute("Owner")
		if not owner then continue end
		
		if owner ~= player.UserId then continue end
		
		return plot
	end
end

function PlotInfo.GetPlotTemplate(plot: BasePart): BasePart
	local templatePlot: ObjectValue = plot:FindFirstChild("TemplatePlot")
	return templatePlot.Value
end

return PlotInfo
