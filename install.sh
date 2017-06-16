#!/bin/bash

#Update your systems DO NOT Upgrade at this stage
sudo apt-get update

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Install all pre-dependencies
sudo apt-get install -y vim curl lynx screen nmap 
sudo apt-get install -y python3 python3-pip python-software-properties
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev

# Add Ondrej Repository with PHP5
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update

sudo apt-get install -y php5.6 apache2 libapache2-mod-php5.6 php5.6-curl php5.6-gd php5.6-mcrypt php5.6-readline mysql-server-5.5 php5.6-mysql git-core php5.6-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

sudo a2enmod rewrite

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5.6/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5.6/apache2/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5.6/cli/php.ini

sudo service apache2 restart

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
