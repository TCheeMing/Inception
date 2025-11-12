FROM alpine:3.22.2

EXPOSE 9000 9001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache php84 php84-fpm php84-mysqli php84-phar php84-iconv php84-tokenizer curl tzdata && \
    ln -s /usr/bin/php84 /usr/bin/php && \
    cp /etc/php84/php-fpm.conf /etc/php84/php-fpm.conf.default && \
    cp /etc/php84/php-fpm.d/www.conf /etc/php84/php-fpm.d/www.conf.default && \
    curl --remote-name https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    php -d memory_limit=512M /usr/local/bin/wp core download --path=/root/wordpress/

COPY ./tools/wordpress-run.sh ./tools/test_page.php /root/
COPY ./resume /root/resume
COPY ./configs/php-fpm.conf /etc/php84/
COPY ./configs/www.conf /etc/php84/php-fpm.d/www.conf

CMD [ "/root/wordpress-run.sh" ]
