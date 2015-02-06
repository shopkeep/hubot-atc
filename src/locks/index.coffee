Lock = require('./lock.coffee')
moment = require('moment')

class Locks
  keyFor = (applicationName, environmentName) ->
    "#{applicationName}-#{environmentName}"

  defaultExpires = ->
    moment().add(60, 'minutes').toDate()

  expiryFor = (expires) ->
    return defaultExpires() unless expires.value && expires.unit

    moment().add(expires.value, expires.unit)

  constructor: ->
    @locks = {}

  lockFor: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    lock = @locks[key]

    if lock?.expired()
      @remove({ applicationName: applicationName, environmentName: environmentName})
      null
    else
      lock

  add: ({applicationName, environmentName}, owner, branch, expires) ->
    key = keyFor(applicationName, environmentName)
    expiry = expiryFor(expires)
    lock = new Lock(applicationName, environmentName, owner, branch, expiry)
    @locks[key] = lock

    lock

  remove: ({applicationName, environmentName}) ->
    key = keyFor(applicationName, environmentName)
    delete @locks[key]

  hasLock: (target) ->
    @lockFor(target)?

module.exports = Locks