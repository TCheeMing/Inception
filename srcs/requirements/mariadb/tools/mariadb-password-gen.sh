#!/bin/sh

# rand:		OpenSSL crytographically secure pseudo-random bytes generator
# -base64:	base64 encoding on the output
# -out:		Write to file instead of stdout
# 20:		Number of random bytes
openssl rand -base64 -out ./secrets/mariadb_root_password 20
openssl rand -base64 -out ./secrets/mariadb_password 20