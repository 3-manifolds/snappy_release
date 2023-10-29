import sys
import os
import subprocess

os.chdir('snappy')
subprocess.check_call([sys.executable, '-m', 'bundle_app.build'])
subprocess.check_call([sys.executable, '-m', 'bundle_app.add_packages'])
subprocess.check_call([sys.executable, '-m', 'bundle_app.streamline'])

