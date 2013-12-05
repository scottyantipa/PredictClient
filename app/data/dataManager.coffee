###
Responsible for creating/getting/storing data
###

module.exports = class DataManager
	state:
		results: []
		query: {}
	
	constructor: () ->
		@createFakeData()
	
	# Create fake predictions from random data
	createFakeData: ->
		minDate = new Date 2013, 1, 1
		maxDate = new Date 2020, 1, 1
		numEvents = 10
		epochDelta = maxDate.getTime() - minDate.getTime()

		@state.results = 
			for i in [1..numEvents]	
				title: "Obama will be impeached"
				author: "Jon Doe"
				date: new Date minDate.getTime() + (epochDelta * Math.random())
				probability: Math.random()
				hot: Math.random()

	# just for resting
	fetchAll: (callBack) ->
		callBack()

