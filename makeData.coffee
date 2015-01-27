fs = require 'fs'
DataManager = require './app/data/dataManager'

# NOTE THAT THESE CONSTANTS ARE REUSED 
# IN dataManager and should be abstracted elsewhere
KEY_SEPARATOR = "|"
COLON = ":" # used in key formatting
NUM_COLUMNS = 24
NUM_ROWS = 16
NUM_CYCLES = 40
MAX_FLUOR = 5000
MIN_FLUOR = 0

resultsByWellKey = {}

numWellsCreated = 0
for row in [1..NUM_ROWS]
	# break if numWellsCreated >= 1
	for column in [1..NUM_COLUMNS]
		# break if numWellsCreated >= 1
		logFnc = (x) ->
			5000 / (1 + Math.pow(Math.E, -(x - ((20 * row) * column) / 100)))

		
		wellKey = DataManager.keyForWell row, column

		numWellsCreated++

		resultsByWellKey[wellKey] ?= []
		i = 1
		while i <= 40
			resultsByWellKey[wellKey].push
				cycle: i
				fluorescense: Math.floor (logFnc(i) * 100) / 100
			i++

fs.writeFile './app/assets/data/qpcrGenData.json', JSON.stringify(resultsByWellKey)
