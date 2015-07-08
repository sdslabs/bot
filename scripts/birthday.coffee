# Description:
#  Wishes Members of SDSLabs Happy Birthday and also reminds other members :P
#
#
# Examples:
#   Happy Birthday Punit!! Turned {age} today..Chapo toh banti hai !!!
#   Next is Punit(pdhoot)'s Birthday on {date} {month}
# 
# Command:
#  bot birthday or bot birthdays
#
# Source of Data:
#	Takes data from Google Spreadsheet.
#
# Author:
#   Akashdeep Goel (@akash)
#   Developer at SDSLabs (@sdslabs)

http = require 'http'

date = 0

month = 0

year = 0

b_person = ""

data_start = 0

curr_date = new Date().getDate()

curr_month = new Date().getMonth() + 1

curr_year = new Date().getFullYear

b_nextPerson = ""

today = false

min_month = 14

min_date = 40

month_difference = 0

date_difference = 0

c_date = 0

c_month = 0

s_month_date = 33

out_month=""
module.exports = (robot) ->
	robot.respond /(birthdays|birthday)/i, (res) ->
		robot.http(process.env.INFO_SPREADSHEET_URL).get() (err, resp, body) ->
      		response = JSON.parse body 
      		if response["version"]
      			check = checkBirthday(row) for row in response.feed.entry
      			if b_person !=""
      				res.send "Happy Birthday #{b_person}!! Turned #{age} today.. Chapo toh banti hai !!!"
      			else
      				if(c_date==1||c_date==21||c_date==31)
      					if(c_month==1)
      						out_month = "January"
      					if(c_month==2)
      						out_month= "February"
      					if(c_month==3)
      						out_month = "March"
      					if(c_month==4)
      						out_month = "April"
      					if(c_month==5)
      						out_month = "May"
      					if(c_month==6)
      						out_month = "June"
      					if(c_month==7)
      						out_month = "July"
      					if(c_month==8)
      						out_month = "August"
      					if(c_month==9)
      						out_month = "September"
      					if(c_month==10)
      						out_month = "October"
      					if(c_month==11)
      						out_month = "November"
      					if(c_month==12)
      						out_month = "December"
      					res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}st #{out_month}"
      				if(c_date==2||c_date==22)
      					if(c_month==1)
      						out_month = "January"
      					if(c_month==2)
      						out_month= "February"
      					if(c_month==3)
      						out_month = "March"
      					if(c_month==4)
      						out_month = "April"
      					if(c_month==5)
      						out_month = "May"
      					if(c_month==6)
      						out_month = "June"
      					if(c_month==7)
      						out_month = "July"
      					if(c_month==8)
      						out_month = "August"
      					if(c_month==9)
      						out_month = "September"
      					if(c_month==10)
      						out_month = "October"
      					if(c_month==11)
      						out_month = "November"
      					if(c_month==12)
      						out_month = "December"
      					res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}nd #{out_month}"
      				if(c_date==3||c_date==23)
      					if(c_month==1)
      						out_month = "January"
      					if(c_month==2)
      						out_month= "February"
      					if(c_month==3)
      						out_month = "March"
      					if(c_month==4)
      						out_month = "April"
      					if(c_month==5)
      						out_month = "May"
      					if(c_month==6)
      						out_month = "June"
      					if(c_month==7)
      						out_month = "July"
      					if(c_month==8)
      						out_month = "August"
      					if(c_month==9)
      						out_month = "September"
      					if(c_month==10)
      						out_month = "October"
      					if(c_month==11)
      						out_month = "November"
      					if(c_month==12)
      						out_month = "December"
      					res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}rd #{out_month}"
      				if(c_date!=1&&c_date!=2&&c_date!=3&&c_date!=21&&c_date!=22&&c_date!=23&&c_date!=31)
      					if(c_month==1)
      						out_month = "January"
      					if(c_month==2)
      						out_month= "February"
      					if(c_month==3)
      						out_month = "March"
      					if(c_month==4)
      						out_month = "April"
      					if(c_month==5)
      						out_month = "May"
      					if(c_month==6)
      						out_month = "June"
      					if(c_month==7)
      						out_month = "July"
      					if(c_month==8)
      						out_month = "August"
      					if(c_month==9)
      						out_month = "September"
      					if(c_month==10)
      						out_month = "October"
      					if(c_month==11)
      						out_month = "November"
      					if(c_month==12)
      						out_month = "December"
      					res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}th #{out_month}"      				
      		else
      			res.send "Akash is the culprit!! Gave me wrong link"

	checkBirthday = (row) ->
		today = false
		data_start = row.content.$t.indexOf("dob")
		data_start = parseInt(data_start)
		data_start = data_start + 5
		date = (parseInt(row.content.$t[data_start])*10 + parseInt(row.content.$t[data_start+1]))
		month = (parseInt(row.content.$t[data_start+3])*10 + parseInt(row.content.$t[data_start+4]))
		year = (parseInt(row.content.$t[data_start+6])*1000 + parseInt(row.content.$t[data_start+7])*100 + parseInt(row.content.$t[data_start+8])*10 + parseInt(row.content.$t[data_start+9]))	
		if date==curr_date
			if month==curr_month	
				b_person = row.title.$t
				age = curr_year - year
				today = true;
		if (today==false)
			month_difference = month - curr_month
			if (month_difference<0)
				month_difference = 12 + month - curr_month	
			if (month_difference <= min_month)
				if month_difference==0
					if date>curr_date
						if date<s_month_date
							min_month = month_difference
							b_nextPerson = row.title.$t
							c_date = date
							c_month = month
							s_month_date = date
				if month_difference==min_month
					if date<min_date
						min_date= date
						min_month = month_difference
						b_nextPerson = row.title.$t
						c_date = date
						c_month = month
				if month_difference < min_month
					min_month = month_difference
					min_date = date
					b_nextPerson = row.title.$t
					c_date = date
					c_month = month
