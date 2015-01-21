Shape = require '../shape'

module.exports = class Polygon extends Shape

	draw: (ctx) ->
		super ctx
		# because canvas draws at .5 pixel, we want it to land directly on a a pixel
		ctx.beginPath()
		offset = if @model.lineWidth % 2 then 0.5 else 0
		points = @model.bezierPoints

		for [x,y], i in points
			break if i is points.length - 1
			x = Math.round(x) + offset
			y = Math.round(y) + offset
			if i is 0
				ctx.moveTo x,y
			else if i is points.length - 2
				ctx.quadraticCurveTo points[i][0], points[i][1], points[i+1][0], points[i+1][1]
			else
				xCenter = (points[i][0] + points[i + 1][0]) / 2
				yCenter = (points[i][1] + points[i + 1][1]) / 2
				ctx.quadraticCurveTo points[i][0], points[i][1], xCenter, yCenter

		ctx.stroke()
		ctx.closePath() if @model.closePath
		


