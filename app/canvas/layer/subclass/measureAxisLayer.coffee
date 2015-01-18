Layer = require '../layer'
Labels = require '../../group/subclass/labelsGroup'

module.exports = class MeasureAxisLayer extends Layer
	MIN_GAP_BETWEEN_LABELS: 50

	constructor: ({@$canvas, @model}) ->
		@labelsGroup = new Labels {}
		@groups = [@labelsGroup]
		group.tweenMapAddShapeForGroups = @tweenMapAddShapeForGroups for group in @groups
		group.tweenMapRemoveShapeForGroups = @tweenMapRemoveShapeForGroups for group in @groups
		super


	updatesForChildren: ->
		{plotHeight, plotWidth, scale, pad} = @model

		# The labels group will be positioned at the upper left most location
		{top, left} = pad
		tx = left
		ty = top
		labels = @calcLabels()
		[
			[@labelsGroup, {labels, tx, ty}]
		]

	# We want to draw numbers that are a factor of 10 if possible
	# and to not draw any of them to close together
	calcLabels: ->
		for tick in @model.scale.ticks @MIN_GAP_BETWEEN_LABELS
			value: tick
			y: @model.scale.map tick
			x: @model.scale.range[0] - 20

	yValForShape: (shape, scale = @model.scale) ->
		scale.map shape.measureValue

# ----------------------------------------------
# Special tweening for adding/removing shapes.  These functions
# get passed to our child groups to be used.
# ----------------------------------------------
	tweenMapAddShapeForGroups: (shape) =>
		propsToTween = [] # figure out what we can tween and put it in here
		{opacity, y} = shape.model


		if oldScale = @previousModel?.scale # we can tween x position if theres an old time scale
			propsToTween.push
				propName: 'y'
				startValue: @yValForShape shape.model, oldScale
				endValue: y

		propsToTween.push
			propName: 'opacity'
			startValue: 0
			endValue: opacity
		
		objToTween: shape.model
		propsToTween: propsToTween
		delegate: shape.delegate
		status: 'add'

	tweenMapRemoveShapeForGroups: (shape) =>
		{opacity, y} = shape.model
		propsToTween = []
		if scale = @model?.scale
			propsToTween.push
				propName: 'y'
				startValue: y
				endValue: @yValForShape(shape.model, scale)
		
		propsToTween.push
			propName: 'opacity'
			startValue: opacity
			endValue: 0

		objToTween: shape.model
		propsToTween: propsToTween
		delegate: shape.delegate
		status: 'remove'