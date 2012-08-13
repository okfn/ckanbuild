ckanbuild
=========

Installation
------------

To use ckanbuild you must first install the following dependencies:

* [Python](http://python.org/)
* [Git](http://git-scm.com/)
* [virtualenv](http://www.virtualenv.org/): `pip install virtualenv`
* [fpm](https://github.com/jordansissel/fpm/): `gem install fpm`

For example, to install these dependencies on Ubuntu 12.04:

    sudo apt-get install python git python-virtualenv rubygems
    sudo gem install fpm

There are further dependencies that need to be satisifed in order to build the
packages required by ckan:

    sudo apt-get install python-dev libpq-dev

Then to get ckanbuild itself simply clone the ckanbuild git repo:

    git clone https://github.com/okfn/ckanbuild.git


Usage
-----

The idea behind ckanbuild is to incrementally build your python virtualenv,
starting with the simplest base case of ckan and its dependencies.  The tools
with which to do this are a bit immature and fragmented at the moment, so it's
still quite manual.

I've been using the following workflow and conventions:

### Directory Layout on the build server

ckanbuild has been extracted to `/home/okfn/build/ckanbuild` on s084.  From now
on, I'll refer to directories relative to this one.  I've been using the
following convention for organising the different builds:

    ./builds
    |--- 1.3.3-s075
    |--- 1.5.1c-fixes-iati
    |--- 1.7.1

This shows 3 separate build projects.  The name of the project determines the
name of the resulting package, so `1.3.3-s075` produces packages named like
`ckan_1.3.3-s075-20120807131804_amd64.deb`.

Each project acts as a kind of workspace to build up what you want packaged.  The packaging script currently only packages the two sub-directories `etc` and `usr`.  This means anything outside these two directories will not end up in the debian package.

Each project has a README file with notes on how the pyenv was created, any
problems encountered, and how they were resolved.  It also shows the extensions
that are installed.  Although that's not really necessary as a `pip freeze`
output is built and distributed with each built package, its useful to see at a
glance what extensions are availble.

### Creating a new project

To create a new project:

    # This will generate a bootstrap file.
    python mk-ckan-bootstrap.py

    # This will create a new virtualenv in ./builds/<project-name>/usr/lib/ckan
    # The /usr/lib/ckan is very important, and should not be changed.
    python ckan-bootstrap.py ./builds/<project-name>/usr/lib/ckan

    # Alternatively, to specify a particular ckan version:
    python ckan-bootstrap.py --ckan-location=git+https://github.com/okfn/ckan.git#egg=ckan \
                             ./builds/<project-name>/usr/lib/ckan

    # Also, a flag can be set to **not** automatically install CKAN's dependencies.
    # This is useful if trying to build an old version of CKAN.
    python ckan-bootstrap.py --ignore-ckan-dependencies \
                             --ckan-location=git+https://github.com/okfn/ckan.git@release-v1.3.3#egg=ckan \
                             ./builds/<project-name>/usr/lib/ckan

### Installing further dependencies

You can now add further dependencies to your pyenv (this is still very manual):

    # Activate the virtualenv
    source ./builds/<project-name>/usr/lib/ckan/bin/activate

    # Install something useful
    # And don't forget to install any of its dependencies too...
    pip install -e git+https://github.com/okfn/ckanext-qa.git#egg=ckanext-qa

    # Once your done you can deactivate the virtualenv
    deactivate

Note: this can be run even after creating a package, to create a more up to
date package.

### Further configuration

As part of the packaging, any files in `./etc` and `./usr` (relative to the
ckanbuild directory, not the project directory) are copied into the project
directory **if** they are more up-to-date than the files already in the project
directory.  This means you can selectively edit config files to be packaged, or
add additional files to be packaged.

Note: this isn't perfect.  If for example you merge some upstream changes in
the ckanbuild repo that update files in `./etc`, then they'll be more
up-to-date that the ones you may have edited in your project directory.  So
please be careful, until this issue is sorted out!

### Packaging

When you're happy with your virtualenv and config files, it's time to package
it up:

    ./package.sh ./builds/<project-name>

All going well, you should end up with a new debian file in
`./packages/<project-name>`, and a `pip-freeze` file to match.

On s084, this `./packages` directory is being
[served](http://s084.okserver.org/packages/).  It's just a bog-standard
listing, ie - it's **not** a repository.  Rather, it's just an easy way of
downloading the package to the target machine.

### Installing the package

Finally, to install the packge on the target machine:

    # After downloading it
    sudo dpkg -i <debian-package-location>

Preparing the target machine
--------------------------

The target machine is the machine that will host the deployment.  

Different types/classes/profiles of servers have different scripts which can be
run on them. To configure a webserver, and assuming the ckanbuild has been
installed you should run:

    bin/webserver.sh

To install the database machine:

    bin/dbserver.sh

Otherwise assuming it's a fresh installation of Ubuntu 12.04 Server Edition (64 bit):


    # Install dependencies
    sudo apt-get install postgresql-9.1 postgresql-9.1-postgis solr-jetty openjdk-6-jdk apache2 libapache2-mod-wsgi nginx

    # Configure jetty
    sudo sed -e 's/#JAVA_HOME=/JAVA_HOME=\/usr\/lib\/jvm\/java-1.6.0-openjdk-amd64\//g' \
             -e 's/#JETTY_PORT=8080/JETTY_PORT=8983/g' \
             -e 's/#JETTY_HOST.*/JETTY_HOST=127.0.0.1/g' \
             -e 's/NO_START=1/NO_START=0/g' \
             -i /etc/default/jetty
    sudo service jetty restart

    # TODO: install and configure elastic search

    # Check services are running:
    curl http://127.0.0.1:8983/solr/admin/ping
    /etc/init.d/postgresql status


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

`package.sh` is a shell script that packages a virtualenv using
[fpm](https://github.com/jordansissel/fpm).

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
