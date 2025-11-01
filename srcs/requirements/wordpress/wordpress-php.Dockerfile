FROM alpine:3.22.2

EXPOSE 9000 9001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache php83 php83-fpm php83-mysqli php83-phar php83-iconv php83-tokenizer curl tzdata && \
    cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
    cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default && \
    curl --remote-name https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    php -d memory_limit=512M /usr/local/bin/wp core download --path=/root/wordpress/

COPY ./tools/wordpress-run.sh ./tools/test_page.php /root/
COPY ./resume /root/resume
COPY ./configs/php-fpm.conf /etc/php83/
COPY ./configs/www.conf /etc/php83/php-fpm.d/www.conf

CMD [ "/root/wordpress-run.sh" ]
