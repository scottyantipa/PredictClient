Layer = require '../layer'
TicksGroup = require '../../group/subclass/probabilityTicksGroup'
TickLabelsGroup = require '../../group/subclass/tickLabelsGroup'
GroupModel = require '../../group/groupModel'

module.exports = class ProbabilityTicksLayer extends Layer
	minDistanceBetweenLines: 30
	steps: [5, 10, 20, 25, 50] # factors of 100

	constructor: ({@$canvas, @model}) ->
		@ticksGroup = new TicksGroup
			model: new GroupModel

		@labelsGroup = new TickLabelsGroup
			model: new GroupModel

		@groups = [@ticksGroup, @labelsGroup]
		super

	updateModel: ->
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

		@extendChildModel @ticksGroup, {bounds, waterMarks, w, h, tx, ty}
		@extendChildModel @labelsGroup, {bounds, waterMarks, w, h, tx, ty}

		super