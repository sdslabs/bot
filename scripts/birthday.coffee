# Description:
#   gets sdslabs member's info from google doc
#   Type a partial name to get all matches
#
# Dependencies:
#   None
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot <birthday>
#
# Author:
#   Abhay Rana
#   http://captnemo.in
#
details = ""
username = ""
module.exports = (robot) ->
  robot.hear /birthday/i, (msg) ->
   msg.http(process.env.INFO_SPREADSHEET_URL)
    .get() (err, res, body) ->
      response = JSON.parse body 
      today=new Date
      for row in response.feed.entry
        #if there is a dob in records
        if(row.indexOf 'dob'>=0)
          result=row.content.$t.match /dob: ([0-9]{1,2})\/(\d*)/
          date=result[1]
          month=result[2]-1 #Months are indexed from 0-11 in JS
          minDiff=36500000
          if(month<today.getMonth() or (month==today.getMonth and date<today.getMonth))
            #if we need to add a year
            year=today.getYear+1
          else if month==today.getMonth() and date==today.getDate()
            msg.send "Today is "+row.title.$t+"'s birthday"
            #someone's birthday is today          
          #calculate person's DateOfBirth
          pDate=new Date today.getFullYear()+1, month, date
          diff=pDate-today #get difference
          if diff<minDiff #check diff
            birthdayMessage="Nearest birthday is "+row.title.$t+"'s on". pDate
      msg.send birthdayMessage
      #send the message