#!/bin/bash

echo "updating..."

sudo apt-get -qq update

sudo apt-get -qq install apache2 php5 php5-mysql git

echo "Downloading Files..."
wget -nc -q https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz

sudo tar xzvf mediawiki-1.28.0.tar.gz
sudo mv mediawiki-1.28.0 /var/www/mediawiki

sudo sed -i /DocumentRoot/s/html/mediawiki/ /etc/apache2/sites-enabled/000-default.conf

sudo service apache2 restart

ip_addr=`ifconfig eth1 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}'`
echo "mediawiki server at $ip_addr"