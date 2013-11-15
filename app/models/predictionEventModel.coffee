###
The model for a prediction event (our primary record)
For example, the record for the prediction "The A's will win the world series"
###

module.exports class PredictionEventModel
	whitelist: [
		'time', # epoch
		'probability', # scale 0 to 100, float values
		'popularity', # measure of user activity around that event (predictions, comments, etc.)
		'category' # "sports", "economics", etc.
	]

	contstructor: (propertyMap) ->
		# init all the values with the config, or null them
		for property in @whitelist
			@[property] = propertyMap[property] or null