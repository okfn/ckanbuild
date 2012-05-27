#! /bin/sh

rm -Rf 'usr/lib/ckan'

mkdir -p 'usr/bin/'
mkdir -p 'usr/lib/ckan'
mkdir -p 'etc/ckan'

python ckan-bootstrap.py usr/lib/ckan
virtualenv --relocatable usr/lib/ckan
cp activate usr/lib/ckan/bin/
fpm -t deb -s dir -n ckan -v 1.7.1 --iteration 1 usr/ etc/
