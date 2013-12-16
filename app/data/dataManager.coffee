###
Responsible for creating/getting/storing data
###

module.exports = class DataManager
	state:
		results: []
		query: {}
	
	constructor: ->
		@state.results = @createFakeData()

	# Create fake predictions from random data
	createFakeData: (random = true, numEvents = 20, startKey = 0) ->
		for i in [1..numEvents]
			if random
				date: @dateForPrediction(true, numEvents)
				probability: Math.random() * 100
				hot: Math.random() * 100
				key: i + startKey

			else
				date: @dateForPrediction(false, numEvents, i)
				probability: probabilityStep * i
				hot: probabilityStep * i
				key: i + startKey

	dateForPrediction: (random = true, numEvents, i) ->
		minDate = new Date 2011, 1, 1
		maxDate = new Date 2011, 3, 1
		epochDelta = maxDate.getTime() - minDate.getTime()
		epochStep = epochDelta / numEvents
		probabilityStep = 100 / numEvents
		if random
			epoch = minDate.getTime() + (epochDelta * Math.random())
			adjustment = Math.random() * epochDelta
			if Math.random() < .5
				epoch += adjustment
			else
				epoch -= adjustment
			new Date epoch
		else
			new Date minDate.getTime() + (numEvents - i) * epochStep

	addNewFakeData: ->
		numExistingEvents = @state.results.length
		newEvents = @createFakeData true, 20, numExistingEvents
		@state.results = @state.results.concat newEvents

	removeTopHalf: ->
		@state.results = _.filter @state.results, (result) ->
			result.probability < 50

	updateBottomHalf: ->
		results = @state.results
		for result in results
			continue if result.probability > 50
			result.probability = 100 * Math.random()
			result.hot = 100 * Math.random()
		@state.results = results

	# just for resting
	fetchAll: (callBack) ->
		callBack()

