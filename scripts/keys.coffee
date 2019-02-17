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

	kb_key = ()->
		Key = robot.brain.get("kb_key") or ""
		robot.brain.set("kb_key" ,Key)
		Key	

	ravindra_key = ()->
		Key = robot.brain.get("ravindra_key") or ""
		robot.brain.set("ravindra_key" ,Key)
		Key

	master_key = ()->
		Key = robot.brain.get("master_key") or ""
		robot.brain.set("master_key" ,Key)
		Key


#this section belongs to "i have keys"
	robot.respond /i have (.+) (a key|the key|key|keys)/i, (msg)->
		keyname = msg.match[1]
		name = msg.message.user.name 
		user = robot.brain.userForName name
		if keyname is 'ravindra' or 'rv'
			k = ravindra_key()
			if typeof user is 'object'
				msg.send "Okay #{name} has #{keyname} keys"
				k = user.name
			robot.brain.set("ravindra_key",k)
		else if keyname is 'kb' or 'kasturba'
			k = kb_key()
			if typeof user is 'object'
				msg.send "Okay #{name} has #{keyname} keys"
				k = user.name
			robot.brain.set("kb_key",k)
		else if keyname is 'master'
			k = root_key()
			if typeof user is 'object'
				msg.send "Okay #{name} has #{keyname} keys"
				k = user.name
			robot.brain.set("master_key",k)	

#this section belongs to "i dont have key"
	robot.respond /i (don\'t|dont|do not) (has|have) (.+) (the key|key|keys|a key)/i , (msg)->
		keyname = msg.match[3]
		name = msg.message.user.name
		user = robot.brain.userForName name
		
		if keyname is 'ravindra' || keyname is 'rv'
			k = ravindra_key()
			if k is name
				k = ""
			if typeof user is 'object'
				if k is ""
					msg.send "Okay #{name} doesn't have ravindra keys. Who got the ravindra keys then?"
				else
					msg.send "Yes , i know buddy, its because #{k} has got the ravindra keys"	
			robot.brain.set("ravindra_key",k)	
		else if keyname is 'kb' || keyname is 'kasturba'
			k = kb_key()
			if k is name
				k = ""
			if typeof user is 'object'
				if k is ""
					msg.send "Okay #{name} doesn't have kb keys. Who got the kb keys then?"
				else
					msg.send "Yes , i know buddy, its because #{k} has got the kb keys"	
			robot.brain.set("kb_key",k)	
		else if keyname is 'master'
			k = master_key()
			if k is name
				k = ""
			if typeof user is 'object'
				if k is ""
					msg.send "Okay #{name} doesn't have master keys. Who got the master keys then?"
				else
					msg.send "Yes , i know buddy, its because #{k} has got the master keys"	
			robot.brain.set("master_key",k)	

#this section belongs to "$name has keys"
	robot.respond /(.+) (has|have) (.+) (the key|key|keys|a key)/i , (msg)->
		othername = msg.match[1]
		keyname = msg.match[3]
		name = msg.message.user.name
		
		if keyname is 'ravindra' || keyname is 'rv'
			k = ravindra_key()
			unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
				if othername is 'you'
					msg.send "How am I supposed to take those ravindra keys? #{name} is a liar!"
				else if othername is robot.name
					msg.send "How am I supposed to take those ravindra keys? #{name} is a liar!"
				else
					users = robot.brain.userForName othername
					if users is null
						msg.send "I don't know anyone by the name #{othername}"
					else
						k = users.name
						msg.send "Okay, so now the ravindra keys are with #{users.name}"	
			robot.brain.set("ravindra_key",k)
		else if keyname is 'kb' || keyname is 'kasturba'
			k = kb_key()
			unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
				if othername is 'you'
					msg.send "How am I supposed to take those kb keys? #{name} is a liar!"
				else if othername is robot.name
					msg.send "How am I supposed to take those kb keys? #{name} is a liar!"
				else
					users = robot.brain.userForName othername
					if users is null
						msg.send "I don't know anyone by the name #{othername}"
					else
						k = users.name
						msg.send "Okay, so now the kb keys are with #{users.name}"
			robot.brain.set("kb_key",k)
		else if keyname is 'master'
			k = master_key()
			unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
				if othername is 'you'
					msg.send "How am I supposed to take those master keys? #{name} is a liar!"
				else if othername is robot.name
					msg.send "How am I supposed to take those master keys? #{name} is a liar!"
				else
					users = robot.brain.userForName othername
					if users is null
						msg.send "I don't know anyone by the name #{othername}"
					else
						k = users.name
						msg.send "Okay, so now the master keys are with #{users.name}"
			robot.brain.set("master_key",k)

#this section belongs to "i gave the keys to $name"
	robot.respond /(i|I) (have given|have given a|have given the|gave|gave the|gave a|had given|had given the|had given a) (.+) (key|keys) to (.+)/i , (msg)->
		othername = msg.match[5]
		keyname = msg.match[3]
		name = msg.message.user.name

		if keyname is 'ravindra' || keyname is 'rv'
			k = ravindra_key()
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
					msg.send "Okay, so now the ravindra keys are with #{users.name}"
			robot.brain.set("ravindra_key",k)	
		else if keyname is 'kb' || keyname is 'kasturba'
			k = kb_key()
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
					msg.send "Okay, so now the kb keys are with #{users.name}"
			robot.brain.set("kb_key",k)
		else if keyname is 'master'
			k = master_key()
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
					msg.send "Okay, so now the master keys are with #{users.name}"	
			robot.brain.set("master_key",k)		
		
#this section is to print the details about the key holder.		
	robot.respond /(who|who all) (has|have|has the|have the|has a|have a) (.+) (key|keys)/i , (msg)->
		othername = msg.match[3]
		if othername is 'ravindra' || othername is 'rv'
			k1 = ravindra_key()
			msgText = k1
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has ravindra keys"
				msg.send msgText	
			robot.brain.set("ravindra_key" ,k1)
		else if othername is 'kasturba' || othername is 'kb'
			k2 = kb_key()
			msgText = k2
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has kb keys"
				msg.send msgText	
			robot.brain.set("kb_key" ,k2)
		else if othername is 'master'
			k3 = master_key()
			msgText = k3
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has master keys"
				msg.send msgText	
			robot.brain.set("master_key" ,k3)
	

