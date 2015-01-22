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


		{results} = @delegate.state() # this won't work with multiple chart widgets
		{groups, projections, resultsByWell} = results
		fluorescense = projections[0] # will only have a single projection which is fluorescense
		@state.fluorescenseScale = fluorescenseScale = new LinearScale
			domain: [fluorescense.domain[0], fluorescense.domain[1]]
			range: [0, plotHeight]

		{name, domain} = results.groups[0] # cycle
		@state.xAxisScale = xAxisScale = new OrdinalScale
			domain: domain
			range: [0, plotWidth]


		# Calculate the qpcr lines here so they can be used by multiple layers
		@state.bezierPointsByWellKey = {}
		numWellsModeled = 0
		for wellKey, results of resultsByWell
			numWellsModeled++
			# For debugging we can draw less lines
			# break if numWellsModeled is 50
			allPoints =
				for {cycle, fluorescense} in results
					[cycle, fluorescense]

			# Get coefficients to a polynomial that approximates the cycle * fluor data
			{equation} = regression 'polynomial', allPoints, 4
			# note that regression lib outputs 'equations' as an array of coefficients
			# in increasing x power, e.g. [a0, .... , an] for poly a0x^0 ... + anx^n

			# Use Polynomial library to create a polynomial from the coefficients
			# Note that Polynomial lib takes coefficients in order of decreasing exp power (the opposite of
			# regression lib) so we reverse the array from regression
			# equation = equation.map (coef) -> (Math.round(coef * 100) / 100
			poly = new Polynomial equation.reverse() # the two libraries take arguments in different orders

			# get roots of the derivative, which are local maxima/minima of our approximating polynomial
			roots = poly.getDerivative().getRootsInInterval 1, 40
			roots = roots.map (root) -> Math.floor(root) # since we are on an ordinal scale lets map natural numbers
			xValuesToGraph = roots
			xValuesToGraph = roots.concat [xAxisScale.domain[0],_.last(xAxisScale.domain)] # include the first and last points
			# so now we have out start/end points and local maxima/minima
			# Lets add a few more points if we only have 2 or 3
			xValuesToGraph = xValuesToGraph.concat [10, 30]
			xValuesToGraph = xValuesToGraph.sort()

			bezierPoints = for x in xValuesToGraph
				[xAxisScale.map(x), -fluorescenseScale.map(poly.eval(x))]

			@state.bezierPointsByWellKey[wellKey] = {poly, bezierPoints}
		
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
					plotHeight
					plotWidth
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
		[x,y] = [e.offsetX - Styling.CHART_PAD, e.offsetY - Styling.CHART_PAD]
		# THIS needs to be abstracted (needing to know about drawing in vert
		# direction or not).  Should be an option in the Scale obj.
		[plotWidth, plotHeight] = @getChartSizes()
		y = plotHeight - y # have to alter y since we draw in negative direction
		cycle = Math.round @state.xAxisScale.invert x # this probably wont be an integer
		fluorescense = @state.fluorescenseScale.invert y 

		closestFluorescense = Infinity
		keyOfClosestWell = null
		for wellKey, {bezierPoints, poly} of @state.bezierPointsByWellKey
			fluorescenseOfThisWell = poly.eval cycle # note this is an aproximation
			if (fluorDiff = Math.abs(fluorescense - fluorescenseOfThisWell)) < closestFluorescense
				closestFluorescense = fluorDiff
				keyOfClosestWell = wellKey

		@model.didMouseOverLine keyOfClosestWell
		@render()



