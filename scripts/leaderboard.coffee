# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for keyword++ or keyword-- in chat text and updates score for each
#   bot score keyword : returns current score of 'keyword'
#   bot alias abc xyz : sets xyz as an alias of abc(abc should be the username you see on "bot show users")
#   bot unset xyz : unsets alias xyz
#   bot debut xyz : add xyz to the leaderboard
#   bot retire xyz : remove xyz from the leaderboard
#   bot set score name score : sets score of name if present in leaderboard
#   tagging someone by @<ALIAS> will lead to the bot replying with their real name(best practice to set as their userid, eg- @manaschaudhary2000)
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

  ranks = [
    "Rookie" # Red ranks
    "Rookie II"
    "Rookie III"
    "General" # Green ranks
    "General II"
    "General III"
    "Bastion" # Blue ranks
    "Bastion II"
    "Bastion III"
    "Viscount" # Yellow ranks
    "Viscount II"
    "Viscount III"
    "Bearer of Excellence" # White ranks
    "Bearer of Excellence II"
    "Bearer of Excellence III"
    "Legend of SDSLabs" # Evergreen rank
  ]

  pointThresholds = [
    5
    8
    13
    21
    34
    55
    70
    100
    152
    209
    266
    310
    387
    477
    577
    610
  ]

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
      response = "\b\n:heavy_plus_sign:"

    # if there is to be `minus` in score
    else if word.indexOf("--") >= 0
      name = word.replace negRegex, ""
      if aliases[name.toLowerCase()]?
        name = aliases[name.toLowerCase()]
      field[name.toLowerCase()] = lastScore(name, field) - 1
      response = "\b\n:heavy_exclamation_mark:"

    newscore = field[name.toLowerCase()]

    # returns 'name' and 'newscore' and 'response'
    New: newscore
    Name: name
    Response: response

  # adds a new alias for a name
  addAlias = (name, alias, aliases) ->
    alias = alias.toLowerCase()
    name = name.toLowerCase()
    if !aliases[alias]
      aliases[alias] = name
      message = alias + " is now an alias of " + name
    else
      message = alias + " is already an alias of " + aliases[alias]
    message

  # removes a alias
  removeAlias = (alias, aliases) ->
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
    if word.indexOf("++") >= 0
      name = word.replace posRegex, ""
    else if word.indexOf("--") >= 0
      name = word.replace negRegex, ""
    if aliases[name.toLowerCase()]?
      name = aliases[name.toLowerCase()]
    if field[name.toLowerCase()]?
      return true
    false

  # set a score to given value
  setScore = (field, aliases, name, score) ->
    score = parseInt(score)
    name = name.toLowerCase()
    if (aliases[name])?
      name = alias[name]
    if isNaN(score)
      return "Please enter a valid score!"
    field[name] = score
    return "#{name}'s score set to #{score}."

  getRank = (score) ->
    for i in [0..ranks.length - 1]
      if score <= pointThresholds[i]
        return ranks[i]

    return ranks[ranks.length - 1]

  isLeveledUp = (score) ->
    for i in [0..ranks.length - 1]
      if score == pointThresholds[i] + 1
        return true
    return false

  robot.hear /[@][a-zA-Z0-9\-_]+/gi, (msg) ->
    Aliases = aliases()
    newmsg = ''
    for i in [0...msg.match.length]
      testword = msg.match[i]
      alias = testword.substr(1, testword.length)
      if !Aliases[alias]?
        continue
      newmsg += '@' + Aliases[alias] + ' '
    if (newmsg != '')
      msg.send(newmsg)
            

  # listen for any [word](++/--) in chat and react/update score
  robot.hear /[a-zA-Z0-9\-_]+(\-\-|\+\+)/gi, (msg) ->

    # message for score update that bot will return
    oldmsg = msg.message.text
    recvmsg = oldmsg
    plusCount = {}
    minusCount = {}
    currentCount = 0

    # data-store object
    ScoreField = scorefield()
    Aliases = aliases()

    # for each ++/--
    for i in [0...msg.match.length]
      testword = msg.match[i]
      username = testword.substr(0, testword.length-2)

      #checks if name is valid
      if !verifyName(testword, ScoreField, Aliases)
        continue;

      # updates Scoring for words, accordingly and returns result string
      result = updateScore(testword, ScoreField, Aliases)
      if testword.indexOf("++") isnt -1
        if plusCount[username]?
          plusCount[username]++
        else
          plusCount[username] = 1
        currentCount = plusCount[username]
      else
        if minusCount[username]?
          minusCount[username]++
        else
          minusCount[username] = 1
        currentCount = minusCount[username]

      # index keeping an eye on starting index of each username++/-- in message
      start = 0

      while currentCount--
        start+=oldmsg.substr(start).indexOf(testword)
        start+=testword.length
      start-=testword.length

      # convert score to rank
      result.rank = getRank(result.New)
      result.index = ranks.indexOf(result.rank)

      # generates response message for reply. 16 is the number of specified ranks in the `ranks` array
      if result.index == ranks.length - 1
        newmsg = "Legends are forever alive in history"
      else
        newmsg = "#{result.Response} #{result.Name} now requires #{pointThresholds[(result.index)] - result.New + 1} point(s) to reach :rank#{result.index + 1}: #{ranks[result.index + 1]}\n"
      if isLeveledUp(result.New)
        newmsg = "\n:fire: Congratulations for reaching :rank#{result.index}: #{ranks[result.index]}\n#{result.Response} #{result.Name} now requires #{pointThresholds[(result.index + 1)] - result.New + 1} point(s) to reach :rank#{result.index + 1}: #{ranks[result.index + 1]}\n"
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
      rank = getRank(ScoreField[name])
      index = ranks.indexOf(rank)
      msg.send "#{name} is a :rank#{index}: #{rank} with #{ScoreField[name]} points"

  # response for setting an alias
  robot.respond /alias ([a-zA-Z0-9_]* [a-zA-Z0-9_\-]*)/i, (msg) ->
    Aliases = aliases()
    message = (msg.match[0].split 'alias ')[1].split ' '
    name = message[0]
    alias = message[1]
    exists = false
    for own key, user of robot.brain.data.users
      if (name == user.name)
        exists = true
        break
    if (exists == false)
      msg.send name + " not found in users list"
    else
      msg.send addAlias(name,alias,Aliases)

  # response for unsetting an alias
  robot.respond /unset ([a-zA-Z0-9_\-]*)/i, (msg) ->
    Aliases = aliases()
    alias = (msg.match[0].split 'unset ')[1]
    response = removeAlias(alias,Aliases)
    msg.send response

  # response for adding to leaderboard
  robot.respond /debut (.+)/i, (msg) ->
    debut = msg.match[1].toLowerCase()
    debut = debut.replace /^\s+|\s+$/g, ""
    queries = debut.split /\s+/
    name_verified = ""
    name_unset = ""
    for name in queries
      ScoreField = scorefield()
      Aliases = aliases()
      if verifyName(name, ScoreField, Aliases)
        name_verified = name_verified.concat name.concat(" ")
      else
        ScoreField[name.toLowerCase()] = 0
        name_unset = name_unset.concat name.concat(" ")
    if name_verified != ""
      name_verified = name_verified.substr 0,name_verified.length-1
      msg.send "#{name_verified} is(are) already in the game."
    if name_unset != ""
      name_unset = name_unset.substr 0,name_unset.length-1
      msg.send "Added #{name_unset} to roster."
    return

  # response for removing from leaderboard
  robot.respond /retire (.+)/i, (msg) ->
    retire = msg.match[1].toLowerCase()
    retire = retire.replace /^\s+|\s+$/g, ""
    queries = retire.split /\s+/
    name_unset = ""
    for name in queries
      ScoreField = scorefield()
      Aliases = aliases()
      if verifyName(name, ScoreField, Aliases)
        if Aliases[name]?
          name = Aliases[name]
        rank = getRank(ScoreField[name.toLowerCase()])
        index = ranks.indexOf(rank)
        response = "After a brilliant career, :rank#{index}: #{rank} #{name} retires with a score of #{ScoreField[name.toLowerCase()]}."
        delete ScoreField[name.toLowerCase()]
        msg.send response
      else
        name_unset = name_unset.concat name.concat(" ")
    if name_unset != ""
      name_unset = name_unset.substr 0,name_unset.length-1
      msg.send "#{name_unset} is(are) not in roster."
    return

  # setting a user's score
  robot.respond /set\s+score\s+([\w\-_]+)\s+([-+]?\d+)/i, (msg) ->
    # switch to enable/disable setScore
    setScoreEnabled = true
    if setScoreEnabled
      name = msg.match[1].toLowerCase()
      newScore = msg.match[2]
      ScoreField = scorefield()
      Aliases = aliases()
      if verifyName(name, ScoreField, Aliases)
        response = setScore(ScoreField, Aliases, name, newScore)
        msg.send response
      else
        response = "#{name} is not a member of leaderboard. Add using 'bot debut #{name}'."
        msg.send response


  robot.on 'plusplus', (event) ->
    ScoreField = scorefield()
    result = updateScore("#{event.username}++", ScoreField, aliases())
    result.rank = getRank(result.New)
    result.index = ranks.indexOf(result.rank)

    if result.index == ranks.length - 1
        newmsg = "Legends are forever alive in history"
    else
    newmsg = "#{event.username}++ [#{result.Response} #{result.rank} #{result.Name} now requires #{pointThresholds[result.index] - result.New + 1} point(s) to reach :rank#{result.index + 1}: #{ranks[result.index + 1]}\n"
    if isLeveledUp(result.New)
        newmsg = "\n:fire: Congratulations for reaching :rank#{result.index}: #{ranks[result.index]}\n#{event.username}++ [#{result.Response} #{result.rank} #{result.Name} now requires #{pointThresholds[result.index + 1] - result.New + 1} point(s) to reach :rank#{result.index + 1}: #{ranks[result.index + 1]}\n"
    robot.send room: 'general', newmsg
