
<!-- saved from url=(0077)https://raw.github.com/github/hubot-scripts/master/src/scripts/redmine.coffee -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><style type="text/css"></style></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;"># Description:
#   Showing of redmine issue via the REST API
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_REDMINE_SSL
#   HUBOT_REDMINE_BASE_URL
#   HUBOT_REDMINE_TOKEN
#
# Commands:
#   hubot (redmine|show) me &lt;issue-id&gt; - Show the issue status
#   hubot show (my|user's) issues - Show your issues or another user's issues
#   hubot assign &lt;issue-id&gt; to &lt;user-first-name&gt; ["notes"] - Assign the issue to the user (searches login or firstname)
#   hubot update &lt;issue-id&gt; with "&lt;note&gt;" - Adds a note to the issue
#   hubot add &lt;hours&gt; hours to &lt;issue-id&gt; ["comments"] - Adds hours to the issue with the optional comments
#   hubot link me &lt;issue-id&gt; - Returns a link to the redmine issue
#   hubot set &lt;issue-id&gt; to &lt;int&gt;% ["comments"] - Updates an issue and sets the percent done
#
# Notes:
#   &lt;issue-id&gt; can be formatted in the following ways: 1234, #1234,
#   issue 1234, issue #1234
#
# Author:
#   robhurring

if process.env.HUBOT_REDMINE_SSL?
  HTTP = require('https')
else
  HTTP = require('http')

URL = require('url')
QUERY = require('querystring')

