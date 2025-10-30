#!/bin/sh

chmod -R 777 /var/log/
exec rsyslogd -n
