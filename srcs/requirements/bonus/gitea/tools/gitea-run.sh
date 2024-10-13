#!/bin/sh

if [ -z "$(ls -A /data/ 2> /dev/null)" ]; then
	mkdir -p custom data git log
	chown -R gitea:www-data /data/
fi
su-exec gitea:www-data gitea web