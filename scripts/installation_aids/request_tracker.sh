!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "updating"
sudo apt-get -qq update

DB_PASS='Pa$$w0rd'
PORT="8081"
IP_ADDRESS="10.0.2.15"

echo "installing mysql"
sudo -E apt-get -qq install mysql-server mysql-client libmysqlclient-dev
mysqladmin -u root password $DB_PASS

echo "installing apache..."
sudo apt-get -qq install \
	make apache2 libapache2-mod-fcgid libssl-dev libyaml-perl \
	libgd-dev libgd-gd2-perl libgraphviz-perl

echo "installing perl modules..."
sudo apt-get -qq install libwww-perl libcss-squish-perl \
	libmodule-versions-report-perl libcatalyst-plugin-log-dispatch-perl \
	libregexp-common-perl libuniversal-require-perl libtext-wrapper-perl  \
	libtext-password-pronounceable-perl libtime-modules-perl liblist-moreutils-perl \
	libscalar-util-numeric-perl libdatetime-locale-perl libtext-template-perl \
	libhtml-scrubber-perl libcache-simple-timedexpiry-perl \
	liblocale-maketext-lexicon-perl libdigest-whirlpool-perl libregexp-common-net-cidr-perl \
	libtext-quoted-perl libmime-tools-perl libdevel-globaldestruction-perl  \
	liblocale-maketext-lexicon-perl libregexp-common-net-cidr-perl libdbix-searchbuilder-perl \
	libdevel-stacktrace-perl libhtml-rewriteattributes-perl libgnupg-interface-perl libperlio-eol-perl \
	libdata-ical-perl libtext-wikiformat-perl libhtml-mason-perl libapache-session-browseable-perl \
	libcgi-psgi-perl libhtml-mason-psgihandler-perl  libcgi-emulate-psgi-perl libconvert-color-perl \
	liblocale-maketext-fuzzy-perl libhtml-quoted-perl libdatetime-perl libnet-cidr-perl libregexp-ipv6-perl \
	libregexp-common-email-address-perl libipc-run3-perl  libxml-rss-perl libconfig-json-perl starlet libgd-text-perl \
	libgd-graph-perl

echo "Downloading webpages..."
wget -q https://download.bestpractical.com/pub/rt/release/rt-4.4.1.tar.gz

sudo cp rt-4.4.1.tar.gz /usr/src

cd /usr/src
sudo tar xzvf ./rt-4.4.1.tar.gz

sudo adduser --system --group rt
sudo usermod -aG rt www-data

cd rt-4.4.1

sudo ./configure --with-web-user=www-data --with-web-group=www-data --enable-graphviz --enable-gd

MISSING=$(sudo make testdeps 2> /dev/null |grep MISSING | awk '{print $1}') # get missing packages

sudo cpan $MISSING
sudo make install
sudo make initialize-database

sudo tee /etc/apache2/sites-available/rt.conf > /dev/null <<EOF
<VirtualHost *:$PORT>
        ServerAdmin webmaster@localhost
        ServerName $IP_ADDRESS:$PORT

        AddDefaultCharset UTF-8
        DocumentRoot /opt/rt4/share/html
        Alias /NoAuth/images/ /opt/rt4/share/html/NoAuth/images/
        ScriptAlias / /opt/rt4/sbin/rt-server.fcgi/
        <Location />
                Require all granted
        </Location>

        LogLevel info

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo tee /opt/rt4/etc/RT_SiteConfig.pm > /dev/null <<EOF
Set(\$rtname, '$IP_ADDRESS');
Set(\$WebDomain, '$IP_ADDRESS');
Set(\$WebPort, $PORT);
EOF

echo "Listen $PORT" | sudo tee -a /etc/apache2/ports.conf > /dev/null

sudo a2enmod fcgid
sudo a2ensite rt

sudo chown www-data:www-data -R /opt/rt4/var/mason_data
sudo service apache2 reload
