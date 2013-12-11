Widget = require '../widget'
EventPointsLayer = require '../../layer/subclass/eventPointsLayer'
ProbabilityTicksLayer = require '../../layer/subclass/probabilityTicksLayer'
LayerModel = require '../../layer/layerModel'
PredictionEventModel = require '../../../models/predictionEventModel'
LinearScale = require '../../../util/linearScale'

module.exports = class ChartWidget extends Widget
	constructor: ({@model, @$element, @delegate}) ->
		super

		probabilityTicksCanvas = $('<canvas class="probability-ticks"></canvas>')
		@$element.append probabilityTicksCanvas
		@probabilityTicksLayer = new ProbabilityTicksLayer
			$canvas: probabilityTicksCanvas
			model: new LayerModel
				w: @model.w
				h: @model.h

		# create a layer for Points, append the <canvas>
		eventCanvas = $('<canvas class="event-layer"></canvas>')
		@$element.append eventCanvas
		@eventPointsLayer = new EventPointsLayer
			$canvas: eventCanvas
			model: new LayerModel
				w: @model.w
				h: @model.h

		@layers = [@probabilityTicksLayer, @eventPointsLayer]

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

		# Calculate where the axis should be placed
		pad = 100
		@model.pad =
			top: pad
			right: pad
			bottom: pad
			left: pad

		{top, right, bottom, left} = @model.pad

		@model.plotWidth = @model.w - left - right
		@model.plotHeight = @model.h - top - bottom

		@model.timeScale = new LinearScale
			domain: [earliestDate.getTime(), latestDate.getTime()]
			range: [0, @model.plotWidth] # full width of div for now

		@model.probabilityScale = new LinearScale
			domain: [0, 100] # 1 is 100%
			range: [0, @model.plotHeight] # full height

		@model.hotScale = new LinearScale
			domain: [0, 100]
			range: [5, 15] # min, max radius

		{events, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth} = @model
		$.extend @eventPointsLayer.model, {events, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth}
		$.extend @probabilityTicksLayer.model, {probabilityScale, timeScale, w, h, pad, plotHeight, plotWidth}

		super