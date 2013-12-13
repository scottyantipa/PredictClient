Tweener = require '../tween/tweener'
BaseCanvasView = require '../base/baseCanvasView'

module.exports = class Widget extends BaseCanvasView
	layers: null
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

		@tweener = new Tweener @draw
		for layer in @layers
			layer.tweener = @tweener
			for group in layer.groups
				group.tweener = @tweener

	# the rest should be done in subclass
	updateModel: ->
		super
		@draw()

	# Fat arrow beacuse it gets called from tweener
	draw: =>
		layer.draw() for layer in @layers
			
	onClick: (e) ->
		return

	onMouseMove: (e) ->
		return 
	