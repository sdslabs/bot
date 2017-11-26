module.exports = (robot) ->
    robot.respond /team [1-5] \d/i, (msg) ->
        year = (msg.match[0].split ' ')[2]
        teamSize = parseInt((msg.match[0].split ' ')[3])
        responseMsg = ""
        responseMsg += "Possible clustering is\n"
        msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
            members = parse body, year
            if members.length > 0
                membersArray = []
                for member in members
                    random = Math.random() * 100
                    membersArray.push [member, random]
                sort membersArray, members.length
                i = 0
                j = 0
                while i < members.length
                    responseMsg = responseMsg + membersArray[i][0] + ', '
                    j++
                    if j % teamSize == 0
                        responseMsg += '\n'
                    i++
                    
                msg.send responseMsg

    sort = (unsorted2dArray, size) ->
        start = 0
        while start < size
            end = start + 1
            index = start
            min = unsorted2dArray[start][1]
            while end < size
                if unsorted2dArray[end][1] < min
                    min = unsorted2dArray[end][1]
                    index = end
                end++
            swap unsorted2dArray, start, index
            start++

    swap = (array2D, element1, element2) ->
        for i in [0..1]
            temp = array2D[element1][i]
            array2D[element1][i] = array2D[element2][i]
            array2D[element2][i] = temp

    parse = (csv, query) ->
        members = []
        lines = csv.toString().split '\n'
        lines.shift()
        for line in lines
            lineArray = line.split ","
            if lineArray[6] == query
                members.push lineArray[0]
        members
