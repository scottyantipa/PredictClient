Layer = require '../layer'
TickLabelsGroup = require '../../group/subclass/tickLabelsGroup'

module.exports = class ProbabilityTicksLayer extends Layer
	minDistanceBetweenLines: 50
	steps: [25, 50] # factors of 100

	constructor: ({@$canvas, @model}) ->
		@labelsGroup = new TickLabelsGroup {}
		@groups = [@labelsGroup]
		super

	updatesForChildren: ->
		{probabilityScale, timeScale, pad, plotHeight, plotWidth} = @model
		{top, left} = pad
		w = plotWidth
		h = plotHeight
		tx = left
		ty = top
		bounds = 
			left: timeScale.range[0]
			right: timeScale.range[1]

		# Create skeletons for the horizontal ticks
		# to be used by the groups 
		waterMarks = []
		i = 0
		numLines = 0
		while (probabilityScale.dy / (100/ @steps[i])) < @minDistanceBetweenLines
			i++

		j = 0
		while @steps[i] * j <= 100
			value = @steps[i] * j
			y = h - probabilityScale.map(value)
			waterMarks.push
				value: value
				y: y
			j++

		[
			[@labelsGroup, {bounds, waterMarks, w, h, tx, ty}]
		]