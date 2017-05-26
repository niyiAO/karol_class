#!/bin/bash

DB="drupal"
RT_PASS="sumtin"
USERNAME="drupal"
DB_PASS="drupal"

sudo apt-get -qq update

export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -qq install mysql-server

sudo sed -i '/^bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
sudo service mysql restart

mysqladmin -u root password $DB_PASS
mysql -uroot -p$DB_PASS -e "CREATE DATABASE $DB"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON $DB.* TO '$USERNAME'@'%' IDENTIFIED BY '$DB_PASS'"

ip_addr=`ifconfig eth1 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}'`
echo Database Server Started at $ip_addr
