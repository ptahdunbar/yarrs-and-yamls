#!/bin/sh

set -e

TIMESTAMP=/vagrant_provisioned_at

echo "base.sh: provisioning starts"
touch $TIMESTAMP && echo $(date) > $TIMESTAMP

# update once a day (every 24 hours).
# if [ ! -e $TIMESTAMP ]; then
	apt-get update -y -qq > /dev/null
	# touch $TIMESTAMP
	echo $(date) > $TIMESTAMP
# fi

# tools
apt-get install -y ntp
apt-get install -y cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd
apt-get install -y language-pack-en-base language-pack-en

# utils
apt-get install -y python-software-properties python-setuptools debconf-utils
apt-get install -y libsasl2-2 ca-certificates libsasl2-modules
apt-get install -y vim htop curl tmux firefox

# Setup sudo to allow no-password sudo for "admin"

dpkg --configure -a > /dev/null 2>&1

echo "base.sh: provisioning ends"
