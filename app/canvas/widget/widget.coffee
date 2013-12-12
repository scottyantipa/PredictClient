Tweener = require '../tween/tweener'
module.exports = class Widget
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
		layer.updateModel() for layer in @layers
		@draw()

	# Fat arrow beacuse it gets called from tweener
	draw: =>
		layer.draw() for layer in @layers
			
	onClick: (e) ->
		return

	onMouseMove: (e) ->
		return 
	