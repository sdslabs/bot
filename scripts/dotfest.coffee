# Description:
#   SDSLabs Dotfest
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   .
#
# Author:
#   abhshkdz

module.exports = (robot) ->
  robot.hear /^\.$/, (msg) ->
    msg.send '.'
