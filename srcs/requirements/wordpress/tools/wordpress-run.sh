#!/bin/sh

while true
do
	curl --fail mariadb:3306 &> /dev/null
	if [ $? -eq 1 ]; then
		echo WordPress-MariaDB connection successful.
		break
	fi
done

wp core is-installed 2> /dev/null
if [ $? -eq 1 ] && [ -z "$(ls -A /var/www/html/ 2> /dev/null)" ]; then
	MARIADB_PASSWORD=$(cat /run/secrets/mariadb_password)
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
	WP_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)
	mv /root/wordpress/* /root/resume/* /var/www/html/
	rm -rf /root/wordpress/ /root/resume/

	# Creates wp_config.php for installation and populates the WordPress database in MariaDB with necessary tables.
	wp config create --dbname=$MARIADB_WORDPRESS_NAME \
			 --dbuser=$MARIADB_USER	\
			 --dbpass=$MARIADB_PASSWORD \
			 --dbhost=mariadb:3306 2> /dev/null
	while [ $? -eq 1 ]
	do
		wp config create --dbname=$MARIADB_WORDPRESS_NAME \
				 --dbuser=$MARIADB_USER	\
				 --dbpass=$MARIADB_PASSWORD \
				 --dbhost=mariadb:3306 2> /dev/null
	done

	# Sets necessary WordPress constants (especially for Redis connection).
	wp config set WP_DEBUG true --raw
	wp config set WP_REDIS_HOST redis
	wp config set WP_REDIS_PORT 6379
	wp config set WP_REDIS_PREFIX redis_

	# Installs WordPress and creates an administrator.
	wp core install --url=$DOMAIN_NAME \
			--title=$WORDPRESS_TITLE \
			--admin_user=$WORDPRESS_ADMIN \
			--admin_password=$WP_ADMIN_PASSWORD \
			--admin_email=$WORDPRESS_ADMIN_EMAIL \
			--skip-email 2> /dev/null
	while [ $? -eq 1 ]
	do
		wp core install --url=$DOMAIN_NAME \
				--title=$WORDPRESS_TITLE \
				--admin_user=$WORDPRESS_ADMIN \
				--admin_password=$WP_ADMIN_PASSWORD \
				--admin_email=$WORDPRESS_ADMIN_EMAIL \
				--skip-email 2> /dev/null
	done

	wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL --user_pass=$WP_USER_PASSWORD
	chmod -R 777 /var/www/html/
	wp plugin install redis-cache --activate
	wp redis enable
fi
exec php-fpm83 --nodaemonize
