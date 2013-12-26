Group = require '../group'
Line = require '../../shape/subclass/line'
LineModel = require '../../shape/subclass/lineModel'
Styling = require '../../util/styling'

module.exports = class PredictionLinesGroup extends Group
	lineKeySeparator: "::"
	
	updateModel: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	# Create a line for each pair of connections
	# Make sure not to duplicate lines -- do this
	# by storing the key as a function of the date of predictions
	createNewShapes: ->
		{predictions} = @model
		uniqueConnections = []
		shapes = []
		for prediction in predictions
			continue if not prediction.connections
			for key in prediction.connections
				continue if key is prediction.key
				otherPrediction = _.filter predictions, (other) ->
					other.key == key
				otherPrediction = otherPrediction[0]
				lineKey = @keyForLine [prediction, otherPrediction]
				if not _.contains uniqueConnections, lineKey
					uniqueConnections.push lineKey
					shapes.push @newModelForPredictions [prediction, otherPrediction], lineKey
		shapes
		
	newModelForPredictions: (predictions, key) ->
		points = []
		for prediction in predictions
			{date, probability} = prediction
			{h, timeScale, probabilityScale} = @model
			x = timeScale.map date.getTime() # so we draw in the positive
			y = h - probabilityScale.map(probability)
			points.push {x, y}

		new LineModel
			x0: points[0].x
			x1: points[1].x
			y0: points[0].y
			y1: points[1].y
			key: key
			opacity: Styling.GRID_LINE_OPACITY

	# Takes array of two predictions and returns a key
	keyForLine: (predictions) ->
		_.sortBy predictions, (prediction) ->
			prediction.date.getTime()
		predictions = predictions.map (prediction) ->
			prediction.key
		predictions.join @lineKeySeparator


	newShapeWithOptions: (options) ->
		new Line options
