chai = require 'chai'

sinon = require 'sinon'
chai.use require 'sinon-chai'

Helper = require('hubot-test-helper')
helper = new Helper('../src')

expect = chai.expect
assert = chai.assert

describe 'hubot-atc', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  lastMessage = (room) ->
    lastMessageIndex = room.messages.length - 1
    room.messages[lastMessageIndex][1]

  describe "applications", ->
    describe "adding", ->
      context "when there are none", ->
        it 'adds the application', ->
          room.user.say "duncan", "hubot application add foo"
          expect(room.robot.brain.data.applications).to.include "foo"

        it 'responds with the proper message', ->
          room.user.say "duncan", "hubot application add foo"
          expect(lastMessage(room)).to.match /application foo was added/

      context "when there are already apps", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add foo"
          room.user.say "duncan", "hubot application add foo"

        it 'only adds the application once', ->
          expect(room.robot.brain.data.applications).eql ["foo"]

        it 'responds with the proper error message', ->
          expect(lastMessage(room)).to.match /application foo already exists/

        it 'adds the new app and responds with the proper message', ->
          room.user.say "duncan", "hubot application add bar"
          expect(lastMessage(room)).to.match /application bar was added/

        it 'adds the new app', ->
          room.user.say "duncan", "hubot application add bar"
          expect(room.robot.brain.data.applications).to.eql ["foo", "bar"]

    describe "removing", ->
      context "when there are apps", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add foo"

        it "removes the app", ->
          room.user.say "duncan", "hubot application remove foo"
          expect(room.robot.brain.data.applications).eql []

        it "respnds with the proper message", ->
          room.user.say "duncan", "hubot application remove foo"
          expect(lastMessage(room)).to.match /application foo was removed/

      context "when the app doesn't exist", ->
        it "responds with the proper message", ->
          room.user.say "duncan", "hubot application remove foo"
          expect(lastMessage(room)).to.match /application foo doesn't exist/

    describe "environments", ->
      describe "adding", ->
        context "for an unknown application", ->
          it "responds with the error message", ->
            room.user.say "duncan", "hubot environment add staging to foo"
            expect(lastMessage(room)).to.match /application foo doesn't exist/

        context "for an existing application", ->
          context "and no environments exist", ->
            beforeEach ->
              room.user.say "duncan", "hubot application add foo"

            it "responds with the correct message", ->
              room.user.say "duncan", "hubot environment add staging to foo"
              expect(lastMessage(room)).to.match /environment staging added to foo/

            it "creates the environment for the application", ->
              room.user.say "duncan", "hubot environment add staging to foo"
              expect(room.robot.brain.data.environments["foo"]).to.eql ["staging"]

          context "and it has environments", ->
            beforeEach ->
              room.user.say "duncan", "hubot application add foo"
              room.user.say "duncan", "hubot environment add staging to foo"

            context "and the environment is new", ->
              it "responds with the correct message", ->
                room.user.say "duncan", "hubot environment add production to foo"
                expect(lastMessage(room)).to.match /environment production added to foo/

              it "is added", ->
                room.user.say "duncan", "hubot environment add production to foo"
                expect(room.robot.brain.data.environments["foo"]).to.eql ["staging", "production"]

            context "and the environment exists", ->
              beforeEach ->
                room.user.say "duncan", "hubot environment add production to foo"

              it "is a no op", ->
                room.user.say "duncan", "hubot environment add production to foo"
                expect(room.robot.brain.data.environments["foo"]).to.eql ["staging", "production"]

              it "responds with the proper message", ->
                room.user.say "duncan", "hubot environment add production to foo"
                expect(lastMessage(room)).to.match /environment production already exists for foo/

      describe "removing", ->
        context "for an unknown app", ->
          it "returns the proper error message", ->
            room.user.say "duncan", "hubot environment remove production from foo"
            expect(lastMessage(room)).to.match /environment production doesn't exist for foo/

        context "for a known application", ->
          beforeEach ->
            room.user.say "duncan", "hubot application add foo"

          context "an unknown environment", ->
            it 'returns the proper error message', ->
              room.user.say "duncan", "hubot environment remove production from foo"
              expect(lastMessage(room)).to.match /environment production doesn't exist for foo/

          context "a known environment", ->
            beforeEach ->
              room.user.say "duncan", "hubot environment add production to foo"

            it 'removes the environment', ->
              room.user.say "duncan", "hubot environment remove production from foo"
              expect(room.robot.brain.data.environments["foo"]).to.eql []

            it 'returns the proper message', ->
              room.user.say "duncan", "hubot environment remove production from foo"
              expect(lastMessage(room)).to.match /environment production removed from foo/

  describe "release", ->
    context "with an app", ->
      context "and an environment", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add hubot"
          room.user.say "duncan", "hubot environment add staging to hubot"

        context "when there is no lock", ->
          context 'allows you to release', ->
            it 'defaults to master', ->
              room.user.say "akatz", "hubot release hubot to staging"
              expect(lastMessage(room)).to.match /^akatz is now releasing hubot\/master to staging/

            it 'allows you to choose a branch', ->
              room.user.say "akatz", "hubot release hubot/test-this to staging"
              expect(lastMessage(room)).to.match /^akatz is now releasing hubot\/test-this to staging/

            it 'allows you to choose a commit', ->
              room.user.say "akatz", "hubot release hubot/1f1920a007f to staging"
              expect(lastMessage(room)).to.match /^akatz is now releasing hubot\/1f1920a007f to staging/

        context "when there is a lock", ->
          beforeEach ->
            room.user.say "akatz", "hubot release hubot to staging"

          it "tells you no", ->
            room.user.say "duncan", "hubot release hubot to staging"
            expect(lastMessage(room)).to.match /sorry, akatz is releasing hubot\/master to staging/

      context "without an environment", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add hubot"

        it 'tells you to do a better job', ->
          room.user.say "duncan", "hubot release hubot to staging"
          expect(lastMessage(room)).to.match /environment staging doesn't exist for hubot/
    context "without an app", ->
      it 'tells you to do a better job', ->
        room.user.say "duncan", "hubot release hubot to staging"
        expect(lastMessage(room)).to.match /application hubot doesn't exist/

  describe "release", ->
    context "with an app", ->
      context "and an environment", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add hubot"
          room.user.say "duncan", "hubot environment add staging to hubot"

        context "when there is a lock", ->
          context 'and you are the releaser', ->
            beforeEach ->
              room.user.say "duncan", "hubot release hubot to staging"

            it 'allows you to release the lock', ->
              room.user.say "duncan", "hubot done releasing hubot to staging"
              expect(lastMessage(room)).to.match /hubot staging is free for releases/

            it 'allows another person to release when the lock is freed', ->
              room.user.say "duncan", "hubot done releasing hubot to staging"
              room.user.say "akatz", "hubot release hubot to staging"

              expect(lastMessage(room)).to.match /akatz is now releasing hubot\/master to staging/

          context 'and you are not the releaser', ->
            beforeEach ->
              room.user.say "duncan", "hubot release hubot to staging"

            it 'allows you to release the lock', ->
              room.user.say "akatz", "hubot done releasing hubot to staging"
              expect(lastMessage(room)).to.match /sorry, duncan is currently releasing hubot\/master to staging/

      context "without an environment", ->
        beforeEach ->
          room.user.say "duncan", "hubot application add hubot"

        it 'tells you to do a better job', ->
          room.user.say "duncan", "hubot done releasing hubot to staging"
          expect(lastMessage(room)).to.match /environment staging doesn't exist for hubot/

    context "without an app", ->
      it 'tells you to do a better job', ->
        room.user.say "duncan", "hubot done releasing hubot to staging"
        expect(lastMessage(room)).to.match /application hubot doesn't exist/

  describe "can I release?", ->
    context "with an app", ->
      beforeEach ->
        room.user.say "duncan", "hubot application add hubot"
      context "and an environment", ->
        beforeEach ->
          room.user.say "duncan", "hubot environment add staging to hubot"
        context "that is unlocked", ->
          it "tells you yes", ->
            room.user.say "duncan", "can I release hubot to staging?"
            expect(lastMessage(room)).to.match /yes, hubot is releasable to staging/
        context "that is locked", ->
          beforeEach ->
            room.user.say "duncan", "hubot release hubot to staging"

          it "tells you no", ->
            room.user.say "akatz", "can I release hubot to staging"
            expect(lastMessage(room)).to.match /sorry, duncan is releasing hubot\/master to staging/

      context "without an environment", ->
        it 'tells you to do a better job', ->
          room.user.say "akatz", "can I release hubot to staging"
          expect(lastMessage(room)).to.match /environment staging doesn't exist for hubot/

    context "without an app", ->
      it 'tells you to do a better job', ->
        room.user.say "akatz", "can I release hubot to staging"
        expect(lastMessage(room)).to.match /application hubot doesn't exist/
