module.exports = (robot) -> 
  robot.on 'slack.attachment', (payload)=>
    robot.emit 'slack-attachment', payload