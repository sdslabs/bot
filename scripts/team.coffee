# Description:
#   cluster lab members of a particular year randomly
#   year and team size is mentioned in the command
#   useful to randomly form teams in internal hackathons
#
# Configuration:
#   INFO_SPREADSHEET_URL   
#
# Commands:
#   listen for
#   bot team [m] [n]
#   [m] = year
#   [n] = team size
#
# Author:
#   Nikhil Kaushik (@c0dzilla)
#   Developer at SDSLabs (@sdslabs)

module.exports = (robot) ->
    robot.respond /team [\w]* \d/i, (msg) ->
        year = (msg.match[0].split ' ')[2]
        teamSize = parseInt((msg.match[0].split ' ')[3])
        msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
            members = parse body, year
            if members.length > 0
                responseMsg = "Possible teams are:\n"
                sort members
                assignedMembers = 0
                while assignedMembers < members.length
                    if assignedMembers % teamSize == 0
                        append = '\n' + (assignedMembers/teamSize + 1) + '. '
                    else
                        append = ', '
                    responseMsg = responseMsg + append + members[assignedMembers]
                    assignedMembers++
                responseMsg += "\n\nAsk me again for different combinations!"
                msg.send responseMsg

    # Fisher-Yates algorithm to shuffle array(cool)
    sort  = (array) ->
        currentIndex = array.length
        while currentIndex--
            selectedIndex = Math.floor(Math.random() * currentIndex)
            swap(array, currentIndex, selectedIndex)

    # a simple swap function
    swap = (array, index1, index2) ->
        temp = array[index1]
        array[index1] = array[index2]
        array[index2] = temp

    # returns array containing names from requested year
    parse = (csv, query) ->
        members = []
        lines = csv.toString().split '\n'
        lines.shift()
        for line in lines
            lineArray = line.split ","
            if lineArray[6] == query
                members.push lineArray[0]
        members
