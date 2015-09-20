#!/bin/sh

echo "php.sh: provisioning starts"

# PHP
sudo apt-get -y install php5-fpm php5-cli
sudo apt-get -y install php5-mysql php5-curl php5-gd php5-imagick php5-mcrypt

sudo php5enmod mcrypt

if ! which php > /dev/null 2>&1; then
    echo "php.sh: php failed to install :/" 1>&2
	exit 1
fi

rm /etc/php5/fpm/conf.d/00-xdebug.ini
rm /etc/php5/apache2/conf.d/00-xdebug.ini

echo "php.sh: -+-+-+- software versions:"
php --version

echo "php.sh: -+-+-+- service status:"
service php5-fpm status

echo "php.sh: provisioning ends"
