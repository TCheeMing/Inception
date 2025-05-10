FROM alpine:3.20.3

EXPOSE 9000 9001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache php83 php83-fpm php83-mysqli php83-phar php83-iconv wget tzdata && \
    cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
    cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/wordpress-run.sh ./tools/db-connection-test.php ./configs/wp-config.php ./tools/test_page.php /root/
COPY ./configs/php-fpm.conf /etc/php83/
COPY ./configs/www.conf /etc/php83/php-fpm.d/www.conf

CMD [ "/root/wordpress-run.sh" ]
