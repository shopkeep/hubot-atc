# Description:
#   An air traffic controller that powers your releases
#
# Configuration:
#   None
#
# Commands:
#   hubot application add hubot
#   hubot application remove hubot
#   hubot environment add staging to hubot
#   hubot environment remove staging to hubot
#   hubot release hubot to staging
#   can I release hubot to staging?

Locks = require('./locks')

filterElementFromArray = (element, array) ->
  array.filter (word) -> word isnt element

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    robot.brain.data.applications ||= []
    robot.brain.data.environments ||= {}
    robot.brain.data.locks ||= new Locks()

  robot.respond /application add ([^\/\s]+)/i, (msg) ->
    applicationName = msg.match[1]
    applications = robot.brain.data.applications
    if applicationName not in applications
      applications.push(applicationName)
      msg.reply "application #{applicationName} was added"
    else
      msg.reply "application #{applicationName} already exists"

  robot.respond /application remove ([^\/\s]+)/i, (msg) ->
    applicationName = msg.match[1]
    applications = robot.brain.data.applications
    if applicationName in applications
      robot.brain.data.applications = filterElementFromArray(applicationName, applications)
      msg.reply "application #{applicationName} was removed"
    else
      msg.reply "application #{applicationName} doesn't exist"

  robot.respond /environment add (\w+) to ([^\/\s]+)/i, (msg) ->
    environmentName = msg.match[1]
    applicationName = msg.match[2]
    currentApplications = robot.brain.data.applications
    currentEnvironments = robot.brain.data.environments[applicationName] || []

    if applicationName not in currentApplications
      msg.reply "application #{applicationName} doesn't exist"
      return

    if environmentName not in currentEnvironments
      if currentEnvironments.length > 0
        currentEnvironments.push(environmentName)
      else
        robot.brain.data.environments[applicationName] = [environmentName]

      msg.reply "environment #{environmentName} added to #{applicationName}"
    else
      msg.reply "environment #{environmentName} already exists for #{applicationName}"

  robot.respond /environment remove (\w+) from ([^\/\s]+)/i, (msg) ->
    environmentName = msg.match[1]
    applicationName = msg.match[2]
    currentApplications = robot.brain.data.applications
    currentEnvironments = robot.brain.data.environments[applicationName] || []

    if environmentName not in currentEnvironments
      msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    else
      robot.brain.data.environments[applicationName] = filterElementFromArray(environmentName, currentEnvironments)

      msg.reply "environment #{environmentName} removed from #{applicationName}"

  robot.respond /release ([^\/\s]+)\/?(\S+)? to (\w+)/i, (msg) ->
    applicationName = msg.match[1]
    branch = msg.match[2] || "master"
    environmentName = msg.match[3]
    requester = msg.message.user.name
    currentApplications = robot.brain.data.applications
    currentEnvironments = robot.brain.data.environments[applicationName] || []

    if applicationName not in currentApplications
      msg.reply "application #{applicationName} doesn't exist"
    else if environmentName not in currentEnvironments
      msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    else
      unless robot.brain.data.locks.hasLock(applicationName, environmentName)
        lock = robot.brain.data.locks.add(applicationName, environmentName, requester, branch)
        msg.send "#{requester} is now releasing #{applicationName}/#{branch} to #{environmentName}"
      else
        lock = robot.brain.data.locks.lockFor(applicationName, environmentName)
        msg.send "sorry, #{lock.overview()}"

  robot.hear /can I release ([^\/\s]+) to (\w+)/i, (msg)->
    applicationName = msg.match[1]
    environmentName = msg.match[2]
    currentApplications = robot.brain.data.applications
    currentEnvironments = robot.brain.data.environments[applicationName] || []
    locks = robot.brain.data.locks

    if applicationName not in currentApplications
      msg.reply "application #{applicationName} doesn't exist"
    else if environmentName not in currentEnvironments
      msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    else
      unless locks.hasLock(applicationName, environmentName)
        msg.reply "yes, #{applicationName} is releasable to #{environmentName}"
      else
        lock = locks.lockFor(applicationName, environmentName)
        msg.send "sorry, #{lock.overview()}"

  robot.respond /done releasing ([^\/\s]+) to (\w+)/i, (msg) ->
    applicationName = msg.match[1]
    environmentName = msg.match[2]
    currentApplications = robot.brain.data.applications
    currentEnvironments = robot.brain.data.environments[applicationName] || []
    requester = msg.message.user.name

    locks = robot.brain.data.locks
    lock = locks.lockFor(applicationName, environmentName)

    if applicationName not in currentApplications
      msg.reply "application #{applicationName} doesn't exist"
    else if environmentName not in currentEnvironments
      msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    else
      if lock.owner == requester
        locks.remove(applicationName, environmentName)
        msg.send "#{applicationName} #{environmentName} is free for releases"
      else
        msg.send "sorry, #{lock.overview()}"
