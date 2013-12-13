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
		if not @groups then @groups = [] # safety net

	updateModel: ->
		for group in @groups
			continue if not group.modelHasChanged
			group.updateModel()
		group.modelHasChanged = false for group in @groups

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

	# Update a groups model.  If there are no changes
	# then don't update the model, and dont flag it for redraw
	extendChildModel: (child, updates) ->
		child.modelHasChanged = false
		for property, value of updates
			if not  _.isEqual child.model[property], value
				child.model[property] = value
				child.modelHasChanged = true
				child.needsRedraw = true
		

	setCanvasSize: ->
		{w, h} = @model
		w *= @pixelRatio
		h *= @pixelRatio
		@$canvas.attr 'width', w
		@$canvas.attr 'height', h
