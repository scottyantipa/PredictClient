AppView = require 'views/appView'
$ ->
	window.app = new AppView
		el: $('body')
		model: new Backbone.Model
