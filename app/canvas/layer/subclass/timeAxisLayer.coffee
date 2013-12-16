Layer = require '../layer'
GroupModel = require '../../group/groupModel'
Ticks = require '../../group/subclass/timeAxisTicksGroup'
Labels = require '../../group/subclass/timeAxisLabelsGroup'
DateUtils = require '../../../util/dateUtils'
	
module.exports = class TimeAxisLayer extends Layer
	DATE_STR_DIVIDER: "/"
	KEY_DIVIDER: "::"
	FIRST_LETTER_OF_EACH_DAY: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
	NUM_DAYS_EACH_MONTH: [31, null, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	PIXELS_BETWEEN_TICKS: 6 # minimal padding between every vert line in the time axis
	COLOR_TICK_LABEL: "#B8B7B6" # dark grey -- "#959391"
	COLOR_TICK_LABEL_SELECTED: "#B39F09" #ruby --"#A30339"# gold--"#C9C920" #light blue "#049BB3"
	COLOR_OUTERMOST_HASH: "#ABABAB" # the vertical hash lines on the time axis
	COLOR_MINOR_HASH: "#DEDDDC"
	FONT_LARGEST_TIME_AXIS: 14
	SMALLEST_HASH_MARK: 12 # shortest length of vert lines in time axis

	constructor: ({@$canvas, @model}) ->
		@ticksGroup = new Ticks
			model: new GroupModel
		@labelsGroup = new Labels
			model: new GroupModel

		@groups = [@ticksGroup, @labelsGroup]
		super

	# Calculate the labels and tick marks for the time axis
	# pass these models down to the groups
	updatesForChildren: ->
		{axisLabels, axisTicks} = @calcShapes()
		{tx, ty} = @calcGroupPositions()
		[
			[@labelsGroup, {axisLabels, tx, ty}]
			[@ticksGroup, {axisTicks, tx, ty}]
		]

	calcGroupPositions: ->
		{timeScale, w, h, pad, plotHeight, plotWidth} = @model
		{top, right, bottom, left} = pad
		tx = left
		ty = plotHeight + top
		w = plotWidth
		h = plotHeight
		{tx, ty}

	calcShapes: ->
		{w, h, tx, ty} = @calcGroupPositions()
		{timeScale, w, h, pad, plotHeight, plotWidth} = @model
		grainsToDraw = ["day" ,"month","year"] # static for now
		numRows = grainsToDraw.length
		axisLabels = [] # all the labels on the axis
		axisTicks = [] # all the vert lines on the axis

		# Calc basic rows of the axis (year, month, day rows)
		tickGroups = [] 
		for grain, row in grainsToDraw
			ticks = @allTicksOnAxisForGrain grain, timeScale
			row = row + 1 # so that the rows start at 1, rather than 0
			group = {ticks, grain, row, numRows}
			tickGroups.push group

		###
		Create the hash marks (the little vertical lines on the time axis).
		We will draw a hash mark for every tick, however, there will be overlap so we
		only draw one in this case.  For example, on January, 1, 2001, there are three (for year, month, and day)
		###
		
		# First, figure out if we even want to draw the hash marks for each of the grains
		# If not, move the rows up (i.e. if showing year-month-day but removing the days, move year and month up
		# a row)
		for tickGroup in tickGroups
			continue if @isOutermostGroup(tickGroup) # Have to draw hashes if its the only row
			if tickGroup.ticks.length > (timeScale.dy / @PIXELS_BETWEEN_TICKS)
				tickGroup.dontDrawHashes = true
				for otherTickGroup in tickGroups # change numRows and rows for remaining groups
					otherTickGroup.row--
					otherTickGroup.numRows--

		# @y is the total height of the time axis
		@y = @getY _.last(tickGroups).row

		for tickGroup in tickGroups
			{ticks, grain, row, numRows} = tickGroup
			for tick in ticks
				$.extend tick, {row, numRows, grain}
				tick.key = @formatKeyForTick tick

		hashByKey = {} # will eventually be added to axisLabels
		i = tickGroups.length
		while i > 0 
			tickGroup = tickGroups[i - 1]
			if tickGroup.dontDrawHashes or @isOutermostGroup(tickGroup) # outtermost handled separately
				i--
				continue 
			for tick, tickIndex in tickGroup.ticks
				@addHashMarkFromTick tick, hashByKey, timeScale, false
			i--

		###
		Figure out the truncationIndex for each group.  This is the level to which
		their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a 
		group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
		just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
		###
		for tickGroup in tickGroups
			{row, numRows, ticks} = tickGroup
			
			dontDrawGroup = =>
				tickGroup.dontDrawLabels = true

			maxWidth = timeScale.dy / ticks.length # max amt of possible space for each tick label
			truncateIndex = largestTruncation = 0 # the level to which we will abreviate each lable in group
			widthOfLargest = 0

			if maxWidth < 3 and not @isOutermostGroup(tickGroup) # cant draw a label in 2 pix
				dontDrawGroup()
				continue

			# Get the font size, then figure out the ratio
			# to the regular Canvas font size (because getLabelWidth uses standard font size)
			fontSize = @getFontSize row, numRows
			fontRatio = fontSize / 12 # standard size
			for tick, tickIndex in ticks
				if row is numRows # we never truncate the outermost row (which is "year") because we need to show something
					text = @formatTimeAxisLabel tick, 0
					textWidth = fontRatio * @ctx.measureText(text).width
				else
					text = @formatTimeAxisLabel tick, truncateIndex
					while (textWidth = fontRatio * @ctx.measureText(text).width) > (maxWidth * .7)
						truncateIndex++
						text = @formatTimeAxisLabel tick, truncateIndex
				if textWidth > widthOfLargest then widthOfLargest = textWidth
				if truncateIndex > largestTruncation then largestTruncation = truncateIndex

			# Remove tick group if they can't fit
			if widthOfLargest is 0
				dontDrawGroup()
			else
				tickGroup.truncateIndex = largestTruncation
				tickGroup.widthOfLargest = widthOfLargest

		# Now that we know how much all the ticks must be truncated, we have to actually
		# iterate over them and see which ones we can draw (can have positive width)
		innerTicksToDraw = [] # will eventually be added to axisLabels
		for tickGroup, groupIndex in tickGroups
			{ticks, row, numRows, truncateIndex, grain, dontDrawLabels} = tickGroup
			fontSize = @getFontSize row, numRows

			continue if row is numRows or dontDrawLabels

			for tick, tickIndex in ticks
				{date} = tick
				text = @formatTimeAxisLabel tick, truncateIndex
				continue if not text # we won't display them at all because there's no space
				textWidth = @ctx.measureText(text).width
				middleEpoch = DateUtils.midPointOfGrain date, grain
				centerInPixels = timeScale.map middleEpoch
				xPos = centerInPixels - textWidth / 2 # offset from center because it is drawn from left
				continue if xPos + textWidth > timeScale.dy # don't draw it if the label goes over the chart width
				$.extend tick, {text, fontSize, xPos}
				innerTicksToDraw.push @formatTickLayout(tick)

		# For outer most ticks, figure out how many to skip (if not enough space for all)
		outerMostTickGroup = _.last tickGroups
		n = 1 # will represent the number of ticks to not label in order to fit them
		while outerMostTickGroup.widthOfLargest * (outerMostTickGroup.ticks.length / n) > timeScale.dy * .7 # some padding
			n++

		# Now we need to pluck a bunch of tick marks out so that there are gaps
		# between each tick mark that we draw. That gap should be n tick marks wide.
		numberSkippedInARow = 0
		outerTicksToDraw = [] # will eventually be added to axisLabels
		{row, numRows, grain} = outerMostTickGroup
		fontSize = @getFontSize row, numRows
		fontRatio = fontSize / 12 # standard size
		for tick, index in outerMostTickGroup.ticks
			if numberSkippedInARow < n and n isnt 1 and index isnt 0
				# we haven't made n ticks invisible yet, so dont draw this one
				numberSkippedInARow++
			else
				numberSkippedInARow = 0 # need to skip the next n ticks since we're drawing this one
				@addHashMarkFromTick tick, hashByKey, timeScale, true
				text = @formatTimeAxisLabel tick, outerMostTickGroup.truncateIndex
				textWidth = fontRatio * @ctx.measureText(text).width
				xPos = timeScale.map tick.date.getTime()
				continue if xPos + textWidth > timeScale.dy # don't draw the label if it goes over the edge
				$.extend tick, {text, fontSize, xPos}
				outerTicksToDraw.push @formatTickLayout(tick)

		# push in our shapes
		axisTicks = (@formatHashMarkLayout(hash) for epoch, hash of hashByKey) # the vert lines
		axisLabels = axisLabels.concat(outerTicksToDraw).concat(innerTicksToDraw)
		{axisTicks, axisLabels}

	# *** Main method for getting tick marks ****			
	# Given a time range, produces a sequence of tick marks at incrementing dates.
	# It only does it for one grain at a time (i.e. "year"). So if you want to show multiple
	# grains, run this function for each grain.
	allTicksOnAxisForGrain: (grain, timeScale) =>
		{domain} = timeScale
		[ startEpoch, endEpoch ] = domain
		[ startDate, endDate ] = [ new Date(domain[0]), new Date(domain[1]) ]

		ticks = [] # the array to populate with all of the time axis tick marks
		dateString = null # ie "2001/01/20" which is used in the shape key
		numGrainsInDateString = 3 # i.e '2001/01' is 2, '2001/01/30' is 3
		increment = # a function that increments a single date grain
			switch grain
				when "day" 
					(tickDate) =>
						tickDate.setDate tickDate.getDate() + 1	
						dateString = @formatDateString tickDate, numGrainsInDateString
				when "month"
					# start with the first full month, unless we have less than a month of data
					numGrainsInDateString = 2
					isOneMonth = startDate.getMonth() is endDate.getMonth()
					if startDate.getDate() > 15 and not isOneMonth
						startDate.setMonth startDate.getMonth() + 1
						startDate.setDate 1
					(tickDate) =>
						tickDate.setMonth tickDate.getMonth() + 1
						tickDate.setDate 1
						dateString = @formatDateString tickDate, numGrainsInDateString
				when "quarter"
					(tickDate) =>
						month = tickDate.getMonth()
						month++
						while @firstMonthArr.indexOf(month) is -1
							month++
							if month > _.last(@firstMonthArr) # we're in the next year
								tickDate.setFullYear tickDate.getFullYear() + 1
								month = @firstMonthArr[0]
						tickDate.setMonth month
						dateString = @formatDateString tickDate, numGrainsInDateString
				when "year"
					numGrainsInDateString = 1
					# start with the first full year, unless we have one year of data
					# or there are two years, but the next year only has Jan (so we may
					isOneYear = startDate.getFullYear() is endDate.getFullYear()
					if not isOneYear and endDate.getMonth() isnt 0 # jan
						startDate.setFullYear startDate.getFullYear() + 1
						startDate.setMonth 0
						startDate.setDate 1
						dateString = @formatDateString startDate, numGrainsInDateString
					(tickDate) =>
						tickDate.setFullYear tickDate.getFullYear() + 1
						tickDate.setMonth 0 # safegaurd, always want first month of year
						tickDate.setDate 1
						dateString = @formatDateString tickDate, numGrainsInDateString
				else
					break

		# Pushes each consecutive grain into an array (Jan, Feb, March...)
		while startDate.getTime() <= endEpoch
			if not dateString
				dateString = @formatDateString startDate, numGrainsInDateString
			newTickDate = new Date(startDate.getTime()) # create a new one to store because we increment the original
			ticks.push # this array is created in the main function
				date: newTickDate
				grain: grain
				dateString: dateString
			increment startDate
		ticks


	# Formats a text label, returning a skeleton for the model
	formatTickLayout: (tick) ->
		{key, row, numRows, text, xPos, fontSize} = tick
		addLeftHandOffset =
			if row is numRows
			then 5 # it's left aligned, so give it padding
			else 0 # its centered already

		y = @getY row, numRows

		# get x
		type: "text"
		fontSize: fontSize 
		x: xPos + addLeftHandOffset
		y: y
		text: text
		key: key

	# Formats the tick mark lines on axis
	formatHashMarkLayout: (tickHash) ->
		{key, row, numRows, xPos} = tickHash
		length = @getY row, numRows

		type: "line"
		x0: xPos
		x1: xPos
		y0: 0
		y1: length
		key: key

	#--------------------------------------------------------------------------------
	# Styling
	#--------------------------------------------------------------------------------			


	getFontSize: (row, numRows) ->
		if row is numRows
			@FONT_LARGEST_TIME_AXIS
		else if row is 1
			@FONT_LARGEST_TIME_AXIS - 3
		else if row is 2
			@FONT_LARGEST_TIME_AXIS - 2
		else
			@FONT_LARGEST_TIME_AXIS

	# The Y length of a hash mark
	getY: (row, numRows) ->
		if row is 1
			@SMALLEST_HASH_MARK
		else
			@SMALLEST_HASH_MARK * row + 2

	# styling
	getStroke: (row, numRows, isInSelection) ->
		return @COLOR_TICK_LABEL_SELECTED if isInSelection
		if row is numRows
			@COLOR_OUTERMOST_HASH
		else
			@COLOR_MINOR_HASH

	# ----------------------------------------------
	#	Helpers
	# ----------------------------------------------

	formatKeyForTick: (tick) =>
		"tick#{@KEY_DIVIDER}#{tick.grain}#{@KEY_DIVIDER}#{tick.dateString}"

	formatKeyForHashMark: (hash) =>
		"hash#{@KEY_DIVIDER}#{hash.grain}#{@KEY_DIVIDER}#{hash.dateString}"

	formatDateString: (date, numGrainsInDateString) ->
		dateArray = [date.getFullYear(), date.getMonth(), date.getDate()][0...numGrainsInDateString]
		dateArray.join @DATE_STR_DIVIDER


	addHashMarkFromTick: (tick, hashMap, timeScale, shouldOverride = false) ->
		tickHash = $.extend {}, tick
		epoch = tick.date.getTime()
		hashKey = @formatKeyForHashMark tickHash
		return if not shouldOverride and hashMap[epoch]
		hashMap[epoch] = tickHash # may override a previous one, which is good
		tickHash.key = hashKey
		tickHash.xPos = timeScale.map tickHash.date.getTime()

	# returns the type of the shape (based on the key). Could be a tick or a hash.
	typeOfShapeFromKey: (key) =>
		parts = key.split @KEY_DIVIDER
		return parts[0]

	isOutermostGroup: (tickGroup) ->
 		tickGroup.row is tickGroup.numRows

	###
	This formats the labels on the time line axis
	arguments:
		tick:
			Info for the mark on the time axis (the date, the scale -- like "year")
		truncateIndex:
			How much we need to abbreviate the text by (its an integer)
	###
	formatTimeAxisLabel: (tick, truncateIndex = 0) ->
		{date, grain, row, numRows, isFirstTick} = tick
		{year, quarter, month, week, day} = dateObj = DateUtils.timeToDateObj date.getTime()

		getMonth = ->
			standardMonth = DateUtils.MONTH_INFOS[month].name
			switch truncateIndex
				when 0
					DateUtils.MONTH_INFOS[month].longName
				when 1
					standardMonth
				when 2
					standardMonth[0]
				else
					# If it's the outermost row, then you have to show something so show first letter
					if row is numRows then standardMonth[0] else ""

		getQuarter = ->
			switch truncateIndex
				when 0
					"Q" + dateObj[grain]
				when 1
					dateObj[grain]
				else
					if row is numRows then dateObj[grain] else ""
		getDay = ->
			switch truncateIndex
				when 0
					dateObj[grain]
				else
					""
		switch grain
			when "month"
				getMonth()
			when "quarter"
				getQuarter()
			when "day"
				getDay()
			else # the default formatting
				switch truncateIndex
					when 0
						dateObj[grain]
					else
						# this is the smallest text we can show for that tick (month and quarter override this)
						if row is numRows then dateObj[grain] else ""
