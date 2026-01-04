# Assumes build_mac_app.sh has already been run.

. build_env/bin/activate
cd snappy/macOS_app
mkdir -p wheelhouse
cp ../../wheelhouse/*.whl wheelhouse
. build.sh
python3 notarize_dmg.py
