class Lock
  constructor: (applicationName, environmentName, owner, branch, expires) ->
    @applicationName = applicationName
    @environmentName = environmentName
    @owner = owner
    @branch = branch
    @expires = expires

  expired: ->
    new Date() > @expires

  overview: ->
    "#{@owner} is releasing #{@applicationName}/#{@branch} to #{@environmentName}"

module.exports = Lock