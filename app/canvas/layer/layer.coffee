###
Responsible for managing a canvas element and Groups (which manage shapes)
It has its own Tweener because it can redraw itself independently of the rest of the layers
###

BaseCanvasView = require '../base/baseCanvasView'
Tweener = require '../tween/tweener'

module.exports = class Layer extends BaseCanvasView
	groups: null
	model: null # LayerModel
	ctx: null # a canvas context
	pixelRatio: 1 # for canvas element 

	constructor: ({@$canvas, @model}) ->
		@ctx = @$canvas[0].getContext "2d"
		{w, h} = @model
		@$canvas.width = w
		@$canvas.height = h
		if not @groups then @groups = [] # safety net
		@tweener = new Tweener @draw
		for group in @groups
			group.tweener = @tweener

	# Called by Tweener so fat arrow
	draw: =>
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
		@$canvas.attr 'width', w
		@$canvas.attr 'height', h

	children: ->
		@groups