fs = require 'fs'

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
	# break if numWellsCreated >= 10
	for column in [1..NUM_COLUMNS]
		# break if numWellsCreated >= 10
		wellKey = "row#{COLON}#{row}#{KEY_SEPARATOR}column#{COLON}#{column}"
		logFunc = (x) ->
			x = x - (25 + [1..16][Math.floor(Math.random() * 16)])
			MAX_FLUOR / (1 + .5 * Math.pow(Math.E, -.5 * x))
		
		resultsByWellKey[wellKey] =
			
			for cycleNum in [1..40]

				cycle: cycleNum
				fluorescense: (Math.floor logFunc(cycleNum) * 100) / 100
		numWellsCreated++

				



fs.writeFile './app/assets/data/qpcrGenData.json', JSON.stringify(resultsByWellKey)