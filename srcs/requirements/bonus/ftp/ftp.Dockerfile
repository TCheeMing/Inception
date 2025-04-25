FROM alpine:3.20.3

EXPOSE 21 30000-30005

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache vsftpd tzdata

COPY ./configs/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/ftp-run.sh	/root/

CMD [ "/root/ftp-run.sh" ]