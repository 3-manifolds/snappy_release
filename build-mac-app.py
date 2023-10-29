import sys
import os
from shutil import rmtree
from subprocess import check_call

os.chdir('macOS')
app = os.path.join('snappy', 'SnapPy.app')
if os.path.exists(app):
    rmtree(app)
check_call([sys.executable, 'bin/make-bundle.py'])
check_call(['/bin/bash', 'bin/sign-bundle.sh'])
if os.path.exists('dist'):
    rmtree('dist')
os.renames('snappy/SnapPy.app', 'dist/SnapPy.app')
check_call(['/bin/bash', 'bin/notarize.sh'])

