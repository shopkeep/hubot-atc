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
#   hubot release hubot to staging for 30 minutes
#   can I release hubot to staging?

Locks = require('./locks')

filterElementFromArray = (element, array) ->
  array.filter (word) -> word isnt element

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    robot.brain.data.applications ||= []
    robot.brain.data.environments ||= {}
    robot.brain.data.locks ||= new Locks()

  validateApplicationName = (msg, applicationName) ->
    currentApplications = robot.brain.data.applications
    return true if applicationName in currentApplications

    msg.reply "application #{applicationName} doesn't exist"
    false

  validateEnvironmentName = (msg, applicationName, environmentName) ->
    currentEnvironments = robot.brain.data.environments[applicationName] || []
    return true if environmentName in currentEnvironments

    msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    false

  validateTarget = (msg, {applicationName, environmentName}) ->
    validateApplicationName(msg, applicationName) && validateEnvironmentName(msg, applicationName, environmentName)

  robot.respond /application list/i, (msg) ->
    applications = robot.brain.data.applications
    if applications.length > 0
      sorted_applications = applications.sort().join(', ')
      msg.reply "applications available: #{sorted_applications}"
    else
      msg.reply "No applications exist"

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
    currentEnvironments = robot.brain.data.environments[applicationName] || []

    return unless validateApplicationName(msg, applicationName)

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
    currentEnvironments = robot.brain.data.environments[applicationName] || []

    if environmentName not in currentEnvironments
      msg.reply "environment #{environmentName} doesn't exist for #{applicationName}"
    else
      robot.brain.data.environments[applicationName] = filterElementFromArray(environmentName, currentEnvironments)

      msg.reply "environment #{environmentName} removed from #{applicationName}"

  robot.respond /release ([^\/\s]+)\/?(\S+)? to (\w+)/i, (msg) ->
    target = { applicationName: msg.match[1], environmentName: msg.match[3] }
    return unless validateTarget(msg, target)

    branch = msg.match[2] || "master"

    requester = msg.message.user.name
    locks = robot.brain.data.locks

    unless locks.hasLock(target)
      lock = locks.add(target, requester, branch)
      msg.send lock.overview()
    else
      lock = locks.lockFor(target)
      msg.send "sorry, #{lock.overview()}"

  robot.hear /can I release ([^\/\s]+) to (\w+)/i, (msg)->
    target = { applicationName: msg.match[1], environmentName: msg.match[2] }
    return unless validateTarget(msg, target)

    locks = robot.brain.data.locks

    unless locks.hasLock(target)
      msg.reply "yes, #{target.applicationName} is releasable to #{target.environmentName}"
    else
      lock = locks.lockFor(target)
      msg.send "sorry, #{lock.overview()}"

  robot.respond /done releasing ([^\/\s]+) to (\w+)/i, (msg) ->
    target = { applicationName: msg.match[1], environmentName: msg.match[2] }
    return unless validateTarget(msg, target)

    requester = msg.message.user.name
    locks = robot.brain.data.locks
    lock = locks.lockFor(target)

    if lock.owner == requester
      locks.remove(target)
      msg.send "#{target.applicationName} #{target.environmentName} is free for releases"
    else
      msg.send "sorry, #{lock.overview()}"
