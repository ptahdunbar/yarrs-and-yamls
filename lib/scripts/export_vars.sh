#!/bin/sh

# Exit if no args are passed in
[ -z $1 ] && exit

echo "export_vars.sh: provisioning starts"

KEY=$1
VALUE=$2

echo 'export $KEY=\"$VALUE\" > /etc/profile.d/exports'
echo "export $KEY=\"$VALUE\"" > /etc/profile.d/exports

chmod +x /etc/profile.d/exports

echo "export_vars.sh: provisioning ends"
