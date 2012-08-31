# Description:
#   gets sdslabs member's info from google doc
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot info <full name>
#
# Author:
#   Shashank Mehta
#   http://shashankmehta.in
#
details = ""
username = ""
module.exports = (robot) ->
  robot.respond /(info|sdsinfo) (.+)$/i, (msg) ->
   username = msg.match[2]
   msg.http("https://spreadsheets.google.com/feeds/list/0Airjt4b64pBKdEdQV0phZ3FEc3VJeDNKN2liRXVGSVE/od6/public/basic?alt=json")
    .get() (err, res, body) ->
      response = JSON.parse body
      if response["version"]
       reply = sendTheMsg(row) for row in response.feed.entry
       msg.send details
      else
       msg.send "Error"

	sendTheMsg = (row) ->
       if (row.title.$t.toLowerCase() == username)
        details = row.content.$t
