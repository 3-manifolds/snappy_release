#!/bin/bash
source Ids.sh
set -e
APP=SnapPy.app
WORK_DIR=snappy

echo Signing SnapPy.app
FRAMEWORKS=$APP/Contents/Frameworks
MACOS=$APP/Contents/MacOS
pushd $WORK_DIR
SIGN="codesign -s $IDENTITY --timestamp --options runtime --force"

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
spctl --verbose --assess SnapPy.app
popd
