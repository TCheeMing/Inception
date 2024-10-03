#!/bin/sh

if [ -z "$(ls -A /var/www/html/ 2> /dev/null)" ]; then
	cd /var/www/html/
	wget https://wordpress.org/wordpress-6.6.2.tar.gz
	tar --strip-components=1 -xf wordpress-6.6.2.tar.gz
	rm -rf *tar.gz
	echo "<?php echo phpinfo();?>" > ./test.php
fi
exec php-fpm83 --nodaemonize