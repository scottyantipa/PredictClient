Widget = require '../widget'
EventPointsLayer = require '../../layer/subclass/eventPointsLayer'
LayerModel = require '../../layer/layerModel'
PredictionEventModel = require '../../../models/predictionEventModel'
LinearScale = require '../../../util/linearScale'
module.exports = class ChartWidget extends Widget
	constructor: ({@model, @$element}) ->
		super

		# create a layer for Points, append the <canvas>
		eventCanvas = $('<canvas class="event-layer"></canvas>')
		@$element.append eventCanvas
		eventPointsLayer = new EventPointsLayer
			model: new LayerModel
			$canvas: eventCanvas

		@layers = [eventPointsLayer]

	# Called by appView when dataManager gets data back
	# Get results and structure model with: events, scales
	onDataChange: ->
		state = @delegate.state
		
		# calculate earliest/latest dates and
		# populate model.events
		earliestDate = null
		latestDate = null
		@model.events = 
			for prediction in state.results
				[date, epoch]  = [prediction.date, prediction.date.getTime()]
				if not earliestDate or epoch < earliestDate.getTime()
					earliestDate = date
				if not latestDate or epoch > latestDate.getTime()
					latestDate = date
				new PredictionEventModel prediction

		model.timeScale = new LinearScale
			domain: [earliestDate.getTime(), latestDate.getTime()]
			range: # pixel range of body width

		return