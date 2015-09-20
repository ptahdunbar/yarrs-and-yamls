#!/bin/sh

echo "php_configure.sh: provisioning starts"

# check prereq
if ! which php > /dev/null 2>&1; then
    echo "php_configure.sh: php not installed :/" 1>&2
	exit 1
fi

# https://raw.githubusercontent.com/php/php-src/PHP-7.0.0/php.ini-development
# https://raw.githubusercontent.com/php/php-src/PHP-7.0.0/php.ini-production

# php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/apache2/php.ini

echo "php_configure.sh: provisioning ends"
