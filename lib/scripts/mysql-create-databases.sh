#!/bin/sh

echo "mysql-create-databases.sh: provisioning starts"

# check if not installed
if ! which mysql > /dev/null 2>&1; then
    echo "mysql is not installed" 1>&2
    exit 1
fi

[ ! -z $MYSQL_ROOT_PASSWORD ] && PASS=" -p=$MYSQL_ROOT_PASSWORD" || PASS=''

for DB in "$@"
do
  echo "mysql-create-databases.sh: creating databse: $DB ..."
  mysql -uroot$PASS -e "CREATE DATABASE IF NOT EXISTS \`$DB\`;" > /dev/null
done

echo "mysql-create-databases.sh: provisioning ends"
