###
Top level app object
###
module.exports = class AppView extends Backbone.View
	template: require './templates/app'
	appTitle: "Predict"
	
	initialize: ({@el}) ->
		@render()

		DataManager = require '../data/dataManager'
		@dataManager = new DataManager

		# setup chrome
		chromeModel = new Backbone.Model
		chromeModel.set 'title', @appTitle
		ChromeView = require('./chromeView')
		chromeView = new ChromeView
			el: $('.chrome')
			model: chromeModel

	render: ->
		@el.append @template