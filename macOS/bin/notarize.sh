#!/bin/bash
source Ids.sh
set -e
cd dmg-maker
APP="../dist/SnapPy.app"
DMG="SnapPy.dmg"
OPTIONS="--wait --no-progress --apple-id $USERNAME \
--team-id $IDENTITY --password $PASSWORD --wait"
python3 dmg-maker.py
echo "Notarizing app ..."
xcrun notarytool submit $DMG $OPTIONS
xcrun stapler staple $APP
python3 dmg-maker.py
echo "Signing disk image ..."
codesign -s $IDENTITY --timestamp --options runtime --force $DMG
echo "Notarizing disk image ..."
xcrun notarytool submit $DMG $OPTIONS
xcrun stapler staple $DMG
