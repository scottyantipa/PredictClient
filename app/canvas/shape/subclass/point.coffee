Shape = require '../shape'

module.exports = class Point extends Shape

	draw: (ctx) ->
		{r, x, y, fill, stroke} = @model
		super ctx
		ctx.beginPath()
		ctx.arc Math.round(x), Math.round(y), r, 0, Math.PI * 2, true
		ctx.closePath()
		ctx.fill() if fill
		# ctx.stroke() if stroke

	boundingBox: ->
		{r, x, y} = @model
		[x - r, y - r, 2 * r, 2 * r]
