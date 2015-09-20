#!/bin/sh

echo "mysql_client.sh: provisioning starts"

# MySQL
if ! mysql --version > /dev/null 2>&1; then
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install mysql-client
fi

# check if not installed
if ! which mysql > /dev/null 2>&1; then
    echo "mysql.sh: mysql failed to install :/" 1>&2
    exit 1
fi

echo "-+-+-+- software versions:"
mysql --version

echo "-+-+-+- service status:"
service mysql status

echo "mysql_client.sh: provisioning ends"
