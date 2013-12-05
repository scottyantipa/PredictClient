Shape = require '../shape'

module.exports = class Circle extends Shape
	
	constructor: ({@model}) ->
		super
		console.log 'creating a circle!'