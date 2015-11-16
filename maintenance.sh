#!/bin/sh

APPNAME="edgar"
BRANCH=`git rev-parse --abbrev-ref HEAD`
HEROKU_APPNAME="$BRANCH-$APPNAME"
MAINTENANCE_PAGE_BASE="http://merciedgar-pages.s3.amazonaws.com"
MAINTENANCE_FLAVOR=$1

if [ "$MAINTENANCE_FLAVOR" != "" ]
then
  MAINTENANCE_PAGE="maintenance_$MAINTENANCE_FLAVOR.html"
else
  MAINTENANCE_PAGE="maintenance.html"
fi

echo "*** set maintenance $MAINTENANCE_FLAVOR to $HEROKU_APPNAME"

heroku config:set MAINTENANCE_PAGE_URL=$MAINTENANCE_PAGE_BASE/$MAINTENANCE_PAGE --app $HEROKU_APPNAME

echo "*** Activating maintenance on $HEROKU_APPNAME"
heroku maintenance:on --app $HEROKU_APPNAME
echo "*** end activating maintenance on $HEROKU_APPNAME"
