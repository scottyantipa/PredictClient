Layer = require '../layer/layer'

module.exports = class Group
	model: null # GroupModel
	shapes: null # Shape array

	constructor: ({@layer, @model}) ->
		@shapes = []
		@model = {}
		return

	draw: (ctx) ->
		for shape in @shapes
			ctx.save()
			if shape.model.tx or shape.model.ty	
				ctx.translate shape.model.tx, shape.model.ty
			shape.draw(ctx)
			ctx.restore()

	translate: ({tx, ty}, animated = false) ->
		if not animated
			[model.tx, model.ty] = [tx, ty]
#
# Managing shapes
#

	# Needs to be overriden in subclass
	updateModel: ->
		return

	# Given a hash of the newly calculated shapes
	# we need to remove/add/update existing shapes
	updateShapes: (newShapeModels) ->
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
		oldShape = _.filter @shapes, (shape) ->
			shape.model.key is key
		oldShape = oldShape[0]
		oldShape.model = model

	# override with a specific shape
	insertShapeWithModel: (model) ->
		return

	removeShape: (shape) ->
		key = shape.model.key
		@shapes = _.filter @shapes, (shape) ->
			shape.model.key isnt key