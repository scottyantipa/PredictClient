baseCanvasModel = require '../base/baseCanvasModel'

module.exports = class ShapeModel extends baseCanvasModel
	type: "shape"
	fill: null
	lineWidth: null
	opacity: 1
	isClickable: true
	tx: 0
	ty: 0

	group: null
