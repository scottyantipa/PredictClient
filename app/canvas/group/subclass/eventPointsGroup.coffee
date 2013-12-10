Group = require '../group'
Point = require '../../shape/subclass/point'
PointModel = require '../../shape/subclass/pointModel'

module.exports = class EventPointsGroup extends Group

	# Take events, timeScale, probabilityScale
	# and calculate new Shapes (then call @updateShapes())
	updateModel: ->
		newShapeModels = 
			for prediction in @model.events
				@newModelForPrediction(prediction)
		@updateShapes newShapeModels
				
	newModelForPrediction: (prediction) ->
		{date, probability, title, key} = prediction
		{w, h, timeScale, probabilityScale} = @model
		x = timeScale.map(date.getTime()) # so we draw in the positive
		y = h - probabilityScale.map(probability)
		new PointModel
			x: x
			y: y
			fill: "#B39F09"
			stroke: "#B39F09"
			key: key

	insertShapeWithModel: (model) ->
		@shapes.push new Point
			model: model
