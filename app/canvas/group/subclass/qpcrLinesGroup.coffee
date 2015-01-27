###
Draws the curves on the qpcr chart for each well
###

Group = require '../group'
Polygon = require '../../shape/subclass/polygon'
PolygonModel = require '../../shape/subclass/polygonModel'
Styling = require '../../util/styling'

module.exports = class qpcrLinesGroup extends Group
	render: ->
		@updateShapes @createNewShapes()

	# For each well, create a Polygon with all of the results
	createNewShapes: ->
		numWellsModeled = 0
		{bezierPointsByWellKey, stroke, lineWidth} = @model
		for wellKey, {poly, bezierPoints} of bezierPointsByWellKey
			new PolygonModel {
				bezierPoints
				closePath: false
				lineWidth: lineWidth or 1
				key: "#{wellKey}"
				stroke: stroke
			}

	newShapeWithOptions: (options) ->
		new Polygon options

	# For now, do not animte on add/remove becuase we dont have it properly set up
	tweenMapForAddShape: (shape) -> false
	tweenMapForRemoveShape: (shape) -> false
