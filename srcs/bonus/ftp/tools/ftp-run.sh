#!/bin/sh

# Sets up a user for FTP logins
if [ -z "$(getent passwd | grep $FTP_USER)" ]; then
	adduser -D -h /var/www/html/ $FTP_USER
	FTP_PASSWORD=$(cat /run/secrets/ftp_password)
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd 2> /dev/null
fi

# https://linux.die.net/man/8/pure-ftpd
# -A: chroot everyone except root.
# -d: Debug logging. Logs every command.
# -E: Only allow authenticated logins, no anonymous users.
# -j: Creates user home directory if it somehow does not exist. 
# -p: Uses the specified port range for passive mode.
# -R: Disallow use of chmod.
# -P: Force specified IP address or host name in reply to a PASV/EPSV command.
exec pure-ftpd -A -d -E -j -p 50000:50005 -R -P 127.0.0.1
