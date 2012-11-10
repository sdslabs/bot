# Description:
# Returns status of service that are down on SDSLabs portal
# 
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot what is down
#
# Author:
#   shashank mehta
#   http://shashankmehta.in

module.exports = (robot) ->
  robot.respond /what is down/i, (msg) ->
    msg.http("http://sdslabs.co/status/").get() (err, res, body) ->
      data = JSON.parse(body)
      for i of data
        if data[i].status != '200'
          msg.send data[i].name
