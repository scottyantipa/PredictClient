###
Basic utils for manipulating objects
###

module.exports = class Klass

	# Update a groups model.  If there are no changes
	# then don't update the model, and dont flag it for redraw
	@extendChildModel: (group, updates) ->
		group.modelHasChanged = false
		for property, value of updates
			if not  _.isEqual group.model[property], value
				group.model[property] = value
				group.modelHasChanged = true
				group.needsRedraw = true
