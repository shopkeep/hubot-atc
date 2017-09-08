Lock = require('./lock.coffee')

class Locks
  keyFor = (applicationName, environmentName) ->
    "#{applicationName}-#{environmentName}"

  constructor: ->
    @locks = {}

  lockFor: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    lock = @locks[key]
    lock

  add: ({applicationName, environmentName}, owner, branch) ->
    key = keyFor(applicationName, environmentName)
    lock = new Lock(applicationName, environmentName, owner, branch)
    @locks[key] = lock

    lock

  remove: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    delete @locks[key]

  hasLock: (target) ->
    @lockFor(target)?

module.exports = Locks