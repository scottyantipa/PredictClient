###
Responsible for drawing the labels on the vertical probability axis
###

Group = require '../group'
Text = require '../../shape/subclass/text'
TextModel = require '../../shape/subclass/textModel'
Styling = require '../../util/styling'

module.exports = class TickLabelsGroup extends Group

	render: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	# Place shapes next to horizontal lines (on LHS for now)
	createNewShapes: ->
		{bounds, waterMarks} = @model
		for {value, y} in waterMarks
			new TextModel
				fontSize: 12
				text: "#{value}%"
				y: y + 4
				x: bounds.left - Styling.SCATTER_CHART_AXIS_PADDING - 30
				key: value
				opacity: Styling.AXIS_LABEL_OPACITY

	newShapeWithOptions: (options) ->
		new Text options
