set -e
cd macOS
rm -rf snappy/SnapPy.app
. bin/make-bundle.sh
. bin/sign-bundle.sh
