Shape = require '../shape'

module.exports = class Text extends Shape

	draw: (ctx) ->
		super ctx
		{fontSize, text, x, y} = @model
		ctx.font = "#{fontSize}px 'Helvetica Neue', Helvetica, Arial, sans-serif" if fontSize isnt 12
		ctx.fillText text, Math.round(x), Math.round(y)
