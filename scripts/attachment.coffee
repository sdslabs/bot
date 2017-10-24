# Description:
#   Custom event for sending slack attachments
#
# Environment:
#   HUBOT_SLACK_TOKEN
#   HUBOT_SLACK_TEAM

module.exports = (robot) ->
  options =
    token : process.env.HUBOT_SLACK_TOKEN
    team  : process.env.HUBOT_SLACK_TEAM
    link_names: process.env.HUBOT_SLACK_LINK_NAMES or 0

  getChannel = (msg) ->
    if msg.room.match /^[#@]/
      # the channel already has an appropriate prefix
      msg.room
    else if msg.user && msg.room == msg.user.name
      "@#{msg.room}"
    else
      "##{msg.room}"

  send = (body) ->
    robot.http("https://#{options.team}.slack.com/services/hooks/hubot?token=#{options.token}")
      .header("Content-Type", "application/json")
      .post(body) (err, res, body) ->
        return if res.statusCode == 200
        robot.logger.error "attachment", res.statusCode, body

  robot.on 'attachment', (data) ->
    send JSON.stringify
      username    : robot.name
      channel     : getChannel data.msg
      attachments : data.attachments
      link_names  : options.link_names
