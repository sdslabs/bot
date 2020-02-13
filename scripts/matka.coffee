# Description:
#   Matka quotes.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   shashankmehta.in

quotes = [
  "@manaschaudhary2000"
]


module.exports = (robot) ->
  robot.hear /matka/i, (msg) ->
    msg.send msg.random quotes
  robot.respond /quote ravi$/i, (msg) ->
    msg.send msg.random quotes