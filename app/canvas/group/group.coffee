Layer = require '../layer/layer'
BaseCanvasView = require '../base/baseCanvasView'

module.exports = class Group extends BaseCanvasView
	model: null # GroupModel
	shapes: null # Shape array
	needsRedraw: false

	constructor: ({@layer, @model}) ->
		@shapes = []
		@model = {}

	draw: (ctx) ->
		for shape in @shapes
			ctx.save()
			if shape.model.tx or shape.model.ty	
				ctx.translate shape.model.tx, shape.model.ty
			shape.draw(ctx)
			ctx.restore()
		@needsRedraw = false
#
# Click handling
#

	onClick: (e) ->
		shape = @shapeBeneathPoint
			x: e.offsetX - @model.tx
			y: e.offsetY - @model.ty
		if shape
			# do stuff here and return false
			return false
		true # so other groups can catch the event

	shapeBeneathPoint: ({x, y}) ->
		selectedShape = null
		for shape in @shapes
			if shape.doesIntersectPoint x, y
				selectedShape = shape
		selectedShape


	children: ->
		@shapes



#
# Managing shapes
#
	# Needing redraw can be determined in two ways.
	# Either this group removes/adds shapes itelf, or
	# an external object changes a shape model directly
	doesNeedRedraw: ->
		if @needsRedraw then return true
		for shape in @shapes
			if shape.model.needsRedraw
				return true
		false

	# Given a hash of the newly calculated shapes
	# we need to remove/add/update existing shapes
	updateShapes: (newShapeModels) ->
		@needsRedraw = true
		[insert, remove, update] = [ [], [], [] ]
		oldShapesByKey = {}
		for oldShape in @shapes
			oldShapesByKey[oldShape.model.key] = oldShape 

		for newModel in newShapeModels
			key = newModel.key
			if oldShapesByKey.hasOwnProperty(key)
				update.push newModel
			else
				insert.push newModel
			delete oldShapesByKey[key]

		# Remove any remaining old shapes (not pushed to update)
		for key of oldShapesByKey
			remove.push oldShapesByKey[key] 
		
		for newModel in update
			@updateShapeForNewModel newModel

		for newModel in insert
			@insertShapeWithOptions 
				model: newModel
				delegate: @

		for oldShape in remove
			@removeShape oldShape


	updateShapeForNewModel: (model) ->
		key = model.key
		shape = _.filter @shapes, (shape) ->
			shape.model.key is key
		shape = shape[0]
		oldModel = shape.model
		tweenMap =
			objToTween: shape.model
			propsToTween: {}
			delegate: shape.delegate
			status: "update"

		needToTween = false
		for property, endValue of model
			startValue = oldModel[property]
			if not startValue
				oldModel[property] = endValue
			else if not _.isEqual startValue, endValue
				needToTween = true
				tweenMap.propsToTween[property] = [startValue, endValue]

		if needToTween
			@tweener.registerObjectToTween(tweenMap)

	# override with a specific shape
	insertShapeWithOptions: (options) ->
		shape = @newShapeWithOptions options
		@shapes.push shape
		tweenMap = @tweenMapForAddShape shape
		@tweener.registerObjectToTween(tweenMap) if tweenMap
		return

	removeShape: (shape) =>
		tweenMap = @tweenMapForRemoveShape shape
		@tweener.registerObjectToTween(tweenMap) if tweenMap

	# should most likely override this
	tweenMapForRemoveShape: (shape) ->
		startOpacity = shape.model.opacity # set initial state

		objToTween: shape.model
		propsToTween:
			opacity: [startOpacity, 0]
		delegate: shape.delegate
		status: 'remove'

	tweenMapForAddShape: (shape) ->
		startOpacity = 0

		objToTween: shape.model
		propsToTween:
			opacity: [startOpacity, shape.model.opacity]
		delegate: shape.delegate
		status: 'add'


	# Delegate methods
	didFinishTween: (tween) =>
		switch tween.status
			when 'remove'
				key = tween.objToTween.key
				@shapes = _.filter @shapes, (shape) ->
					shape.model.key isnt key
			when 'update'
				break
			when 'add'
				break
