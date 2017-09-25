chai = require 'chai'

sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require('hubot-test-helper')
helper = new Helper('../src')

Locks = require('../src/locks');

expect = chai.expect
assert = chai.assert

describe 'hubot-atc', ->

  beforeEach ->
    @clock = sinon.useFakeTimers()
    @room = helper.createRoom()
    @room.robot.brain.data.applications = []
    @room.robot.brain.data.environments = {}

  afterEach ->
    @clock.restore()
    @room.destroy()

  lastMessage = (room) ->
    lastMessageIndex = room.messages.length - 1
    room.messages[lastMessageIndex][1]

  addApplication = (room, applicationName) ->
    room.robot.brain.data.applications.push(applicationName);
    room.robot.brain.data.environments[applicationName] = [];

  addApplicationEnvironment = (room, applicationName, environmentName) ->
    room.robot.brain.data.environments[applicationName].push(environmentName);

  deployApplication = (room, userName, applicationName, environmentName) ->
    locks = new Locks()
    deploymentDetails = { applicationName: applicationName, environmentName: environmentName }

    locks.add(deploymentDetails, userName, "master")

    room.robot.brain.data.locks = locks

  describe "applications", ->
    describe "listing", ->
      context "when there are none", ->
        it 'responds with the proper message', ->
          @room.user.say("duncan", "hubot application list").then =>
            expect(lastMessage(@room)).to.match /No applications exist/

      context "when there are already apps", ->
        beforeEach ->
          addApplication(@room, "foo")
          addApplication(@room, "bar")

        it 'responds with the proper message', ->
          @room.user.say("duncan", "hubot application list").then =>
            expect(lastMessage(@room)).to.match /applications available: bar, foo/

    describe "adding", ->
      context "when there are none", ->
        it 'adds the application', ->
          @room.user.say("duncan", "hubot application add foo").then =>
            expect(@room.robot.brain.data.applications).to.include "foo"

        it 'responds with the proper message', ->
          @room.user.say("duncan", "hubot application add foo").then =>
            expect(lastMessage(@room)).to.match /application foo was added/

      context "when there are already apps", ->
        beforeEach ->
          addApplication(@room, "foo")

        it 'only adds the application once', ->
          @room.user.say("duncan", "hubot application add foo").then =>
            expect(@room.robot.brain.data.applications).eql ["foo"]

        it 'responds with the proper error message', ->
          @room.user.say("duncan", "hubot application add foo").then =>
            expect(lastMessage(@room)).to.match /application foo already exists/

        it 'adds the new app and responds with the proper message', ->
          @room.user.say("duncan", "hubot application add bar").then =>
            expect(lastMessage(@room)).to.match /application bar was added/

        it 'adds the new app', ->
          @room.user.say("duncan", "hubot application add bar").then =>
            expect(@room.robot.brain.data.applications).to.eql ["foo", "bar"]

        it 'handles hypens', ->
          @room.user.say("duncan", "hubot application add bar-baz").then =>
            expect(@room.robot.brain.data.applications).to.eql ["foo", "bar-baz"]

        it 'handles pluses', ->
          @room.user.say("duncan", "hubot application add bar+baz").then =>
            expect(@room.robot.brain.data.applications).to.eql ["foo", "bar+baz"]

    describe "removing", ->
      context "when there are apps", ->
        beforeEach ->
          addApplication(@room, "foo")

        it "removes the app", ->
          @room.user.say("duncan", "hubot application remove foo").then =>
            expect(@room.robot.brain.data.applications).eql []

        it "respnds with the proper message", ->
          @room.user.say("duncan", "hubot application remove foo").then =>
            expect(lastMessage(@room)).to.match /application foo was removed/

      context "when the app doesn't exist", ->
        it "responds with the proper message", ->
          @room.user.say("duncan", "hubot application remove foo").then =>
            expect(lastMessage(@room)).to.match /application foo doesn't exist/

    describe "environments", ->
      describe "adding", ->
        context "for an unknown application", ->
          it "responds with the error message", ->
            @room.user.say("duncan", "hubot environment add staging to foo").then =>
              expect(lastMessage(@room)).to.match /application foo doesn't exist/

        context "for an existing application", ->
          context "and no environments exist", ->
            beforeEach ->
              addApplication(@room, "foo")

            it "responds with the correct message", ->
              @room.user.say("duncan", "hubot environment add staging to foo").then =>
                expect(lastMessage(@room)).to.match /environment staging added to foo/

            it "creates the environment for the application", ->
              @room.user.say("duncan", "hubot environment add staging to foo").then =>
                expect(@room.robot.brain.data.environments["foo"]).to.eql ["staging"]

          context "and it has environments", ->
            beforeEach ->
              addApplication(@room, "foo")
              addApplicationEnvironment(@room, "foo", "staging")

            context "and the environment is new", ->
              it "responds with the correct message", ->
                @room.user.say("duncan", "hubot environment add production to foo").then =>
                  expect(lastMessage(@room)).to.match /environment production added to foo/

              it "is added", ->
                @room.user.say("duncan", "hubot environment add production to foo").then =>
                  expect(@room.robot.brain.data.environments["foo"]).to.eql ["staging", "production"]

            context "and the environment exists", ->
              beforeEach ->
                addApplicationEnvironment(@room, "foo", "production")

              it "is a no op", ->
                @room.user.say("duncan", "hubot environment add production to foo").then =>
                  expect(@room.robot.brain.data.environments["foo"]).to.eql ["staging", "production"]

              it "responds with the proper message", ->
                @room.user.say("duncan", "hubot environment add production to foo").then =>
                  expect(lastMessage(@room)).to.match /environment production already exists for foo/

      describe "removing", ->
        context "for an unknown app", ->
          it "returns the proper error message", ->
            @room.user.say("duncan", "hubot environment remove production from foo").then =>
              expect(lastMessage(@room)).to.match /environment production doesn't exist for foo/

        context "for a known application", ->
          beforeEach ->
            addApplication(@room, "foo")

          context "an unknown environment", ->
            it 'returns the proper error message', ->
              @room.user.say("duncan", "hubot environment remove production from foo").then =>
                expect(lastMessage(@room)).to.match /environment production doesn't exist for foo/

          context "a known environment", ->
            beforeEach ->
              addApplicationEnvironment(@room, "foo", "production")

            it 'removes the environment', ->
              @room.user.say("duncan", "hubot environment remove production from foo").then =>
                expect(@room.robot.brain.data.environments["foo"]).to.eql []

            it 'returns the proper message', ->
              @room.user.say("duncan", "hubot environment remove production from foo").then =>
                expect(lastMessage(@room)).to.match /environment production removed from foo/

  describe "release", ->
    context "with an app", ->
      beforeEach ->
        addApplication(@room, "hubot")

      context "and an environment", ->
        beforeEach ->
          addApplicationEnvironment(@room, "hubot", "staging")

        context "when there is no lock", ->
          context 'allows you to release', ->
            it 'defaults to master', ->
              @room.user.say("akatz", "hubot release hubot to staging").then =>
                expect(lastMessage(@room)).to.match /^akatz is releasing hubot\/master to staging/

            it 'allows you to choose a branch', ->
              @room.user.say("akatz", "hubot release hubot/test-this to staging").then =>
                expect(lastMessage(@room)).to.match /^akatz is releasing hubot\/test-this to staging/

            it 'allows you to choose a commit', ->
              @room.user.say("akatz", "hubot release hubot/1f1920a007f to staging").then =>
                expect(lastMessage(@room)).to.match /^akatz is releasing hubot\/1f1920a007f to staging/

        context "when there is a lock", ->
          beforeEach ->
            deployApplication(@room, "akatz", "hubot", "staging")

          context "and releasing master", ->
            it "tells you no", ->
              @room.user.say("duncan", "hubot release hubot to staging").then =>
                expect(lastMessage(@room)).to.match /sorry, akatz is releasing hubot\/master to staging/

          context "and releasing a branch", ->
            it "tells you no", ->
              @room.user.say("duncan", "hubot release hubot/my_branch to staging").then =>
                expect(lastMessage(@room)).to.match /sorry, akatz is releasing hubot\/master to staging/

      context "without an environment", ->
        it 'tells you to do a better job', ->
          @room.user.say("duncan", "hubot release hubot to staging").then =>
            expect(lastMessage(@room)).to.match /environment staging doesn't exist for hubot/

    context "without an app", ->
      it 'tells you to do a better job', ->
        @room.user.say("duncan", "hubot release hubot to staging").then =>
          expect(lastMessage(@room)).to.match /application hubot doesn't exist/

  describe "release", ->
    context "with an app", ->
      context "and an environment", ->
        beforeEach ->
          addApplication(@room, "hubot")
          addApplicationEnvironment(@room, "hubot", "staging")

        context "when there is a lock", ->
          context 'and you are the releaser', ->
            beforeEach ->
              deployApplication(@room, "duncan", "hubot", "staging")

            it 'allows you to release the lock', ->
              @room.user.say("duncan", "hubot done releasing hubot to staging").then =>
                expect(lastMessage(@room)).to.match /hubot staging is free for releases/

            it 'allows another person to release when the lock is freed', ->
              @room.user.say("duncan", "hubot done releasing hubot to staging").then =>
                @room.user.say("akatz", "hubot release hubot to staging").then =>
                  expect(lastMessage(@room)).to.match /akatz is releasing hubot\/master to staging/

          context 'and you are not the releaser', ->
            beforeEach ->
              deployApplication(@room, "duncan", "hubot", "staging")

            it 'allows you to release the lock', ->
              @room.user.say("akatz", "hubot done releasing hubot to staging").then =>
                expect(lastMessage(@room)).to.match /sorry, duncan is releasing hubot\/master to staging/

      context "without an environment", ->
        beforeEach ->
          addApplication(@room, "hubot")

        it 'tells you to do a better job', ->
          @room.user.say("duncan", "hubot done releasing hubot to staging").then =>
            expect(lastMessage(@room)).to.match /environment staging doesn't exist for hubot/

    context "without an app", ->
      it 'tells you to do a better job', ->
        @room.user.say("duncan", "hubot done releasing hubot to staging").then =>
          expect(lastMessage(@room)).to.match /application hubot doesn't exist/

  describe "can I release?", ->
    context "with an app", ->
      beforeEach ->
        addApplication(@room, "hubot")

      context "and an environment", ->
        beforeEach ->
          addApplicationEnvironment(@room, "hubot", "staging")

        context "that is unlocked", ->
          it "tells you yes", ->
            @room.user.say("duncan", "can I release hubot to staging?").then =>
              expect(lastMessage(@room)).to.match /yes, hubot is releasable to staging/

        context "that is locked", ->
          beforeEach ->
            deployApplication(@room, "duncan", "hubot", "staging")

          it "tells you no", ->
            @room.user.say("akatz", "can I release hubot to staging").then =>
              expect(lastMessage(@room)).to.match /sorry, duncan is releasing hubot\/master to staging/

      context "without an environment", ->
        it 'tells you to do a better job', ->
          @room.user.say("akatz", "can I release hubot to staging").then =>
            expect(lastMessage(@room)).to.match /environment staging doesn't exist for hubot/

    context "without an app", ->
      it 'tells you to do a better job', ->
        @room.user.say("akatz", "can I release hubot to staging").then =>
          expect(lastMessage(@room)).to.match /application hubot doesn't exist/
