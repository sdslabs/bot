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
#     Takes data from Google Spreadsheet.
#
# Author:
#   Akashdeep Goel (@akash)
#   Developer at SDSLabs (@sdslabs)

http = require 'http'

date = 0

month = 0

year = 0

age = ""

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

monthMap = ["January","February","March","April","May","June","July","August","September","October","November","December"]

birthdayTrack = null
module.exports = (robot) ->
      robot.respond /(birthdays|birthday)/i, (res) ->
            if birthdayTrack
                  min_date = 40
                  min_month = 14
                  s_month_date = 33
                  today = false
                  robot.http(process.env.INFO_SPREADSHEET_URL).get() (err, resp, body) ->
                        response = JSON.parse body
                        if response["version"]
                              for row in response.feed.entry
                                    checkBirthday(row)
                              if today is true
                                    res.send "Happy Birthday #{b_nextPerson}!! Turned #{age} today.. Chapo toh banti hai !!!"
                              else
                                    if(c_date==1||c_date==21||c_date==31)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}st #{monthMap[c_month-1]}"
                                    if(c_date==2||c_date==22)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}nd #{monthMap[c_month-1]}"
                                    if(c_date==3||c_date==23)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}rd #{monthMap[c_month-1]}"
                                    if(c_date!=1&&c_date!=2&&c_date!=3&&c_date!=21&&c_date!=22&&c_date!=23&&c_date!=31)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}th #{monthMap[c_month-1]}"
                        else
                              res.send "Akash is the culprit!! Gave me wrong link"
                  return
            birthdayTrack = setInterval () ->
                  min_date = 40
                  min_month = 14
                  s_month_date = 33
                  today = false
                  robot.http(process.env.INFO_SPREADSHEET_URL).get() (err, resp, body) ->
                        response = JSON.parse body
                        if response["version"]
                              for row in response.feed.entry
                                    checkBirthday(row)
                              if today is true
                                    res.send "Happy Birthday #{b_nextPerson}!! Turned #{age} today.. Chapo toh banti hai !!!"
                              else
                                    if(c_date==1||c_date==21||c_date==31)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}st #{monthMap[c_month-1]}"
                                    if(c_date==2||c_date==22)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}nd #{monthMap[c_month-1]}"
                                    if(c_date==3||c_date==23)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}rd #{monthMap[c_month-1]}"
                                    if(c_date!=1&&c_date!=2&&c_date!=3&&c_date!=21&&c_date!=22&&c_date!=23&&c_date!=31)
                                          res.send "Next is #{b_nextPerson}\'s birthday on #{c_date}th #{monthMap[c_month-1]}"
                        else
                              res.send "Akash is the culprit!! Gave me wrong link"
            , 86400000

      robot.respond /stop/, (res) ->
            if birthdayTrack
                  res.send "Not tracking Birthdays!"
                  clearInterval(birthdayTrack) ->
                  birthdayTrack = null
            else
                  res.send "Not annoying you right now, am I?"

      checkBirthday = (row) ->
            sendobj = []
            data_start = row.content.$t.indexOf("dob")
            data_start = parseInt(data_start)
            data_start = data_start + 5
            date = (parseInt(row.content.$t[data_start])*10 + parseInt(row.content.$t[data_start+1]))
            month = (parseInt(row.content.$t[data_start+3])*10 + parseInt(row.content.$t[data_start+4]))
            year = (parseInt(row.content.$t[data_start+6])*1000 + parseInt(row.content.$t[data_start+7])*100 + parseInt(row.content.$t[data_start+8])*10 + parseInt(row.content.$t[data_start+9]))
            if date==curr_date
                  if month==curr_month
                        today = true
                        b_nextPerson = row.title.$t
                        age = curr_year - year
            else if (today==false)
                  month_difference = month - curr_month
                  if month_difference<0
                        month_difference = 12 + month_difference
                  if month_difference<=min_month
                        if month_difference==0
                              if date>curr_date
                                    if date<s_month_date
                                          min_month = month_difference
                                          b_nextPerson = row.title.$t
                                          c_date = date
                                          c_month = month
                                          s_month_date = date
                        else if month_difference==min_month
                              if date<min_date
                                    min_date= date
                                    b_nextPerson = row.title.$t
                                    c_date = date
                                    c_month = month
                        else if month_difference < min_month
                              min_month = month_difference
                              min_date = date
                              b_nextPerson = row.title.$t
                              c_date = date
                              c_month = month
                        else