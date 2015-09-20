#!/bin/sh

echo "nvm.sh: provisioning starts"

rm /etc/profile.d/nvm.sh > /dev/null 2>&1

cat > /etc/profile.d/nvm.sh <<- NVM
if [[ \$- == *i* ]]; then

  if ! nvm --version > /dev/null 2>&1; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
  fi

  source ~/.nvm/nvm.sh

  nvm --version
  nvm install stable
  nvm use stable
fi
NVM

echo "nvm.sh: provisioning ends"
exit

# BLEEDING - OR just use NGINX

# Run Node.js apps on low ports without running as root
# http://technosophos.com/2012/12/17/run-nodejs-apps-low-ports-without-running-root.html
# sudo apt-get install libcap2-bin
# sudo setcap cap_net_bind_service=+ep $(which iojs)
