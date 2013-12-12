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
		# the rest should be in the subclass
