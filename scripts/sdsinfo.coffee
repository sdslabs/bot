# Description:
#   gets sdslabs member's info from google doc
#   Type a partial name to get all matches
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot info <partial name> - Get information about a person

moment = require 'moment'

module.exports = (robot) ->
  robot.respond /(info|sdsinfo) (.+)$/i, (msg) ->
    information = msg.match[2].toLowerCase()
    information = information.replace /^\s+|\s+$/g, ""
    queries = information.split /\s+/
    msg.http(process.env.INFO_SPREADSHEET_URL).get() (err, res, body) ->
      for query in queries
        members = parse body, query
        if members.length > 0 
          msg.send "#{members.length} user(s) found matching `#{query.toString()}`"
          attachments = []
          attachments.push createAttachment user for user in members
          robot.emit 'attachment', 
            msg: msg.message
            attachments: attachments
        else
          if query is "bot"
            msg.send "That could be Nemo, Yoda or OMGAarti"
          else
            msg.send "I could not find a user matching `#{query.toString()}`"

  createAttachment = (user) ->
    body = "Address: #{user[8]}"
    if user[7].length > 0
      body += "\nWebmail: #{user[7]}"
    if user[9].length > 0
      body += "\nCurrent Occupation: #{user[9]}"
    attachment =
      "fallback": user.join ' \t '
      "color": randomColor()
      "title": user[0]
      "text": body
      "fields": [
          "title": "Mobile"
          "value": "<tel:#{user[3]}|#{user[3]}>"
          "short": true
        ,
          "title": "Email"
          "value": "<mailto:#{user[4]}|#{user[4]}>"
          "short": true
        ,
      ]
      "footer": "#{user[6]} #{user[5]} (#{user[1]})"
      "ts": moment(user[2], 'DD/MM/YYYY').format("X")
  
  parse = (csv, query) ->
    members = []
    lines = csv.toString().split '\n'
    lines.shift()
    for line in lines
      y = line.toLowerCase().indexOf query
      if y > -1
        members.push line.split(',').map Function.prototype.call, String.prototype.trim
    members

  randomColor = () ->
    return '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6)
