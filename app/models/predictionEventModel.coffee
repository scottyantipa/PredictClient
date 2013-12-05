###
The model for a prediction event (our primary record)
###

module.exports class PredictionEventModel
	@whitelist: [
		'date', # js date obj
		'probability', # scale 0 to 1
		'title' # string
	]
	
	# init all the values with the config, or null them
	contstructor: (propertyMap) ->
		for property in @whitelist
			@[property] = propertyMap[property] or null