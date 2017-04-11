# Description:
# Returns either Heads or Tails
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   bot toss
#
# Author:
#   alphadose


module.exports = (robot) ->
  robot.respond /toss/i, (res) ->
    outcome = [':heads:\nHeads', ':tails:\nTails']
    res.send res.random outcome
