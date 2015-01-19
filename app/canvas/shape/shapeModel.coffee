baseCanvasModel = require '../base/baseCanvasModel'

module.exports = class ShapeModel extends baseCanvasModel
	# Styling
	type: "shape"
	fill: null
	opacity: 1
	tx: 0
	ty: 0
	lineWidth: 1
	fontSize: 12
	stroke: "#FFFFFF"

	# Group it belongs to
	group: null

	# If this is a data point of a chart
	# NOTE: There are some layers which don't use this yet like TimeAxisLayer
	data: null

	key: ""
