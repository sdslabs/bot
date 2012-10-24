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
            msg.http("http://vps2.sdslabs.co.in/mail/send.php?from=contact@sdslabs.co.in&subject=SDSLabs:%20URGENT&pass="+process.env.SDSLABS_MAIL_PASS)
              .query({
                'to': email
                'body': emailbody
              })
              .get() (err, res, body) ->
                msg.send "#{body}"
          else
            msg.send "User not found."
        else
          msg.send "Error in gettin JSON data."
          
  findEmail = (row) ->
    if (row.title.$t.toLowerCase().indexOf(name.toLowerCase())>=0)
      email = row.content.$t.match(/(email): (\S+@\S+),/i)[2]

