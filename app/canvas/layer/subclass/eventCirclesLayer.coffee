Layer = require '../layer'

module.exports = class EventCirclesLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		super