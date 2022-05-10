#!/bin/sh

set -eo pipefail

if [ "$S3_ACCESS_KEY_ID" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "$S3_SECRET_ACCESS_KEY" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "$S3_BUCKET" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "$S3_PREFIX" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "$POSTGRES_DATABASE" = "**None**" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "$POSTGRES_HOST" = "**None**" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ "$POSTGRES_USER" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "$POSTGRES_PASSWORD" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi


if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
