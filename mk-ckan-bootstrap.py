#!/usr/bin/env python
import virtualenv, textwrap
output = virtualenv.create_bootstrap_script(textwrap.dedent("""
import os, subprocess

def extend_parser(optparse_parser):
    optparse_parser.add_option('--ckan-location',
            default='git+https://github.com/okfn/ckan.git#egg=ckan',
            help="Target for 'pip install ...' command to install the CKAN package [default: %default]")
    optparse_parser.add_option('--pip-download-cache',
            default=os.path.join(os.getcwd(), 'pip-cache'),
            help="Where pip can store its cached downloads [default: %default]")

def after_install(options, pyenv):

    pip = os.path.join(pyenv, 'bin', 'pip')
    download_cache = options.pip_download_cache

    if options.ckan_location.startswith('git+'):
        ckan_dir = os.path.join(pyenv, 'src', 'ckan')
    else:
        ckan_dir = options.ckan_location

    def install_deps(dep=None, deps_file=None, retries=3):
        '''Helper function for making multiple attempts at installing dependencies.

        The cheeseshop can be a bit flakey with a big long list of dependencies,
        github too can fail sometimes.
        '''

        if dep is not None:
            dep_args = ['-e', dep]
        elif deps_file is not None:
            dep_args = ['-r', deps_file]
        else:
            raise RuntimeError, 'Need a dependency to install!'

        success = False
        while not success and retries > 0:
            retcode = subprocess.call([pip, 'install',
                                       '--download-cache=%s' % download_cache,
                                       '--use-mirrors'] + dep_args)
            success = retcode == 0
            retries -= 1
        return success

    # Install the CKAN source code into the virtual environment.
    if not install_deps(dep=options.ckan_location):
        raise RuntimeError, "Couldn't install CKAN! :-("

    # Newer versions of CKAN use a pip-requirements file.  Older versions
    # have a pip-requirements file, and a requires directory.  With older
    # versions we use the contents of the requires directory, and ignore the
    # pip-requirements file.
    #
    # If the requires directory exists, then install from there.  Otherwise,
    # install from the pip-requirements file.
    requirements_directory = os.path.join(ckan_dir, 'requires')
    if os.path.exists(requirements_directory):
        requirements_files = [ os.path.join(ckan_dir, 'requires', f) for f in [
            'lucid_present.txt',
            'lucid_conflict.txt',
            'lucid_missing.txt',
        ]]
    else:
        requirements_files = [os.path.join(ckan_dir, 'pip-requirements.txt')]
    
    for f in requirements_files:
        success = install_deps(deps_file=f)
        if not success:
            raise RuntimeError, "Couldn't install CKAN's dependencies"

    # Create a CKAN config file.
    paster = os.path.join(pyenv, 'bin', 'paster')
    development_ini = os.path.join(ckan_dir, 'development.ini')
    subprocess.call([paster, 'make-config', 'ckan', '--no-interactive', development_ini])

    # Create CKAN's cache and session directories.
    data_dir = os.path.join(ckan_dir, 'data')
    sstore_dir = os.path.join(ckan_dir, 'sstore')
    subprocess.call(['mkdir', data_dir, sstore_dir])

    # Install CKAN's test-specific dependencies into the virtual environment.
    pip_requirements_test = os.path.join(ckan_dir, 'pip-requirements-test.txt')
    if not install_deps(deps_file=pip_requirements_test):
        raise RuntimeError, "Couldn't install CKAN's dependencies! :-("

"""))
f = open('ckan-bootstrap.py', 'w').write(output)
