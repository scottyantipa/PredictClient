Shape = require '../shape'

module.exports = class Line extends Shape

	draw: (ctx) ->
		{x0, y0, x1, y1} = @model
		super ctx
		ctx.beginPath()
		ctx.moveTo Math.round(x0) + 0.5, Math.round(y0) + 0.5
		ctx.lineTo Math.round(x1) + 0.5, Math.round(y1) + 0.5
		ctx.stroke()
