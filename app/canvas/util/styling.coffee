module.exports = class CanvasStyling

	# Color
	@CHART_LINES_FILL: "#C4C2C2"
	@CONNECTING_PREDICTION_LINES: "#3079F0"
	@AXIS_LABEL_OPACITY: 1
	@SELECTED_SHAPE_BLUE: "#3AB8FC"
	@BLACK: "#000"
	@WHITE: "#FFF"

	# Shapes
	@MIN_RADIUS: 2
	@MAX_RADIUS: 30

	# Positioning
	@SCATTER_CHART_AXIS_PADDING: CanvasStyling.MAX_RADIUS
	@CHART_PAD = 80

	# Animation
	@DEFAULT_ANIMATION_DURATION: 500
	@QUICK_ANIMATION_DURATION: 300

	# TRANSCRIPTIC SPECIFIC LINE COLORING
	@mapRowToColor: (row) ->
		if row <= 4
			"#EF6A42" # orange
		else if row > 4 and row <= 8
			"#96EF42" # green
		else if row > 8 and row <= 12
			"#CC42EF" # magenta
		else
			"#EF426A" # red