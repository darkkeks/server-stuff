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
    aws $AWS_OPTIONS s3 cp "s3://$S3_BUCKET/$S3_PREFIX/$LATEST_BACKUP" "$MONGO_DATABASE.dump.gz"

echo "Restoring $POSTGRES_DATABASE from $LATEST_BACKUP"
mongorestore --host "$MONGO_HOST" --port "${MONGO_PORT:=27017}" --archive="$MONGO_DATABASE.dump.gz" --drop

echo "Restored successfully"
