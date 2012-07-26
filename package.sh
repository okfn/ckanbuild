#!/bin/bash

# WorkingDirectory
WD="$1"

if [[ "X" == "X$WD" ]]
then
  echo "Please specify the directory you wish to package up."
  exit
fi

# Makek the virtualenv relocatable
virtualenv --relocatable "$WD/usr/lib/ckan"

# Copy configuration templates into etc directory
cp -r ./etc "$WD/etc"

# Copy CKAN's solr schema
mkdir -p "$WD/etc/solr/conf"
cp "$WD/usr/lib/ckan/src/ckan/ckan/config/solr/schema-1.4.xml" "$WD/etc/solr/conf/schema.xml"

cd "$WD"

# For some reason I need to be root to run this.  I'm sure this shouldn't be
# the case.
sudo fpm -t deb \
      -s dir \
      -n ckan \
      -v 1.8b \
      --iteration `date "+%Y%m%d%H%M%S"` \
      -d 'python-virtualenv' \
      -d 'solr-common' \
      --replaces 'solr-common' \
      --config-files '/etc/solr/conf/schema.xml' \
      --post-install '../packaging_scripts/post-install.sh' \
      ./usr ./etc

cd -
