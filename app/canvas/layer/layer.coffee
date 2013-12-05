module.exports = class Layer
	groups: []
	model: null # LayerModel

	constructor: ({@$canvas, @model}) ->
		return