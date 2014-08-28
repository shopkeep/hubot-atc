chai = require 'chai'

sinon = require 'sinon'
chai.use require 'sinon-chai'

Path   = require("path")
Helper = require('hubot-test-helper')

room   = null
helper = new Helper(Path.join(__dirname, "..", "src", "atp.coffee"))

expect = chai.expect
assert = chai.assert

describe 'hello-world', ->
  beforeEach ->
    room = helper.createRoom()

  it "displays deployment environment help", () ->
    room.user.say 'akatz', 'hubot where can i deploy'

    result = room.messages[1][1]
    expect(result).to.match(/Environments you can deploy to/im)

  it "allows you to register a new env", () ->
    room.user.say 'akatz', 'hubot atp register Production'
    result = room.messages[1][1]
    expect(result).to.match(/Environment Production registered./im)

  it "saves the env in redis", () ->
    room.user.say 'akatz', 'hubot atp register Production'
    expect(Object.keys(room.robot.brain.data.stagehand)).to.include('Production')

  context 'with a list of environments', () ->
    beforeEach ->
      room.robot.brain.data.stagehand.Production = {}
      room.robot.brain.data.stagehand.Staging = {}

    it "returns the list", () ->
      room.user.say 'akatz', 'hubot where can i deploy'
      result = room.messages
      expect(result[1][1]).to.match(/Environments you can deploy to/im)
      expect(result[2][1]).to.match(/Production/im)
      expect(result[3][1]).to.match(/Staging/im)
      expect(result[4]).to.be.undefined
