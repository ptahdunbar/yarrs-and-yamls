#!/bin/sh

echo "apache2_ssl.sh: provisioning starts"

SSL_PATH=/var/www/provision/ssl
LOCAL_PATH=/etc/apache2/ssl/

sudo a2enmod ssl
mkdir -p $LOCAL_PATH

# Check if keys exists
if [ ! -f $LOCAL_PATH/intermediate.crt ]; then
    ln -s $SSL_PATH/intermediate.crt $LOCAL_PATH
fi

if [ ! -f $LOCAL_PATH/public.crt ]; then
    ln -s $SSL_PATH/public.crt $LOCAL_PATH
fi

if [ ! -f $LOCAL_PATH/private.key ]; then
    ln -s $SSL_PATH/private.key $LOCAL_PATH
fi

echo "apache2_ssl.sh: provisioning ends"
