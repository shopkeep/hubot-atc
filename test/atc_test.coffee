chai = require 'chai'

sinon = require 'sinon'
chai.use require 'sinon-chai'

Path   = require("path")
Helper = require('hubot-test-helper')

room   = null
helper = new Helper(Path.join(__dirname, "..", "src", "atc.coffee"))

expect = chai.expect
assert = chai.assert

describe 'hello-world', ->
  beforeEach ->
    room = helper.createRoom()

  it "displays deployment environment help", ->
    room.user.say "akatz", "hubot where can i deploy"
    result = room.messages[1][1]
    expect(result).to.match /Environments you can deploy to/i

  context "registering an env", ->
    it "allows you to register a new env", ->
      room.user.say "akatz", "hubot atc register Production"
      result = room.messages[1][1]
      expect(result).to.match /Environment Production registered./i

    it "saves the env in redis", ->
      room.user.say "akatz", "hubot atc register Production"
      expect(Object.keys(room.robot.brain.data.stagehand)).to.include "Production"

    it "is initially unbooked", ->
      room.user.say "akatz", "hubot atc register Production"
      room.user.say "akatz", "hubot atc who booked Production"
      expect(room.messages[3][1]).to.match /Production is free for use/i


  context "with a list of environments", ->
    beforeEach ->
      room.user.say "akatz", "hubot atc register Production"
      room.user.say "akatz", "hubot atc register Staging"

    it "returns the list", ->
      room.user.say "akatz", "hubot where can i deploy"
      result = room.messages
      expect(result[5][1]).to.match /Environments you can deploy to/i
      expect(result[6][1]).to.match /Production/i
      expect(result[7][1]).to.match /Staging/i
      expect(result[8]).to.be.undefined

    context "when one is booked", ->
      beforeEach ->
        room.user.say "akatz", "hubot atc register Production"
        room.user.say "akatz", "hubot atc book Production"

      it "excludes that env from the list", ->
        room.user.say "akatz", "hubot where can i deploy"
        result = room.messages
        expect(result[9][1]).to.match /Environments you can deploy to/i
        expect(result[10][1]).to.match /Staging/i
        expect(result[11]).to.be.undefined
