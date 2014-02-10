###
Manages the circles that represent certain predictions
###

Group = require '../group'
Point = require '../../shape/subclass/point'
PointModel = require '../../shape/subclass/pointModel'

module.exports = class EventPointsGroup extends Group
	updateModel: (options) ->
		super
		newShapeModels = 
			for prediction in @model.predictions
				@newModelForPrediction prediction
		@updateShapes newShapeModels
				
	newModelForPrediction: (prediction) ->
		{date, probability, hot, key} = prediction
		{h, timeScale, probabilityScale, hotScale} = @model
		x = timeScale.map date.getTime() # so we draw in the positive
		y = h - probabilityScale.map(probability)
		r = hotScale.map hot
		new PointModel
			x: x
			y: y
			r: r
			key: key

	newShapeWithOptions: (options) ->
		new Point options

	tweenMapForAddShape: (shape) ->
		{model} = shape

		objToTween: model
		delegate: shape.delegate
		status: 'add'
		propsToTween: [
			propName: 'r'
			startValue: model.r / 2
			endValue: model.r
			duration: 600
		,
			propName: 'opacity'
			startValue: 0
			endValue: model.opacity
			duration: 800
		]


	tweenMapForRemoveShape: (shape) ->
		{model} = shape

		objToTween: model
		delegate: shape.delegate
		status: 'add'
		propsToTween: [
			propName: 'r'
			startValue: model.r
			endValue: model.r / 2
			duration: 600
		,
			propName: 'opacity'
			startValue: model.opacity
			endValue: 0
			duration: 800
		]