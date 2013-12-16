module.exports = class BaseCanvasView

	# for now, just change the model.  Eventually we'll
	# want to compare old model with updates for fancy animation, etc
	updateModel: (updates) ->
		$.extend @model, updates
		for [child, childUpdates] in @updatesForChildren()	
			child.updateModel(childUpdates)
		# the rest should be in subclass

	# Returns an array of array, like:  [[child, update]..], where the updates
	# are the new props for the child
	updatesForChildren: ->
		[] # default, don't update anybody (like groups dont update children)