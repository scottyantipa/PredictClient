###
A scale object whos domain can be mapped to a subset of
the natural numbers (e.g. an ordered list)
###

LinearScale = require './linearScale'

module.exports = class OrdinalScale extends LinearScale
	domain: [] # an ordered set like ["A", "B", "C"...]
	range: []

	# Used to compare to values in scale domain
	# override this in implementation if necessary
	aIsGreater: (a, b) -> a > b 

	computeDX: ->
		@dx = @domain.length

	map: (x) ->
		@k * @positionInDomain(x) + @b

	# Different from index in that position can be negative
	# if the x value passed is not in @domain and is less than all values
	positionInDomain: (x) ->
		index = @domain.indexOf x
		if index isnt -1
			index
		else
			if @aIsGreater x, _.last(@domain)
				@domain.length
			else if @aIsGreater @domain[0], x
				-1
	yValueAtZero: ->
		@range[0]

	ticks: (minGapInRange) ->
		@domain