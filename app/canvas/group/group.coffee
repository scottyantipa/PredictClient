Layer = require '../layer/layer'
BaseCanvasView = require '../base/baseCanvasView'
GroupModel = require './groupModel'

module.exports = class Group extends BaseCanvasView
	model: null # GroupModel
	shapes: null # Shape array
	needsRedraw: false

	constructor: ({@model}) ->
		@shapes = []
		if not @model then @model = new GroupModel

	draw: (ctx) ->
		# startDraw = new Date()
		for shape in @shapes
			ctx.save()
			if shape.model.tx or shape.model.ty	
				ctx.translate shape.model.tx, shape.model.ty
			shape.draw(ctx)
			ctx.restore()
		@needsRedraw = false
		# console.log "group draw in", (new Date).getTime() - startDraw.getTime() 
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
	# calculate which shapes need to be removed/added/updated
	# and then call methods on each set (subclass may handle them)
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
		
		# Handle the update/insert/remove
		for newModel in update
			@updateShapeForNewModel newModel
		for newModel in insert
			@insertShapeWithOptions 
				model: newModel
				delegate: @
		for oldShape in remove
			@removeShape oldShape

	# Figure out how the old and new model are different
	# and register those diffs with the tweener
	updateShapeForNewModel: (model) ->
		key = model.key
		shape = _.filter @shapes, (shape) ->
			shape.model.key is key
		shape = shape[0]
		oldModel = shape.model
		tweenMap =
			objToTween: shape.model
			propsToTween: []
			delegate: shape.delegate
			status: "update"

		needToTween = false
		for property, endValue of model
			startValue = oldModel[property]
			if not startValue
				oldModel[property] = endValue
			else if not _.isEqual startValue, endValue
				needToTween = true
				propertyToTween = {propName: property, startValue, endValue}
				tweenMap.propsToTween.push propertyToTween

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

	###
	Default tweening for adding/removing shapes just fades opacity
	You can override these if you want fancy animations in/out (like with time axis)
	At some point we should have multiple default ways of tweening in/out (like fly off screen)
	###
	tweenMapForRemoveShape: (shape) ->
		{model} = shape

		objToTween: model
		status: 'remove'
		delegate: shape.delegate
		propsToTween: [
			propName: 'opacity'
			startValue: model.opacity
			endValue: 0
		]
		
	tweenMapForAddShape: (shape) ->
		{model} = shape

		objToTween: model
		delegate: shape.delegate
		status: 'add'
		propsToTween: [
			propName: 'opacity'
			startValue: 0
			endValue: model.opacity
		]


	# Delegate methods

	# Tweener tells us when its finished a tween
	# NOTE: Great example of why @shapes should be a hash map by 
	# key -- _.filter is expensive
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
