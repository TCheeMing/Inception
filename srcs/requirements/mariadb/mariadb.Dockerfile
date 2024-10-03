FROM alpine:3.20.3

WORKDIR /var/lib/mysql/

RUN apk add --no-cache mariadb mariadb-client

COPY ./tools/mariadb-run.sh /tmp/

EXPOSE 3306

CMD [ "/tmp/mariadb-run.sh" ]