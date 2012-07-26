#! /bin/bash

WORKING_DIRECTORY="./scratch"

if [[ "X" == "X$WORKING_DIRECTORY" ]]
then
	echo 'Please set a working directory in ./build.sh'
	return 1
fi

mkdir -p $WORKING_DIRECTORY

ABS_WORKING_DIRECTORY=`cd "$WORKING_DIRECTORY"; pwd`
PYENV="$ABS_WORKING_DIRECTORY/pyenv"

PIP_DOWNLOAD_CACHE="$ABS_WORKING_DIRECTORY/pip_download_cache"
mkdir -p "$PIP_DOWNLOAD_CACHE"

echo "Working in $ABS_WORKING_DIRECTORY"

echo 'Re-generating ckan-bootstrap.py ...'
python mk-ckan-bootstrap.py
echo "Done."

## echo 'Removing old virtualenv if it exists...'
## rm -rf "$PYENV"
## echo 'Done.'

echo "Building virtual env in \"$PYENV\""
#python ckan-bootstrap.py "$PYENV" 2>&1 | tee "$ABS_WORKING_DIRECTORY/bootstrap.log"
python ckan-bootstrap.py "$PYENV"
echo 'Done.'


### The new acitvate script  path points to /usr/lib/ckan/bin
##rm -Rf '/usr/lib/ckan'
##
### make sure directories are present
##mkdir -p '/usr/lib/ckan'
##
### run download all dependancies
##python ckan-bootstrap.py /usr/lib/ckan
##
###virtualenv --relocatable /usr/lib/ckan
##
###sudo fpm -t deb -s dir -n ckan -v 1.8a --iteration 1 -d 'python-virtualenv' --after-install=after-install.sh usr/ etc/ 
##
