module.exports = (robot) ->
  robot.on 'slack.attachment', (payload)=>
    robot.emit 'slack-attachment',
      message:
        room: payload.channel
      content:
        text: payload.text
        fallback: ""
        pretext: ""