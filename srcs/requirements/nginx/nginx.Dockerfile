FROM alpine:3.20.3

EXPOSE 443

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache nginx tzdata && \
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default

COPY ./configs/nginx.conf /etc/nginx/

CMD [ "nginx", "-g", "daemon off;" ]