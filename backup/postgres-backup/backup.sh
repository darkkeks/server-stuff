#!/bin/sh

set -eo pipefail

AWS_OPTIONS="--endpoint-url=https://storage.yandexcloud.net/"

echo "Creating backup of database $POSTGRES_DATABASE from $POSTGRES_HOST"
PGHOST=$POSTGRES_HOST \
PGPORT=$POSTGRES_PORT \
PGUSER=$POSTGRES_USER \
PGDATABASE=$POSTGRES_DATABASE \
PGPASSWORD=$POSTGRES_PASSWORD \
    pg_dump --format custom > "$POSTGRES_DATABASE.dump"

echo "Uploading backup to S3"
AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY \
    aws $AWS_OPTIONS s3 cp "$POSTGRES_DATABASE.dump" "s3://$S3_BUCKET/$S3_PREFIX/${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").dump"

echo "Uploaded successfully"
rm "$POSTGRES_DATABASE.dump"
