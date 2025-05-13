FROM alpine:3.20.3

EXPOSE 21 50000-50005

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache pure-ftpd tzdata

COPY ./tools/ftp-run.sh /root/

CMD [ "/root/ftp-run.sh" ]
