###
Draws the curves on the qpcr chart for each well
###

Group = require '../group'
Polygon = require '../../shape/subclass/polygon'
PolygonModel = require '../../shape/subclass/polygonModel'
Styling = require '../../util/styling'

module.exports = class qpcrLinesGroup extends Group
	updateModel: (options) ->
		super
		@updateShapes @createNewShapes()

	# For each well, create a Polygon with all of the results
	createNewShapes: ->
		numWellsModeled = 0
		{bezierPointsByWellKey} = @model
		for wellKey, bezierPoints of bezierPointsByWellKey
			new PolygonModel {
				bezierPoints
				closePath: false
				lineWidth: 2
				key: "#{wellKey}"
			}

	newShapeWithOptions: (options) ->
		new Polygon options

	# For now, do not animte on add/remove becuase we dont have it properly set up
	tweenMapForAddShape: (shape) -> false
	tweenMapForRemoveShape: (shape) -> false


