module.exports = class AppView extends Backbone.View
	template: require './templates/app'
	appTitle: "Predict"
	
	constructor: () ->
		@$el = $('body')
		@render()

		ChromeView = require('./chromeView')
		chromeView = new ChromeView @$('.chrome'), @appTitle


	render: ->
		@$el.append @template