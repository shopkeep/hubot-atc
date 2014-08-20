# http://chaijs.com/
chai = require 'chai'
# https://github.com/domenic/sinon-chai
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hello-world', ->
  user =
    name: 'foo'
    id: 'U123'
  robot =
    respond: sinon.spy()
    hear: sinon.spy()
    brain:
      on: (_, cb) ->
        cb()
      data: {}
      userForName: (who) ->
        forName =
          name: who
          id: 'U234'

  beforeEach ->
    @robot = robot
    @user = user
    @data = @robot.brain.data
    @msg =
      send: sinon.spy()
      reply: sinon.spy()
      envelope:
        user:
          @user
      message:
        user:
          @user


    require('../src/hello-world')(@robot)

  it 'sets up an empty brain', ->
    expect(@data.stagehand.production).to.be.an('object')

  it 'registers a respond listener', ->
    expect(@robot.respond).to.have.been.calledWith(/stagehand/)

  it 'registers a hear listener', ->
    expect(@robot.hear).to.have.been.calledWith(/message/)
