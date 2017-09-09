# Description:
#   Counts messages sent by a particular user
#   Show message stats
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot stats
#
# Author:
#   csoni111

cron = require 'node-cron'

module.exports = (robot) ->
  robot.hear /^(.+)/i, (msg) ->
    if msg.match[0].toLowerCase().startsWith robot.name.toLowerCase()
      return
    text = msg.match[0]
    name = msg.message.user.name 
    user = robot.brain.userForName name
    user.msgcount = ++user.msgcount or 1

  robot.respond /stats/i, (msg) ->
    name = msg.message.user.name 
    sender = robot.brain.userForName name
    isSenderInList = false
    response = "```Name : Message Count\n"
    sorted = listOfUsersWithCount()
    if sorted.length
      for user in sorted
        if sender.name is user[0]
          isSenderInList = true
          break
      sorted = sorted.map (val) -> "#{val[0]} : #{val[1]}"
      response += sorted.join '\n'
    response += "```"
    if not isSenderInList
      response += "\nCan't find your name?\n" + msg.random responses 
    msg.send response

  #This will run every Saturday at 9 pm
  cron.schedule '0 0 21 * * Saturday', ()->
    sorted = listOfUsersWithCount()
    name = sorted[0][0]
    currMsgRecord = sorted[0][1]
    msg = "This week's top poster is @#{name}"
    msg += " with #{currMsgRecord} messages"
    robot.send room: 'general', msg
    robot.emit "plusplus", {username: name}
    for own key, user of robot.brain.data.users
      if user.msgcount>0
        user.msgcount = 0


  listOfUsersWithCount = () ->
    sorted = []
    for own key, user of robot.brain.data.users
      if user.msgcount>0
        sorted.push [user.name, user.msgcount]
    if sorted.length
      sorted.sort (a, b) ->
        b[1] - a[1]
    return sorted


responses = [
  'Looks like you are more of a silent man'
  'There ain\'t anything for you!'
  'Be more active next time!'
]
