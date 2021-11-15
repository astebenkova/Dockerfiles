#!/bin/sh

dockerize --template /config.tmpl:/etc/nginx/conf.d/default.conf

nginx -g "daemon off;"
