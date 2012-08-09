#!/bin/bash

ROOT_DIR=$PWD

# WorkingDirectory
WD="$PWD/$1"

if [[ "X" == "X$WD" ]]
then
  echo "Please specify the directory you wish to package up."
  exit
fi

# Makek the virtualenv relocatable
virtualenv --relocatable "$WD/usr/lib/ckan"

# Copy any missing configuration templates.
# This allows custom templates to be packaged.
# Using rsync with the --update flag means that any
# new files in the target directory won't be overwritten.
# The sudo is required to preserve ownership of the synced
# (preserving ownership is implied by the '-a' flag, but
# only works if run by the superuser.
sudo rsync -avr --update ./etc/ "$WD/etc"
sudo rsync -avr --update ./usr/bin "$WD/usr/"

## TODO: should we handle updating the solr schema on a remote machine?
## # Copy CKAN's solr schema
## mkdir -p "$WD/etc/solr/conf"
## cp "$WD/usr/lib/ckan/src/ckan/ckan/config/solr/schema-1.4.xml" "$WD/etc/solr/conf/schema.xml"
## 
cd "$WD"

DATE=`date "+%Y%m%d%H%M%S"`
CKAN_VERSION=`basename "$WD"`

# Make a note of the virtualenv state before packaging it up.
mkdir -p "$ROOT_DIR/packages/$CKAN_VERSION"
"$WD/usr/lib/ckan/bin/pip" freeze > "$ROOT_DIR/packages/$CKAN_VERSION/pip-freeze-$DATE.txt"

# And also, copy it into the package itself for record keeping.
cp "$ROOT_DIR/packages/$CKAN_VERSION/pip-freeze-$DATE.txt" "$WD/usr/lib/ckan/pip-freeze.txt"

# For some reason I need to be root to run this.  I'm sure this shouldn't be
# the case.
fpm -t deb \
      -s dir \
      -n ckan \
      -v "$CKAN_VERSION" \
      --iteration "$DATE" \
      -d 'python-virtualenv' \
      -d 'apache2' \
      --replaces 'apache2' \
      --replaces 'apache2.2-common' \
      --config-files '/etc/apache2/ports.conf' \
      --post-install "$ROOT_DIR/packaging_scripts/post-install.sh" \
      ./usr ./etc

cd -

## Cleanup
mv "$WD/ckan_${CKAN_VERSION}-${DATE}_amd64.deb" "$ROOT_DIR/packages/$CKAN_VERSION/"

## Run virtualenv on the pyenv (after having run 'virtualenv --relocatable' on it.
## I've had problems installing deps on a pyenv that's had '--relocatable' run on
## it, but this sorts it out.
virtualenv "$WD/usr/lib/ckan"

