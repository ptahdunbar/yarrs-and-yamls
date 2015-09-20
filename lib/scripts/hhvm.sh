#!/bin/sh

echo "hhvm.sh: provisioning starts"

# install
if ! which hhvm > /dev/null 2>&1; then
	sudo apt-get -y install software-properties-common
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
	sudo add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'
	sudo apt-get update
	sudo apt-get -y install hhvm
	#sudo /usr/share/hhvm/uninstall_fastcgi.sh
	#sudo apt-get install -y hhvm-nightly

	sudo /usr/share/hhvm/install_fastcgi.sh
	sudo /etc/init.d/hhvm restart
	sudo /etc/init.d/nginx restart
	sudo update-rc.d hhvm defaults
	sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60
fi

if ! which hhvm > /dev/null 2>&1; then
    echo "hhvm.sh: hhvm failed to install :/" 1>&2
	exit 1
fi

echo "hhvm.sh: -+-+-+- software versions:"
hhvm --version

echo "hhvm.sh: -+-+-+- service status:"
service hhvm status

echo "hhvm.sh: provisioning ends"
