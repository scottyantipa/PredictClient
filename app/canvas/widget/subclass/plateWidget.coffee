Koolaid = require '../../koolaid'
Widget = require '../widget'
LayerModel = require '../../layer/layerModel'
Layer = require '../../layer/layer'
OrdinalAxisLayer = require '../../layer/subclass/ordinalAxisLayer'
PlateWellsLayer = require '../../layer/subclass/plateWellsLayer'
OrdinalScale = require '../../util/ordinalScale'
Styling = require '../../util/styling'

module.exports = class PlateWidget extends Widget
	state: {}

	constructor: ({@model, @$element, @delegate}) ->
		{w, h} = @model

		# This will contain both axis and the unselected well circles
		# Another layer will go on top for interaction/selection of circles
		rowLabelsCanvas = $('<canvas id="row-labels"></canvas>')
		@$element.append rowLabelsCanvas
		@rowLayer = new OrdinalAxisLayer
			$canvas: rowLabelsCanvas
			model: new LayerModel {}

		columnLabelsCanvas = $('<canvas id="column-labels"></canvas>')
		@$element.append columnLabelsCanvas
		@columnLayer = new OrdinalAxisLayer
			$canvas: columnLabelsCanvas
			model: new LayerModel {}

		plateWellsCanvas = $('<canvas id="plate-wells"></canvas>')
		@$element.append plateWellsCanvas
		@plateWellsLayer = new PlateWellsLayer
			$canvas: plateWellsCanvas
			model: new LayerModel {}

		selectedPlateWellsCanvas = $('<canvas id="plate-wells-selected"></canvas>')
		@$element.append selectedPlateWellsCanvas
		@selectedPlateWellsLayer = new PlateWellsLayer
			$canvas: selectedPlateWellsCanvas
			model: new LayerModel {}

		@layers = [@columnLayer, @rowLayer, @plateWellsLayer, @selectedPlateWellsLayer]

		super

	render: ->
		# size our div container
		{w, h} = @model
		pad = Styling.CHART_PAD

		# Calculate where the axis should be placed
		[plotWidth, plotHeight] = @getChartSizes()


		@state.rowsScale = new OrdinalScale
			domain: [1..@model.numRows]
			range: [0, plotHeight]

		@state.columnScale = new OrdinalScale
			domain: [1..@model.numColumns] 
			range: [0, plotWidth]

		origin = [pad, 30] # set the origin of the chart in a little bit

		Koolaid.renderChildren [
			[
				@columnLayer
				{
					scale: @state.columnScale
					w
					h
					labelYOffset: -13 # so that the bottom of the numbers line up with the top of origin
					labelXOffset: origin[0]
					fill: Styling.WHITE
				}
			]

			[
				@rowLayer
				{
					scale: @state.rowsScale
					w
					h
					labelYOffset: origin[1]
					labelXOffset: 20
					vertical: true
					fill: Styling.WHITE
				}
			]

			[
				@plateWellsLayer
				{
					rowScale: @state.rowsScale
					columnScale: @state.columnScale
					w
					h
					pad
					origin
					drawSelected: false
					wellSelected: @wellSelected
					respondsToMouseEvents: true
				}
			]

			[
				@selectedPlateWellsLayer
				{
					rowScale: @state.rowsScale
					columnScale: @state.columnScale
					w
					h
					pad
					origin
					selectedWellKey: @model.selectedWellKey
					drawSelected: true
					respondsToMouseEvents: false
				}
			]
		]

		super

	# Called by appView when dataManager gets data back
	# Get results and structure model with: predictions, scales
	onDataChange: ->
		@render()

	getChartSizes: ->
		{w, h} = @model
		plotWidth = w - Styling.CHART_PAD
		plotHeight = h - 50
		[plotWidth, plotHeight]

	wellSelected: (welLKey) => @model.didMouseOverWell welLKey