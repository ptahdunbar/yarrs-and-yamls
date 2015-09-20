#!/bin/sh

echo "tz.sh: provisioning starts"

echo $1 > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo "tz.sh: provisioning ends"
