Layer = require '../layer/layer'

module.exports = class Group
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
# Managing shapes
#

	# Needs to be overriden in subclass
	updateModel: ->
		return

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
			@insertShapeWithModel newModel

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
	insertShapeWithModel: (model) ->
		return

	removeShape: (shape) ->
		key = shape.model.key
		@shapes = _.filter @shapes, (shape) ->
			shape.model.key isnt key
