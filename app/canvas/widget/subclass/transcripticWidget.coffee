Widget = require '../widget'
MeasureAxisLayer = require '../../layer/subclass/measureAxisLayer'
LayerModel = require '../../layer/layerModel'
LinearScale = require '../../util/linearScale'
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

		@layers = [@measureAxisLayer]
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
			domain: [fluorescense.range[0], fluorescense.range[1]]
			range: [0, @model.plotHeight]

		super

	updatesForChildren: ->
		{fluorescenseScale, w, h, pad, plotHeight, plotWidth} = @model

		[
			[@measureAxisLayer, {scale: fluorescenseScale, w, h, pad, plotHeight, plotWidth}]
		]
