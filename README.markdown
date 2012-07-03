ckanbuild
=========

Installation
------------

To use ckanbuild you must first install the following dependencies:

* [Python](http://python.org/)
* [Git](http://git-scm.com/)
* [virtualenv](http://www.virtualenv.org/): `pip install virtualenv`
* [fpm](https://github.com/jordansissel/fpm/): `gem install fpm`

Then to get ckanbuild itself simply clone the ckanbuild git repo:

    git clone https://github.com/okfn/ckanbuild.git

Usage
-----

To build the CKAN Debian package, run:

    ./build.sh

Troubleshooting
---------------

If you get errors from fpm like one of these:

    `utime': No such file or directory - /tmp/package-dir-staging20120703-30729-jkji81/usr/lib/ckan/src/ckan/who.ini

    `utime': Operation not permitted - /tmp/package-dir-staging20120703-28058-164vj7h/usr/lib/ckan/lib/python2.7/sre.py (Errno::EPERM)

try downgrading to fpm 0.4.9: `gem install fpm -v 0.4.9`

How it Works
------------

ckanbuild is a script for deploying and managing single or multiple CKAN
websites.

`ckan-bootstrap.py` is a virtualenv bootstrap script (see _Creating Your Own
Bootstrap Scripts_  in the
[virtualenv documentation](http://pypi.python.org/pypi/virtualenv)) that
creates a new Python virtual environment, installs CKAN and its dependencies
into it, creates a CKAN config file, etc.
Note that `ckan-bootstrap.py` is a generated file, you shouldn't edit it
manually.

`mk-ckan-bootstrap.py` is the script that creates `ckan-bootstrap.py`, it
contains the code that specifies how `ckan-bootstrap.py` should install CKAN
and its dependencies into the virtualenv, create the CKAN config file, etc.
To update `ckan-bootstrap.py` you would edit `mk-ckan-bootstrap.py` then run
it to generate the new `ckan-bootstrap.py`.

`build.sh` is a shell script that creates a CKAN virtualenv (using
`ckan-bootstrap.py`) in `./usr/lib/ckan` and then uses
[fpm](https://github.com/jordansissel/fpm) to package up the entire virtualenv
into a Debian package.

In `./etc/apache2/sites-available/ckan` there should be one Apache config file
for each CKAN website on the server (todo).

In `./etc/ckan/` there should be a subdir for each CKAN site containing
`apache.wsgi`, `ckan.ini` and `who.ini` config files (todo).

`./usr/bin/ckan` is a script for running paster commands on CKAN instances.

`./activate` is a script for activating the CKAN virtual environment after it
has been installed via the .deb package to `/usr/lib/ckan`. After creating the
virtualenv, `build.sh` copies thie `activate` script over the virtualenv's
default `activate` script.

(The directories follow the Debian directory structure for packaging.)
