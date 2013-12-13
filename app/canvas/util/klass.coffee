###
Basic utils for manipulating objects
###

module.exports = class Klass

	# Update a groups model.  If there are no changes
	# then don't update the model, and dont flag it for redraw
	@extendChildModel: (group, updates) ->
		group.modelHasChanged = false
		propsToUpdate = []
		
		for property, value of updates
			if not  _.isEqual group.model[property], value
				propsToUpdate.push [property]
		
		if propsToUpdate.length isnt 0
			for property in propsToUpdate
				group.model[property] = updates[property]
			group.modelHasChanged = true
			group.needsRedraw = true
