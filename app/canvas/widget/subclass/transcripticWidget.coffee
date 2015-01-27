Koolaid = require '../../koolaid'
Widget = require '../widget'
MeasureAxisLayer = require '../../layer/subclass/measureAxisLayer'
OrdinalAxisLayer = require '../../layer/subclass/ordinalAxisLayer'
qpcrLinesLayer = require '../../layer/subclass/qpcrLinesLayer'
LayerModel = require '../../layer/layerModel'
Layer = require '../../layer/layer'
LinearScale = require '../../util/linearScale'
OrdinalScale = require '../../util/ordinalScale'
Styling = require '../../util/styling'

module.exports = class TranscripticWidget extends Widget
	state: {}

	constructor: ({@model, @$element, @delegate}) ->
		{w, h} = @model

		measureAxisCanvas = $('<canvas id="measure-axis"></canvas>')
		@$element.append measureAxisCanvas
		@measureAxisLayer = new MeasureAxisLayer
			$canvas: measureAxisCanvas
			model: new LayerModel

		xAxisCanvas = $('<canvas id="x-axis"></canvas>')
		@$element.append xAxisCanvas
		@xAxisLayer = new OrdinalAxisLayer
			$canvas: xAxisCanvas
			model: new LayerModel

		linesCanvas = $('<canvas id="lines"></canvas>')
		@$element.append linesCanvas
		@qpcrLinesLayer = new qpcrLinesLayer
			$canvas: linesCanvas
			model: new LayerModel

		selectedLinesCanvas = $('<canvas id="selected-lines"></canvas>')
		@$element.append selectedLinesCanvas
		@selectedLinesLayer = new qpcrLinesLayer
			$canvas: selectedLinesCanvas
			model: new LayerModel


		@layers = [@measureAxisLayer, @xAxisLayer, @qpcrLinesLayer, @selectedLinesLayer]

		super

	# Called by appView when dataManager gets data back
	# Get results and structure model with: predictions, scales
	onDataChange: ->
		@render()

	render: ->
		# size our div container
		{w, h} = @model
		pad = Styling.CHART_PAD

		# Calculate where the axis should be placed
		[plotWidth, plotHeight] = @getChartSizes()

		@state.results = @delegate.state().results # this won't work with multiple chart widgets
		{groups, projections, resultsByWell} = @state.results
		fluorescense = projections[0] # will only have a single projection which is fluorescense
		@state.fluorescenseScale = fluorescenseScale = new LinearScale
			domain: [fluorescense.domain[0], fluorescense.domain[1]]
			range: [0, plotHeight]

		{name, domain} = @state.results.groups[0] # cycle
		@state.xAxisScale = xAxisScale = new OrdinalScale
			domain: domain
			range: [0, plotWidth]


		# Calculate the qpcr lines here so they can be used by multiple layers
		@state.bezierPointsByWellKey = {}
		numWellsModeled = 0
		for wellKey, results of resultsByWell
			numWellsModeled++
			
			allPoints =
				for {cycle, fluorescense} in results
					[cycle, fluorescense]

			bezierPoints = for x in [1,5,10,15,25,30,35,40]
				[xAxisScale.map(x), -fluorescenseScale.map(allPoints[x - 1][1])]


			@state.bezierPointsByWellKey[wellKey] = {bezierPoints}
		
		selectedBezierPointsByWellKey = {}
		for wellKey, value of @state.bezierPointsByWellKey
			if @model.selectedWellKey is wellKey
				selectedBezierPointsByWellKey[wellKey] = value

		Koolaid.renderChildren [
			[
				@measureAxisLayer
				{
					scale: fluorescenseScale
					w
					h
					pad
					plotHeight
					plotWidth
				}
			]

			[
				@xAxisLayer
				{
					scale: xAxisScale
					w
					h
					pad
					labelYOffset: plotHeight + pad
					labelXOffset: pad
				}
			]

			[
				@qpcrLinesLayer
				{
					bezierPointsByWellKey: @state.bezierPointsByWellKey
					w
					h
					pad
					plotHeight
					plotWidth
					stroke: "#000"
				}
			],

			[
				@selectedLinesLayer
				{
					bezierPointsByWellKey: selectedBezierPointsByWellKey
					w
					h
					pad
					plotHeight
					plotWidth
					stroke: "#BD040D"
					lineWidth: 4
				}
			]

		]

		super # so we get a draw() call

	getChartSizes: ->
		{w, h} = @model
		plotWidth = w - 2 * Styling.CHART_PAD
		plotHeight = h - 2 * Styling.CHART_PAD
		[plotWidth, plotHeight]

	onMouseMove: (e) ->
		start = new Date()
		[x,y] = [e.offsetX - Styling.CHART_PAD, e.offsetY - Styling.CHART_PAD]
		# THIS needs to be abstracted (needing to know about drawing in vert
		# direction or not).  Should be an option in the Scale obj.
		[plotWidth, plotHeight] = @getChartSizes()
		y = plotHeight - y # have to alter y since we draw in negative direction
		cycleAtCursor = Math.round @state.xAxisScale.invert x # this probably wont be an integer
		fluorescenseAtCursor = @state.fluorescenseScale.invert y 

		resultsByCycle = @state.results.resultsByCycle
		valuesByWell = resultsByCycle[cycleAtCursor]
		minStart = new Date()
		minWell = _.min valuesByWell, ({wellKey, fluorescense}) ->
			Math.abs fluorescense - fluorescenseAtCursor

		diffOfClosest = Math.abs(fluorescenseAtCursor - minWell.fluorescense)

		selectedWellKey = 
			if diffOfClosest < 100
				minWell.wellKey
			else
				null
		@model.didMouseOverLine selectedWellKey
		console.log "calculated key in ", (new Date().getTime()) - start.getTime(), minWell.wellKey		
