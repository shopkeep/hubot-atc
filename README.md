# Hubot ATC

[![Build Status](https://magnum.travis-ci.com/shopkeep/hubot-atc.svg?token=k5XqB7xVsuXDBZsrELpB&branch=master)](https://magnum.travis-ci.com/shopkeep/hubot-atc)

## Usage

Include it in your hubot's package.json as a dependency, and it's external-scripts.json file.

### Managing your applications and environments

This section provides an example walkthrough of registering an application, adding environments for that application, and releasing a version of the application.

```
# Add an application
hubot atc add application foobar
#=> application foobar was added


# Add some environments to that application
hubot atc add environment staging to foobar
#=> environment staging added to foobar

hubot atc add environment production to foobar
#=> environment production added to foobar


# Ask if you can release that application to that environment
hubot can I release foobar to staging?
#=> yes, foobar is releasable to staging


# Release foobar/master to staging
hubot atc release foobar/master to staging
#=> user is now releasing hubot\/master to staging


# Let other people release
hubot atc done releasing foobar to staging
#=>foobar staging is now free for releases
```
