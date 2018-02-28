# Description:
#   Listens for webhooks from google apps script on Ideas page at https://goo.gl/Pmw2D5
#

module.exports = (robot) ->
  robot.router.post '/webhook/idea/', (req, res) ->
    try
      robot.logger.info("Ideas new entry recieved", req.body)
      json = req.body
      if json.name and json.idea
        msg = "New Idea posted by #{json.name}\n```#{json.idea}```"
        robot.send room: 'general', msg
    catch error
      robot.logger.error "Ideas webhook listener error: #{error.stack}. Request: #{req.body}"

    res.end ""
