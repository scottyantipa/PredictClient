module.exports = class Layer
	groups: []
	model: null # LayerModel
	ctx: null # a canvas context
	pixelRatio: 1 # for canvas element 

	constructor: ({@$canvas, @model}) ->
		@ctx = @$canvas[0].getContext("2d")
		@pixelRatio = window.devicePixelRatio or 1
		console.log '@pixelRatio: ', @pixelRatio
		@$canvas.width = @pixelRatio * @model.w
		@$canvas.height = @pixelRatio * @model.h
		return

	updateModel: ->
		@setCanvasSize()
		group.updateModel() for group in @groups

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
			@ctx.save()
			if group.tx or group.ty
				@ctx.translate(group.tx, group.ty)
			group.draw(@ctx) 
			@ctx.restore()
