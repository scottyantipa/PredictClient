DataManager = require '../../../data/dataManager'
Koolaid = require '../../koolaid'
Layer = require '../layer'
Group = require '../../group/group'
Point = require '../../shape/subclass/point'
PointModel = require '../../shape/subclass/pointModel'
Styling = require '../../util/styling'

module.exports = class PlateWellsLayer extends Layer

	constructor: ({@$canvas, @model}) ->
		@circlesGroup = new Group {}
		@circlesGroup.render = @renderCircles
		@circlesGroup.newShapeWithOptions = @newShapeWithOptions
		@circlesGroup.tweenMapForAddShape = @tweenMapForAddShape
		@circlesGroup.tweenMapForRemoveShape = @tweenMapForRemoveShape
		@groups = [@circlesGroup]
		super

	render: ->
		Koolaid.renderChildren [
			[
				@circlesGroup
				{
					rowScale: @model.rowScale
					columnScale: @model.columnScale
					origin: @model.origin
					selectedWellKey: @model.selectedWellKey
					drawSelected: @model.drawSelected
				}
			]
		]

	#
	# Methods I override group with
	#

	newShapeWithOptions: (options) ->
		new Point options

	# TODO: The manual x offset is so that the circles
	# line up with the column headers.  This needs to be done programmatically
	# by measuring the column headerse and properly centering them
	renderCircles: ->
		shapeModels =
			for row in @model.rowScale.domain
				rowProjection = @model.rowScale.map row
				for column in @model.columnScale.domain
					columnProjection = @model.columnScale.map column
					key = DataManager.keyForWell row, column
					isSelected = key is @model.selectedWellKey
					continue if @model.drawSelected and not isSelected
					new PointModel
						x: columnProjection + @model.origin[0] + 4
						y: rowProjection + @model.origin[1] - 3
						r: if isSelected then 8 else 5
						key: key
						stroke: if isSelected then Styling.SELECTED_SHAPE_BLUE else Styling.BLACK
						lineWidth: if isSelected then 2 else .5
						fill: if isSelected then Styling.SELECTED_SHAPE_BLUE else Styling.White


		@updateShapes _.flatten(shapeModels)

	tweenMapForAddShape: (shape) ->
		return false

		# returning false for now, but use this if you'd like to animate radius
		{model} = shape

		objToTween: model
		delegate: shape.delegate
		status: 'add'
		propsToTween: [
			propName: 'r'
			startValue: 0
			endValue: model.r
			duration: 300
		]

	tweenMapForRemoveShape: (shape) ->
		return false

		# returning false for now, but use this if you'd like to animate radius
		{model} = shape
		
		objToTween: model
		delegate: shape.delegate
		status: 'remove'
		propsToTween: [
			propName: 'r'
			startValue: model.r
			endValue: 0
			duration: 300
			delegate: shape.delegate
		]