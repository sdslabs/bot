#Description
#	Displays the people who have keys
#
#Dependencies
#	None
#
#Configuration
#	None
#
#Commands:
##	hubot i have keys
#	hubot who have keys
#	hubot user does not possess the keys anymore
#	hubot user has keys
#
#Author:
#	AartiNdi

module.export = (robot) ->


	robot.respond /(who all have) (lab keys) (\?)?/i, (msg) ->
		messageText=''
		users=robot.users()
		for k, u of users
			if u.keys
				messageText += "#{u.name} has keys\n"
			else
				messageText += ""
		if messageTet.trim() is "" then messageText = "Get the keys from Andromeda"
		msg.send messageText

	robot.respond /(i've | i have) keys /i, (msg) ->
		name = msg.message.user.name
		user = robot.userForName name

		if typeof user is 'object'
			user.keys = true
			msg.send "Alright #{user.name} is the secret keeper"

	robot.respond /(.*) (has keys) /i, (msg) ->
		name = msg.match[1]
		user=robot.userForName name
		if typeof user is 'object'
			user.keys = true
			msg.send "Alright #{user.name} is the secret keeper"
		else if typeof user.length > 1
      		msg.send "I found #{user.length} people named #{name}"
    	else
      		msg.send "Why didn't you introduce me to #{name}"		