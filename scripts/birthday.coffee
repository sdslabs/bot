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

date = ""

month = ""

year = ""

b_person = ""

age = ""

data_start = ""

curr_date = new Date().getDate()

curr_month = new Date().getMonth() + 1

curr_year = new Date().getFullYear()

module.exports = (robot) ->
	robot.hear /Birthdays/i, (res) ->
		robot.http(process.env.INFO_SPREADSHEET_URL).get() (err, resp, body) ->
      		response = JSON.parse body 
      		if response["version"]
      			check = checkBirthday(row) for row in response.feed.entry
      			if b_person !=""
      				res.send "Happy Birthday #{b_person}!! Turned #{age} today.. Chapo toh banti hai !!!"
      			else
      				res.send "No Birthdays Today!! No Chapos..Focus on work"
      		else
      			res.send "Akash is the culprit!! Gave me wrong link"

	checkBirthday = (row) ->
		data_start = row.content.$t.indexOf("dob")
		data_start = parseInt(data_start)
		data_start = data_start + 5
		date = (row.content.$t[data_start]*10 + row.content.$t[data_start+1])
		month = (row.content.$t[data_start+3]*10 + row.content.$t[data_start+4])
		year = (row.content.$t[data_start+6]*1000 + row.content.$t[data_start+7]*100 + row.content.$t[data_start+8]*10 + row.content.$t[data_start+9])	
		if date==curr_date
			if month==curr_month
				b_person = row.title.$t
				age = curr_year - year	