#!/bin/sh

echo "phpbrew.sh: provisioning starts"

curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
sudo mv phpbrew /usr/bin/phpbrew

phpbrew init

echo "phpbrew.sh: provisioning ends"
