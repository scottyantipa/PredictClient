###
Super class for widget, layer, group
This has the code responsible for the update/draw cycle in updateModel.  updateModel
is called on a view when someone has updated its model.  The view is then responsible for
doing things with that model (and possibly adding to it) so its children can update themselves in turn
###

module.exports = class BaseCanvasView

	# for now, just change the model.  Eventually we'll
	# want to compare old model with updates for fancy animation, etc
	updateModel: (updates) ->
		@previousModel = _.extend {}, @model
		$.extend @model, updates if updates
		for [child, childUpdates] in @updatesForChildren()	
			child.updateModel childUpdates
		# the rest should be in subclass

	# Pass onClick to all children unless one returns false (meaning it doesnt want other children to get event)
	onClick: (options) ->
		for child in @children()
			break if not child.onClick options

	# This is how a view passes updates to its children.
	# It returns an array of array, like:  [[childView, updates], [childView, updates], ...].
	# Then in this base class, updateModel extends the childs model with the updates and then calls updateModel on the child
	updatesForChildren: ->
		[] # default, don't update anybody (like groups dont update their shapes)
