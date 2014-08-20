# Description:
#   Manage environments with Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot stagehand - "hodor!"
#   hubot message - "message!"
#
# Author:
#   akatz

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
      robot.brain.data.stagehand ?= {}

      robot.brain.data.stagehand['production'] = {}

  robot.respond /stagehand/, (msg) ->
    msg.reply "hodor!"

  robot.hear /message/, ->
    msg.send "message!"
