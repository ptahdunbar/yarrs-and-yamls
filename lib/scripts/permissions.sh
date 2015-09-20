#!/bin/sh

echo "permissions.sh: provisioning starts"

WEB_GROUP=www-data
WEB_DIR=/var/www

if [ -d /home/ubuntu ]; then
	sudo usermod -g $WEB_GROUP ubuntu
else
    echo "permissions.sh: failed adding ubuntu to $WEB_GROUP."
fi

sudo chown -R root:$WEB_GROUP $WEB_DIR
sudo chmod 2775 $WEB_DIR
sudo chown $WEB_GROUP $WEB_DIR/web/.htaccess

echo "permissions.sh: provisioning ends"
