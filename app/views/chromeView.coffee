module.exports = class ChromeView extends Backbone.View
	template: require './templates/chrome'

	initialize: ->
		@render()

	render: ->
		@$el.html @template(@model.attributes)