#!/bin/sh

# First-time user setup
# if [ -z "$(getent passwd | grep $MARIADB_USER)" ]; then
#	adduser -D -G mysql -g mysql $MARIADB_USER
# fi

# First-time MariaDB setup
if [ -z "$(ls -A /var/lib/mysql/ 2> /dev/null)" ]; then
	MARIADB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
	MARIADB_PASSWORD=$(cat /run/secrets/mariadb_password)
	mariadb-install-db --skip-test-db
	mariadbd-safe --user=root --no-watch
	sleep 3
	MARIDB_PID=$(pgrep /usr/bin/mariadbd)

	# Secure installation to improve database security.
	# Needed especially for < 10.4.
	# mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.password_last_changed', UNIX_TIMESTAMP(), '$.plugin', 'mysql_native_password', '$.authentication_string', 'invalid', '$.auth_or', json_array(json_object(), json_object('plugin', 'unix_socket'))) WHERE User='root';"
	mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('$MARIADB_ROOT_PASSWORD')) WHERE User='root';"
	# mariadb -e "DELETE FROM mysql.global_priv WHERE User='';"
	# mariadb -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	# mariadb -e "DROP DATABASE IF EXISTS test;"
	# mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
	
	# WordPress Database Preparation
	# https://developer.wordpress.org/advanced-administration/before-install/creating-database/
	# Creates a user with access rights to an empty database for WordPress. 
	mariadb -e "CREATE DATABASE IF NOT EXISTS $MARIADB_WORDPRESS_NAME";
	mariadb -e "CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';"
	mariadb -e "GRANT ALL PRIVILEGES ON $MARIADB_WORDPRESS_NAME.* TO '$MARIADB_USER'@'%';"
	
	# Gitea Database Preparation
	# https://docs.gitea.com/installation/database-prep 
	mariadb -e "CREATE USER 'gitea'@'%' IDENTIFIED BY 'gitea';"
	mariadb -e "CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';"
	mariadb -e "GRANT ALL PRIVILEGES ON giteadb.* TO 'gitea';"

	mariadb -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
	mariadb -e "FLUSH PRIVILEGES;"

	kill -s 15 $MARIDB_PID
	# wait $MARIADB_PID
	sleep 3
fi
exec mariadbd --user=root
