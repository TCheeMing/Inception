FROM alpine:3.20.3

WORKDIR /etc/

RUN apk add --no-cache redis && \
	mv redis.conf redis.conf.default

COPY ./redis.conf /etc/

EXPOSE 6379

CMD [ "redis-server", "/etc/redis.conf" ]