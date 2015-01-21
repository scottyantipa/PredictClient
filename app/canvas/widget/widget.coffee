Tweener = require '../tween/tweener'
BaseCanvasView = require '../base/baseCanvasView'

module.exports = class Widget extends BaseCanvasView
	layers: null # [], determines order of click events
	model: null # a WidgetModel
	delegate: null # usually the main app

	# Call super in subclass
	constructor: ({@model, @$element, @delegate}) ->
		{h, w} = @model
		@$element.attr 'width', w
		@$element.attr 'height', h

		@$element
			.click((e) => @onClick(e))
			.mousemove((e) => @onMouseMove(e))

	# the rest should be done in subclass
	updateModel: ->
		super
		@draw()

	# called when there is a data change
	draw: ->
		layer.draw() for layer in @layers

	onMouseMove: (e) ->
		return 
	
	children: ->
		@layers