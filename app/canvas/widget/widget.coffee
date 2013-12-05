module.exports = class Widget
	layers: []
	model: null # a WidgetModel
	delegate: # usually the main app

	# Call super in subclass
	constructor: ({@model, @$element}) ->
		@$element
			.click((e) => @onClick(e))
			.mousemove((e) => @onMouseMove(e))

	onClick: (e) ->

	onMouseMove: (e) ->
	