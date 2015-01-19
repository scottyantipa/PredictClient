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
		{cycleScale, fluorescenseScale, resultsByWell} = @model
		for wellKey, results of resultsByWell
			numWellsModeled++
			# For debugging we can draw less lines
			# break if numWellsModeled > 20
			allPoints =
				for {cycle, fluorescense} in results
					[cycle, fluorescense]

			# Get coefficients to a polynomial that approximates the cycle * fluor data
			{equation} = regression 'polynomial', allPoints, 4
			# note that regression lib outputs 'equations' as an array of coefficients
			# in increasing x power, e.g. [a0, .... , an] for poly a0x^0 ... + anx^n

			# Use Polynomial library to create a polynomial from the coefficients
			# Note that Polynomial lib takes coefficients in order of decreasing exp power (the opposite of
			# regression lib) so we reverse the array from regression
			# equation = equation.map (coef) -> (Math.round(coef * 100) / 100
			poly = new Polynomial equation.reverse() # the two libraries take arguments in different orders

			# get roots of the derivative, which are local maxima/minima of our approximating polynomial
			roots = poly.getDerivative().getRootsInInterval 1, 40
			roots = roots.map (root) -> Math.floor(root) # since we are on an ordinal scale lets map natural numbers
			xValuesToGraph = roots
			xValuesToGraph = roots.concat [cycleScale.domain[0],_.last(cycleScale.domain)] # include the first and last points
			# so now we have out start/end points and local maxima/minima
			# Lets add a few more points if we only have 2 or 3
			xValuesToGraph = xValuesToGraph.concat [10, 30]
			xValuesToGraph = xValuesToGraph.sort()

			bezierPoints =
				for x in xValuesToGraph
					[cycleScale.map(x), -fluorescenseScale.map(poly.eval(x))]

			new PolygonModel {
				bezierPoints
				closePath: false
				lineWidth: 1
				key: "#{wellKey}"
			}

	newShapeWithOptions: (options) ->
		new Polygon options

	# For now, do not animte on add/remove becuase we dont have it properly set up
	tweenMapForAddShape: (shape) -> false
	tweenMapForRemoveShape: (shape) -> false


