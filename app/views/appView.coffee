###
Top level app view

TODO: A lot of the logic for setting up layers and canvases should
be abstracted so the dev-user doesnt have to insert canvas into Dom, etc.
###


DataManager = require '../data/dataManager'
ChromeView = require './chromeView'
TranscripticWidget = require '../canvas/widget/subclass/transcripticWidget'
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

		$chartContainer = @$('.visualization.container')
		{w, h} = @sizeForChart()
		@chartWidget = new TranscripticWidget
			$element: $chartContainer
			delegate: @
			
			model: new WidgetModel
				w: w
				h: h
				selectedWellKey: null
				didMouseOverLine: @didMouseOverLine
				
		
		@dataManager.fetchAll => 
			@onDataChange()

	render: ->
		@el.append @template
		@setBrowserEvents()

	onDataChange: ->
		@chartWidget.onDataChange()

	#
	# delegate methods
	#
	didMouseOverLine: (wellKey) =>
		@model.set "selectedWellKey", wellKey

	#
	# Backbone model
	#
	change_selectedWellKey: =>
		@chartWidget.model.selectedWellKey = @model.get "selectedWellKey"	
		@onDataChange()

	###
	Browser events
	###	
	setBrowserEvents: ->
		$(window).on "resize", @onResize

	onResize: =>
		_.extend @chartWidget.model, @sizeForChart()
		@chartWidget.render()

	###
	Delegate methods
	###
	state: ->
		@dataManager.state

	sizeForChart: ->
		w: $('body').width() #/ 2
		h: ($('.app').height() - $('.chrome').height()) #/ 2