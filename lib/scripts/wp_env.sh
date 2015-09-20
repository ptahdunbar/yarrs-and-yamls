#!/bin/sh

echo "wp_env.sh: provisioning starts"

$ENV_PATH=/var/www/.env

# get the value of WP_ENV or die
if [ -f $ENV_PATH ]; then
	source $ENV_PATH 2> /dev/null
	echo $WP_ENV
else
	echo "WP_ENV not defined yet."
	exit 1
fi

echo "wp_env.sh: provisioning ends"
