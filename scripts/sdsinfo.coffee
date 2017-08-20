# Description:
#   gets sdslabs member's info from google doc
#   Type a partial name to get all matches
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot info <partial name> - Get information about a person

details = 0
username = ""
module.exports = (robot) ->
  robot.respond /(info|sdsinfo) (.+)$/i, (msg) ->
    username = msg.match[2]
    msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
      response = JSON.parse body 
      details = -1
      if response["version"]
        sendTheMsg(row) for row in response.feed.entry
        if details != -1
          msg.send details
        else
          msg.send "User Not found"
      else
        msg.send "Error"

  sendTheMsg = (row) ->
      if (row.title.$t.toLowerCase().indexOf(username.toLowerCase())>=0)
        if (details == -1)
          details = row.content.$t
        else
          details += "\n"
          details += row.content.$t
      if username == "bot"
        details = "That could be Nemo, Yoda or OMGAarti" 
