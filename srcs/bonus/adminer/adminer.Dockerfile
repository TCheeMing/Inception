FROM alpine:3.22.2

EXPOSE 8000 8001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache make curl php84 php84-fpm php84-tokenizer php84-session php84-mysqli tzdata && \
	ln -s /usr/bin/php84 /usr/bin/php && \
	curl --remote-name https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.zip --location && \
	unzip adminer-5.4.1.zip && \
	mv adminer-5.4.1/* . && \
	rm -rf adminer-5.4.1/ *zip && \
	make && \
	mv adminer-5.4.1.php adminer.php && \
	cp /etc/php84/php-fpm.conf /etc/php84/php-fpm.conf.default && \
	cp /etc/php84/php-fpm.d/www.conf /etc/php84/php-fpm.d/www.conf.default

COPY ./configs/php-fpm.conf /etc/php84/
COPY ./configs/www.conf /etc/php84/php-fpm.d/www.conf

CMD [ "php-fpm84", "--nodaemonize" ]
