module.exports = (robot) ->
	robot.respond /team [1-5] \d/i, msg() ->
		teamSize = msg.match[3]
		msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
			members = parse body, teamSize
			if members.length > 0
				membersArray = []
				for member in members
					random = Math.random() * 100
					membersArray.push [member[0], random]
				sort membersArray members.length
				responseMsg = ""
				i = 0
				j = 0
				while i < members.length
					responseMsg += membersArray[i][0]
					j++
					if j % teamSize == 0
						responseMsg += "\n"
					i++

		msg.send responseMsg

	sort = (unsorted2dArray, size) ->
		start = 0
		while start < size
			end = start + 1
			index = i
			min = unsorted2dArray[i][1]
			while end < size
				if unsortedArray[j][1] < min
					min = unsorted2dArray[j][1]
					index = j
				end++
			swap unsorted2dArray i index
			start++

	swap = (2dArray, element1, element2) ->
		for i in [0..1]
			temp = 2dArray[element1][i]
			2dArray[element1][i] = 2dArray[element2][i]
			2dArray[element2][i] = temp


	parse = (csv, query) ->
    members = []
    lines = csv.toString().split '\n'
    lines.shift()
    for line in lines
    	lineArray = line.split ','
    	if lineArray[6] == query
    	members.push lineArray[0]
    members

