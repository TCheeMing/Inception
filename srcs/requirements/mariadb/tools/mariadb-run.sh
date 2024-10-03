#!/bin/sh

if [ -z "$(getent passwd | grep $MARIADB_USER)" ]; then
	adduser -D -G mysql -g mysql $MARIADB_USER
fi
if [ -z "$(ls -A /var/lib/mysql/ 2> /dev/null)" ]; then
	mariadb-install-db --datadir=/var/lib/mysql --user=$MARIADB_USER
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
	mariadb -e "SET PASSWORD FOR '$MARIADB_USER'@localhost = PASSWORD(\"$MARIADB_PASSWORD\");" 2> /dev/null
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='';" 2> /dev/null
	mariadb -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" 2> /dev/null
	mariadb -e "DROP DATABASE IF EXISTS test;" 2> /dev/null
	mariadb -e "FLUSH PRIVILEGES;" 2> /dev/null
	kill -s 15 $!
	wait $!
fi
exec mariadbd-safe --user=$MARIADB_USER