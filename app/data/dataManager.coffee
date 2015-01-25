###
Responsible for creating/getting/storing data
###

module.exports = class DataManager
	KEY_SEPARATOR: "|"
	COLON: ":" # used in key formatting
	NUM_COLUMNS: 24
	NUM_ROWS: 16
	state:
		results: []

	# just for resting
	fetchAll: (callBack) ->
		$.ajax
			type: "GET"
			url: "./data/qpcrGenData.json"
			success: (results) =>
				@parseResults results
				callBack()
			error: (results) ->
				console.warn "error loading qpcr data: ", results

	parseResults: (resultsByWell) ->

		@state.results =
			groups: [

					name: "cycle"
					domain: [1..40]
				,
				
					name: "well"
					domain: [1..384]
				
			]

			projections: [
				name: "fluorescense"
				domain: [0, 5000]
			]

			resultsByWell: resultsByWell


		# Commented out code here is for if i'm taking the data from transcriptic source
		###
		plateread_data = results.data.plateread_data
		resultsByWell = {}
		minFluor = 0
		maxFluor = 0
		for {channelSeparatedData}, cycle in plateread_data
			break if cycle is 40
			# for right now i'm only looking at the first of the 6 arrays
			allWellDataPoints = channelSeparatedData[0]
			
			for row in [1..@NUM_ROWS]
				for column in [1..@NUM_COLUMNS]
					wellKey = @keyForWell row, column
					wellResults = resultsByWell[wellKey] ?= [] # if this is the first data point for this well, we need to create the array
					fluorescense = allWellDataPoints[@wellFlatIndex(row, column) - 1] # row/columns start at 1, so remove 1
					# fluorescense = Math.pow fluorescense, 2
					if minFluor > fluorescense
						minFluor = fluorescense
					if maxFluor < fluorescense
						maxFluor = fluorescense
					wellResults.push {cycle, fluorescense}
		###
	keyForWell: (row, column) ->
		"row#{@COLON}#{row}#{@KEY_SEPARATOR}column#{@COLON}#{column}"

	wellFromKey: (wellKey) ->
		getNum = (str) => parseInt str.split(@COLON)[1]
		[rowStr, columnStr] = wellKey.split @KEY_SEPARATOR
		
		row: getNum rowStr
		column: getNum columnStr

	# returns a number between 1 and the total number of wells
	wellFlatIndex: (row, column) ->
		(row - 1) * @NUM_COLUMNS + column
