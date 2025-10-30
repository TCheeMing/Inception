FROM alpine:3.22.2

EXPOSE 514

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/log/

RUN apk add --no-cache rsyslog tzdata && \
	mv /etc/rsyslog.conf /etc/rsyslog.conf.default

COPY ./configs/rsyslog.conf /etc/
COPY ./tools/rsyslog-run.sh /root/

CMD [ "/root/rsyslog-run.sh" ]
