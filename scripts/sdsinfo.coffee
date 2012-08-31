# Description:
#   gets sdslabs member's info from google doc
#   Type a partial name to get all matches
#
# Dependencies:
#   None
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot info <partial name>
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
   msg.http(process.env.INFO_SPREADSHEET_URL)
    .get() (err, res, body) ->
      response = JSON.parse body
      if response["version"]
       reply = sendTheMsg(row) for row in response.feed.entry
       msg.send details
      else
       msg.send "Error"

	sendTheMsg = (row) ->
       details = "That could be Nemo, Yoda or OMGAarti" if username == "bot"
       if (row.title.$t.toLowerCase().indexOf(username.toLowerCase())>=0)
        details = row.content.$t
       if username == "bot"
        details = "That could be Nemo, Yoda or OMGAarti" 