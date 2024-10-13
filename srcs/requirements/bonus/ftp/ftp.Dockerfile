FROM alpine:3.20.3

EXPOSE 22

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache openssh tzdata && \
	ssh-keygen -A && \
	mv /etc/ssh/sshd_config /etc/ssh/sshd_config.default

COPY ./configs/sshd_config /etc/ssh/
COPY ./tools/ftp-run.sh	/root/

CMD [ "/root/ftp-run.sh" ]