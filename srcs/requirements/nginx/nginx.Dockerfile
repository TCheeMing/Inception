FROM alpine:3.20.3

WORKDIR /var/www/html/

RUN apk add --no-cache nginx && \
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default

COPY ./nginx.conf /etc/nginx/

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]