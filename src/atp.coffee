# Description:
#   Say Hi to Hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hello - "hello!"
#   hubot orly - "yarly"
#
# Author:
#   tombell

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    robot.brain.data.stagehand ||= {}

  robot.respond /where can I deploy/i, (msg) ->
    environments = Object.keys(robot.brain.data.stagehand)

    msg.reply 'Environments you can deploy to:'
    for env in environments
      msg.send env


  robot.respond /atp register (\w+)/i, (msg) ->
    env = msg.match[1]
    robot.brain.data.stagehand[env] ||= {}

    msg.reply "Environment #{env} registered."
