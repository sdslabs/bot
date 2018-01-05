# Description:
#   Keeps track of number of commits done by a particular user
#   and rewards highest committer at the end of week.
#
# Dependencies:
#   node-cron
#
# Configuration:
#   None
#
# Commands:
#   hubot commits
#
# Author:
#   csoni111

cron = require 'node-cron'

module.exports = (robot) ->

  fetch_aliases = () ->
    Alias = robot.brain.get("aliases") or {}
    robot.brain.set("aliases",Alias)
    Alias

  verfiy = (headers, json) ->
    headers['X-GitHub-Event'] is 'push' and json.commits?.length > 0 and not json.forced

  robot.router.post '/webhook/github/', (req, res) ->
    try
      robot.logger.info("Github push webhook recieved", req.body)
      headers = req.headers
      json = req.body
      if verify headers, json
        aliases = fetch_aliases()
        for c in json.commits
          name = c.committer.username
          name = aliases[name] if aliases[name]?
          user = robot.brain.userForName name
          user.commits = ++user.commits or 1 if user?
    catch error
      robot.logger.error "Github webhook listener error: #{error.stack}. Request: #{req.body}"
    res.end ""

  robot.respond /commits/i, (msg) ->
    name = msg.message.user.name
    sender = robot.brain.userForName name
    isSenderInList = false
    response = "```Name : Commit Count\n"
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

  #This will run every Saturday at 9:10 pm
  cron.schedule '0 10 21 * * Saturday', ()->
    sorted = listOfUsersWithCount()
    name = sorted[0][0]
    currMsgRecord = sorted[0][1]
    msg = "This week's top committer is @#{name}"
    msg += " with #{currMsgRecord} messages"
    robot.send room: 'general', msg
    robot.emit "plusplus", {username: name}
    for own key, user of robot.brain.data.users
      if user.commits>0
        user.commits = 0


  listOfUsersWithCount = () ->
    sorted = []
    for own key, user of robot.brain.data.users
      if user.commits>0
        sorted.push [user.name, user.commits]
    if sorted.length
      sorted.sort (a, b) ->
        b[1] - a[1]
    return sorted


responses = [
  'This might be a glitch but you seem to have no commits this week'
  'There ain\'t anything for you!'
  'Be more active next time!'
  'Looks like the source is not with you'
  'You are not contributing enough'
]
