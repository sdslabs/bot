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

  robot.respond /fb(\s*)likes/i, (msg) ->
    http = require 'http'
    http.get {host: 'graph.facebook.com', 'path': '/sdslabs'}, (res) ->
      data = ''
      res.on 'data', (chunk) ->
        data += chunk.toString()
      res.on 'end', () ->
      	data = JSON.parse(data)
      	msg.send "#{data['likes']}"