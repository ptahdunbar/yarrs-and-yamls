#!/bin/bash

set -e

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

# Install necessary libraries for guest additions and Vagrant NFS Share
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common

# Install necessary dependencies
sudo apt-get -y -q install curl wget git tmux firefox xvfb vim

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers


##########

# # Installing vagrant keys
# mkdir ~/.ssh
# chmod 700 ~/.ssh
# cd ~/.ssh
# wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
# chmod 600 ~/.ssh/authorized_keys
# chown -R vagrant ~/.ssh

# # Node.js Setup
# wget --retry-connrefused -q -O - https://raw.github.com/creationix/nvm/master/install.sh | sh
# source ~/.nvm/nvm.sh
#
# nvm install 0.10.18
# nvm alias default 0.10.18
#
# echo "source ~/.nvm/nvm.sh" >> ~/.bash_profile

# # RVM Install
# wget --retry-connrefused -q -O - https://get.rvm.io | bash -s stable
# source /home/vagrant/.rvm/scripts/rvm
#
# rvm autolibs read-fail
# rvm install 2.0.0-p195
# gem install bundler zeus
