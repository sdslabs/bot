Bot
===

bot is our friendly robot that sits on sdslabs chat and helps us in lots of things.
It is powered by Hubot (by GitHub), and uses some custom scripts as well.

This is hosted on the heroku free tier, and we use jsonblob.com as the brain storage
service.

Set-up Instructions
===================

After cloning repository, run the following command in the terminal:

JSONBLOB_URL="{JSONBLOB_URL}" INFO_SPREADSHEET_URL="{INFO_SPREADSHEET_URL}" bin/hubot

The config variables can be found from the heroku account.

