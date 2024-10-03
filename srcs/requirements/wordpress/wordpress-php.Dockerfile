FROM alpine:3.20.3

WORKDIR /var/www/html/

RUN apk add --no-cache php83 php83-fpm php83-mysqli wget && \
	cp /etc/php83/php-fpm.conf /etc/php83/php-fpm.conf.default && \
	cp /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf.default && \
	sed -i 's/;error_log = log\/php83\/error.log/error_log = \/dev\/stderr/g' /etc/php83/php-fpm.conf && \
	echo >> /etc/php83/php-fpm.d/www.conf && \
	echo '; Pool Config' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'listen = 9000' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'pm.status_path = /status' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'pm.status_listen = 9001' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'ping.path = /ping' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'access.log = /dev/stdout' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'access.format = "%R - %u %t \"%m %r%Q%q\" %s %f %{milli}d %{kilo}M %C%%"' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'catch_workers_output = yes' >> /etc/php83/php-fpm.d/www.conf && \
	echo >> /etc/php83/php-fpm.d/www.conf && \
	echo '; PHP (.ini) Config' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'php_admin_flag[display_errors] = On' >> /etc/php83/php-fpm.d/www.conf && \
	echo 'php_admin_value[error_log] = /dev/stderr' >> /etc/php83/php-fpm.d/www.conf

COPY ./tools/wordpress-run.sh /tmp/

EXPOSE 9000
EXPOSE 9001

CMD [ "/tmp/wordpress-run.sh" ]