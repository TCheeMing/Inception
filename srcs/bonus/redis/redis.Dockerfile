FROM alpine:3.22.2

EXPOSE 6379

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /etc/

RUN apk add --no-cache redis tzdata && \
	mv redis.conf redis.conf.default

COPY ./configs/redis.conf /etc/

CMD [ "redis-server", "/etc/redis.conf" ]
