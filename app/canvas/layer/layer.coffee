BaseCanvasView = require '../base/baseCanvasView'

module.exports = class Layer extends BaseCanvasView
	groups: null
	model: null # LayerModel
	ctx: null # a canvas context
	pixelRatio: 1 # for canvas element 

	constructor: ({@$canvas, @model}) ->
		@ctx = @$canvas[0].getContext "2d"
		@pixelRatio = window.devicePixelRatio or 1
		@$canvas.width = @pixelRatio * @model.w
		@$canvas.height = @pixelRatio * @model.h
		if not @groups then @groups = [] # safety net

	draw: ->
		needsRedraw = false
		for group in @groups
			if group.doesNeedRedraw()
				needsRedraw = true
				break
		return if not needsRedraw
		@setCanvasSize()
		{w, h} = @model
		@ctx.clearRect 0, 0, w, h
		for group in @groups
			{tx, ty} = group.model
			@ctx.save()
			if tx or ty
				@ctx.translate(tx, ty)
			group.draw(@ctx) 
			@ctx.restore()

	setCanvasSize: ->
		{w, h} = @model
		w *= @pixelRatio
		h *= @pixelRatio
		@$canvas.attr 'width', w
		@$canvas.attr 'height', h
