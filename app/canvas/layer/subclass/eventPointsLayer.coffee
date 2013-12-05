Layer = require '../layer'

module.exports = class EventPointsLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		super