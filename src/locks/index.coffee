Lock = require('./lock.coffee')
moment = require('moment')

class Locks
  keyFor = (applicationName, environmentName) ->
    "#{applicationName}-#{environmentName}"

  constructor: ->
    @defaultExpires = moment().add(60, 'minutes').toDate()
    @locks = {}

  lockFor: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    lock = @locks[key]

    if lock?.expired()
      @remove(applicationName, environmentName)
      null
    else
      lock

  add: ({applicationName, environmentName}, owner, branch) ->
    key = keyFor(applicationName, environmentName)
    expires = @defaultExpires
    lock = new Lock(applicationName, environmentName, owner, branch, expires)
    @locks[key] = lock
    lock

  remove: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    @locks[key] = null

  hasLock: (target) ->
    @lockFor(target)?

module.exports = Locks