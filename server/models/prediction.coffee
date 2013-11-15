mongoose = require 'mongoose'
Schema = mongoose.Schema

PredictionSchema = mongoose.Schema
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

mongoose.model 'Prediction', PredictionSchema