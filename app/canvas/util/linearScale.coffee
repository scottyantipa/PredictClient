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

	# This will return an array of domain values
	# which when mapped are all at least minGapInRange apart
	# This useful for rendering labels on an axis
	# TODO: right now it just finds a good multiple of 10, but
	# instead it should smartly find nice even values like 250, 500, 1000, ...
	ticks: (minGapInRange) ->
		multiplier = 0
		base = 10
		foundExp = false
		while not foundExp
			multiplier++
			currentDomainGap = base * multiplier
			foundExp = Math.abs(@map(currentDomainGap)) > minGapInRange

		# now we have the multiple of 10 which nicely divides the domain
		currentVal = @domain[0]
		ticks = [] # always return the first (it should be 0)
		stop = false
		while currentVal < @domain[1]
			ticks.push currentVal
			currentVal = currentVal + base*multiplier

		ticks



