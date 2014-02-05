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

	constructor: (@afterTweenFct, tweenFct = 'sine') ->
		@keyCounter = 0
		@registeredTweens = [] # just make sure its at least an array
		@processFrame() # kick it off immediately (may want to provide a start() method instead)
		@tweenRateFct = @tweenFunctions[tweenFct]

	# Check if there are shapes to tween, then tween them
	processFrame: =>
		now = (new Date()).getTime()
		for tween in @registeredTweens
			if not tween.startTime then tween.startTime = now
			x = (now - tween.startTime) / tween.duration
			if x > 1 then x = 1 # to be safe
			if x < 0 then x = 0
			if x is 1
				tween.remove = true
				tween.fps = tween.numTimesTweens / tween.duration * 1000
				if CanvasLog.fps then console.log 'fps: ', tween.fps 
				continue
			x = @tweenRateFct x

			if tween.custom
				console.warn 'no custom objs in tweener yet'
			else
				{objToTween, propsToTween, startTime, duration} = tween
				for property, [startValue, endValue] of propsToTween
					continue if startValue is endValue
					if property is "color" or property is "text"
						newValue = endValue
					else # regular int values
						newValue = @valueForX x, startValue, endValue
					objToTween[property] = newValue

				# This obj could be a shape, a group, a layer
				# So set the flag that it needs to be redrawn (whatever that means)
				objToTween.needsRedraw = true

		# alert tween delegates when tween has finished (like group gets notified if shape is done tweening)
		for tween in @registeredTweens
			if tween.remove then tween.delegate.didFinishTween(tween)

		# filter down list of tweens to just the incomplete ones
		@registeredTweens = _.filter @registeredTweens, (tween) ->
			not tween.remove

		@afterTweenFct() # for a widget, this runs draw() on the canvases

		if CanvasLog.fps
			tween.numTimesTweens++ for tween in @registeredTweens
				

		requestAnimationFrame @processFrame

	valueForX: (x, start, end) ->
		start + (end - start) * x

	colorForX: (x, startRGB, endRGB) ->
		colors.rgbToHex Math.round(@tweenValue x, startRGB.r, endRGB.r), Math.round(@tweenValue x, startRGB.g, endRGB.g), Math.round(@tweenValue x, startRGB.b, endRGB.b)


	###
	Should look like
		objToTween: some_model
		custom:
			args: {} (e.g. {model, prop1, prop2,...})
			fct: () ->
		duration: ms
	or
		objToTween: some_model
		propsToTween:
			prop1: [startVal, endVal]
			prop2: [startVal, endVal]
			etc
		duration: ms
	###
	registerObjectToTween: (object) =>
		object.duration ?= @STANDARD_DURATION
		object.numTimesTweens ?= 0 # for testing fps
		object.objToTween.tweenKey ?= @keyForNewObjToTween()
		@registeredTweens.push object

# ---------------------------------
# Utils 
# ---------------------------------
	# We put a key on the object thats being tweened (like the model of a shape)
	# So that if the shape gets registered/unregistered later we will know
	keyForNewObjToTween: ->
		"tweenKey||#{@keyCounter++}"

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
