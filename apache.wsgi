import os
instance_name = os.environ['CKAN_INSTANCE']

activate_this = os.path.join('/var/lib/ckan/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

from paste.deploy import loadapp
config_filepath = os.path.join('/etc/ckan', instance_name, 'deployment.ini')
from paste.script.util.logging_config import fileConfig
fileConfig(config_filepath)
application = loadapp('config:%s' % config_filepath)

