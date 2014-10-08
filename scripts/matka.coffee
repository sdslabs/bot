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
  "Never in your life",
  "You should go kill yourself",
  "You should go kill yourself for that joke",
  "_does a matka dance_",
  "for what joy?"
]


module.exports = (robot) ->
  robot.hear /matka/i, (msg) ->
    msg.send msg.random quotes
  robot.respond /quote ravi$/i, (msg) ->
    msg.send msg.random quotes