#!/bin/sh

APPNAME="edgar"
BRANCH=`git rev-parse --abbrev-ref HEAD`
DESTINATION="git@heroku.com:$BRANCH-$APPNAME.git"

echo "*** deploy $APPNAME to $DESTINATION"

git pull origin $BRANCH && \
  bundle exec rake spec && \
  git push origin $BRANCH && \
  echo "git push $DESTINATION $BRANCH:master" && \
  git push $DESTINATION $BRANCH:master

echo "*** end deploy $APPNAME to $DESTINATION"
