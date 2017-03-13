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
  robot.hear /toss/i, (res) ->
    lulz = ['Heads','Tails']
    res.send res.random lulz