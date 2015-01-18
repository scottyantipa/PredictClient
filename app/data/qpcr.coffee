DATA = require "./qpcr_example.json"
calibration_data = DATA.data.calibration_data[0]
plateread_data = DATA.data.plateread_data
amp_grouped_read_indices = DATA.data.amp_grouped_read_indices
melting = DATA.data.melting
postprocessed_data = DATA.data.postprocessed_data

# length of plateread_data is 101
# console.log "plateread_data length", plateread_data.length

# firstPlateRead = plateread_data[0]
# console.log "firstPlateRead.channelSeparatedData.length ", firstPlateRead.channelSeparatedData.length
# console.log "firstPlateRead.channelSeparatedData[6] ", firstPlateRead.channelSeparatedData[6]

# console.log "baseline_subtracted ", postprocessed_data.amp0.SYBR.baseline_subtracted_curve_fit.length
# console.log "baseline_subtracted[2].length ", postprocessed_data.amp0.SYBR.baseline_subtracted_curve_fit[2].length

console.log "baseline_subtracted[383].length", postprocessed_data.amp0.SYBR.baseline_subtracted[383].length

printAllKeys = (obj) ->
	if obj.constructor is Array
		console.log "Arra length #{obj.length}"
		for index, arrVal of obj
			printAllKeys arrVal
	else if typeof obj is "object"
		for objKey, objVal of obj
			console.log objKey
			printAllKeys objVal

# printAllKeys DATA