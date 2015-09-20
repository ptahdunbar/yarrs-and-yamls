#!/bin/sh

# Exit if no args are passed in
[ -z $1 ] && exit

echo "nginx_site.sh: provisioning starts"

HOST=$1
HOSTPATH=$2
CONFIG=$3

# SSL
mkdir -p /etc/nginx/ssl 2>/dev/null
openssl genrsa -out "/etc/nginx/ssl/$HOST.key" 1024 2>/dev/null
openssl req -new -key /etc/nginx/ssl/$HOST.key -out /etc/nginx/ssl/$HOST.csr -subj "/CN=$HOST/O=Vagrant/C=UK" 2>/dev/null
openssl x509 -req -days 365 -in /etc/nginx/ssl/$HOST.csr -signkey /etc/nginx/ssl/$HOST.key -out /etc/nginx/ssl/$HOST.crt 2>/dev/null

# CONFIG

echo "nginx_ensite $HOST"
echo $CONFIG > "/etc/nginx/sites-available/$HOST"
ln -fs "/etc/nginx/sites-available/$HOST" "/etc/nginx/sites-enabled/$HOST"

service nginx restart 2>/dev/null
service php5-fpm restart 2>/dev/null

echo "nginx_site.sh: provisioning ends"
