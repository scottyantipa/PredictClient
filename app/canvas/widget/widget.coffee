Tweener = require '../tween/tweener'
BaseCanvasView = require '../base/baseCanvasView'

module.exports = class Widget extends BaseCanvasView
	layers: null # [], determines order of click events
	model: null # a WidgetModel
	delegate: null # usually the main app

	# Call super in subclass
	constructor: ({@model, @$element, @delegate}) ->
		@$element
			.click((e) => @onClick(e))
			.mousemove((e) => @onMouseMove(e))

	# the rest should be done in subclass
	render: ->
		{h, w, tx, ty} = @model
		@$element.attr 'width', w
		@$element.attr 'height', h
		@$element.css 'top', ty
		@$element.css 'left', tx
		@draw()

	# called when there is a data change
	draw: ->
		layer.draw() for layer in @layers
		return

	onMouseMove: (e) ->
		[x,y] = [e.offsetX, e.offsetY]
		layer.mouseMove(x,y) for layer in @layers
		return
	
	children: ->
		@layers