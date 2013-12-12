###
Controls the horizontal lines denoting a measure axis
###

Group = require '../group'
Line = require '../../shape/subclass/line'
LineModel = require '../../shape/subclass/lineModel'

module.exports = class ProbabilityTicksGroup extends Group
	updateModel: ->
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels
		super

	createNewShapes: ->
		{bounds, waterMarks} = @model
		for {y, value} in waterMarks
			new LineModel
				x0: bounds.left
				x1: bounds.right
				y0: y
				y1: y
				key: value

	insertShapeWithModel: (model) ->
		@shapes.push new Line
			model: model