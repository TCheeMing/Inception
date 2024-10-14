#!/bin/sh

if [ -z "$(ls -A /var/www/html/ 2> /dev/null)" ]; then
	MARIADB_PASSWORD=$(base64 /run/secrets/mariadb_password)
	mv /root/wp-config.php /root/test_page.php /var/www/html/
	cd /var/www/html/
	wget --no-verbose https://wordpress.org/wordpress-6.6.2.tar.gz
	tar --strip-components=1 -xf wordpress-6.6.2.tar.gz
	rm -rf *tar.gz
	sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$MARIADB_WP_NAME' );/g" wp-config.php
	sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$MARIADB_USER' );/g" wp-config.php
	sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$MARIADB_PASSWORD' );/g" wp-config.php
fi
exec php-fpm83 --nodaemonize