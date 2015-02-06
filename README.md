# Hubot ATC

[![Build Status](https://travis-ci.org/shopkeep/hubot-atc.svg?branch=master)](https://travis-ci.org/shopkeep/hubot-atc)

## Usage

Include it in your hubot's package.json as a dependency, and it's external-scripts.json file.

### Managing your applications and environments

This section provides an example walkthrough of registering an application, adding environments for that application, and releasing a version of the application.

# Setup

```
# Add an application
hubot application add foobar
#=> application foobar was added


# Add some environments to that application
hubot environment add staging to foobar
#=> environment staging added to foobar

hubot environment add production to foobar
#=> environment production added to foobar
```

# Release

```
# Ask if you can release that application to that environment
hubot can I release foobar to staging?
#=> yes, foobar is releasable to staging

# Release foobar/master to staging
hubot release foobar/master to staging
#=> user is now releasing hubot\/master to staging for 60 minutes

hubot release foobar/master to staging for 30 minutes
#=> user is now releasing hubot\/master to staging for 30 minutes

hubot release foobar/master to staging for 2 hours
#=> user is now releasing hubot\/master to staging for 120 minutes

# Let other people release
hubot done releasing foobar to staging
#=>foobar staging is now free for releases
```
