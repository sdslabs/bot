module.exports = (robot) ->

  robot.respond /teleport$/i, (msg) ->
    # Get the data from Jsonblob's api for the first time
    robot.http(process.env.JSONBLOB_URL).get() (err, res, body) ->
      robot.brain.mergeData JSON.parse(body)
  		msg.send "updated things \m/"

