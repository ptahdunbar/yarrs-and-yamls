#!/bin/sh

echo "apache2.sh: provisioning starts"

# install
if ! which apache > /dev/null 2>&1; then
	sudo apt-get install -y apache2 apache2-mpm-worker apache2-utils libapache2-mod-log-slow libapache2-mod-php5 libapache2-mod-upload-progress libapache2-mod-fcgid
	sudo apt-get install -y libapache2-mod-geoip
	sudo a2enmod actions alias rewrite ssl
fi

# check if not installed
if ! which apache2ctl > /dev/null 2>&1; then
    echo "apache2.sh: apache2 failed to install :/" 1>&2
	exit 1
fi

# remove any preexisting active sites
rm /etc/apache2/sites-enabled/* > /dev/null 2>&1

sudo rm /etc/apache2/apache2.conf

# Link up config files
ln -sf /var/www/provision/templates/apache2.conf /etc/apache2/apache2.conf

sudo service apache2 restart

echo "apache2.sh: -+-+-+- software versions:"
apache2ctl -v

echo "apache2.sh: -+-+-+- service status:"
service apache2 status

echo "apache2.sh: provisioning ends"
