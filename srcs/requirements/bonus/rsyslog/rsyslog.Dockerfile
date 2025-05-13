FROM alpine:3.20.3

EXPOSE 514

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/log/

RUN apk add --no-cache rsyslog tzdata && \
	mv /etc/rsyslog.conf /etc/rsyslog.conf.default

COPY ./configs/rsyslog.conf /etc/
COPY ./tools/rsyslog-run.sh /root/

CMD [ "/root/rsyslog-run.sh" ]
