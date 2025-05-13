FROM alpine:3.20.3

EXPOSE 3306

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/lib/mysql/

RUN apk add --no-cache mariadb mariadb-client tzdata && \
	mv /etc/my.cnf.d/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf.default

COPY ./tools/mariadb-run.sh /root/
COPY ./configs/mariadb-server.cnf /etc/my.cnf.d/

CMD [ "/root/mariadb-run.sh" ]
