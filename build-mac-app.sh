set -e
cd macOS
rm -rf snappy/SnapPy.app
. bin/make-bundle.sh
. bin/sign-bundle.sh
rm -rf dist
mkdir dist
mv snappy/SnapPy.app dist
. bin/notarize.sh

