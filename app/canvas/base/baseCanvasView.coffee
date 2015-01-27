###
Super class for widget, layer, group
This has the code responsible for the update/draw cycle in render.  render
is called on a view when someone has updated its model.  The view is then responsible for
doing things with that model (and possibly adding to it) so its children can update themselves in turn
###

module.exports = class BaseCanvasView
	###
	# NOT HANDLING STATE YET
	setState: (stateUpdates) ->
		for key, value of stateUpdates
			@stateAttributesChangedSinceLastRender[key] = key
		@state = _.extend @state, stateUpdates
		@render()
	###

	# Pass onClick to all children unless one returns false (meaning it doesnt want other children to get event)
	onClick: (options) ->
		for child in @children()
			break if not child.onClick options

	# Returns the props that are different between old and new model
	updatedProperties: ->
		props = []
		for key, value of @previousModel
			continue if not @previousModel.hasOwnProperty key
			if not @model[key]? or not _.isEqual(@previousModel[key], @model[key])
				props.push key

		for key, value of @model
			if not @previousModel[key]?
				props.push key

		props
