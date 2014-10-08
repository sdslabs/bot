# Description:
#   Tell bot if you have lab key so he can give out info about keys when asked
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot i have key
#   hubot i gave key to <name>
#   hubot i dont have key 
#   hubot who all have keys
#   hubot <name> has key
#
# Author:
#   Durgesh Suthar

module.exports = (robot) ->

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  robot.respond /(who all have|who have|who is having|whos having) (keys|key|a key|the key)/i, (msg) ->
    messageText = '';
    users = robot.users()
    for k, u of users
        if u.key is 'yes'
            messageText += "#{u.name}, "
        else
            messageText += ""
    if messageText.trim() is "" then messageText = "Nobody told me about keys."
    msg.send messageText

  robot.respond /i have (a key|key|keys|the key)/i, (msg) ->
    name = msg.message.user.name
    user = robot.userForName name

    if typeof user is 'object'
      user.key = 'yes'
      msg.send "okay #{user.name}, Tell me again when you give it to someone"

  robot.respond /i (don\'t|dont|do not) have (key|keys)/i, (msg) ->
    name = msg.message.user.name
    user = robot.userForName name

    if typeof user is 'object'
      user.key = 'no'
      msg.send "okay #{user.name}, Got it"

  robot.respond /i (gave|have given) (key|a key|the key|keys) to (.+)/i, (msg) ->
    othername = msg.match[3]
    name = msg.message.user.name
    user = robot.userForName name

    if othername is "you"
      msg.send "I never takes keys. #{user.name} is a liar"
    else if othername is robot.name
      msg.send "I never takes keys. #{user.name} is a liar"
    else
      users = robot.usersForFuzzyName(othername)
      if users.length is 1
        otheruser = users[0]
        otheruser.key = 'yes'
        if typeof user is 'object'
          user.key = 'no'
        msg.send "Okay #{user.name}, Now i will remember #{otheruser.name} "
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "#{othername}? Never heard of 'em"
  
  robot.respond /(.+) (has|have) (a key|key|keys|the key)/i, (msg) ->
    othername = msg.match[1]
    name = msg.message.user.name
    user = robot.userForName name

    unless othername in ['','who','who all','whos','i','I','i dont','i don\'t']
      if othername is "you"
        msg.send "I never takes keys. #{user.name} is a liar"
      else if othername is robot.name
        msg.send "I never takes keys. #{user.name} is a liar"
      else
        users = robot.usersForFuzzyName(othername)
        if users.length is 1
          otheruser = users[0]
          otheruser.key = 'yes'
          msg.send "Thanks #{user.name} for informing me!"
        else if users.length > 1
          msg.send getAmbiguousUserText users
        else
          msg.send "#{othername}? Never heard of 'em"
