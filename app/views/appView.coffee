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

module.exports = class AppView extends Backbone.View
	template: template
	appTitle: "Transcriptic"

	initialize: ({@el}) ->
		@render()
		@onResize = _.debounce @onResize, 500

		chromeModel = new Backbone.Model
		chromeModel.set 'title', @appTitle
		@chromeView = new ChromeView
			el: $('.chrome')
			model: chromeModel
		@chromeView.delegate = @

		@dataManager = new DataManager

		@model.on "change:selectedWellKey", @change_selectedWellKey
		[numRows, numColumns] = [@dataManager.NUM_ROWS, @dataManager.NUM_COLUMNS]
		# TranscripicWidget
		$lineChartContainer = @$('.visualization.container.lines')
		{w, h, tx, ty} = @sizeForLineChart()
		@lineChartWidget = new TranscripticWidget
			$element: $lineChartContainer
			delegate: @
			model: new WidgetModel {
				w
				h
				tx
				ty
				numRows
				numColumns
				selectedWellKey: null
				didMouseOverLine: @didMouseOverLine
			}
				
		# Plate Widget
		$plateChartContainer = @$('.visualization.container.plate')
		{w, h, tx, ty} = @sizeForPlateChart()
		@plateChartWidget = new PlateWidget
			$element: $plateChartContainer
			delegate: @
			model: new WidgetModel {
				w
				h
				tx
				ty
				numRows
				numColumns
				selectedWellKey: null
				didMouseOverWell: @didMouseOverWell
			}
		
		@dataManager.fetchAll => 
			@onDataChange()

	render: ->
		@el.append @template
		@setBrowserEvents()

	onDataChange: ->
		@lineChartWidget.onDataChange()
		@plateChartWidget.onDataChange()

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
		selected = @model.get "selectedWellKey"
		@lineChartWidget.model.selectedWellKey = selected
		@plateChartWidget.model.selectedWellKey = selected 
		@onDataChange()

	###
	Browser events
	###	
	setBrowserEvents: ->
		$(window).on "resize", @onResize

	onResize: =>
		_.extend @lineChartWidget.model, @sizeForLineChart()
		_.extend @plateChartWidget.model, @sizeForPlateChart()
		@lineChartWidget.render()

		@plateChartWidget.$element.attr 'top', ($('body').height() / 2)
		@plateChartWidget.render()

	###
	Delegate methods
	###
	state: ->
		@dataManager.state

	sizeForLineChart: ->
		w: $('body').width()
		h: $('.app').height() / 2
		tx: 0
		ty: 0

	sizeForPlateChart: ->
		h = $('.app').height() / 2
		w: $('body').width()
		h: h
		tx: 0
		ty: h