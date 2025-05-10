#!/bin/sh

if [ -z "$(ls -A /var/www/html/ 2> /dev/null)" ]; then
	MARIADB_PASSWORD=$(cat /run/secrets/mariadb_password)
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
	WP_USER_ONE_PASSWORD=$(cat /run/secrets/wordpress_user_one_password)
	wget --no-verbose https://wordpress.org/wordpress-6.6.2.tar.gz
	tar --strip-components=1 -xf wordpress-6.6.2.tar.gz
	rm -rf *tar.gz
	mv /root/wp-config.php /root/test_page.php /var/www/html/
	sed -i "s|define( 'DB_NAME', 'database_name_here' );|define( 'DB_NAME', '$MARIADB_WORDPRESS_NAME' );|g" wp-config.php
	sed -i "s|define( 'DB_USER', 'username_here' );|define( 'DB_USER', '$MARIADB_USER' );|g" wp-config.php
	sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', '$MARIADB_PASSWORD' );|g" wp-config.php
	php /root/db-connection-test.php
	wp core install --url=$DOMAIN_NAME --title=$WORDPRESS_TITLE --admin_user=$WORDPRESS_ADMIN --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WORDPRESS_ADMIN_EMAIL --skip-email
	wp user create $WORDPRESS_USER_ONE $WORDPRESS_USER_ONE_EMAIL --user_pass=$WP_USER_ONE_PASSWORD
fi
exec php-fpm83 --nodaemonize
