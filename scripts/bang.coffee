module.exports = (robot) ->

	bangSection = () ->
		Field = robot.brain.get("bang") or {}
		robot.brain.set("bang",Field)
		Field
 
	robot.respond /bang [a-zA-Z0-9\-_]+\s*/gi, (msg) ->
		Msg = msg.message.text
		parsed = Msg.replace /.*bang /, ""

		array = parsed.split /\s+/

		bangdata = bangSection()

		

		# storing something
		if array.length == 1

			if bangdata[array[0]]
				msg.send bangdata[array[0]]

			else
				msg.send "You never taught me this thing"

		# retrieving something
		else

			toBang = array[1]

			for i in [2...array.length]
				toBang = toBang + " " + array[i]

			bangdata[array[0]] = toBang
			msg.send "Banged #{toBang} into #{array[0]}"