Group = require '../group'
Text = require '../../shape/subclass/text'
TextModel = require '../../shape/subclass/textModel'

module.exports = class TimeAxisLabelsGroup extends Group

	updateModel: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	createNewShapes: ->
		{axisLabels} = @model
		for label in axisLabels
			new TextModel label

	newShapeWithOptions: (options) ->
		new Text options

	tweenMapForAddShape: (shape) ->
		@tweenMapAddShapeForGroups shape # parent method

	tweenMapForRemoveShape: (shape) ->
		@tweenMapRemoveShapeForGroups shape # parent method