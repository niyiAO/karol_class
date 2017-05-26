
echo "updating the vm..."
sudo apt-get -qq update

echo "installing apache2..."
sudo apt-get -qq install apache2

echo "installing php5..."
sudo apt-get -qq install php5 php5-mysql php5-gd

echo "downloading drupal..."
wget -q https://ftp.drupal.org/files/projects/drupal-8.2.4.tar.gz
tar -zxf drupal-8.2.4.tar.gz
sudo rm -rf /var/www/html
sudo cp -rf drupal-8.2.4/ /var/www/html
sudo mkdir /var/www/html/sites/default/files
sudo cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php

sudo chmod 777 /var/www/html/sites/default/files
sudo chmod 777 /var/www/html/sites/default/settings.php

sudo a2enmod rewrite

sudo sed -i '/^\s*DocumentRoot/a \
\
	<Directory /var/www/html>\
		AllowOverride All\
	</Directory>' /etc/apache2/sites-enabled/000-default.conf

sudo service apache2 restart

ip_addr=`ifconfig eth1 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}'`

echo Web Server Started at $ip_addr
