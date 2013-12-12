Group = require '../group'
Text = require '../../shape/subclass/text'
TextModel = require '../../shape/subclass/textModel'

module.exports = class TickLabelsGroup extends Group
	updateModel: ->
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels
		super

	# Place shapes next to horizontal lines (on LHS for now)
	createNewShapes: ->
		{bounds, waterMarks} = @model
		for {value, y} in waterMarks
			new TextModel
				fontSize: 12
				text: "#{value}%"
				y: y + 4
				x: bounds.left - 40
				key: value

	insertShapeWithModel: (model) ->
		@shapes.push new Text
			model: model