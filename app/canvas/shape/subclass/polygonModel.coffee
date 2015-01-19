ShapeModel = require '../shapeModel'
Styling = require '../../util/styling'

module.exports = class PolygonModel extends ShapeModel
	points: null # list of poins ordered by drawing order
	closePath: true # closes path of first/last points (e.g. set false if you want a line, set true if you wanta  closed shape)