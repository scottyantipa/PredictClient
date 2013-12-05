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
			model: new WidgetModel
			$element: @$('.visualization.container')
			delegate: @
		
		@dataManager.fetchAll => @onDataChange()

	render: ->
		@el.append @template

	# delegate to chart widget
	onDataChange: ->
		@chartWidget.onDataChange

###
Delegate methods
###

	state: ->
		@dataManager.state