# A simple 1 to 1 scale
# x is the domain, y is the range
module.exports = class LinearScale
	domain: []
	range: []

	constructor: ({domain, range}) ->
		@domain domain
		@range range

	# x -> y
	map: (x) ->
		xRatio = (@_dx / (@domain[1] - x))
		@range[0] + @_dy * xRatio

	# y -> x
	invert: (y) ->
		yRatio = (@_dy / (@range[1] - y))
		@domain[0] + @_dx * yRatio

# Chained setters
	domain: (@domain) ->
		@_dx = @domain[1] - @domain[0]
		@

	range: (@range) ->
		@_dy = @range[1] - @range[0]
		@