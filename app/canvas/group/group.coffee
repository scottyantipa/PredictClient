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
		startDraw = new Date()
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
		tweensForUpdate =
			for newModel in update
				if not tweenMap = @updateShapeForNewModel(newModel)
					continue
				else
					tweenMap

		tweensForAdd =
			for newModel in insert
				if not tweenMap = @insertShapeWithOptions {model: newModel, delegate: @}
					continue
				else 
					tweenMap

		tweensForRemove =
			for oldShape in remove
				if not tweenMap = @removeShape oldShape
					continue
				else
					tweenMap


		@tweener.registerObjectsToTween(
			tweensForUpdate
			.concat tweensForAdd
			.concat tweensForRemove
		)

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
			tweenMap
		else
			null

	# override with a specific shape
	insertShapeWithOptions: (options) ->
		shape = @newShapeWithOptions options
		@shapes.push shape
		@tweenMapForAddShape shape

	removeShape: (shape) =>
		if not tweenMap = @tweenMapForRemoveShape shape
			@removeShapeFromShapes shape.model.key
			return false
		else
			tweenMap

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

	removeShapeFromShapes: (shapeKey) ->
		@shapes = _.filter @shapes, (shape) ->
			shape.model.key isnt shapeKey
	# Delegate methods

	# Tweener tells us when its finished a tween
	# NOTE: Great example of why @shapes should be a hash map by 
	# key -- _.filter is expensive
	didFinishTween: (tween) =>
		switch tween.status
			when 'remove'
				debugger
				@removeShapeFromShapes tween.objToTween.key
			when 'update'
				break
			when 'add'
				break
