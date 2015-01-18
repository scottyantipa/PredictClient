Group = require '../group'
Line = require '../../shape/subclass/line'
LineModel = require '../../shape/subclass/lineModel'
Styling = require '../../util/styling'

module.exports = class TimeAxisTicksGroup extends Group
	VERT_AXIS_KEY: "timeAxisVerticalAxisKey"

	updateModel: (options) ->
		super
		newShapeModels = @createNewShapes()
		@updateShapes newShapeModels

	# Place shapes next to horizontal lines (on LHS for now)
	createNewShapes: ->
		# the primary ticks marks on the axis
		{axisTicks} = @model
		for tick in axisTicks
			new LineModel tick

	newShapeWithOptions: (options) ->
		new Line options

	tweenMapForAddShape: (shape) ->
		@tweenMapAddShapeForGroups shape # parent method

	tweenMapForRemoveShape: (shape) ->
		@tweenMapRemoveShapeForGroups shape