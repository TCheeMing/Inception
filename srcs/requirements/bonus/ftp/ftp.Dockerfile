FROM alpine:3.20.3

WORKDIR /var/www/html/

RUN apk add --no-cache openssh && \
	ssh-keygen -A && \
	mv /etc/ssh/sshd_config /etc/ssh/sshd_config.default

COPY ./sshd_config /etc/ssh/
COPY ./tools/ftp-run.sh	/root/

EXPOSE 22

CMD [ "/root/ftp-run.sh" ]