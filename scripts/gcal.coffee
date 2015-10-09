# Description:
#   Google Calendar integration
#
# Commands:
#   hubot show events <number> - Shows the <number> number list of events for GROUP_PRIMARY_CALENDAR, (default 10)
#   hubot create an event <event> - Creates event <event> using quick add in GROUP_PRIMARY_CALENDAR
#

express = require 'express'


module.exports = (robot)->

  robot.emit 'google:authenticate', 'message':'user':'name':'bottesting', (err, oauth) ->
    console.log 'Done'
