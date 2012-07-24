#! /bin/sh


# The new acitvate script  path points to /usr/lib/ckan/bin
rm -Rf '/usr/lib/ckan'

# make sure directories are present
mkdir -p '/usr/lib/ckan'

# run download all dependancies
python ckan-bootstrap.py /usr/lib/ckan

#virtualenv --relocatable /usr/lib/ckan

#sudo fpm -t deb -s dir -n ckan -v 1.8a --iteration 1 -d 'python-virtualenv' --after-install=after-install.sh usr/ etc/ 

