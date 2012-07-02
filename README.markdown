ckanbuild
=========

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

In `.etc/apache2/sites-available/ckan` there should be one Apache config file
for each CKAN website on the server (todo).

In `./etc/ckan/` there should be a subdir for each CKAN site containing
`apache.wsgi`, `ckan.ini` and `who.ini` config files (todo).

`./usr/bin/ckan` is a script for running paster commands on CKAN instances.

(The directories follow the Debian directory structure for packaging.)

`./activate` is this supposed to be here?
