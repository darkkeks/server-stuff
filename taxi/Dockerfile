FROM alpine:3.6
RUN apk update
RUN apk add jq
RUN apk add curl
COPY taxi.sh /usr/bin/taxi.sh
COPY crontab /etc/crontabs/root
CMD ["crond", "-f", "-d", "8"]
