#!/bin/sh

echo "wpcli.sh: provisioning starts"

# check prereq
if ! which php > /dev/null 2>&1; then
    echo "wpcli.sh: php not installed :/" 1>&2
	exit 1
fi

# wp-cli
if ! which wp > /dev/null 2>&1; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	sudo chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp
	sudo chown root: /usr/local/bin/composer
fi

if ! which wp > /dev/null 2>&1; then
    echo "wpcli.sh: wp-cli failed to install :/" 1>&2
	exit 1
fi

echo "-+-+-+- software versions:"
wp --version --allow-root

echo "wpcli.sh: provisioning ends"
