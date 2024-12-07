#!/bin/sh

if [ -z "$(getent passwd | grep $FTP_USER)" ]; then
	adduser -D -G ftp -g ftp -h /var/www/html/ $FTP_USER
	FTP_PASSWORD=$(base64 /run/secrets/ftp_password)
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
	chown root:root /var/www/html/
fi
exec vsftpd /etc/vsftpd/vsftpd.conf