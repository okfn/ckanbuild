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
    requirements = os.path.join(ckan_dir, 'pip-requirements.txt')
    subprocess.call([pip, 'install', '--ignore-installed', '-r',
            requirements])

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
    subprocess.call([pip, 'install', '--ignore-installed', '-r',
            pip_requirements_test])
"""))
f = open('ckan-bootstrap.py', 'w').write(output)
