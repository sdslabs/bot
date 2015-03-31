# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for * has/have keys in chat text and displays users with the keys/updates the user having keys
#   bot who has keys : returns current user having lab keys
#   bot i have keys : set's the key-holder to the user who posted
#   bot i dont have keys : unsets the user who posted from key-holders
#	bot xyz has keys : sets xyz as the holder of keys
#
# Examples:
#   :bot who has keys
#   :bot i have keys
#   :bot i dont have keys
#	:bot who has keys
#	:bot ravi has keys
#
# Author:
#   Punit Dhoot (@pdhoot)
#   Developer at SDSLabs (@sdslabs)

module.exports = (robot)->

	key = ()->
		Key = robot.brain.get("key") or ""
		robot.brain.set("key" ,Key)
		Key	

	
	robot.respond /i have (a key|the key|key|keys)/i, (msg)->
		name = msg.message.user.name 
		user = robot.brain.userForName name
		k = key()
		if typeof user is 'object'
			msg.send "Okay #{name} has keys"
			k = user.name
		robot.brain.set("key",k)	


	robot.respond /i (don\'t|dont|do not) (has|have) (the key|key|keys|a key)/i , (msg)->
		name = msg.message.user.name
		user = robot.brain.userForName name
		k = key()
		if k is name
			k = ""
		if typeof user is 'object'
			if k is ""
				msg.send "Okay #{name} doesn't have keys. Who got the keys then?"
			else
				msg.send "Yes , i know buddy, its because #{k} has got the keys"	
		robot.brain.set("key",k)	


	robot.respond /(.+) (has|have) (the key|key|keys|a key)/i , (msg)->
		othername = msg.match[1]
		name = msg.message.user.name
		k = key()
		unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
			if othername is 'you'
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else if othername is robot.name
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else
				users = robot.brain.userForName othername
				if users is null
					msg.send "I don't know anyone by the name #{othername}"
				else
					k = users.name
					msg.send "Okay, so now the keys are with #{users.name}"	

		robot.brain.set("key",k)			

	robot.respond /(i|I) (have given|gave|had given) (the key|key|keys|a key|the keys) to (.+)/i , (msg)->
		othername = msg.match[4]
		name = msg.message.user.name
		k = key()
		if othername is 'you'
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else if othername is robot.name
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else
			users = robot.brain.userForName othername
			if users is null
				msg.send "I don't know anyone by the name #{othername}"
			else
				k = users.name
				msg.send "Okay, so now the keys are with #{users.name}"	
			

		robot.brain.set("key",k)		
				
	robot.respond /(who|who all) (has|have) (the key|key|keys|a key)/i , (msg)->
		k = key()
		msgText = k
		if msgText is ""
			msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
		else
			msgText+=" has keys"
			msg.send msgText	
		robot.brain.set("key" ,k)	

