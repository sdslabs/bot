# Dependencies:
#   None
#
# Configuration:
#   https://github.com/github/hubot/blob/master/docs/scripting.md#middleware
#
# Author:
#   csoni111

end = (msg, done) ->
  # Don't process this message further.
  msg.finish()
  # Don't process further middleware.
  done()

module.exports = (robot) ->
  robot.receiveMiddleware (context, next, done) ->
    msg = context.response.message
    # Check if message was sent by someone other than SlackBot
    if msg.user.id != 'USLACKBOT'
       # Check if this message was sent in a private channel
      if msg.message?.channel.is_private or msg.rawMessage?.channel.is_private
        robot.send room: 'general', "@#{msg.user.name} stop sending me messages in private channel. Talk here in public!"
        end(msg, done)
      # or a DM
      else if msg.rawMessage?.channel.is_im
        robot.send room: 'general', "@#{msg.user.name} pls dont DM me. Talk here in public!"
        end(msg, done)
      else
        next(done)
    else
      end(msg, done)
