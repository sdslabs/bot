# Description:
#   Google Calendar integration
#
# Configuration:
#   SLACK_DEFAULT_CHANNEL
#   GROUP_CALENDAR
#
# Commands:
#   hubot show events <number> - Shows the <number> number list of events for GROUP_PRIMARY_CALENDAR, (default 10)
#   hubot create event <event> - Creates event <event> using quick add in GROUP_PRIMARY_CALENDAR
#   hubot enable calendar notifications
#
# Author:
#   aryanraj
#

googleapis = require 'googleapis'
uuid = require 'node-uuid'
_ = require 'underscore'

last_update = new Date()
general_events = []

SLACK_DEFAULT_CHANNEL = process.env.SLACK_DEFAULT_CHANNEL
GROUP_CALENDAR = process.env.GROUP_CALENDAR

module.exports = (robot)->
  root = exports ? this
  authenticate = (cb)->
    robot.emit 'google:authenticate', message:user:name:SLACK_DEFAULT_CHANNEL, (err, oauth) ->
      if err
        console.log 'No Authentication'
      else
        cb oauth

  cleanDate = (date)->
    new Date(new Date(date).valueOf()+5.5*60*60*1000).toISOString().replace(/T/, ' ').replace(/\..+/, '')

  manageEvent = (event, count)->
    if event.status is "cancelled"
      old_event = _.findWhere general_events, id:event.id
      if old_event
        text = "#{count}. #{cleanDate old_event.start.dateTime} #{old_event.summary ? 'An Event'} at #{event.location ? 'SDSLabs'} got #{event.status}\n" if count?
        general_events = _.without general_events, old_event
    else
      if new Date(event.start.dateTime) < last_update
        event.reminded = true
      general_events.push event
      text = "#{count}. #{cleanDate event.start.dateTime} #{event.summary ? 'An Event'} at #{event.location ? 'SDSLabs'} got #{event.status}\n" if count?
    return text ? ""

  setTimeout func = (token)->
      console.log "starting with #{token}"
      authenticate (oauth)->
        googleapis.calendar('v3').events.list
          auth: oauth
          calendarId: GROUP_CALENDAR
          maxResults: 100
          singleEvents: true
          orderBy: 'startTime'
          pageToken: token ? null
          (err, res)->
            if err
              console.log "The API returned an error: ",err
            else
              # console.log res
              events = res.items
              root.defaultReminders = res.defaultReminders
              manageEvent event for event in events
              if res.nextPageToken then func res.nextPageToken
  ,5000
  
  setInterval ()->
    text = "The following events are going to start:\n"
    flag = false
    _.each general_events, (event)->
      reminders = if event.reminders.useDefault then root.defaultRemindes else event.reminders.overrides
      return "No reminder" if not reminders
      reminder = _.find reminders, (r)-> r.method is "popup"
      return "No popup reminder" if not reminder
      start_date = new Date event.start.dateTime
      difference = new Date() - start_date + reminder.minutes*60000
      if difference > 0 and not event.reminded
        text += "#{cleanDate event.start.dateTime} - #{event.summary} at #{event.location ? 'SDSLabs'} within #{reminder.minutes} minutes.\n"
        event.reminded = true
        flag = true
    robot.emit 'slack.attachment', {channel: SLACK_DEFAULT_CHANNEL, text: text} if flag
  ,60000

  robot.respond /show events (.+)/i, (msg) ->
    authenticate (oauth) ->
      googleapis.calendar('v3').events.list 
        auth: oauth
        calendarId: GROUP_CALENDAR
        timeMin: new Date().toISOString()
        maxResults: parseInt msg.match[1]
        singleEvents: true
        orderBy: 'startTime'
        (err, res)->
          if err
            console.log "The API returned an error:",err
          else
            events = res.items
            console.log res.defaultReminders
            console.log item.summary,item.reminders for item in events
            if events.length is 0
              text = "No upcoming events found"
            else
              text = "Upcoming #{msg.match[1]} events: \n"
              text += "#{i+1}. #{cleanDate event.start.dateTime} - #{event.summary}\n" for event,i in events
            robot.emit 'slack.attachment', {channel: msg.message.user.room, text: text}
  
  robot.respond /create event (.+)/i, (msg) ->
    authenticate (oauth) ->
      googleapis.calendar('v3').events.quickAdd
        auth: oauth
        calendarId: GROUP_CALENDAR
        text: msg.match[1]
        (err, event) ->
          if err
            console.log "The API returned an error: #{err}"
          else
            if event.status is 'confirmed'
              text = "The event was successfully created. Watch at #{event.htmlLink}"
            robot.emit 'slack.attachment', {channel: msg.message.user.room, text: text}

  robot.respond /enable calendar notifications/i, (msg)->
    authenticate (oauth)->
      googleapis.calendar('v3').events.watch
        auth: oauth
        resource: 
          id: uuid.v1()
          type: 'web_hook'
          address: "#{process.env.HUBOT_URL}/push"
        calendarId: GROUP_CALENDAR
        (err, res)->
          if err
            console.log "The API returned an error :",err
          else
            text = "You will get notification for calendar events."
            root.channelID = res.id
            robot.emit 'slack.attachment', {channel: SLACK_DEFAULT_CHANNEL, text: text}
  
  robot.router.post '/push', (req, res)->
    channelID = req.get "X-Goog-Channel-ID"
    state = req.get "X-Goog-Resource-State"
    res.send(201)
    if state is "exists" and channelID is root.channelID
      authenticate (oauth)->
        googleapis.calendar('v3').events.list 
          auth: oauth
          calendarId: GROUP_CALENDAR
          singleEvents: true
          orderBy: 'startTime'
          updatedMin: last_update.toISOString()
          (err, res)->
            if err
              console.log "The API returned an error:",err
            else
              last_update = new Date()
              console.log res
              events = res.items
              if events.length is 0
                console.log "No event updates"
              else
                text = "These Events got updated\n"
                for event,i in events
                  console.log event
                  text += manageEvent event,i+1
                robot.emit 'slack.attachment', {channel: SLACK_DEFAULT_CHANNEL, text: text} if text
