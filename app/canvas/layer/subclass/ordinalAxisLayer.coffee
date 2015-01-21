Layer = require '../layer'
Labels = require '../../group/subclass/labelsGroup'
Styling = require '../../util/styling'

module.exports = class OrdinalAxisLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		@labelsGroup = new Labels {}
		@groups = [@labelsGroup]
		group.tweenMapAddShapeForGroups = @tweenMapAddShapeForGroups for group in @groups
		group.tweenMapRemoveShapeForGroups = @tweenMapRemoveShapeForGroups for group in @groups
		super


	updatesForChildren: ->
		{pad} = @model
		{tx, ty} = @calcGroupPositions()
		labels = @calcLabels()
		[
			[@labelsGroup, {labels, tx, ty}]
		]

	# We want to draw numbers that are a factor of 10 if possible
	# and to not draw any of them to close together
	calcLabels: ->
		for tick in @model.scale.ticks @MIN_GAP_BETWEEN_LABELS
			value: tick
			y: 0
			x: @model.scale.map tick

	calcGroupPositions: ->
		{pad, plotHeight} = @model
		{top, left} = pad
		tx = left
		ty = plotHeight + top + Styling.MAX_RADIUS
		{tx, ty}

	xValForShape: (shape, scale = @model.scale) ->
		scale.map shape.x

# ----------------------------------------------
# Special tweening for adding/removing shapes.  These functions
# get passed to our child groups to be used.
# ----------------------------------------------
	tweenMapAddShapeForGroups: (shape) =>
		propsToTween = [] # figure out what we can tween and put it in here
		{opacity, x} = shape.model

		hasOldScale = false
		startValue =
			if oldScale = @previousModel?.scale # we can tween x position if theres an old time scale
				hasOldScale = true
				@xValForShape shape.model, oldScale
			else
				@model.scale.range[0]

		propsToTween.push
			propName: 'x'
			startValue: startValue
			endValue: x
			duration: if hasOldScale then Styling.DEFAULT_ANIMATION_DURATION else Styling.QUICK_ANIMATION_DURATION

		propsToTween.push
			propName: 'opacity'
			startValue: 0
			endValue: opacity
		
		objToTween: shape.model
		propsToTween: propsToTween
		delegate: shape.delegate
		status: 'add'

	tweenMapRemoveShapeForGroups: (shape) =>
		{opacity, x} = shape.model
		propsToTween = []
		if scale = @model?.scale
			propsToTween.push
				propName: 'x'
				startValue: x
				endValue: @xValForShape(shape.model, scale)
		
		propsToTween.push
			propName: 'opacity'
			startValue: opacity
			endValue: 0

		objToTween: shape.model
		propsToTween: propsToTween
		delegate: shape.delegate
		status: 'remove'