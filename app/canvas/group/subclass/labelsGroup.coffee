#
# Light weight group for text labels.  Does almost nothing, Layer must implement most logic, this just draws
# and handles basic tweening
#

Styling = require '../../util/styling'
Group = require '../group'
Text = require '../../shape/subclass/text'
TextModel = require '../../shape/subclass/textModel'

module.exports = class LabelsGroup extends Group

	updateModel: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	createNewShapes: ->
		for {data, value, x, y} in @model.labels
			new TextModel
				fontSize: 12
				text: "#{value}"
				y: y
				x: x
				key: "#{value}"
				opacity: Styling.AXIS_LABEL_OPACITY
				data: data

	newShapeWithOptions: (options) ->
		new Text options

	tweenMapForAddShape: (shape) ->
		@tweenMapAddShapeForGroups shape # parent method

	tweenMapForRemoveShape: (shape) ->
		@tweenMapRemoveShapeForGroups shape # parent method