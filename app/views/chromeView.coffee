module.exports = class ChromeView extends Backbone.View
	template: require './templates/chrome'

	initialize: ->
		@render()
		@setupEvents()

	render: ->
		@$el.html @template(@model.attributes)

	setupEvents: ->
		@$add = @$('.options :nth-child(1)').click((e) =>
			@delegate.onClickAdd(e)
		)
		
		@$remove = @$('.options :nth-child(2)').click((e) =>
			@delegate.onClickRemove(e)
		)

		@$update = @$('.options :nth-child(3)').click((e) =>
			@delegate.onClickUpdate(e)
		)