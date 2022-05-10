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


AWS_OPTIONS="--endpoint-url=https://storage.yandexcloud.net/"

function latest_backup {
    AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY \
        aws $AWS_OPTIONS s3 ls "s3://$S3_BUCKET/$S3_PREFIX/" | sort | tail -n 1 | awk '{ print $4 }'
}


echo "Finding latest backup"
LATEST_BACKUP=$(latest_backup)

echo "Fetching $LATEST_BACKUP"
AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY \
    aws $AWS_OPTIONS s3 cp "s3://$S3_BUCKET/$S3_PREFIX/$LATEST_BACKUP" "$POSTGRES_DATABASE.dump"

echo "Restoring $POSTGRES_DATABASE from $LATEST_BACKUP"
PGHOST=$POSTGRES_HOST \
PGPORT=$POSTGRES_PORT \
PGUSER=$POSTGRES_USER \
PGPASSWORD=$POSTGRES_PASSWORD \
    pg_restore --clean --if-exists --dbname $POSTGRES_DATABASE --format custom "$POSTGRES_DATABASE.dump"

echo "Restored successfully"
