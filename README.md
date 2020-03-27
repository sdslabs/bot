# bot

bot is our friendly robot that sits on SDSLabs Slack and helps us in lots of things.
It is powered by Hubot (by GitHub), and have been personalized for our use case.

This is hosted on the Heroku Free tier, and we use https://github.com/sdslabs/botdb as the brain storage
service. This can be changed to use https://jsonblob.com too (`botdb` and JSON Blob use the same API endpoints).

## Set-up Instructions

1. Setup [botdb](https://github.com/sdslabs/botdb) using the setup instructions.

2. Clone this repository at your desired location

```bash
  git clone https://github.com/sdslabs/bot
  cd bot
```

3. Prepare a Google Sheet using this template and enable link sharing 

4. Setup environment variables

```bash
  export JSONBLOB_URL="http://localhost:5050/"
  export JSONBLOB_TOKEN="token_set_in_botdb"
  export INFO_SPREADSHEET_URL="csv_export_url_of_link"
```

5. Run the bot for testing using `./bin/hubot`

