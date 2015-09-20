#!/bin/sh

echo "postfix.sh: provisioning starts"

echo "postfix postfix/mailname string `hostname`" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes postfix
sudo apt-get install -y postfix
sudo apt-get install -y mailutils default-mta

sudo service postfix restart

echo "postfix.sh: provisioning ends"
