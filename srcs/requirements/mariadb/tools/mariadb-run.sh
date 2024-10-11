#!/bin/sh

if [ -z "$(getent passwd | grep $MARIADB_USER)" ]; then
	adduser -D -G mysql -g mysql $MARIADB_USER
fi
if [ -z "$(ls -A /var/lib/mysql/ 2> /dev/null)" ]; then
	mariadb-install-db --datadir=/var/lib/mysql --user=$MARIADB_USER --skip-test-db
	mariadbd-safe --user=$MARIADB_USER &
	MARIADB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
	MARIADB_PASSWORD=$(cat /run/secrets/mariadb_password)
	while true
	do
		mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '\$.plugin', 'mysql_native_password', '\$.authentication_string', PASSWORD('$MARIADB_ROOT_PASSWORD')) WHERE User='root';" 2> /dev/null
		if [ "$(echo $?)" = 0 ]; then
			break
		fi
	done
	mariadb -e "RENAME USER '$MARIADB_USER'@'localhost' TO '$MARIADB_USER'@'%';"
	mariadb -e "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
	mariadb -e "UPDATE mysql.global_priv SET priv=json_set(priv, '\$.plugin', 'mysql_native_password', '\$.authentication_string', PASSWORD('$MARIADB_PASSWORD')) WHERE User='$MARIADB_USER';"
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='';"
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	mariadb -e "FLUSH PRIVILEGES;"
	mariadb -e "CREATE DATABASE IF NOT EXISTS $MARIADB_DB_NAME";
	kill -s 15 $!
	wait $!
fi
exec mariadbd-safe --user=$MARIADB_USER