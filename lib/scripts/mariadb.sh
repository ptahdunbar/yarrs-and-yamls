#!/bin/sh

echo "mariadb.sh: provisioning starts"

# install
if ! mysql --version | grep Maria > /dev/null 2>&1; then

	sudo apt-get -y install software-properties-common
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
	sudo add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/10.0/ubuntu trusty main'
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install mariadb-server mariadb-server-10.0

	sudo mkdir -p /opt/mysql/data
	sudo mysql_install_db --user=mysql --datadir=/opt/mysql/data

	#mysql_secure_installation
	mysql -u root -e "DROP USER ''@'localhost';"
	mysql -u root -e "DELETE FROM mysql.db WHERE Db LIKE 'test%';"
	#mysql -u root -e "UPDATE mysql.user set user=\"overlord\" where user=\"root\";"
fi

# check if not installed
if ! which mysql > /dev/null 2>&1; then
    echo "maraidb.sh: mariadb failed to install :/" 1>&2
	exit 1
fi

echo "maraidb.sh: -+-+-+- software versions:"
mysql --version

echo "maraidb.sh: -+-+-+- service status:"
service mysql status

echo "mariadb.sh: provisioning ends"
