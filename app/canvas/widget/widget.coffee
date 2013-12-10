module.exports = class Widget
	layers: []
	model: null # a WidgetModel
	delegate: null # usually the main app

	# Call super in subclass
	constructor: ({@model, @$element, @delegate}) ->
		{h, w} = @model
		@$element.css 'width', w
		@$element.css 'height', h

		@$element
			.click((e) => @onClick(e))
			.mousemove((e) => @onMouseMove(e))

	# the rest should be done in subclass
	updateModel: ->
		layer.updateModel() for layer in @layers
		@draw()

	draw: ->
		for layer in @layers
			layer.draw()

	onClick: (e) ->
		return

	onMouseMove: (e) ->
		return
	