#!/bin/sh

if [ -z "$(ls -A /var/www/html/ 2> /dev/null)" ]; then
	cd /var/www/html/
	wget --no-verbose https://wordpress.org/wordpress-6.6.2.tar.gz
	tar --strip-components=1 -xf wordpress-6.6.2.tar.gz
	rm -rf *tar.gz
	cp /var/www/html/wp-config-sample.php wp-config.php
	sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$MARIADB_DB_NAME' );/g" wp-config.php
	sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$MARIADB_USER' );/g" wp-config.php
	MARIADB_PASSWORD=$(cat /run/secrets/mariadb_password)
	sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$MARIADB_PASSWORD' );/g" wp-config.php
	sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'mariadb:3306' );/g" wp-config.php
	sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/g" wp-config.php
	echo "<?php echo phpinfo();?>" > ./test.php
fi
exec php-fpm83 --nodaemonize