#!/bin/sh

echo "mysql.sh: provisioning starts"

# MySQL
if ! mysql --version > /dev/null 2>&1; then
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install mysql-server mysql-client
fi

# check if not installed
if ! which mysql > /dev/null 2>&1; then
    echo "mysql.sh: mysql failed to install :/" 1>&2
    exit 1
fi

# reset root mysql password
[ ! -z $MYSQL_ROOT_PASSWORD ] && PASS=" -p=$MYSQL_ROOT_PASSWORD" && mysqladmin -uroot password $MYSQL_ROOT_PASSWORD > /dev/null 2>&1 || PASS=''

if test -d "/home/vagrant"; then
    echo "mysql.sh: Setting up vagrant mysql user" 1>&2
    mysql -uroot -p$PASS -e "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY '';" > /dev/null 2>&1
    mysql -uroot -p$PASS -e "CREATE USER 'vagrant'@'%' IDENTIFIED BY '';" > /dev/null 2>&1
    mysql -uroot -p$PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' WITH GRANT OPTION;" > /dev/null 2>&1
    mysql -uroot -p$PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;" > /dev/null 2>&1
    mysql -uroot -p$PASS -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
fi

echo "mysql.sh: provisioning ends"
