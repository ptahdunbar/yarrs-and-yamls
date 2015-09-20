#!/bin/sh

echo "nodejs.sh: provisioning starts"

# MySQL
if ! node --version > /dev/null 2>&1; then
	curl -sL https://deb.nodesource.com/setup | sudo bash -
  apt-get install -y nodejs
fi

# check if not installed
if ! which node > /dev/null 2>&1; then
    echo "nodejs.sh: node failed to install :/" 1>&2
    exit 1
fi

echo "nodejs.sh: provisioning ends"

# BLEEDING - OR just use NGINX

# Run Node.js apps on low ports without running as root
# http://technosophos.com/2012/12/17/run-nodejs-apps-low-ports-without-running-root.html
# sudo apt-get install libcap2-bin
# sudo setcap cap_net_bind_service=+ep $(which iojs)
