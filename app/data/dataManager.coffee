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
	createFakeData: (random = true, numEvents = 20, startKey = 0, start, end) ->
		predictions = 
			for i in [1..numEvents]
				if random
					date: @dateForPrediction(true, numEvents, start, end)
					probability: Math.random() * 100
					hot: Math.random() * 100
					key: i + startKey

				else
					probabilityStep = 100 / numEvents

					date: @dateForPrediction(false, numEvents, i, start, end)
					probability: probabilityStep * i
					hot: probabilityStep * i
					key: i + startKey

		@createConnections predictions
		predictions

	# Create the connections between predictions so
	# we can draw lines between them
	createConnections: (predictions) ->
		numPredictions = predictions.length - 1
		for prediction, index in predictions
			continue if index % 2 is 0 # just do it for half of them
			connection = predictions[Math.floor(Math.random() * numPredictions)] # grab a random one
			if not connection
				console.warn 'no connection'
			prediction.connections = [connection.key]

	dateForPrediction: (random = true, numEvents, i, start, end) ->
		minDate = if start then start else new Date 2011, 1, 1
		maxDate = if end then end else new Date 2011, 3, 1
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
		newPredictions = @createFakeData true, 20, numExistingEvents
		prediction.connections = null for prediction in newPredictions
		@createConnections newPredictions
		@state.results = @state.results.concat newPredictions

	removeTopHalf: ->
		newPredictions = _.filter @state.results, (result) ->
			result.probability < 50
		prediction.connections = null for prediction in newPredictions
		@createConnections newPredictions
		@state.results = newPredictions

	updateBottomHalf: ->
		results = @state.results
		for result in results
			continue if result.probability > 50
			result.probability = 100 * Math.random()
			result.hot = 100 * Math.random()
		@state.results = results

	createStandardOneYear: ->
		@state.results = @createFakeData false, 20, 0, new Date(2011, 0, 1), new Date(2012, 0, 1)

	createStandardYearAndHalf: ->
		@state.results = @createFakeData false, 20, 0, new Date(2011, 0, 1), new Date(2012, 7, 1)

	# just for resting
	fetchAll: (callBack) ->
		callBack()

