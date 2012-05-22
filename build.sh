#! /bin/sh


rm -Rf 'usr/lib/ckan'

mkdir -p 'usr/bin/'
mkdir -p 'usr/lib/ckan'
mkdir -p 'etc/ckan'

python ckan-bootstrap.py usr/lib/ckan
virtualenv --relocatable usr/lib/ckan
cp activate usr/lib/ckan/bin/
