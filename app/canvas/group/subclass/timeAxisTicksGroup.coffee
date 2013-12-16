Group = require '../group'
Line = require '../../shape/subclass/line'
LineModel = require '../../shape/subclass/lineModel'

module.exports = class TimeAxisLabelsGroup extends Group

	updateModel: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	# Place shapes next to horizontal lines (on LHS for now)
	createNewShapes: ->
		{axisTicks} = @model
		for tick in axisTicks
			new LineModel tick

	newShapeWithOptions: (options) ->
		new Line options
