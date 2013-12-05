Widget = require '../widget'
EventCirclesLayer = require '../../layer/subclass/eventCirclesLayer'
LayerModel = require '../../layer/layerModel'

module.exports = class ChartWidget extends Widget
	constructor: ({@model, @$element}) ->
		super

		# create a layer for circles, append the <canvas>
		eventCanvas = $('<canvas class="event-layer"></canvas>')
		@$element.append eventCanvas
		eventCirclesLayer = new EventCirclesLayer
			model: new LayerModel
			$canvas: eventCanvas

		@layers = [eventCirclesLayer]

	# Called by appView when dataManager gets data back
	onDataChange: (state) ->
		return