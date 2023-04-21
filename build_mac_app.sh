set -e
SNAPPY_SUITE=`pwd`
# Create a virtual env here for building SnapPy et al and the app.
# It is important to not have any extraneous modules installed in the
# virtual env in order to prevent py2app from embedding them into the
# app
if [ ! -d build_env ]; then
    python3 -m venv build_env
fi
. build_env/bin/activate
SITE_PACKAGES=`python3 -c "import site ; print(site.getsitepackages()[0])"`
pip_install="python3 -m pip install --upgrade --no-user --target=$SITE_PACKAGES"
$pip_install --upgrade pip setuptools wheel cython sphinx ipython pyx pypng py2app

install_package () {
    echo checking for $1
    if [ ! -d $1 ]; then
	git clone git@github.com:3-manifolds/$1.git
	cd $1
    else
	cd $1
        git pull
	python3 setup.py clean
    fi
    python3 setup.py build
    python3 setup.py bdist_wheel
    shift
    $pip_install $@ dist/*.whl
    cd ..
    }

if [ ! -d frameworks ]; then
    git clone git@github.com:3-manifolds/frameworks.git
    ln -s ../DEV_ID.txt frameworks
fi
cd frameworks/TclTk
if [ ! -d Tk ] || [ ! -d Tcl ]; then
    . fetch_tcltk.sh
fi
cd ..
make FOR_PY2APP=yes
cd ..
install_package notary
install_package PLink
install_package FXrays
install_package low_index
install_package snappy_manifolds
install_package snappy_15_knots
install_package CyPari
install_package knot_floer_homology
install_package Spherogram
# Without --no-deps pip will try to rebuild low_index and Spherogram
# from out-of-date sources
install_package SnapPy --no-deps
cd SnapPy/mac_osx_app
if [ ! -e Frameworks.tgz ]; then
    ln -s ../../frameworks/Frameworks.tgz .
fi
if [ ! -e notabot.cfg ]; then
    ln -s ../../notabot.cfg .
fi
python3 release.py --no-freshen
python3 notarize_snappy.py
