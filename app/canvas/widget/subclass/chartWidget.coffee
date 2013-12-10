Widget = require '../widget'
EventPointsLayer = require '../../layer/subclass/eventPointsLayer'
LayerModel = require '../../layer/layerModel'
PredictionEventModel = require '../../../models/predictionEventModel'
LinearScale = require '../../../util/linearScale'

module.exports = class ChartWidget extends Widget
	constructor: ({@model, @$element, @delegate}) ->
		super

		# create a layer for Points, append the <canvas>
		eventCanvas = $('<canvas class="event-layer"></canvas>')
		@$element.append eventCanvas
		@eventPointsLayer = new EventPointsLayer
			model: new LayerModel
				w: @model.w
				h: @model.h
			$canvas: eventCanvas

		@layers = [@eventPointsLayer]

	# Called by appView when dataManager gets data back
	# Get results and structure model with: events, scales
	onDataChange: ->
		@updateModel()

	###
	For now, let's have parents update their child's model.
	Then, when call a global redraw. This means:
	-- No animation (model0 not tracked)
	-- Redraw every layer, rather than selectively
	-- All views must be able to redraw themselves just from model
	###
	updateModel: ->
		state = @delegate.state() # this won't work with multiple chart widgets
		
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
				new PredictionEventModel(prediction)

		@model.timeScale = new LinearScale
			domain: [earliestDate.getTime(), latestDate.getTime()]
			range: [0, @model.w] # full width of div for now

		@model.probabilityScale = new LinearScale
			domain: [0, 100] # 1 is 100%
			range: [0, @model.h] # full height

		{events, timeScale, probabilityScale, w, h} = @model
		$.extend @eventPointsLayer.model, {events, timeScale, probabilityScale, w, h}

		super