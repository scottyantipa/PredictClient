###
The model for a prediction event (our primary record)
###
PredictionEventModel = require './predictionEventModel'

module.exports = class PredictionEventModel
	@whitelist: [
		'date', # js date obj
		'probability', # scale 0 to 1
		'title' # string
		'key' # string
	]
	
	# init all the values with the config, or null them
	constructor: (propertyMap) ->
		for property in PredictionEventModel.whitelist
			@[property] = propertyMap[property] or null