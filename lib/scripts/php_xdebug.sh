#!/bin/sh

echo "php_xdebug.sh: provisioning starts"

# check if not installed
if ! which php > /dev/null 2>&1; then
    echo "php_xdebug.sh: Abort. php not installed :/" 1>&2
	exit 1
fi

## PHP
sudo apt-get install -y php5-xdebug

[ ! -z $1 ] && cat $1 > /etc/php5/fpm/conf.d/00-xdebug.ini

sudo service php5-fpm restart

echo "php_xdebug.sh: provisioning ends"
