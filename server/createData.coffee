mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost:27017/predict'
db = mongoose.connection

db.on 'error', console.error.bind(console, 'connection error with mongoose')

db.once 'open', () ->
	predictionSchema = mongoose.Schema
		title: String
		author: String
		date: Date
		probability:
			type: Number
			min: 0
			max: 1
		hot:
			type: Number
			min: 0
			max: 1

	predictionSchema.methods.logInfo = () ->
		console.log "#{@title} predicted by #{@author} at epoch #{@date.getTime()}"

	Prediction = mongoose.model 'Prediction', predictionSchema
	
	# Create 100 fake predictions from random data
	minDate = new Date 2013, 1, 1
	maxDate = new Date 2020, 1, 1
	numEvents = 10
	epochDelta = maxDate.getTime() - minDate.getTime()
	for i in [1..numEvents]	
		prediction = new Prediction
			title: "Obama will be impeached"
			author: "Jon Doe"
			date: new Date minDate.getTime() + (epochDelta * Math.random())
			probability: Math.random()
			hot: Math.random()

		prediction.save (err, somePrediction) ->
			if err
			then console.log 'Failure saving somePrediction'
			else console.log 'Success saving somePrediction'

		prediction.logInfo()