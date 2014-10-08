# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for keyword++ or keyword-- in chat text and updates score for each
#   bot score keyword : returns current score of 'keyword'
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

  # returns last score
  lastScore = (name, field) ->
    name = name.toLowerCase()
    lastscore = field[name] or 0
    lastscore

  # updates score according to ++/--
  updateScore = (word, field) ->
    posRegex = /\+\+/
    negRegex = /\-\-/

    # if there is to be `plus` in score
    if word.indexOf("++") >= 0
      name = word.replace posRegex, ""
      field[name.toLowerCase()] = lastScore(name, field) + 1
      response = "woot!"

    # if there is to be `minus` in score
    else if word.indexOf("--") >= 0
      name = word.replace negRegex, ""
      field[name.toLowerCase()] = lastScore(name, field) - 1
      response = "ouch!"

    newscore = field[name.toLowerCase()]

    # returns 'name' and 'newscore' and 'response'
    New: newscore
    Name: name
    Response: response


  # listen for any [word](++/--) in chat and react/update score
  robot.hear /[a-zA-Z0-9\-_]+(\-\-|\+\+)/gi, (msg) ->

    # message for score update that bot will return
    oldmsg = msg.message.text

    # data-store object
    ScoreField = scorefield()

    # index keeping an eye on position, where next replace will be
    start = 0
    end = 0

    # for each ++/--
    for i in [0...msg.match.length]
      testword = msg.match[i]

      # updates Scoring for words, accordingly and returns result string
      result = updateScore(testword, ScoreField)

      end = start + testword.length

      # generates response message for reply
      newmsg = "#{testword} [#{result.Response} #{result.Name} now at
 #{result.New}] "
      oldmsg = oldmsg.substr(0, start) + newmsg + oldmsg.substr(end+1)
      start += newmsg.length

    # reply with updated message
    msg.send "#{oldmsg}"


  # response for score status of any <keyword>
  robot.respond /score ([\w\-_]+)/i, (msg) ->

    # data-store object
    ScoreField = scorefield()

    # <keyword> whose score is to be shown
    name = msg.match[1]
    name = name.toLowerCase()

    # current score for keyword
    ScoreField[name] = ScoreField[name] or 0
    currentscore = ScoreField[name]

    msg.send "#{name} : #{currentscore}"
