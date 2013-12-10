WidgetModel = require '../widgetModel'

module.exports = class ChartWidgetModel extends WidgetModel
	events: [] # array of PredictionEventModel from engine
	timeScale: null # LinearScale for time axis