#!/bin/sh

echo "DevOps provisioning: deploy_init.sh"

# Learn more: https://developer.github.com/guides/managing-deploy-keys/

useradd deploy -m
mkdir /home/deploy/.ssh
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
