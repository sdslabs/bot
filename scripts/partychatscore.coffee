module.exports = (robot) ->

	# parsed score data from old partychat + recent new
	data = [{"name":"muzi","scorebox":5},{"name":"github","scorebox":3},{"name":"nemo","scorebox":249},{"name":"shagun","scorebox":49},{"name":"neeraj","scorebox":20},{"name":"jayant","scorebox":25},{"name":"sm","scorebox":150},{"name":"sethu","scorebox":1215},{"name":"ankita","scorebox":13},{"name":"durgesh","scorebox":27},{"name":"richa","scorebox":17},{"name":"nisha","scorebox":19},{"name":"kandoi","scorebox":49},{"name":"ashwini","scorebox":91},{"name":"bot","scorebox":13},{"name":"deepali","scorebox":34},{"name":"satyam","scorebox":24},{"name":"saket","scorebox":10},{"name":"chetty","scorebox":86},{"name":"pranav","scorebox":18},{"name":"rishabh","scorebox":11},{"name":"das","scorebox":106},{"name":"divij","scorebox":46},{"name":"abhinav","scorebox":7},{"name":"kushal","scorebox":20},{"name":"rt","scorebox":53},{"name":"surya","scorebox":12},{"name":"evileyes","scorebox":11},{"name":"pravj","scorebox":20},{"name":"vikalp","scorebox":12},{"name":"parag","scorebox":12},{"name":"aps","scorebox":3},{"name":"sdslabs","scorebox":2},{"name":"nano","scorebox":2},{"name":"ravi","scorebox":118},{"name":"vkm","scorebox":1},{"name":"dc","scorebox":1}]

	robot.respond /teleport score/i, (msg) ->
		names = (janta.name for janta in data)
		scores = (janta.scorebox for janta in data)

		# object to store data for all keywords
		# storing this in brain's "scorefield" key
		ScoreField = robot.brain.get("scorefield") or {}
		robot.brain.set("scorefield",ScoreField)

		i = 0
		for name in names
			ScoreField[name] = scores[i]
			i = i + 1

		msg.send "updated things \m/"