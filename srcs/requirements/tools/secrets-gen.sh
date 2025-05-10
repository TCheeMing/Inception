#!/bin/sh

SECRETS_DIR=secrets

case "$1" in
	"mariadb") 
		# rand:		OpenSSL crytographically secure pseudo-random bytes generator
		# -base64:	base64 encoding on the output
		# -out:		Write to file instead of stdout
		# 20:		Number of random bytes
		openssl rand -base64 -out $SECRETS_DIR/mariadb_root_password 20
		openssl rand -base64 -out $SECRETS_DIR/mariadb_password 20
		;;
	"wordpress")
		openssl rand -base64 -out $SECRETS_DIR/wordpress_admin_password 20
		openssl rand -base64 -out $SECRETS_DIR/wordpress_user_one_password 20
		;;
	"ftp")
		openssl rand -base64 -out $SECRETS_DIR/ftp_password 20
		;;
	"nginx")
		# req:		OpenSSL certificate request and certificate generating utility
		# -newkey:	Creates new certificate request and new private key (Default size of RSA key is 2048 bits)
		# -x509:	Outputs a self signed certificate, instead of a certificate request
		# -sha256:	Uses 256-bit Secure Hash Algorithm
		# -days:	Specifies number of days to certify the certificate for (used with -x509)
		# -nodes:	If a private key is created it will not be encrypted (without a passphrase)
		# -out:		Specifies output filename to write the newly created certificate to (Default is stdout)
		# -keyout:	Gives the filename to write the newly created private key to
		# -subj:	Replaces subject field of input request with specified data
		openssl req \
			-newkey rsa:4096 \
			-x509 \
			-sha256 \
			-days 3650 \
			-nodes \
			-out $SECRETS_DIR/nginx-server.rsa.crt \
			-keyout $SECRETS_DIR/nginx-server.rsa.key \
			-subj "/C=/ST=/L=/O=/OU=/CN="
		;;
	"ssh")
		ssh-keygen -q -f $SECRETS_DIR/ssh_key -N ""
		;;
	"gitea")
		# req:		OpenSSL certificate request and certificate generating utility
		# -newkey:	Creates new certificate request and new private key (Default size of RSA key is 2048 bits)
		# -x509:	Outputs a self signed certificate, instead of a certificate request
		# -sha256:	Uses 256-bit Secure Hash Algorithm
		# -days:	Specifies number of days to certify the certificate for (used with -x509)
		# -nodes:	If a private key is created it will not be encrypted (without a passphrase)
		# -out:		Specifies output filename to write the newly created certificate to (Default is stdout)
		# -keyout:	Gives the filename to write the newly created private key to
		# -subj:	Replaces subject field of input request with specified data
		openssl req \
			-newkey rsa:4096 \
			-x509 \
			-sha256 \
			-days 3650 \
			-nodes \
			-out $SECRETS_DIR/gitea-server.rsa.crt \
			-keyout $SECRETS_DIR/gitea-server.rsa.key \
			-subj "/C=/ST=/L=/O=/OU=/CN="
		;;
esac
