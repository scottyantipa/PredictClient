###
Top level app view
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

		$chartContainer = @$('.visualization.container')
		{w, h} = @sizeForChart()
		@chartWidget = new TranscripticWidget
			$element: $chartContainer
			delegate: @
			model: new WidgetModel
				w: w
				h: h
		
		@dataManager.fetchAll => 
			@onDataChange()

	render: ->
		@el.append @template
		@setBrowserEvents()

	onDataChange: ->
		@chartWidget.onDataChange()

	###
	Browser events
	###	
	setBrowserEvents: ->
		$(window).on "resize", @onResize

	onResize: =>
		_.extend @chartWidget.model, @sizeForChart()
		@chartWidget.updateModel()

	###
	Delegate methods
	###
	state: ->
		@dataManager.state

	onClickAdd: (e) ->
		@dataManager.addNewFakeData()
		@onDataChange()

	onClickRemove: (e) ->
		@dataManager.removeTopHalf()
		@onDataChange()

	onClickUpdate: (e) ->
		@dataManager.updateBottomHalf()
		@onDataChange()
	
	onClickOneYear: (e) ->
		@dataManager.createStandardOneYear()
		@onDataChange()

	onClickYearAndHalf: (e) ->
		@dataManager.createStandardYearAndHalf()
		@onDataChange()

	sizeForChart: ->
		w: $('body').width()
		h: $('.app').height() - $('.chrome').height()