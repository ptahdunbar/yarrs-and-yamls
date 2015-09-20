#!/bin/sh

echo "composer.sh: provisioning starts"

# check prereq
if ! which php > /dev/null 2>&1; then
    echo "composer.sh: php not installed :/" 1>&2
	exit 1
fi

# install
if ! which composer > /dev/null 2>&1; then
	curl -sS https://getcomposer.org/installer | php
	sudo mv composer.phar /usr/local/bin/composer
	sudo chown root: /usr/local/bin/composer
	sudo chmod +x /usr/local/bin/composer
fi

# check if not installed
if ! which composer > /dev/null 2>&1; then
    echo "composer.sh: composer failed to install :/" 1>&2
	exit 1
fi

echo "composer.sh: -+-+-+- software versions:"
composer --version

echo "composer.sh: provisioning ends"
