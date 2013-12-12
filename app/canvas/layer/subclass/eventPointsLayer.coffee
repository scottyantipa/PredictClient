Layer = require '../layer'
EventPointsGroup = require '../../group/subclass/eventPointsGroup'
GroupModel = require '../../group/groupModel'

module.exports = class EventPointsLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		@eventsGroup = new EventPointsGroup
			model: new GroupModel

		@groups = [@eventsGroup]
		super

	updateModel: ->
		{events, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth} = @model
		{top, left} = pad
		w = plotWidth
		h = plotHeight
		tx = left
		ty = top
		
		@extendChildModel @eventsGroup, {events, timeScale, probabilityScale, hotScale, w, h, tx, ty}

		super