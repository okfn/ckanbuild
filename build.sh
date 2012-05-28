#! /bin/sh

## Note: do not run as root as svn does not like it

# remove ckan so it can be rebuilt
rm -Rf 'usr/lib/ckan'

# make sure directories are present
mkdir -p 'usr/bin/'
mkdir -p 'usr/lib/ckan'
mkdir -p 'etc/ckan'

# run download all dependancies
python ckan-bootstrap.py usr/lib/ckan

# Make sure virtualenv can be moved to another location
# Note: this does not work for nose still need to run 
# setup.py develop once installed
virtualenv --relocatable usr/lib/ckan

# The new acitvate script  path points to /usr/lib/ckan/bin
cp activate usr/lib/ckan/bin/


# checkout release, change to one you want

cd usr/lib/ckan/src/ckan
git checkout release-v1.7.1
cd -

# Do packaging, change -v flag

sudo fpm -t deb -s dir -n ckan -v 1.7.1 --iteration 1 usr/ etc/

# in order to install the package run
# dpkg -i 
