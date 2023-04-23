#! /bin/bash
set -e
USE_PIP=no
usage () {
    echo "usage: $0 [--use-pip]"
    exit 1
}
if (( $# == 1 )); then
   if [ "$1" == "--use-pip" ]; then
        USE_PIP=yes
    else
        usage
    fi
elif (( $# > 0 )); then
    usage
fi
if [ "$USE_PIP" == "yes" ]; then
    echo Installing auxiliary SnapPy packages with pip if possible.
fi
SNAPPY_SUITE=`pwd`
# Create a virtual env here for building SnapPy et al and the app.
# It is important to not have any extraneous modules installed in the
# virtual env in order to prevent py2app from embedding them into the
# app.
if [ ! -d build_env ]; then
    python3 -m venv build_env
fi
. build_env/bin/activate
SITE_PACKAGES=`python3 -c "import site ; print(site.getsitepackages()[0])"`

pip_install="python3 -m pip install --upgrade --no-user --target=$SITE_PACKAGES"
$pip_install --upgrade wheel cython sphinx ipython pypng py2app networkx
$pip_install --upgrade --no-use-pep517 pyx
install_package () {
    if [ "$1" == "binary" ]; then
	$pip_install --only-binary :all: $2
    else
        echo checking for $1
        if [ ! -d $1 ]; then
	    git clone https://github.com/3-manifolds/$1.git
	    cd $1
        else
	    cd $1
            git pull
	    python3 setup.py clean
        fi	
        #python3 setup.py build
        #python3 setup.py bdist_wheel
        shift
        $pip_install --no-deps $@ .
        cd ..
    fi
    }
if [ "$USE_PIP" == "yes" ]; then
   BINARY=binary
fi
install_package notary
install_package $BINARY PLink
install_package $BINARY FXrays
install_package $BINARY snappy_manifolds
install_package $BINARY snappy_15_knots
install_package $BINARY CyPari
install_package $BINARY knot_floer_homology
# Packages with no current wheel
install_package low_index
install_package Spherogram
install_package SnapPy

# if frameworks/Frameworks.tgz does not exist, build it.
if [ ! -e frameworks/Frameworks.tgz ]; then
    if [ ! -d frameworks ]; then
	git clone https://github.com/3-manifolds/frameworks.git
	ln -s ../DEV_ID.txt frameworks
    fi
    cd frameworks/TclTk
    if [ ! -d Tk ] || [ ! -d Tcl ]; then
	. fetch_tcltk.sh
    fi
    cd ..
    make FOR_PY2APP=yes
    cd ..
fi
cd SnapPy/mac_osx_app
if [ ! -e Frameworks.tgz ]; then
    ln -s ../../frameworks/Frameworks.tgz .
fi
if [ ! -e notabot.cfg ]; then
    ln -s ../../notabot.cfg .
fi
python3 release.py --no-freshen
python3 notarize_snappy.py
