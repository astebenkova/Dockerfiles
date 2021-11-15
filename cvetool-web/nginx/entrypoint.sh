#!/bin/sh

dockerize --template /cw.tmpl:/etc/nginx/conf.d/cw.conf

nginx -g "daemon off;"
