#!/bin/sh

echo "install-nodejs-modules.sh: provisioning starts"

source ~/.nvm/nvm.sh

nvm --version
nvm install stable
nvm use stable

modules=$(echo $1 | tr " " "\n")

for module in $modules
do
  echo "npm install -g $module"
  npm install -g $module
done

echo "install-nodejs-modules.sh: provisioning starts"
