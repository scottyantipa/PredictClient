Layer = require '../layer'
PredictionPointsGroup = require '../../group/subclass/predictionPointsGroup'
PredictionLinesGroup = require '../../group/subclass/predictionLinesGroup'
GroupModel = require '../../group/groupModel'

module.exports = class PredictionPointsLayer extends Layer
	constructor: ({@$canvas, @model}) ->
		@pointsGroup = new PredictionPointsGroup {}
		@linesGroup = new PredictionLinesGroup {}
		@groups = [@linesGroup, @pointsGroup]
		super

	updatesForChildren: ->
		{predictions, timeScale, probabilityScale, hotScale, w, h, pad, plotHeight, plotWidth} = @model
		{top, left} = pad
		w = plotWidth
		h = plotHeight
		tx = left
		ty = top

		[
			[@pointsGroup, {predictions, timeScale, probabilityScale, hotScale, w, h, tx, ty}]
			[@linesGroup, {predictions, timeScale, probabilityScale, w, h, tx, ty}]
		]
