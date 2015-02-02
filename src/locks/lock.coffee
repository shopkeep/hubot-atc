class Lock
  constructor: (applicationName, environmentName, owner, branch) ->
    @applicationName = applicationName
    @environmentName = environmentName
    @owner = owner
    @branch = branch

  overview: ->
    "#{@owner} is releasing #{@applicationName}/#{@branch} to #{@environmentName}"

module.exports = Lock