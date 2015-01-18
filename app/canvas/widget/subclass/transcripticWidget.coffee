Widget = require '../widget'
MeasureAxisLayer = require '../../layer/subclass/measureAxisLayer'
OrdinalAxisLayer = require '../../layer/subclass/ordinalAxisLayer'
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

		@layers = [@measureAxisLayer, @xAxisLayer]
		super

	# Called by appView when dataManager gets data back
	# Get results and structure model with: predictions, scales
	onDataChange: ->
		@updateModel()

	updateModel: ->
		# size our div container
		{w, h} = @model
		@$element.css 'width', w
		@$element.css 'height', h

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

		super

	updatesForChildren: ->
		{xAxisScale, fluorescenseScale, w, h, pad, plotHeight, plotWidth} = @model

		[
			[@measureAxisLayer, {scale: fluorescenseScale, w, h, pad, plotHeight, plotWidth}]
			[@xAxisLayer, {scale: xAxisScale, w, h, pad, plotHeight, plotWidth}]
		]
