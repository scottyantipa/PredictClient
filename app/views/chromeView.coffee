module.exports = class ChromeView extends Backbone.View
	template: require './templates/chrome'

	constructor: (@$el, @title) ->
		@model = new Backbone.Model
		@model.set 'title', @title
		@render()

	render: ->
		@$el.html @template({appTitle: @model.get('title')})