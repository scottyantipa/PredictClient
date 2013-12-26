###
Top level app view
###
DataManager = require '../data/dataManager'
ChromeView = require './chromeView'
ChartWidget = require '../canvas/widget/subclass/chartWidget'
WidgetModel = require '../canvas/widget/widgetModel'
template = require './templates/appView'

module.exports = class AppView extends Backbone.View
	template: template
	appTitle: "Predict"

	initialize: ({@el}) ->
		@render()

		chromeModel = new Backbone.Model
		chromeModel.set 'title', @appTitle
		@chromeView = new ChromeView
			el: $('.chrome')
			model: chromeModel
		@chromeView.delegate = @

		@dataManager = new DataManager

		$chartContainer = @$('.visualization.container')
		{w, h} = @sizeForChart()
		@chartWidget = new ChartWidget
			$element: $chartContainer
			delegate: @
			model: new WidgetModel
				w: w
				h: h
		
		@dataManager.fetchAll => 
			@onDataChange()

	render: ->
		@el.append @template

	onDataChange: ->
		@chartWidget.onDataChange()

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