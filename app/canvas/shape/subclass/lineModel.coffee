ShapeModel = require '../shapeModel'
Styling = require '../../util/styling'

module.exports = class LineModel extends ShapeModel
	x0: null
	x1: null
	y0: null
	y1: null
	fill: null
	stroke: Styling.CHART_LINES_FILL