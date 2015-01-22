Koolaid = require '../../koolaid'
Layer = require '../layer'
Labels = require '../../group/subclass/labelsGroup'
Styling = require '../../util/styling'

module.exports = class MeasureAxisLayer extends Layer
	MIN_GAP_BETWEEN_LABELS: 50

	constructor: ({@$canvas, @model}) ->
		@labelsGroup = new Labels {}
		@groups = [@labelsGroup]
		group.tweenMapAddShapeForGroups = @tweenMapAddShapeForGroups for group in @groups
		group.tweenMapRemoveShapeForGroups = @tweenMapRemoveShapeForGroups for group in @groups
		super

	render: ->
		# The labels group will be positioned at the upper left most location
		tx = ty = @model.pad
		labels = @calcLabels()
		Koolaid.renderChildren [
			[@labelsGroup, {labels, tx, ty}]
		]

	# We want to draw numbers that are a factor of 10 if possible
	# and to not draw any of them to close together
	calcLabels: ->
		for tick in @model.scale.ticks @MIN_GAP_BETWEEN_LABELS
			data: [
				value: tick
				name: "measure"
			]
			value: tick
			y: @model.plotHeight - @model.scale.map tick
			x: @model.scale.range[0] - 60

	yValForShape: (shapeModel, model = @model) ->
		model.plotHeight - model.scale.map shapeModel.data[0].value

# ----------------------------------------------
# Special tweening for adding/removing shapes.  These functions
# get passed to our child groups to be used.
# ----------------------------------------------
	tweenMapAddShapeForGroups: (shape) =>
		propsToTween = [] # figure out what we can tween and put it in here
		{opacity, y} = shape.model


		hasOldScale = false
		startValue =
			if oldScale = @previousModel?.scale # we can tween x position if theres an old time scale
				hasOldScale = true
				@yValForShape shape.model, @previousModel
			else
				# Take the first value from domain and animate everything from there
				@model.plotHeight - @model.scale.map(@model.scale.domain[0])

		duration = Styling.DEFAULT_ANIMATION_DURATION

		propsToTween.push
			propName: 'y'
			startValue: startValue
			endValue: y
			duration: duration

		propsToTween.push
			propName: 'opacity'
			startValue: 0
			endValue: opacity
			duration: duration
		
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
				endValue: @yValForShape shape.model, @model
		
		propsToTween.push
			propName: 'opacity'
			startValue: opacity
			endValue: 0

		objToTween: shape.model
		propsToTween: propsToTween
		delegate: shape.delegate
		status: 'remove'
