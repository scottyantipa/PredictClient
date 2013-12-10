###
Responsible for creating/getting/storing data
###

module.exports = class DataManager
	state:
		results: []
		query: {}
	
	constructor: () ->
		@createFakeData true
	
	# Create fake predictions from random data
	createFakeData: (random = false) ->
		minDate = new Date 2013, 1, 1
		maxDate = new Date 2020, 1, 1
		numEvents = 20
		epochDelta = maxDate.getTime() - minDate.getTime()
		epochStep = epochDelta / numEvents
		probabilityStep = 100 / numEvents
		title = "Some event name here"

		@state.results = 
			for i in [1..numEvents]
				if random
					date: new Date minDate.getTime() + (epochDelta * Math.random())
					probability: Math.random() * 100
					title: title
					key: i

				else
					date: new Date minDate.getTime() + (numEvents - i) * epochStep
					probability: probabilityStep * i
					title: title
					key: i

	# just for resting
	fetchAll: (callBack) ->
		callBack()

