#!/bin/sh

if [ -z "$(getent passwd | grep $SFTP_USER)" ]; then
	adduser -D -G ftp -g ftp -h /var/www/html/ $SFTP_USER
	SFTP_PASSWORD=$(cat /run/secrets/ftp_password)
	echo "$SFTP_USER:$SFTP_PASSWORD" | chpasswd
	mkdir -p /var/www/html/.ssh/
	chmod 700 /var/www/html/.ssh/
	cat /run/secrets/ssh_key > /var/www/html/.ssh/authorized_keys
	chmod 600 /var/www/html/.ssh/authorized_keys
	chown root:root /var/www/html/
	sed -i "s/Match User/Match User $SFTP_USER/g" /etc/ssh/sshd_config
fi
exec /usr/sbin/sshd -eD