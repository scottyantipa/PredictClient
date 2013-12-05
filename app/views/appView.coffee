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

		@chartWidget = new ChartWidget
			model: new WidgetModel
			$element: @$('.visualization.container')
		
		@dataManager = new DataManager
		@dataManager.fetchAll => @onDataChange()

	render: ->
		@el.append @template

	# delegate to chart widget
	onDataChange: ->
		@chartWidget.onDataChange @dataManager.state
