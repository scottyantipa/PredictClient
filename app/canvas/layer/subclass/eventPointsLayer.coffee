Layer = require '../layer'
EventPointsGroup = require '../../group/subclass/eventPointsGroup'
GroupModel = require '../../group/groupModel'

module.exports = class EventPointsLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		super
		@eventsGroup = new EventPointsGroup
			model: new GroupModel

		@groups = [@eventsGroup]

	###
	Will get the following modified by parent: 
		events, timeScale, probabilityScale
	Will modify the following in it's children:
		eventsGroup:  events, timeScale, probabilityScale
	###
	updateModel: ->
		{events, timeScale, probabilityScale, w, h} = @model
		$.extend @eventsGroup.model, {events, timeScale, probabilityScale, w, h}
		super