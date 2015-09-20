#!/bin/sh

echo "deploy.sh: provisioning starts"

if ! which mysql > /dev/null 2>&1; then
    echo "deploy.sh: Abort. mysql not installed :/" 1>&2
    exit 1
fi

if ! which apache2ctl > /dev/null 2>&1; then
    echo "deploy.sh: Abort. apache2 not installed :/" 1>&2
    exit 1
fi

# Link up vhost file
ln -sf /var/www/provision/templates/apache2_vhost_http.conf /etc/apache2/sites-enabled/000-http-default.conf

sudo service apache2 restart

# reset root mysql password
mysqladmin -uroot password root > /dev/null 2>&1

# allow remote login to database.
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

if test -d "/home/vagrant"; then
    echo "deploy.sh: Setting up vagrant mysql user" 1>&2
    mysql -uroot -proot -e "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY '';" > /dev/null 2>&1
    mysql -uroot -proot -e "CREATE USER 'vagrant'@'%' IDENTIFIED BY '';" > /dev/null 2>&1
    mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' WITH GRANT OPTION;" > /dev/null 2>&1
    mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;" > /dev/null 2>&1
    mysql -uroot -proot -e "FLUSH PRIVILEGES;" > /dev/null 2>&1

    echo "<?php phpinfo();" > /var/www/web/phpinfo.php
fi


echo "deploy.sh: provisioning ends"
