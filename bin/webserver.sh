#!/bin/sh
APT="apt-get -y --quiet"

sudo $APT update
sudo $APT upgrade

sudo $APT install htop
sudo $APT install apache2
sudo $APT install libapache2-mod-wsgi
sudo $APT install nginx


# libpq-dev and python-dev are required for psycopg2 but
# should also install gcc.
sudo $APT install python-virtualenv
sudo $APT install libpq-dev python-dev

sudo cp etc/apache2/sites-available/ckan /etc/apache2/sites-available/

sudo a2ensite ckan
sudo a2dissite default
sudo service apache2 reload

vim /etc/apache2/sites-enabled/ckan
