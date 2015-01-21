ShapeModel = require '../shapeModel'
Styling = require '../../util/styling'

module.exports = class TextModel extends ShapeModel
	fontSize: null
	text: null
	x: null
	y: null
	# fill: Styling.CHART_LINES_FILL