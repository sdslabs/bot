# Description:
# Returns the number of likes on SDSLabs page on FB
# 
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot fb likes
#
# Author:
#   abhshkdz

module.exports = (robot) ->

  robot.respond /fb likes/i, (msg) ->
    msg.http("http://graph.facebook.com/sdslabs")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).likes
