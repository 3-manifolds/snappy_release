#!/bin/bash
source Ids.sh
set -e
APP=SnapPy.app
WORK_DIR=snappy

echo "Signing $APP ..."
FRAMEWORKS=$APP/Contents/Frameworks
MACOS=$APP/Contents/MacOS
pushd $WORK_DIR
SIGN="codesign -s $IDENTITY --entitlements entitlements.txt --timestamp --options runtime --force"

for executable in `find $FRAMEWORKS -perm +111 -type f`; do
   $SIGN $executable
done

for framework in `ls $FRAMEWORKS`; do
   $SIGN $FRAMEWORKS/$framework
done 

for executable in `find $MACOS -perm +111 -type f`; do
   $SIGN $executable
done

$SIGN $APP
# Of course spctl will fail, since the app is not notarized.
# But we want to see what it says anyway.
echo "Verifying with spctl - should be rejected as unnotarized ..."
spctl --verbose --assess SnapPy.app || true
popd

