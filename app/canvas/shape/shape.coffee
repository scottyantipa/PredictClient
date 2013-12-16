module.exports = class Shape
	model: null # ShapeModel

	constructor: ({@model, @delegate}) ->
		return

	draw: (ctx) ->
		{opacity, stroke, fill, lineWidth} = @model
		ctx.globalAlpha = if opacity < 0 then 0 else opacity
		ctx.strokeStyle = stroke if stroke
		ctx.fillStyle = fill if fill
		ctx.lineWidth = lineWidth if lineWidth
		@model.needsRedraw = false
		# the rest should be in the subclass


	doesIntersectPoint: (x, y) ->
		bb = @boundingBox()
		return false unless bb

		left = bb[0]
		width = bb[2]
		if width < 0
			width =- width
			left -= width

		top = bb[1]
		height = bb[3]
		if height < 0
			height =- height
			top -= height

		x >= left and
		x <= (left + width) and
		y >= top and
		y <= (top + height)

	# need to override
	boundingBox: ->
		null
