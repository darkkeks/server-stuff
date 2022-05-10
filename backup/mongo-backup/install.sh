#!/bin/sh

set -eo pipefail

apk update

# install mongodump
apk add mongodb-tools

# install s3 tools
apk add aws-cli

# install go-cron
apk add curl
curl -L https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron
apk del curl

# cleanup
rm -rf /var/cache/apk/*
