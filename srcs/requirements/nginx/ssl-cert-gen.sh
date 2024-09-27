#!/bin/sh

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
		-days 365 \
		-nodes \
		-out ./secrets/server.rsa.crt \
		-keyout ./secrets/server.rsa.key \
		-subj "/C=/ST=/L=/O=/OU=/CN=cteoh.42.fr"