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

module.exports = (robot) ->
	robot.respond /(akashtest) (.+)$/i, (msg) ->
	    msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
	      response = JSON.parse body 
	      	msg.send response




