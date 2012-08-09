# Hubot adapter for Partychat-Hooks #

This is an adapter that connects [hubot](http://hubot.github.com/) to [partychat](http://partychapp.appspot.com/), by way of [partychat-hooks](http://partychat-hooks.appspot.com/).

# Setup #

## Create a hook ##

1. Log into [partychat-hooks](http://partychat-hooks.appspot.com/) and create a
   hook for your chat room.

2. Click `New Post Hook` and enter this as the body:

        {{get_argument("body")}}

   Take note of the HTTP Endpoint. You'll need to pass this to hubot.

3. Click `New Receive Hook`. For the command sequence, enter `*`.

   For the HTTP Endpoint, enter the address+port that hubot will run at,
   plus `/partychat`. For example:

        http://hooks.myserver.com:8080/partychat

## Set up your hubot ##

1. [Obtain your own Hubot](http://hubot.github.com/).

2. Edit `package.json`, adding this to the dependencies:

        "hubot-partychat-hooks": "0.x"

3. Install the needed packages.

        npm install

## SYSTEMS ONLINE ##

1. Remember that Post Hook endpoint from earlier? You need it now.

        HUBOT_POST_ENDPOINT=http://partychat-hooks.appspot.com/post/p_xyzabc12 bin/hubot -a partychat-hooks
