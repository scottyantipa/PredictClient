Shape = require '../shape'

module.exports = class Polygon extends Shape

	# default is a bezier drawing
	draw: (ctx) ->
		super ctx
		# @drawStraightAllPoints ctx
		# return
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
	
	# Used for testing.  Just draws a straight line between start/end points in polygon		
	drawStraightEndToEnd: (ctx) ->
		ctx.beginPath()
		points = @model.bezierPoints
		ctx.moveTo points[0][0], points[0][1]
		ctx.lineTo _.last(points)[0], _.last(points)[1]
		ctx.stroke()
		ctx.closePath() if @model.closePath

	drawStraightAllPoints: (ctx) ->
		ctx.beginPath()
		points = @model.bezierPoints
		for [x,y], i in points
			# y += 2800
			if i is 0
				ctx.moveTo x,y
			else
				ctx.lineTo x,y
		ctx.stroke()
		ctx.closePath() if @model.closePath

