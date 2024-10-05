FROM alpine:3.20.3

WORKDIR /var/lib/mysql/

RUN apk add --no-cache mariadb mariadb-client && \
	sed -i "s/skip-networking/#skip-networking/g" /etc/my.cnf.d/mariadb-server.cnf

COPY ./tools/mariadb-run.sh /root/

EXPOSE 3306

CMD [ "/root/mariadb-run.sh" ]