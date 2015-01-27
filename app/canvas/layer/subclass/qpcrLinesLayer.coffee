Koolaid = require '../../koolaid'
Layer = require '../layer'
qpcrLinesGroup = require '../../group/subclass/qpcrLinesGroup'
Styling = require '../../util/styling'

module.exports = class qpcrLinesLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		@qpcrLinesGroup = new qpcrLinesGroup {}
		@groups = [@qpcrLinesGroup]
		super

	render: ->
		{pad, bezierPointsByWellKey, stroke, lineWidth} = @model
		{tx, ty} = @calcGroupPositions()
		Koolaid.renderChildren [
			[
				@qpcrLinesGroup
				{
					tx
					ty
					bezierPointsByWellKey
					stroke
					lineWidth
				}
			]
		]
		super

	calcGroupPositions: ->
		{pad, plotHeight} = @model
		tx = pad
		ty = plotHeight + pad
		{tx, ty}
