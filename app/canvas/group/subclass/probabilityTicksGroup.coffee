###
Controls the horizontal lines denoting a measure axis
###

Group = require '../group'
Line = require '../../shape/subclass/line'
LineModel = require '../../shape/subclass/lineModel'
Styling = require '../../util/styling'

module.exports = class ProbabilityTicksGroup extends Group
	render: ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	createNewShapes: ->
		{bounds, waterMarks, h} = @model
		lineWidth = .1
		opacity = .7
		shapes = 
			for {y, value} in waterMarks
				new LineModel
					x0: bounds.left - Styling.SCATTER_CHART_AXIS_PADDING # paddding
					x1: bounds.right
					y0: y
					y1: y
					key: value
					stroke: Styling.CHART_LINES_FILL
					lineWidth: lineWidth
					opacity: opacity
		
		# now add a big vertical line at 0
		shapes.push new LineModel
			x0: 0
			x1: 0
			y0: 0
			y1: h
			key: @VERT_AXIS_KEY
			stroke: Styling.CHART_LINES_FILL
			lineWidth: lineWidth
			opacity: opacity

		shapes

	newShapeWithOptions: (options) ->
		new Line options
