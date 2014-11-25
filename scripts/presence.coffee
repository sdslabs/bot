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
    msg.http("https://presence.sdslabs.co/?control=present").get() (err, res, body) ->
      if body is '[]'
        msg.send 'No one here to give me company.'
      else
        data = JSON.parse(body)
        if data.length is 1
          msg.send 'I sense 1 human in lab.'
        else
          msg.send 'I sense '+data.length+' humans in lab.'
        for i of data
          msg.send data[i].name.split(' ')[0]
      msg.send "Here's a pic: https://presence.sdslabs.co/spycam.png?q="+Math.random()
