CanvasLog = require '../util/log'

requestAnimationFrame =
	window.requestAnimationFrame or
	window.webkitRequestAnimationFrame or
	window.mozRequestAnimationFrame or
	window.oRequestAnimationFrame or
	window.msRequestAnimationFrame or
	(callback, element) ->
		currTime = new Date().getTime()
		timeToCall = Math.max(0, 1000/60 - (currTime - animLastTime))
		id = window.setTimeout(->
			callback currTime + timeToCall
		, timeToCall)
		animLastTime = currTime + timeToCall
		id

module.exports = class Tweener
	STANDARD_DURATION: 1000
	STANDARD_TWEEN_FCT: 'sine'

	constructor: (@afterTweenFct) ->
		@keyCounter = 0 # keys for tweens
		@registeredTweens = [] # just make sure its at least an array
		@tweenRateFct = @tweenFunctions['sine']
		@processFrame() # kick it off immediately (may want to provide a start() method instead)
		

	# Each tween in @registeredTweens can change one or man properties of the given object
	# The tween may have a duration, startTime, etc. and the individual tweens within it can override those
	# properties.  For example, you may want to tween the color, radius, and xPos of a circle, where the duration is
	# 500ms for all three properties, but the radius tween you want to override to 200ms.
	processFrame: =>
		now = new Date().getTime()
		for tween in @registeredTweens
			{objToTween, propsToTween, startTime} = tween
			continue if startTime > now

			# Itereate through each property to tween.  
			# Note that each property to tween can override the properties of the group of tweens it is in
			# e.g. duration, startTime, tweenFct, etc.
			for propertyTween, index in propsToTween
				{propName, startValue, endValue, completed, duration} = propertyTween
				continue if startValue is endValue or completed
				
				# override the props of the group
				startTime = propertyTween.startTime or startTime
				tweenFct = propertyTween.tweenFct or @tweenFunctions[@STANDARD_TWEEN_FCT]
				
				# calculate where we are in percent complete of the tween (between 0 and 1)
				x = (now - startTime) / duration
				if x > 1 then x = 1 # to be safe
				if x < 0 then x = 0
				if x is 1
					propertyTween.completed = true
					continue
				x = tweenFct x

				# now do the actual tweening
				if propName is "color" or propName is "text"
					continue if x < .5
					newValue = endValue 
				else # regular int values
					newValue = @valueForX x, startValue, endValue
				objToTween[propName] = newValue

			# Mark tween as completed=true if all its propertyTweens are done for that batch
			completed = _.filter propsToTween, (propertyTween) -> 
				propertyTween.completed
			tween.completed = propsToTween.length is completed.length

			# This obj could be a shape, a group, a layer
			# So set the flag that it needs to be redrawn (whatever that means)
			objToTween.needsRedraw = true

		# alert tween delegates when tween has finished (like group gets notified if shape is done tweening)
		# and filter down list of tweens to just the incomplete ones
		@registeredTweens = _.filter @registeredTweens, (tween) ->
			if tween.completed then tween.delegate.didFinishTween tween
			not tween.completed

		@afterTweenFct() # e.g. for a widget this runs draw() on the canvases
				
		requestAnimationFrame @processFrame # recurse

	valueForX: (x, start, end) ->
		start + (end - start) * x

	colorForX: (x, startRGB, endRGB) ->
		colors.rgbToHex Math.round(@tweenValue x, startRGB.r, endRGB.r), Math.round(@tweenValue x, startRGB.g, endRGB.g), Math.round(@tweenValue x, startRGB.b, endRGB.b)


	###
	Standard tween (multiple props from A to B) must look like:
	
		objToTween: some_model
		duration: ms (duration specified within a specific tween will override this)
		startTime: epoch
		delegate: guy_that_handles_completion_callback
		status: 'add' or 'remove' or 'update'
		propsToTween: [
			propName: 'name'
			startValue: val
			endValue: val
			duration: int
			tweenFct: 'sine' or 'sproing' etc.
			,
			propName: 'name'
			.
			.
			.
		]
		
	###
	registerObjectToTween: (tween) =>
		tween.tweenKey ?= "tweenKey:#{@keyCounter++}"
		tween.duration ?= @STANDARD_DURATION
		# Make sure each property tween has a duration
		for propertyTween in tween.propsToTween
			propertyTween.duration ?= tween.duration
		tween.startTime ?= new Date().getTime()
		@registeredTweens.push tween

# ---------------------------------
# Utils 
# ---------------------------------
		

	tweenFunctions:
		linear: (v) -> v
		set: (v) -> Math.floor v
		discrete: (v) -> Math.floor v
		sine: (v) -> 0.5 - 0.5 * Math.cos(v * Math.PI)
		fullsine: (v) -> Math.sin v * Math.PI
		sproing: (v) -> (0.5 - 0.5 * Math.cos(v * 3.59261946538606)) * 1.05263157894737
		square: (v) -> v * v
		cube: (v) -> v * v * v
		sqrt: (v) -> Math.sqrt v
		curt: (v) -> Math.pow v, -0.333333333333
