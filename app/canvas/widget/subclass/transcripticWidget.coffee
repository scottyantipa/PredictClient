Widget = require '../widget'
MeasureAxisLayer = require '../../layer/subclass/measureAxisLayer'
OrdinalAxisLayer = require '../../layer/subclass/ordinalAxisLayer'
qpcrLinesLayer = require '../../layer/subclass/qpcrLinesLayer'
LayerModel = require '../../layer/layerModel'
LinearScale = require '../../util/linearScale'
OrdinalScale = require '../../util/ordinalScale'
Styling = require '../../util/styling'

module.exports = class TranscripticWidget extends Widget
	constructor: ({@model, @$element, @delegate}) ->
		{w, h} = @model

		measureAxisCanvas = $('<canvas id="measure-axis"></canvas>')
		@$element.append measureAxisCanvas
		@measureAxisLayer = new MeasureAxisLayer
			$canvas: measureAxisCanvas
			model: new LayerModel
				w: w
				h: h

		xAxisCanvas = $('<canvas id="x-axis"></canvas>')
		@$element.append xAxisCanvas
		@xAxisLayer = new OrdinalAxisLayer
			$canvas: xAxisCanvas
			model: new LayerModel
				w: w
				h: h

		linesCanvas = $('<canvas id="lines"></canvas>')
		@$element.append linesCanvas
		@qpcrLinesLayer = new qpcrLinesLayer
			$canvas: linesCanvas
			model: new LayerModel
				w: w
				h: h

		@layers = [@measureAxisLayer, @xAxisLayer, @qpcrLinesLayer]
		super

	# Called by appView when dataManager gets data back
	# Get results and structure model with: predictions, scales
	onDataChange: ->
		@updateModel()

	updateModel: ->
		# size our div container
		{w, h} = @model
		# @$element.attr 'width', w
		# @$element.attr 'height', h

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

		{results} = @delegate.state() # this won't work with multiple chart widgets
		{groups, projections, resultsByWell} = results
		fluorescense = projections[0] # will only have a single projection which is fluorescense
		@model.fluorescenseScale = new LinearScale
			domain: [fluorescense.domain[0], fluorescense.domain[1]]
			range: [0, @model.plotHeight]

		{name, domain} = results.groups[0] # cycle
		@model.xAxisScale = new OrdinalScale
			domain: domain
			range: [0, @model.plotWidth]


		# Calculate the qpcr lines here so they can be used by multiple layers
		@model.bezierPointsByWellKey = {}
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
			xValuesToGraph = roots.concat [@model.xAxisScale.domain[0],_.last(@model.xAxisScale.domain)] # include the first and last points
			# so now we have out start/end points and local maxima/minima
			# Lets add a few more points if we only have 2 or 3
			xValuesToGraph = xValuesToGraph.concat [10, 30]
			xValuesToGraph = xValuesToGraph.sort()

			@model.bezierPointsByWellKey[wellKey] =
				for x in xValuesToGraph
					[@model.xAxisScale.map(x), -@model.fluorescenseScale.map(poly.eval(x))]

		super

	updatesForChildren: ->
		{bezierPointsByWellKey, xAxisScale, fluorescenseScale, w, h, pad, plotHeight, plotWidth} = @model

		[
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
					bezierPointsByWellKey
					w
					h
					pad
					plotHeight
					plotWidth
				}
			]
		]
