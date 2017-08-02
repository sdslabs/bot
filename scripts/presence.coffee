# Description:
# Returns the names of people in lab
# 
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot who all in lab
#
# Author:
#   abhshkdz

module.exports = (robot) ->
  robot.respond /who.*lab/i, (msg) ->
    message = ""
    msg.http("https://presence.sdslabs.co/?control=present").get() (err, res, body) ->
      if body is '[]'
        meassage += 'No one here to give me company.'
      else
        data = JSON.parse(body)
        if data.length is 1
          message += 'I sense 1 human in lab.\n'
        else
          message += 'I sense ' + data.length + ' humans in lab.\n'
        for i of data
          message += data[i].name + "\n"
      message += "Here's a pic: https://presence.sdslabs.co/spycam.png?q=" + Math.random()
      msg.send message