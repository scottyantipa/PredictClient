Layer = require '../layer/layer'

module.exports = class Group
	layer: null # a Layer
	model: null # GroupModel

	constructor: ({@layer, @model}) ->
		return