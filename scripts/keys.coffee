# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   bot who (has the|have the|has|have) (kb|kasturba|rv|ravindra|master) (key|keys) : returns current user having respective lab keys
#   bot i (have the|have) (kb|kasturba|rv|ravindra|master) (key|keys) : set's the respective key-holder to the user who posted
#   bot i (do not|don't|dont) (has the|have the|has|have) (kb|kasturba|rv|ravindra|master) (key|keys) : unsets the user who posted from the respective key-holders
#	bot uttu (has the|have the|has|have) (kb|kasturba|rv|ravindra|master) (key|keys) : sets uttu as the holder of respective keys
#	bot (i|I) (have given the|had given the|have given|gave the|had given|gave) (kb|kasturba|rv|ravindra|master) (key|keys) to uttu : sets uttu as the holder of respective keys
#
# Examples:
#   :bot who has kb keys
#   :bot i have rv keys
#   :bot i dont have master keys
#	:bot who has kasturba keys
#	:bot ravi has ravindra keys
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
	robot.respond /i (have the|have) (.+) (key|keys)/i, (msg)->
		keyname = msg.match[2]
		name = msg.message.user.name 
		user = robot.brain.userForName name
		unless keyname not in  ["rv", "ravindra", "kb", "kasturba", "master"]
			if keyname is 'ravindra' || keyname is 'rv'
				key_holder = ravindra_key()
				key_holder = user.name
				robot.brain.set("ravindra_key",key_holder)
			else if keyname is 'kb' || keyname is 'kasturba'
				key_holder = kb_key()
				key_holder = user.name
				robot.brain.set("kb_key",key_holder)
			else if keyname is 'master'
				key_holder = master_key()
				key_holder = user.name
				robot.brain.set("master_key",key_holder)
			if typeof user is 'object'
				msg.send "Okay #{name} has #{keyname} keys"	

#this section belongs to "i dont have key"
	robot.respond /i (do not|don\'t|dont) (has the|have the|has|have) (.+) (key|keys)/i , (msg)->
		keyname = msg.match[3]
		name = msg.message.user.name
		user = robot.brain.userForName name
		unless keyname not in  ["rv", "ravindra", "kb", "kasturba", "master"]
			if keyname is 'ravindra' || keyname is 'rv'
				key_holder = ravindra_key()
				if key_holder is name
					key_holder = ""	
				robot.brain.set("ravindra_key",key_holder)	
			else if keyname is 'kb' || keyname is 'kasturba'
				key_holder = kb_key()
				if key_holder is name
					key_holder = ""
				robot.brain.set("kb_key",key_holder)	
			else if keyname is 'master'
				key_holder = master_key()
				if key_holder is name
					key_holder = ""	
				robot.brain.set("master_key",key_holder)
			if typeof user is 'object'
				if key_holder is ""
					msg.send "Okay #{name} doesn't have #{keyname} keys. Who got the #{keyname} keys then?"
				else
					msg.send "Yes , I know buddy, its because #{key_holder} has got the #{keyname} keys"

#this section belongs to "$name has keys"
	robot.respond /(.+) (has the|have the|has|have) (.+) (key|keys)/i , (msg)->
		othername = msg.match[1]
		keyname = msg.match[3]
		name = msg.message.user.name
		unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
			unless keyname not in ["rv", "ravindra", "kb", "kasturba", "master"]
				users = robot.brain.userForName othername
				if users is null
					key_holder = null
				else
					key_holder = users.name
				if key_holder is null
					if othername is 'you'
						msg.send "How am I supposed to take those #{keyname} keys? #{name} is a liar!"
					else if othername is robot.name
						msg.send "That's utter lies! How can you blame a bot to have the keys?"
					else
						msg.send "I don't know anyone by the name #{othername}"
				else
					if keyname is 'ravindra' || keyname is 'rv'
						robot.brain.set("ravindra_key",key_holder)
					else if keyname is 'kb' || keyname is 'kasturba'
						robot.brain.set("kb_key",key_holder)
					else if keyname is 'master'
						robot.brain.set("master_key",key_holder)
					msg.send "Okay, so now the #{keyname} keys are with #{othername}"	

#this section belongs to "i gave the keys to $name"
	robot.respond /(i|I) (have given the|had given the|have given|gave the|had given|gave) (.+) (key|keys) to (.+)/i , (msg)->
		othername = msg.match[5]
		keyname = msg.match[3]
		name = msg.message.user.name
		unless keyname not in ["rv", "ravindra", "kb", "kasturba", "master"]
			users = robot.brain.userForName othername
			if users is null
				key_holder = null
			else
				key_holder = users.name
			if key_holder is null
				if othername is 'you'
					msg.send "That's utter lies! How can you blame a bot to have the keys? #{name} is a liar!"
				else if othername is robot.name
					msg.send "That's utter lies! How can you blame a bot to have the keys?"
				else
					msg.send "I don't know anyone by the name #{othername}"
			else
				if keyname is 'ravindra' || keyname is 'rv'
					robot.brain.set("ravindra_key",key_holder)	
				else if keyname is 'kb' || keyname is 'kasturba'
					robot.brain.set("kb_key",key_holder)
				else if keyname is 'master'
					robot.brain.set("master_key",key_holder)
				msg.send "Okay, so now the #{keyname} keys are with #{users.name}"
		
#this section is to print the details about the key holder.		
	robot.respond /who (has the|have the|has|have) (.+) (key|keys)/i , (msg)->
		keyname = msg.match[2]
		if keyname is 'ravindra' || keyname is 'rv'
			key_holder = ravindra_key()
			msgText = key_holder
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has ravindra keys"
				msg.send msgText	
			robot.brain.set("ravindra_key" ,key_holder)
		else if keyname is 'kasturba' || keyname is 'kb'
			key_holder = kb_key()
			msgText = key_holder
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has kb keys"
				msg.send msgText	
			robot.brain.set("kb_key" ,key_holder)
		else if keyname is 'master'
			key_holder = master_key()
			msgText = key_holder
			if msgText is ""
				msg.send "Ah! Nobody informed me about the keys. Don't hold me responsible for this :expressionless:"
			else
				msgText+=" has master keys"
				msg.send msgText	
			robot.brain.set("master_key" ,key_holder)
	