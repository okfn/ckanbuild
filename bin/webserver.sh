#!/bin/bash

# Don't allow unset variables to be used
set -o nounset

# Exit upon any non-zero return code
set -o errexit

init() {
    while true; do
        read -p "Have you written down the IPs for solr, database and elastic search [y/n]? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    
    echo ""
    read -p "Please enter the IP for the SOLR server? " SOLR
    read -p "Please enter the IP for the DATABASE server? " DATABASE
    read -p "Please enter the IP for the ELASTIC server? " ELASTIC
    
    echo "Configuring network with: "
    echo " SOLR -> $SOLR"
    echo " DATABASE -> $DATABASE"
    echo " ELASTIC -> $ELASTIC"
    echo ""
    
    while true; do
        read -p "Should we run with those values [y/n]? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    
    check_hosts 'solrserver' $SOLR
    check_hosts 'dbserver' $DATABASE
    check_hosts 'elasticserver' $ELASTIC
    
    APT="apt-get -y --quiet"
    
    sudo $APT update
    sudo $APT upgrade
    
    sudo $APT install htop
    sudo $APT install apache2
    sudo $APT install libapache2-mod-wsgi
    sudo $APT install nginx
    sudo $APT install python-virtualenv python-setuptools

    configure_firewall
}

configure_firewall() {
    APT="apt-get -y"

    sudo $APT install ufw

    echo 'Setting up default firewall configuration...'
    sudo ufw default deny
    sudo ufw allow openssh
    open_tcp_port 80
    echo 'Done setting up default firewall configuration.'
}

open_tcp_port() {
    local PORT_NUMBER
    PORT_NUMBER=$1
    sudo ufw allow in on eth0 proto tcp from any to any port "$PORT_NUMBER"
    sudo ufw allow in on eth1 proto tcp from any to any port "$PORT_NUMBER"
}

close_tcp_port() {
    local PORT_NUMBER
    PORT_NUMBER=$1
    sudo ufw delete allow in on eth0 proto tcp from any to any port "$PORT_NUMBER"
    sudo ufw delete allow in on eth1 proto tcp from any to any port "$PORT_NUMBER"
}

check_hosts() {
    if grep -q "$1" /etc/hosts
    then
        echo "$1 was found in /etc/hosts"
    else
        echo "$2 $1" | sudo tee -a /etc/hosts
    fi
}
    
case ${1-} in
    init) init ;;
    *) echo "

Commands are:
init # Install and configures apache and nginx
"

esac
