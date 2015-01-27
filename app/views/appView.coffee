###
Top level app view

TODO: A lot of the logic for setting up layers and canvases should
be abstracted so the dev-user doesnt have to insert canvas into Dom, etc.
###

DataManager = require '../data/dataManager'
ChromeView = require './chromeView'
TranscripticWidget = require '../canvas/widget/subclass/transcripticWidget'
PlateWidget = require '../canvas/widget/subclass/plateWidget'	
WidgetModel = require '../canvas/widget/widgetModel'
template = require './templates/appView'
Koolaid = require '../canvas/koolaid'

module.exports = class AppView extends Backbone.View
	template: template
	appTitle: "Transcriptic"

	initialize: ({@el}) ->
		@renderDOM()

		chromeModel = new Backbone.Model
		chromeModel.set 'title', @appTitle
		@chromeView = new ChromeView
			el: $('.chrome')
			model: chromeModel
		@chromeView.delegate = @

		@dataManager = new DataManager

		@model.on "change:selectedWellKey", @change_selectedWellKey
		
		# TranscripicWidget
		$lineChartContainer = @$('.visualization.container.lines')
		@lineChartWidget = new TranscripticWidget
			$element: $lineChartContainer
			delegate: @
			model: new WidgetModel {}
				
		# Plate Widget
		$plateChartContainer = @$('.visualization.container.plate')
		@plateChartWidget = new PlateWidget
			$element: $plateChartContainer
			delegate: @
			model: new WidgetModel {}
		
		@dataManager.fetchAll => 
			@onDataChange()

	renderDOM: ->
		@el.append @template
		@setBrowserEvents()
		
	render: ->
		lineSize = @sizeForLineChart()
		[wLine, hLine, txLine, tyLine] = [lineSize.w, lineSize.h, lineSize.tx, lineSize.ty]
		
		plateSize = @sizeForPlateChart()
		[wPlate, hPlate, txPlate, tyPlate] = [plateSize.w, plateSize.h, plateSize.tx, plateSize.ty]

		[numRows, numColumns] = [@dataManager.NUM_ROWS, @dataManager.NUM_COLUMNS]
		selectedWellKey = @model.get "selectedWellKey"
		Koolaid.renderChildren [
			[
				@lineChartWidget
				{
					w: wLine
					h: hLine
					tx: txLine
					ty: tyLine
					numRows
					numColumns
					selectedWellKey
					didMouseOverLine: @didMouseOverLine
				}
			]

			[
				@plateChartWidget
				{
					w: wPlate
					h: hPlate
					tx: txPlate
					ty: tyPlate
					numRows
					numColumns
					selectedWellKey
					didMouseOverWell: @didMouseOverWell
				}
			]
		]


	onDataChange: ->
		@render()

	#
	# delegate methods
	#
	didMouseOverLine: (wellKey) =>
		@model.set "selectedWellKey", wellKey

	didMouseOverWell: (wellKey) =>
		@model.set "selectedWellKey", wellKey

	#
	# Backbone model
	#
	change_selectedWellKey: =>
		@render()

	###
	Browser events
	###	
	setBrowserEvents: ->
		$(window).on "resize", _.debounce @onResize, 300

	onResize: =>
		@render()

	###
	Delegate methods
	###
	state: ->
		@dataManager.state

	sizeForLineChart: ->
		w: $('body').width()
		h: $('.app').height() / 2 + 30
		tx: 0
		ty: 0

	sizeForPlateChart: ->
		h = $('.app').height() / 2
		w: $('body').width()
		h: h
		tx: 0
		ty: h