module.exports = (robot) -&gt;
  redmine = new Redmine process.env.HUBOT_REDMINE_BASE_URL, process.env.HUBOT_REDMINE_TOKEN

  # Robot link me &lt;issue&gt;
  robot.respond /link me (?:issue )?(?:#)?(\d+)/i, (msg) -&gt;
    id = msg.match[1]
    msg.reply "#{redmine.url}/issues/#{id}"

  # Robot set &lt;issue&gt; to &lt;percent&gt;% ["comments"]
  robot.respond /set (?:issue )?(?:#)?(\d+) to (\d{1,3})%?(?: "?([^"]+)"?)?/i, (msg) -&gt;
    [id, percent, notes] = msg.match[1..3]
    percent = parseInt percent

    if notes?
      notes = "#{msg.message.user.name}: #{userComments}"
    else
      notes = "Ratio set by: #{msg.message.user.name}"

    attributes =
      "notes": notes
      "done_ratio": percent

    redmine.Issue(id).update attributes, (err, data, status) -&gt;
      if status == 200
        msg.reply "Set ##{id} to #{percent}%"
      else
        msg.reply "Update failed! (#{err})"

  # Robot add &lt;hours&gt; hours to &lt;issue_id&gt; ["comments for the time tracking"]
  robot.respond /add (\d{1,2}) hours? to (?:issue )?(?:#)?(\d+)(?: "?([^"]+)"?)?/i, (msg) -&gt;
    [hours, id, userComments] = msg.match[1..3]
    hours = parseInt hours

    if userComments?
      comments = "#{msg.message.user.name}: #{userComments}"
    else
      comments = "Time logged by: #{msg.message.user.name}"

    attributes =
      "issue_id": id
      "hours": hours
      "comments": comments

    redmine.TimeEntry(null).create attributes, (error, data, status) -&gt;
      if status == 201
        msg.reply "Your time was logged"
      else
        msg.reply "Nothing could be logged. Make sure RedMine has a default activity set for time tracking. (Settings -&gt; Enumerations -&gt; Activities)"

  # Robot show &lt;my|user's&gt; [redmine] issues
  robot.respond /show (?:my|(\w+\'s)) (?:redmine )?issues/i, (msg) -&gt;
    userMode = true
    firstName =
      if msg.match[1]?
        userMode = false
        msg.match[1].replace(/\'.+/, '')
      else
        msg.message.user.name.split(/\s/)[0]

    redmine.Users name:firstName, (err,data) -&gt;
      unless data.total_count &gt; 0
        msg.reply "Couldn't find any users with the name \"#{firstName}\""
        return false

      user = resolveUsers(firstName, data.users)[0]

      params =
        "assigned_to_id": user.id
        "limit": 25,
        "status_id": "open"
        "sort": "priority:desc",

      redmine.Issues params, (err, data) -&gt;
        if err?
          msg.reply "Couldn't get a list of issues for you!"
        else
          _ = []

          if userMode
            _.push "You have #{data.total_count} issue(s)."
          else
            _.push "#{user.firstname} has #{data.total_count} issue(s)."

          for issue in data.issues
            do (issue) -&gt;
              _.push "\n[#{issue.tracker.name} - #{issue.priority.name} - #{issue.status.name}] ##{issue.id}: #{issue.subject}"

          msg.reply _.join "\n"

  # Robot update &lt;issue&gt; with "&lt;note&gt;"
  robot.respond /update (?:issue )?(?:#)?(\d+)(?:\s*with\s*)?(?:[-:,])? (?:"?([^"]+)"?)/i, (msg) -&gt;
    [id, note] = msg.match[1..2]

    attributes =
      "notes": "#{msg.message.user.name}: #{note}"

    redmine.Issue(id).update attributes, (err, data, status) -&gt;
      unless data?
        if status == 404
          msg.reply "Issue ##{id} doesn't exist."
        else
          msg.reply "Couldn't update this issue, sorry :("
      else
        msg.reply "Done! Updated ##{id} with \"#{note}\""

  # Robot add issue to "&lt;project&gt;" [traker &lt;id&gt;] with "&lt;subject&gt;"
  robot.respond /add (?:issue )?(?:\s*to\s*)?(?:"?([^" ]+)"? )(?:tracker\s)?(\d+)?(?:\s*with\s*)("?([^"]+)"?)/i, (msg) -&gt;
    [project_id, tracker_id, subject] = msg.match[1..3]

    attributes =
      "project_id": "#{project_id}"
      "subject": "#{subject}"

    if tracker_id?
      attributes =
        "project_id": "#{project_id}"
        "subject": "#{subject}"
        "tracker_id": "#{tracker_id}"

    redmine.Issue().add attributes, (err, data, status) -&gt;
      unless data?
        if status == 404
          msg.reply "Couldn't update this issue, #{status} :("
      else
        msg.reply "Done! Added issue #{data.id} with \"#{subject}\""

  # Robot assign &lt;issue&gt; to &lt;user&gt; ["note to add with the assignment]
  robot.respond /assign (?:issue )?(?:#)?(\d+) to (\w+)(?: "?([^"]+)"?)?/i, (msg) -&gt;
    [id, userName, note] = msg.match[1..3]

    redmine.Users name:userName, (err, data) -&gt;
      unless data.total_count &gt; 0
        msg.reply "Couldn't find any users with the name \"#{userName}\""
        return false

      # try to resolve the user using login/firstname -- take the first result (hacky)
      user = resolveUsers(userName, data.users)[0]

      attributes =
        "assigned_to_id": user.id

      # allow an optional note with the re-assign
      attributes["notes"] = "#{msg.message.user.name}: #{note}" if note?

      # get our issue
      redmine.Issue(id).update attributes, (err, data, status) -&gt;
        unless data?
          if status == 404
            msg.reply "Issue ##{id} doesn't exist."
          else
            msg.reply "There was an error assigning this issue."
        else
          msg.reply "Assigned ##{id} to #{user.firstname}."
          msg.send '/play trombone' if parseInt(id) == 3631

  # Robot redmine me &lt;issue&gt;
  robot.respond /(?:redmine|show)(?: me)? (?:issue )?(?:#)?(\d+)/i, (msg) -&gt;
    id = msg.match[1]

    params =
      "include": "journals"

    redmine.Issue(id).show params, (err, data, status) -&gt;
      unless status == 200
        msg.reply "Issue ##{id} doesn't exist."
        return false

      issue = data.issue

      _ = []
      _.push "\n[#{issue.project.name} - #{issue.priority.name}] #{issue.tracker.name} ##{issue.id} (#{issue.status.name})"
      _.push "Assigned: #{issue.assigned_to?.name ? 'Nobody'} (opened by #{issue.author.name})"
      if issue.status.name.toLowerCase() != 'new'
         _.push "Progress: #{issue.done_ratio}% (#{issue.spent_hours} hours)"
      _.push "Subject: #{issue.subject}"
      _.push "\n#{issue.description}"

      # journals
      _.push "\n" + Array(10).join('-') + '8&lt;' + Array(50).join('-') + "\n"
      for journal in issue.journals
        do (journal) -&gt;
          if journal.notes? and journal.notes != ""
            date = formatDate journal.created_on, 'mm/dd/yyyy (hh:ii ap)'
            _.push "#{journal.user.name} on #{date}:"
            _.push "    #{journal.notes}\n"

      msg.reply _.join "\n"

# simple ghetto fab date formatter this should definitely be replaced, but didn't want to
# introduce dependencies this early
#
# dateStamp - any string that can initialize a date
# fmt - format string that may use the following elements
#       mm - month
#       dd - day
#       yyyy - full year
#       hh - hours
#       ii - minutes
#       ss - seconds
#       ap - am / pm
#
# returns the formatted date
formatDate = (dateStamp, fmt = 'mm/dd/yyyy at hh:ii ap') -&gt;
  d = new Date(dateStamp)

  # split up the date
  [m,d,y,h,i,s,ap] =
    [d.getMonth() + 1, d.getDate(), d.getFullYear(), d.getHours(), d.getMinutes(), d.getSeconds(), 'AM']

  # leadig 0s
  i = "0#{i}" if i &lt; 10
  s = "0#{s}" if s &lt; 10

  # adjust hours
  if h &gt; 12
    h = h - 12
    ap = "PM"

  # ghetto fab!
  fmt
    .replace(/mm/, m)
    .replace(/dd/, d)
    .replace(/yyyy/, y)
    .replace(/hh/, h)
    .replace(/ii/, i)
    .replace(/ss/, s)
    .replace(/ap/, ap)

# tries to resolve ambiguous users by matching login or firstname
# redmine's user search is pretty broad (using login/name/email/etc.) so
# we're trying to just pull it in a bit and get a single user
#
# name - this should be the name you're trying to match
# data - this is the array of users from redmine
#
# returns an array with a single user, or the original array if nothing matched
resolveUsers = (name, data) -&gt;
    name = name.toLowerCase();

    # try matching login
    found = data.filter (user) -&gt; user.login.toLowerCase() == name
    return found if found.length == 1

    # try first name
    found = data.filter (user) -&gt; user.firstname.toLowerCase() == name
    return found if found.length == 1

    # give up
    data

# Redmine API Mapping
# This isn't 100% complete, but its the basics for what we would need in campfire
class Redmine
  constructor: (url, token) -&gt;
    @url = url
    @token = token

  Users: (params, callback) -&gt;
    @get "/users.json", params, callback

  User: (id) -&gt;

    show: (callback) =&gt;
      @get "/users/#{id}.json", {}, callback

  Projects: (params, callback) -&gt;
    @get "/projects.json", params, callback

  Issues: (params, callback) -&gt;
    @get "/issues.json", params, callback

  Issue: (id) -&gt;

    show: (params, callback) =&gt;
      @get "/issues/#{id}.json", params, callback

    update: (attributes, callback) =&gt;
      @put "/issues/#{id}.json", {issue: attributes}, callback

    add: (attributes, callback) =&gt;
      @post "/issues.json", {issue: attributes}, callback

  TimeEntry: (id = null) -&gt;

    create: (attributes, callback) =&gt;
      @post "/time_entries.json", {time_entry: attributes}, callback

  # Private: do a GET request against the API
  get: (path, params, callback) -&gt;
    path = "#{path}?#{QUERY.stringify params}" if params?
    @request "GET", path, null, callback

  # Private: do a POST request against the API
  post: (path, body, callback) -&gt;
    @request "POST", path, body, callback

  # Private: do a PUT request against the API
  put: (path, body, callback) -&gt;
    @request "PUT", path, body, callback

  # Private: Perform a request against the redmine REST API
  # from the campfire adapter :)
  request: (method, path, body, callback) -&gt;
    headers =
      "Content-Type": "application/json"
      "X-Redmine-API-Key": @token

    endpoint = URL.parse(@url)
    pathname = endpoint.pathname.replace /^\/$/, ''

    options =
      "host"   : endpoint.hostname
      "port"   : endpoint.port
      "path"   : "#{pathname}#{path}"
      "method" : method
      "headers": headers

    if method in ["POST", "PUT"]
      if typeof(body) isnt "string"
        body = JSON.stringify body

      options.headers["Content-Length"] = body.length

    request = HTTP.request options, (response) -&gt;
      data = ""

      response.on "data", (chunk) -&gt;
        data += chunk

      response.on "end", -&gt;
        switch response.statusCode
          when 200
            try
              callback null, JSON.parse(data), response.statusCode
            catch err
              callback null, (data or { }), response.statusCode
          when 401
            throw new Error "401: Authentication failed."
          else
            console.error "Code: #{response.statusCode}"
            callback null, null, response.statusCode

      response.on "error", (err) -&gt;
        console.error "Redmine response error: #{err}"
        callback err, null, response.statusCode

    if method in ["POST", "PUT"]
      request.end(body, 'binary')
    else
      request.end()

    request.on "error", (err) -&gt;
      console.error "Redmine request error: #{err}"
      callback err, null, 0
</pre></body></html>