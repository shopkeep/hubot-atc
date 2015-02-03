Lock = require('./lock.coffee')

class Locks
  constructor: ->
    @locks = {}

  keyFor = (applicationName, environmentName) ->
    "#{applicationName}-#{environmentName}"

  lockFor: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    @locks[key]

  add: ({applicationName, environmentName}, owner, branch) ->
    key = keyFor(applicationName, environmentName)
    lock = new Lock(applicationName, environmentName, owner, branch)
    @locks[key] = lock
    lock

  remove: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    @locks[key] = null

  hasLock: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    lock = @locks[key]
    lock?

module.exports = Locks