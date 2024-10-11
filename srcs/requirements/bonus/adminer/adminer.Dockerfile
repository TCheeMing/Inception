FROM alpine:3.20.3

WORKDIR /var/www/html/

RUN apk add --no-cache make wget php83 php83-fpm php83-tokenizer php83-session php83-mysqli && \
	wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.zip && \
	unzip adminer-4.8.1.zip && \
	mv adminer-4.8.1/* . && \
	rm -rf adminer-4.8.1/ *zip && \
	make && \
	sed -i 's/\$Re=\$_SESSION\["messages"\]\[\$Mi\];/\$Session=!isset(\$_SESSION\["messages"\]\[\$Mi\])?0:\$_SESSION\["messages"\]\[\$Mi\];\$Re=\$Session;/g' adminer-4.8.1.php && \
	cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
	cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default && \
	sed -i 's/;error_log = log\/php83\/error.log/error_log = \/dev\/stderr/g' /etc/php83/php-fpm.conf && \
	echo >> /etc/php83/php-fpm.d/www.conf && \
	echo '; Pool Config' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'listen = 8080' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'pm.status_path = /status' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'pm.status_listen = 8081' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'ping.path = /ping' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'access.log = /dev/stdout' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'access.format = "%R - %u %t \"%m %r%Q%q\" %s %f %{milli}d %{kilo}M %C%%"' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'catch_workers_output = yes' >> /etc/php83/php-fpm.d/www.conf && \
	echo >> /etc/php83/php-fpm.d/www.conf && \
	echo '; PHP (.ini) Config' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'php_admin_flag[display_errors] = On' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'php_admin_value[error_log] = /dev/stderr' >> /etc/php83/php-fpm.d/www.conf

EXPOSE 8080
EXPOSE 8081

CMD [ "php-fpm83", "--nodaemonize" ]