FROM alpine:3.15

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ADD restore.sh restore.sh

CMD ["sh", "restore.sh"]
