#!/bin/sh

APPNAME="edgar"
BRANCH=`git rev-parse --abbrev-ref HEAD`
HEROKU_APPNAME="$BRANCH-$APPNAME"

echo "*** Stopping  maintenance on $HEROKU_APPNAME"
heroku maintenance:off --app $HEROKU_APPNAME
echo "*** end maintenance on $HEROKU_APPNAME"
