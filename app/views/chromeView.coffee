module.exports = class ChromeView extends Backbone.View
	template: require './templates/chrome'

	initialize: ->
		@render()
		@setupEvents()

	render: ->
		@$el.html @template(@model.attributes)

	setupEvents: ->
		@$('.options :nth-child(1)').click((e) =>
			@delegate.onClickAdd(e)
		)
		
		@$('.options :nth-child(2)').click((e) =>
			@delegate.onClickRemove(e)
		)

		@$('.options :nth-child(3)').click((e) =>
			@delegate.onClickUpdate(e)
		)

		@$('.options :nth-child(4)').click((e) =>
			@delegate.onClickOneYear(e)
		)

		@$('.options :nth-child(5)').click((e) =>
			@delegate.onClickYearAndHalf(e)
		)
