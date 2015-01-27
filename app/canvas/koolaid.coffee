# Placeholder framework name
# This is also a module for globally needed methods throughout the framework

module.exports = class Koolaid


	@renderChildren: (childrenAndUpdates) ->
		for [child, updates] in childrenAndUpdates
			if not _.isEqual updates, child.model
				child.previousModel = $.extend {}, child.model
				child.model = $.extend {}, updates # dont want multiple people sharing same object
				child.render()
