# A simple 1 to 1 scale
# x is the domain, y is the range

# NOTE: only working for positive values
module.exports = class LinearScale
	domain: []
	range: []
	dx: 1 # change in domain
	dy: 1 # change in 
	
	# y = kx + b
	k: null 
	b: null

	constructor: ({domain, range}) ->
		@domain domain
		@range range
		@k =  @dy / @dx
		@b = @yValueAtZero 0

	map: (x) ->
		@k * x + @b

	invert: (y) ->
		(y - @b) / @k

	# x -> y
	yValueAtZero: (x) ->
		x = x - @domain[0]
		if x is 0
			@range[0]
		else
			xRatio = (x/ @dx)
			@range[0] + (@dy * xRatio)

# Chained setters
	domain: (@domain) ->
		@dx = Math.abs(@domain[1] - @domain[0])
		@

	range: (@range) ->
		@dy = Math.abs(@range[1] - @range[0])
		@