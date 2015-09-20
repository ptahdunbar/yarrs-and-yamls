#!/bin/sh

echo "nginx.sh: provisioning starts"

# web server
if ! which nginx > /dev/null 2>&1; then
	nginx=stable # use nginx=development for latest development version
	add-apt-repository ppa:nginx/$nginx
	apt-get update
	sudo apt-get install -y nginx
	sudo apt-get install -y python-software-properties
	sudo service nginx restart
	rm /var/www/html/index.nginx-debian.html
	find /var/www/html/ -type d -depth -empty -delete
fi

# check if not installed
if ! which nginx > /dev/null 2>&1; then
    echo "nginx.sh: nginx failed to install :/" 1>&2
    exit 1
fi

rm /etc/nginx/sites-available/* > /dev/null 2>&1
rm /etc/nginx/sites-enabled/* > /dev/null 2>&1

service nginx start

echo "nginx.sh: provisioning ends"
