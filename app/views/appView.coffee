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

		@dataManager = new DataManager

		@chartWidget = new ChartWidget
			$element: @$('.visualization.container')
			delegate: @
			model: new WidgetModel
				h: 500
				w: 1000
		
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