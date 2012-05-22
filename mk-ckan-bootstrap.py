#!/usr/bin/env python
import virtualenv, textwrap
output = virtualenv.create_bootstrap_script(textwrap.dedent("""
import os, subprocess

def extend_parser(optparse_parser):
    optparse_parser.add_option('--ckan-location',
            default='git+https://github.com/okfn/ckan.git#egg=ckan',
            help="Target for 'pip install ...' command to install the CKAN package [default: %default]")

def after_install(options, pyenv):

    pip = os.path.join(pyenv, 'bin', 'pip')

    if options.ckan_location.startswith('git+'):
        ckan_dir = os.path.join(pyenv, 'src', 'ckan')
    else:
        ckan_dir = options.ckan_location

    # Install the CKAN source code into the virtual environment.
    subprocess.call([pip, 'install', '--ignore-installed', '-e',
            options.ckan_location])

    # Install additional CKAN dependencies into the virtual environment.
    lucid_missing = os.path.join(ckan_dir, 'requires', 'lucid_missing.txt')
    subprocess.call([pip, 'install', '--ignore-installed', '-r',
            lucid_missing])
    lucid_conflict = os.path.join(ckan_dir, 'requires', 'lucid_conflict.txt')
    subprocess.call([pip, 'install', '--ignore-installed', '-r',
            lucid_conflict])
    subprocess.call([pip, 'install', '--ignore-installed', 'webob==1.0.8'])

    # Install the remaining dependencies into the virtual environment.
    # With no --ignore-installed option in the command below, if any of these
    # packages are already installed by apt (which is the preferred way to
    # install them because it's faster), this command should just skip them.
    lucid_present = os.path.join(ckan_dir, 'requires', 'lucid_present.txt')
    subprocess.call([pip, 'install', '-r', lucid_present])

    # At this point we need to install paster into the virtual environment
    # (if the commands above didn't do so already).
    subprocess.call([pip, 'install', '--ignore-installed', 'PasteScript'])
    paster = os.path.join(pyenv, 'bin', 'paster')

    # Create a CKAN config file.
    development_ini = os.path.join(ckan_dir, 'development.ini')
    subprocess.call([paster, 'make-config', 'ckan', '--no-interactive', development_ini])

    # Create CKAN's cache and session directories.
    data_dir = os.path.join(ckan_dir, 'data')
    sstore_dir = os.path.join(ckan_dir, 'sstore')
    subprocess.call(['mkdir', data_dir, sstore_dir])

    # Install CKAN's test-specific dependencies into the virtual environment.
    pip_requirements_test = os.path.join(ckan_dir, 'pip-requirements-test.txt')
    subprocess.call([pip, 'install', '--ignore-installed', '-r',
            pip_requirements_test])
"""))
f = open('ckan-bootstrap.py', 'w').write(output)
