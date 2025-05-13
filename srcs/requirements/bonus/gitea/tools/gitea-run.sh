#!/bin/sh

if [ -z "$(ls -A /gitea/data/ 2> /dev/null)" ]; then
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
