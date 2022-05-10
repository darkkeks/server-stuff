#!/bin/sh

set -eo pipefail

AWS_OPTIONS="--endpoint-url=https://storage.yandexcloud.net/"

echo "Creating backup of database $MONGO_DATABASE from $MONGO_HOST"
mongodump --host "$MONGO_HOST" --port "${MONGO_PORT:=27017}" --archive="$MONGO_DATABASE.dump.gz"

echo "Uploading backup to S3"
AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY \
    aws $AWS_OPTIONS s3 cp "$MONGO_DATABASE.dump.gz" "s3://$S3_BUCKET/$S3_PREFIX/${MONGO_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").dump.gz"

echo "Uploaded successfully"
rm "$MONGO_DATABASE.dump.gz"
