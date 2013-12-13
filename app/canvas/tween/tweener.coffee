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
	STANDARD_DURATION: 500

	constructor: (@afterTweenFct) ->
		@registeredTweens = []
		@processFrame() # kick it off
		@tweenRateFct = @tweenFunctions.sine

	# Check if there are shapes to tween, then tween them
	processFrame: =>
		if @registeredTweens?.length > 0
			now = (new Date()).getTime()
			for tween in @registeredTweens
				if not tween.startTime then tween.startTime = now
				
				x = (now - tween.startTime) / tween.duration
				if x > 1 then x = 1 # to be safe
				if x < 0 then x = 0
				if x is 1
					tween.Remove = true
					continue
				x = @tweenRateFct x

				if tween.custom
					console.warn 'no custom objs in tweener yet'
				else
					{objToTween, propsToTween, startTime, duration} = tween
					for property, [startValue, endValue] of propsToTween
						if property is "color"
							console.warn 'no color tweening yet for objToTween: ', objToTween
						if property is "text"
							console.warn 'no text tweening yet for objToTween: ', objToTween
						else # regular int values
							newValue = @valueForX x, startValue, endValue
						objToTween[property] = newValue

					# This obj could be a shape, a group, a layer
					# So set the flag that it needs to be redrawn (whatever that means)
					objToTween.needsRedraw = true

			# remove the finished tweens
			for tween in @registeredTweens
				if tween.Remove then tween.delegate.didFinishTween(tween)

			@registeredTweens = _.filter @registeredTweens, (tween) ->
				not tween.Remove

			@afterTweenFct()
			
		requestAnimationFrame @processFrame

	valueForX: (x, start, end) ->
		start + (end - start) * x

	colorForX: (x, startRGB, endRGB) ->
		colors.rgbToHex Math.round(@tweenValue x, startRGB.r, endRGB.r), Math.round(@tweenValue x, startRGB.g, endRGB.g), Math.round(@tweenValue x, startRGB.b, endRGB.b)


	###
	Should look like
		custom:
			args: {}
			fct: () ->
		duration: ms
	or
		objToTween: shapeObject
		propsToTween:
			prop1: [startVal, endVal]
			prop2: [startVal, endVal]
			etc
		duration: ms
	###
	registerObjectToTween: (object) =>
		object.duration ?= @STANDARD_DURATION
		@registeredTweens.push object

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
