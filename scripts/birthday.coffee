# Description:
#  Wishes Members of SDSLabs Happy Birthday and also reminds other members :P
#
#
# Examples:
#   Happy Birthday Punit!! Turned {age} today..Chapo toh banti hai !!!
#
# Source of Data:
#	Takes data from Google Spreadsheet.
#
# Author:
#   Akashdeep Goel (@akash)
#   Developer at SDSLabs (@sdslabs)

http = require 'http'

date = 

b_boy = ""

age = ""

data_start = ""

data_end = ""

module.exports = (robot) ->
	robot.hear /Birthdays/i, (res) ->
		robot.http(process.env.INFO_SPREADSHEET_URL).get() (err, resp, body) ->
      		response = JSON.parse body 
      		if response["version"]
      			check = checkBirthday(row) for row in response.feed.entry
      			if b_boy !=""
      				res.send "Happy Birthday #{b_boy}!! Turned #{age} today.. Chapo toh banti hai !!!"
      			else
      				res.send "No Birthdays Today!! No Chapos..Focus on work"
      		else
      			res.send "Akash is the culprit!! Gave me wrong link"

	checkBirthday = (row) ->
		data_start = row.content.$t.indexOf("dob")
		b_boy = data_start			