#!/bin/sh
APT="apt-get -y --quiet"

sudo $APT install htop
sudo $APT install nginx
sudo $APT install postgresql-9.1
sudo $APT install postgresql-9.1-postgis
sudo $APT install solr-jetty
sudo $APT install openjdk-6-jre
sudo $APT install openjdk-6-jdk

sudo sed -i 's/#JAVA_HOME=/JAVA_HOME=\/usr\/lib\/jvm\/java-1.6.0-openjdk-amd64\//g' /etc/default/jetty
sudo sed -i 's/#JETTY_PORT=8080/JETTY_PORT=8983/g' /etc/default/jetty
sudo sed -i 's/#JETTY_HOST.*/JETTY_HOST=127.0.0.1/g' /etc/default/jetty
sudo sed -i 's/NO_START=1/NO_START=0/g' /etc/default/jetty

sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak

wget https://raw.github.com/okfn/ckan/master/ckan/config/solr/schema-1.4.xml

sudo cp schema-1.4.xml /etc/solr/conf/schema.xml
rm schema-1.4.xml

sudo service jetty restart
