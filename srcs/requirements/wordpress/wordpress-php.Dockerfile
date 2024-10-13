FROM alpine:3.20.3

EXPOSE 9000 9001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache php83 php83-fpm php83-mysqli wget tzdata && \
	cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
	cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default

COPY ./tools/wordpress-run.sh ./configs/wp-config.php ./tools/test_page.php /root/
COPY ./configs/php-fpm.conf /etc/php83/
COPY ./configs/www.conf /etc/php83/php-fpm.d/www.conf

CMD [ "/root/wordpress-run.sh" ]