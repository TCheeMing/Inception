#!/bin/sh

if [ -z "$(getent passwd | grep $MARIADB_USER)" ]; then
	adduser -D -G mysql -g mysql $MARIADB_USER
fi
if [ -z "$(ls -A /var/lib/mysql/ 2> /dev/null)" ]; then
	MARIADB_ROOT_PASSWORD=$(base64 /run/secrets/mariadb_root_password)
	MARIADB_PASSWORD=$(base64 /run/secrets/mariadb_password)
	mariadb-install-db --user=$MARIADB_USER --skip-test-db
	mariadbd-safe --user=$MARIADB_USER --no-watch
	sleep 3
	MARIDB_PID=$(pgrep mariadb)
	mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '\$.plugin', 'mysql_native_password', '\$.authentication_string', PASSWORD('$MARIADB_ROOT_PASSWORD')) WHERE User='root';"
	mariadb -e "RENAME USER '$MARIADB_USER'@'localhost' TO '$MARIADB_USER'@'%';"
	mariadb -e "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
	mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '\$.plugin', 'mysql_native_password', '\$.authentication_string', PASSWORD('$MARIADB_PASSWORD')) WHERE User='$MARIADB_USER';"
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='';"
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	mariadb -e "CREATE DATABASE IF NOT EXISTS $MARIADB_WP_NAME";
	mariadb -e "CREATE USER 'gitea'@'%' IDENTIFIED BY 'gitea';"
	mariadb -e "CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';"
	mariadb -e "GRANT ALL PRIVILEGES ON giteadb.* TO 'gitea';"
	mariadb -e "FLUSH PRIVILEGES;"
	kill -s 15 $MARIDB_PID
	wait $MARIADB_PID
	sleep 3
fi
exec mariadbd-safe --user=$MARIADB_USER
