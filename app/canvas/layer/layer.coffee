module.exports = class Layer
	groups: null
	model: null # LayerModel
	ctx: null # a canvas context
	pixelRatio: 1 # for canvas element 

	constructor: ({@$canvas, @model}) ->
		@ctx = @$canvas[0].getContext("2d")
		@pixelRatio = window.devicePixelRatio or 1
		@$canvas.width = @pixelRatio * @model.w
		@$canvas.height = @pixelRatio * @model.h
		if not groups then groups = [] # safety net

	updateModel: ->
		@setCanvasSize()
		for group in @groups
			group.updateModel()

	setCanvasSize: ->
		{w, h} = @model
		w *= @pixelRatio
		h *= @pixelRatio
		@$canvas.attr 'width', w
		@$canvas.attr 'height', h

	draw: ->
		{w, h} = @model
		@ctx.clearRect 0, 0, w, h
		for group in @groups
			{tx, ty} = group.model
			@ctx.save()
			if tx or ty
				@ctx.translate(tx, ty)
			group.draw(@ctx) 
			@ctx.restore()
