###
Draws the curves on the qpcr chart for each well
###

Group = require '../group'
Polygon = require '../../shape/subclass/polygon'
PolygonModel = require '../../shape/subclass/polygonModel'
Styling = require '../../util/styling'
DataManager = require '../../../data/dataManager'

module.exports = class qpcrLinesGroup extends Group
	render: ->
		@updateShapes @createNewShapes()

	# For each well, create a Polygon with all of the results
	createNewShapes: ->
		numWellsModeled = 0
		{bezierPointsByWellKey, stroke, lineWidth} = @model
		for wellKey, {poly, bezierPoints} of bezierPointsByWellKey
			{row} = DataManager.wellFromKey wellKey
			new PolygonModel {
				bezierPoints
				closePath: false
				lineWidth: lineWidth or .5
				key: "#{wellKey}"
				stroke: Styling.mapRowToColor row
			}

	newShapeWithOptions: (options) ->
		new Polygon options

	# For now, do not animte on add/remove becuase we dont have it properly set up
	tweenMapForAddShape: (shape) -> false
	tweenMapForRemoveShape: (shape) -> false
