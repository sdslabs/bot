# Description:
#   Summon with custom message
# 
# Dependencies:
#   None
#
# Configuration:
#   INFO_SPREADSHEET_URL
#   SDSLABS_MAIL_PASS
#
# Commands:
#   hubot summon <name> say <message>
#
# Author:
#   abhshkdz

email = ""
name = ""
emailbody = ""
module.exports = (robot) ->
  robot.respond /@?summon (.+) say (.+)*$/i, (msg) ->
    name = msg.match[1].trim()
    emailbody = msg.match[2].trim()
    msg.http(process.env.INFO_SPREADSHEET_URL)
      .get() (err, res, body) ->
        response = JSON.parse body
        email = -1
        if response["version"]
          findEmail(row) for row in response.feed.entry
          msg.send "Mailing "+email
          if email != -1
            auth = 'Basic ' + new Buffer('api:' + ).toString('base64');
            msg.http("https://api:"+process.env.MAILGUN_API_KEY+"@api.mailgun.net/v2/samples.mailgun.org/messages")
              .query({
                'to': email
                'text': emailbody,
                'from': 'SDSLabs Bot <bot@sdslabs.mailgun.org>',
                'subject':"You have been summoned"
              })
              .post()
          else
            msg.send "User not found."
        else
          msg.send "Error in gettin JSON data."
          
  findEmail = (row) ->
    if (row.title.$t.toLowerCase().indexOf(name.toLowerCase())>=0)
      email = row.content.$t.match(/(email): (\S+@\S+),/i)[2]