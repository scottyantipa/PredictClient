Widget = require '../widget'
PredictionPointsLayer = require '../../layer/subclass/predictionPointsLayer'
ProbabilityTicksLayer = require '../../layer/subclass/probabilityTicksLayer'
TimeAxisLayer = require '../../layer/subclass/timeAxisLayer'
LayerModel = require '../../layer/layerModel'
PredictionEventModel = require '../../../models/predictionEventModel'
LinearScale = require '../../util/linearScale'
Styling = require '../../util/styling'

module.exports = class ChartWidget extends Widget
	constructor: ({@model, @$element, @delegate}) ->
		{w, h} = @model

		# a layer for the horizontal probability lines
		probabilityTicksCanvas = $('<canvas class="probability-ticks"></canvas>')
		@$element.append probabilityTicksCanvas
		@probabilityTicksLayer = new ProbabilityTicksLayer
			$canvas: probabilityTicksCanvas
			model: new LayerModel
				w: w
				h: h

		# a layer for the time axis
		timeAxisCanvas = $('<canvas class="time-axis"></canvas>')
		@$element.append timeAxisCanvas
		@timeAxisLayer = new TimeAxisLayer
			$canvas: timeAxisCanvas
			model: new LayerModel
				w: w
				h: h

		# create a layer for Points that represent each prediction
		eventCanvas = $('<canvas class="event-layer"></canvas>')
		@$element.append eventCanvas
		@predictionPointsLayer = new PredictionPointsLayer
			$canvas: eventCanvas
			model: new LayerModel
				w: w
				h: h

		@layers = [@probabilityTicksLayer, @timeAxisLayer, @predictionPointsLayer]
		super

	# Called by appView when dataManager gets data back
	# Get results and structure model with: predictions, scales
	onDataChange: ->
		@updateModel()

	###
	For now, let's have parents update their child's model.
	Then whe call a global redraw. This means:
	-- No animation (model0 not tracked)
	-- All views must be able to redraw themselves just from model
	###
	updateModel: ->
		# size our div container
		{w, h} = @model
		@$element.css 'width', w
		@$element.css 'height', h

		state = @delegate.state() # this won't work with multiple chart widgets
		
		# calculate earliest/latest dates and
		# populate model.events
		earliestDate = null
		latestDate = null
		@model.predictions = 
			for prediction in state.results
				[date, epoch]  = [prediction.date, prediction.date.getTime()]
				if not earliestDate or epoch < earliestDate.getTime()
					earliestDate = date
				if not latestDate or epoch > latestDate.getTime()
					latestDate = date
				new PredictionEventModel(prediction)

		# Calculate where the axis should be placed
		pad = Styling.CHART_PAD
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
			range: [Styling.MIN_RADIUS, Styling.MAX_RADIUS] # min, max radius

		super

	updatesForChildren: ->
		{predictions, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth} = @model

		[
			[@predictionPointsLayer, {predictions, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth}]
			[@probabilityTicksLayer, {probabilityScale, timeScale, w, h, pad, plotHeight, plotWidth}]
			[@timeAxisLayer, {timeScale, w, h, pad, plotHeight, plotWidth}]
		]
