Layer = require '../layer'
qpcrLinesGroup = require '../../group/subclass/qpcrLinesGroup'
Styling = require '../../util/styling'

module.exports = class qpcrLinesLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		@qpcrLinesGroup = new qpcrLinesGroup {}
		@groups = [@qpcrLinesGroup]
		super

	updatesForChildren: ->
		{pad} = @model
		{tx, ty} = @calcGroupPositions()
		[
			[
				@qpcrLinesGroup
				{
					tx
					ty
					resultsByWell: @model.resultsByWell
					cycleScale: @model.cycleScale
					fluorescenseScale: @model.fluorescenseScale
				}
			]
		]

	calcGroupPositions: ->
		{pad, plotHeight} = @model
		{top, left} = pad
		tx = left
		ty = plotHeight + top + Styling.MAX_RADIUS
		{tx, ty}
