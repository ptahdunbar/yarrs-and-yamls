#!/bin/sh

echo "git.sh: provisioning starts"

[ ! -z $1 ] && cat $1 > /etc/gitconfig

sudo apt-get -y install git-core

git --version

echo "git.sh: provisioning ends"
