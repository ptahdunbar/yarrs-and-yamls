# RVM Install

echo "rvm.sh: provisioning starts"

FILE=/etc/profile.d/rvm.sh
SCRIPT=~/.rvm/scripts/rvm

cat > $FILE <<- RVM
if [[ \$- == *i* ]]; then

  echo progress-bar >> ~/.curlrc

  if [[ ! -e $SCRIPT ]]; then
    echo "NOT THERE"
  else
    echo "YES ITS THERE"
  fi

  if [[ ! -e ~/.rvmrc ]]; then
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    sudo \curl -sSL https://get.rvm.io | bash -s stable --without-gems="rvm rubygems-bundler"
    rvm get head --auto-dotfiles
    sudo rvm install 2.0.0-p195
    sudo gem install bundler zeus
  fi

  echo "sudo source $SCRIPT"
  source $SCRIPT
fi
RVM

chmod +x $FILE

echo "rvm.sh: provisioning ends"
exit
