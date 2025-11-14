FROM alpine:3.22.2

EXPOSE 443

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache nginx tzdata && \
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default

COPY ./configs/nginx.conf /etc/nginx/

CMD [ "nginx" ]
