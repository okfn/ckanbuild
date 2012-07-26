#!/bin/sh

## Post installation script.
##
## There are a few things that need to occur upon successful installation
## of the package:
##
## 1.  The virtualenv needs to work on this machine, as it was packaged
##     on a different machine under a different directory.  To do this
##     we run the virtualenv command again on the pyenv.  This only works
##     if the machine that built the virtualenv has the same packaging
##     structure for python as the target machine.  ie - it's only really
##     safe to assume that this works if the build machine was ubuntu 12.04
##     server edition (64-but) as well.  It **is** possible to get the same
##     effect by creating a temporary pyenv on the target machine, and then
##     rsync-ing the files that are different (rsync-ing rather than copying
##     maintains new files), but that seems a bit flakey!
##
## 2.  All the src installations in the packaged pyenv need to be
##     "pip install -e ."-ed again  because they egg-links that were created
##     use absolute path names, which are incorrect on this new machine.
##
## 3.  Jetty (solr) needs to be restarted due to the new schema file.
##
## 4.  The CKAN application needs to be reloaded as well.

# Set bash to exit if any command exits with non-zero return code.
set -e

case "$1" in
    configure)
        # Step 1: fix the virtual env
        virtualenv /usr/lib/ckan

        # Step 2: Fix the egg-links
        find /usr/lib/ckan/src/* -maxdepth 0 -type d | xargs -n 1 /usr/lib/ckan/bin/pip install -e

        # Step 3: Restart solr config
        service jetty restart

        # Step 4: Reload wsgi app
        touch /etc/ckan/apache.wsgi
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac
