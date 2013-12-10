###
Model that will be extended for all canvas view objects
e.g. widget, layer, group, shape
###

module.exports = class BaseCanvasModel
	hidden: false # show or not show the view
	key: -1

	constructor: (propertyMap) ->
		for property of propertyMap
			@[property] = propertyMap[property]