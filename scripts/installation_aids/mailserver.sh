#!/bin/bash

# aid script for dovecot, rainloop mailserver installation 

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -qq \
	apache2 php5 unzip curl php5-curl

export DEBIAN_FRONTEND=noninteractive

sudo -E apt-get install -qq \
	postfix dovecot-imapd dovecot-pop3d \
	mailutils

sudo service dovecot restart

wget -q \
	http://www.rainloop.net/repository/\
	webmail/rainloop-community-latest.zip

sudo mkdir /var/www/rainloop
sudo unzip -q rainloop-community-latest.zip\
 -d /var/www/rainloop

cd /var/www/rainloop
sudo find . -type d -exec chmod 755 {} \;
sudo find . -type f -exec chmod 644 {} \;
sudo chown -R www-data:www-data .

sudo tee /etc/apache2/sites-enabled/rainloop.conf > \
	/dev/null <<EOF
Alias /rainloop /var/www/rainloop

<Directory /var/www/rainloop>
  Options FollowSymLinks
  <IfModule mod_php5.c>
    php_flag register_globals off
  </IfModule>
  <IfModule mod_dir.c>
    DirectoryIndex index.php
  </IfModule>

  # access to configtest is limited by default to prevent information leak
  <Files configtest.php>
    order deny,allow
    deny from all
    allow from 127.0.0.1
  </Files>
</Directory>
EOF

sudo service apache2 restart
