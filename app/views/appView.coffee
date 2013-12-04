###
Top level app view
###

ChromeView = require './chromeView'
Widget = require '../canvas/widget/widget'
WidgetModel = require '../canvas/widget/widgetModel'

module.exports = class AppView extends Backbone.View
	template: require './templates/appView'
	appTitle: "Predict"
	
	initialize: ({@el}) ->
		@render()

		DataManager = require '../data/dataManager'
		@dataManager = new DataManager

		# setup chrome
		chromeModel = new Backbone.Model
		chromeModel.set 'title', @appTitle
		chromeView = new ChromeView
			el: $('.chrome')
			model: chromeModel

		# setup widget
		widgetModel = new WidgetModel
		widget = new Widget
			model: widgetModel
			
	render: ->
		@el.append @template