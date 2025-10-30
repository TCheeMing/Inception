FROM alpine:3.22.2

EXPOSE 8000 8001

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /var/www/html/

RUN apk add --no-cache make curl php83 php83-fpm php83-tokenizer php83-session php83-mysqli tzdata && \
	curl --remote-name https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.zip --location && \
	unzip adminer-5.4.1.zip && \
	mv adminer-5.4.1/* . && \
	rm -rf adminer-5.4.1/ *zip && \
	make && \
	sed -i 's|\$Re=\$_SESSION\["messages"\]\[\$Mi\];|\$Session=!isset(\$_SESSION\["messages"\]\[\$Mi\])?0:\$_SESSION\["messages"\]\[\$Mi\];\$Re=\$Session;|g' adminer-5.4.1.php && \
	mv adminer-5.4.1.php adminer.php && \
	cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
	cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default

COPY ./configs/php-fpm.conf /etc/php83/
COPY ./configs/www.conf /etc/php83/php-fpm.d/www.conf

CMD [ "php-fpm83", "--nodaemonize" ]
