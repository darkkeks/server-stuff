#!/bin/sh

set -eo pipefail

AWS_OPTIONS="--endpoint-url=https://storage.yandexcloud.net/"

GRAFANA_DB="/var/lib/grafana/grafana.db"

echo "Uploading backup of to S3"
AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY \
    aws $AWS_OPTIONS s3 cp "$GRAFANA_DB" "s3://$S3_BUCKET/$S3_PREFIX/grafana_$(date +"%Y-%m-%dT%H:%M:%SZ").db"
echo "Uploaded successfully"
