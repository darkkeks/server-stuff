#!/bin/sh

set -eo pipefail

if [ -z "$S3_ACCESS_KEY_ID" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ -z "$S3_SECRET_ACCESS_KEY" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$S3_PREFIX" ]; then
  echo "You need to set the S3_PREFIX environment variable."
  exit 1
fi

if [ -z "$MONGO_HOST" ]; then
  echo "You need to set the MONGO_HOST environment variable."
  exit 1
fi

if [ -z "$MONGO_DATABASE" ]; then
  echo "You need to set the MONGO_DATABASE environment variable."
  exit 1
fi


if [ -z "$SCHEDULE" ]; then
  sh backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
