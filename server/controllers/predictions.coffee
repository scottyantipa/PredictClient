mongoose = require 'mongoose'
Prediction = mongoose.model 'Prediction'

# all should return all the fake data 
exports.all = (req, res) ->
	Prediction.find {}, (err, predictions) ->
		map = {}
		predictions.forEach (prediction) ->
			map[prediction._id] = prediction
		res.send map 
