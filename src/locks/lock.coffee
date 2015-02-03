moment = require('moment')

class Lock
  constructor: (applicationName, environmentName, owner, branch, expires) ->
    @applicationName = applicationName
    @environmentName = environmentName
    @owner = owner
    @branch = branch
    @expires = expires

  expired: ->
    new Date() > @expires

  remainingTime: ->
    moment(@expires).diff(new Date(), 'minutes') + ' minutes'

  overview: ->
    "#{@owner} is releasing #{@applicationName}/#{@branch} " +
    "to #{@environmentName} " +
    "for #{@remainingTime()}"

module.exports = Lock