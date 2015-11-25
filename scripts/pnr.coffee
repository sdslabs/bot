# Description:
#   Tracks pnr status of trains for different SDSLabs members
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Author: Akashdeep Goel
# 
# Made during Bloom Filter
#
# Commands:
#   bot add pnr <userName> <pnr_number> - Adds this pnr to tracking list
#   bot pnrstatus <userName> - Shows status of all pnr numbers for a user
#   bot stoptrack <userName> <pnr> - stops tracking specified

module.exports = (robot)->
  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  robot.respond /add ?pnr @?([\w .\-_]+) (.+)/i , (msg)->
    name    = msg.match[1].trim()
    pnrNumber = msg.match[2]
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      user.pnr = user.pnr or [ ]
      if pnrNumber in user.pnr
        msg.send "This PNR is already under Tracking"
      else
        user.pnr.push(pnrNumber)
        msg.send "PNR is under our surveillance! Have a safe journey!"
    else
      msg.send "I don't know anything about #{name}."
  
  robot.respond /pnr ?status (.+)/i , (msg)->
    name = msg.match[1]
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      user.pnr = user.pnr or [ ]
      if user.pnr.length > 0
        msg.send "Status of your PNRs\n"
        for pnrNum in user.pnr
          http = require 'http'
          url = "http://api.railwayapi.com/pnr_status/pnr/#{pnrNum}/apikey/ubvkp5258/"
          http.get url, (res) ->
            res.on 'data', (chunk) ->
              body  = JSON.parse(chunk)
              string = ""
              string+="Train name: #{body['train_name']}\n"
              string+="Chart Prepared: #{body['chart_prepared']}\n"
              for pass in body.passengers
                string+="Passenger No: #{pass.no} -- Status: #{pass.current_status}\n"
              msg.send string
      else
        msg.send "You never gave me a PNR to track!"
    else if users.length > 1
      msg.send getAmbiguousUserText users
    else
      msg.send "#{name}? Never heard of 'em"

  robot.respond /stoptrack (.+) (.+)/i , (msg)->
    name = msg.match[1]
    pnrNum = msg.match[2]
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      user.pnr = user.pnr or [ ]
      if pnrNum not in user.pnr
        msg.send "This is nor being Tracked"
      else
        user.pnr = (pnr for pnr in user.pnr when pnr isnt pnrNum)
        msg.send "Ok! I won't keep a track of this"
    else if users.length > 1
      msg.send getAmbiguousUserText users
    else
      msg.send "#{name}? Never heard of 'em"
   

