#!/bin/sh

if [ -z "$(ls -A /gitea/data/ 2> /dev/null)" ]; then
	if [ -z $GITEA_PORT ]; then
		URL=$DOMAIN_NAME
	else
		URL=$DOMAIN_NAME:$GITEA_PORT
	fi

	sed -i "s/ROOT_URL =/ROOT_URL = https:\/\/$URL\/gitea\//" /etc/gitea/app.ini
	sed -i "s/DOMAIN =/DOMAIN = $DOMAIN_NAME/" /etc/gitea/app.ini

	for dir in custom data git log
	do
		mkdir -p /gitea/data/$dir
	done
	chown -R gitea:www-data /gitea/data/
	chmod -R 777 /gitea/
fi

if [ -z "$(ls -A /gitea/public/ 2> /dev/null)" ]; then
	cp -r /usr/share/webapps/gitea/public/* /gitea/public/
	chown -R gitea:www-data /gitea/public/
	chmod -R 777 /gitea/
fi
exec su-exec gitea:www-data gitea web
