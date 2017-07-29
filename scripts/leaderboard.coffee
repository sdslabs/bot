# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for keyword++ or keyword-- in chat text and updates score for each
#   bot score keyword : returns current score of 'keyword'
#   bot alias abc xyz : sets xyz as an alias of abc
#   bot unset xyz : unsets alias xyz
#   bot debut xyz : add xyz to the leaderboard
#   bot retire xyz : remove xyz from the leaderboard
#
# Examples:
#   : will update score for each, accordingly :
#   SDSLabs++ for itself
#   nemo++ for everything
#   pravj-- for nothing
#   : will return score for SDSLabs :
#   bot score SDSLabs
#
# Author:
#   Pravendra Singh (@hackpravj)
#   Developer at SDSLabs (@sdslabs)

module.exports = (robot) ->

  # return object to store data for all keywords
  # using this, stores the data in brain's "scorefield" key
  scorefield = () ->
    Field = robot.brain.get("scorefield") or {}
    robot.brain.set("scorefield",Field)
    Field

  aliases = () ->
    Alias = robot.brain.get("aliases") or {}
    robot.brain.set("aliases",Alias)
    Alias

  # returns last score
  lastScore = (name, field) ->
    name = name.toLowerCase()
    lastscore = field[name] or 0
    lastscore

  # updates score according to ++/--
  updateScore = (word, field, aliases) ->
    posRegex = /\+\+/
    negRegex = /\-\-/

    # if there is to be `plus` in score
    if word.indexOf("++") >= 0
      name = word.replace posRegex, ""
      if aliases[name.toLowerCase()]?
         name = aliases[name.toLowerCase()]
      field[name.toLowerCase()] = lastScore(name, field) + 1
      response = "woot!"

    # if there is to be `minus` in score
    else if word.indexOf("--") >= 0
      name = word.replace negRegex, ""
      if aliases[name.toLowerCase()]?
        name = aliases[name.toLowerCase()]
      field[name.toLowerCase()] = lastScore(name, field) - 1
      response = "ouch!"

    newscore = field[name.toLowerCase()]

    # returns 'name' and 'newscore' and 'response'
    New: newscore
    Name: name
    Response: response

  # adds a new alias for a name
  addAlias = (name,alias,aliases) ->
    alias = alias.toLowerCase()
    name = name.toLowerCase()
    if !aliases[alias]
      aliases[alias] = name
      message = alias + " is now an alias of " + name
    else
      message = alias + " is already an alias of " + aliases[alias]
    message

  # removes a alias
  removeAlias = (alias,aliases) ->
   alias = alias.toLowerCase()
   if aliases[alias]?
      aliases[alias] = ""
      message = "Unset alias " + alias
   else 	
     message = alias + " is not an alias"
   message

  # checks if name is valid for score updation
  verifyName = (word, field, aliases) ->
    posRegex = /\+\+/
    negRegex = /\-\-/
    name = word
    if word.indexOf("++")>=0
      name = word.replace posRegex, ""
    else if word.indexOf("--")>=0
      name = word.replace negRegex, ""
    if aliases[name.toLowerCase()]?
      name = aliases[name.toLowerCase()]

    if field[name.toLowerCase()]?
      return true
    false

  # listen for any [word](++/--) in chat and react/update score
  robot.hear /[a-zA-Z0-9\-_]+(\-\-|\+\+)/gi, (msg) ->

    # message for score update that bot will return
    oldmsg = msg.message.text
    recvmsg = oldmsg
    plusCount = 0
    minusCount = 0
    currentCount = 0

    # data-store object
    ScoreField = scorefield()
    Aliases = aliases()

    # for each ++/--
    for i in [0...msg.match.length]
      testword = msg.match[i]

      #checks if name is valid
      if !verifyName(testword, ScoreField, Aliases)
        continue;

      # updates Scoring for words, accordingly and returns result string
      result = updateScore(testword, ScoreField, Aliases)
      if testword.indexOf("++") isnt -1
        plusCount++
        currentCount = plusCount
      else
        minusCount++
        currentCount = minusCount

      # index keeping an eye on starting index of each username++/-- in message
      start = 0
      
      while currentCount--
        start+=oldmsg.substr(start).indexOf(testword)
        start+=testword.length
      start-=testword.length

      # generates response message for reply
      newmsg = "[#{result.Response} #{result.Name} now at #{result.New}]"
      msg.send "#{start}"
      oldmsg = oldmsg.substr(0, start+testword.length) + newmsg + oldmsg.substr(start+testword.length)

    # reply with updated message
    if (oldmsg isnt recvmsg)
      msg.send "#{oldmsg}"


  # response for score status of any <keyword>
  robot.respond /score ([\w\-_]+)/i, (msg) ->

    # data-store object
    ScoreField = scorefield()
    Aliases = aliases()

    # <keyword> whose score is to be shown
    name = msg.match[1]
    name = name.toLowerCase()
    if Aliases[name]?
      name = Aliases[name]
	
    if verifyName(name, ScoreField, Aliases)
      msg.send "#{name} : #{ScoreField[name]}"

  # response for setting an alias
  robot.respond /alias ([a-zA-Z0-9_]* [a-zA-Z0-9_]*)/i, (msg) ->
    Aliases = aliases()
    message = (msg.match[0].split 'alias ')[1].split ' '
    name = message[0]
    alias = message[1]
    response = addAlias(name,alias,Aliases)
    msg.send response

  # response for unsetting an alias
  robot.respond /unset ([a-zA-Z0-9_]*)/i, (msg) ->
    Aliases = aliases()
    alias = (msg.match[0].split 'unset ')[1]
    response = removeAlias(alias,Aliases)
    msg.send response

  # response for adding to leaderboard
  robot.respond /debut ([\w\-_]+)/i, (msg) -> 
    name = msg.match[1]
    ScoreField = scorefield()
    Aliases = aliases()
    if verifyName(name, ScoreField, Aliases)
      response = "#{name} is already in the game."
      msg.send response
    else
      ScoreField[name] = 0
      response = "Added #{name} to roster."
      msg.send response
    return

  #response for removing from leaderboard
  robot.respond /retire ([\w\-_]+)/i, (msg) ->
    name = msg.match[1]
    ScoreField = scorefield()
    Aliases = aliases()
    if verifyName(name, ScoreField, Aliases)
      if Aliases[name]?
        name = Aliases[name]
      response = "After a brilliant career, #{name} retires with a score of #{ScoreField[name]}."
      delete ScoreField[name]
      msg.send response
    else
      response = "#{name} is not in roster."
      msg.send response
    return


