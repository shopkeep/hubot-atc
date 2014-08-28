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

moment = require('moment')

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    robot.brain.data.stagehand ||= {}

  robot.respond /where can I deploy/i, (msg) ->
    msg.reply 'Environments you can deploy to:'
    for env in availableEnvironments()
      msg.send env


  robot.respond /atc who booked (\w+)/i, (msg) ->
    env_name = msg.match[1]
    env = extract_env(env_name)
    msg.reply "#{env_name} is free for use"  if moment() >= moment(env.expires)

  robot.respond /atc register (\w+)/i, (msg) ->
    env_name = msg.match[1]
    env = extract_env(env_name)
    set_env(env_name, { user: "initial", expires: moment().format() })

    msg.reply "Environment " + env_name + " registered."

  robot.respond /atc book (\w+)/i, (msg) ->
    env_name = msg.match[1]
    env = extract_env(env_name)
    set_env(env_name, { user: user_for_message(msg), expires: moment().add('minutes', 30).format() })

    msg.reply "Environment #{env_name} successfully booked by #{user_for_message(msg)}"

  extract_env = (env) ->
    robot.brain.data.stagehand[env]

  set_env = (env, data) ->
    robot.brain.data.stagehand[env] = data

  user_for_message = (msg) ->
    msg.message.user.name

  availableEnvironments = ->
    available_environments = []
    environments = robot.brain.data.stagehand
    for env of environments
      env_data = environments[env]
      available_environments.push env if moment(env_data.expires) <= moment()
    available_environments
