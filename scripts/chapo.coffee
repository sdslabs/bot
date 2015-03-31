# Description:
#  displays the list of the pending chapos
#
# Commands:
#   listen for 
#   bot chapo user for reason
# 	bot show all pending chapos
#
# Examples:
#   :bot chapo nemo for everything
#   :bot chapo nightfury for nothing
#   :bot show all pending chapos
# 	:bot display all pending chapos
#
# Author:
#   Punit Dhoot (@pdhoot)
#   Developer at SDSLabs (@sdslabs)
module.exports = (robot)->
	chapoList = ()->
		chapo = []
		chapo = robot.brain.get('chapos') or []
		robot.brain.set('chapos' , chapo)
		chapo

	robot.respond /chapo (.+) for (.+)/i , (msg)->
		username = msg.match[1]
		user = robot.brain.userForName username
		if username is "bot"
			msg.send "Was that a joke? :unamused"
		else if user is null
			msg.send "You can't get a chapo from a virtual user. Please check the uesrname."
		else
			reason = msg.match[2]
			chapo = []
			chapo = chapoList()
			chapo[username] = reason
			robot.brain.set("chapos" , chapo)
			msg.send "Ok , added this to the list of remaining chapos"

	robot.respond /(show|display|give) all (pending|remaining) (chapos|chapo)/i , (msg)->
		chapo = []
		chapo = chapoList()
		string = "Pending chapos"
		for key , value of chapo
			string+="\n"
			string+="#{key} for #{value}"
		if string is "Pending chapos"
			msg.send "There are no pending chapos"
		else		
			msg.send string		

	robot.respond /(.+) gave chapo/i , (msg)->
		user = msg.match[1]
		chapo = []
		chapo = chapoList()
		if 	chapo[user] 
			delete chapo[user]
			msg.send "Hmm.. #{user} fullfils his promises."
		else
			msg.send "There was no such pending chapo"		

	