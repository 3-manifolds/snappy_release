#! /bin/bash
set -e
USE_PYPI=no
usage () {
    echo "usage: $0 [--use-pypi]"
    exit 1
}
if (( $# == 1 )); then
   if [ "$1" == "--use-pypi" ]; then
        USE_PYPI=yes
    else
        usage
    fi
elif (( $# > 0 )); then
    usage
fi
if [ "$USE_PYPI" == "yes" ]; then
    echo Installing auxiliary SnapPy packages from PyPI if possible.
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
# We store the wheels created here
rm -rf wheelhouse
mkdir wheelhouse

pip_install="python3 -m pip install --upgrade --no-user --target=$SITE_PACKAGES"
$pip_install --upgrade wheel build cython sphinx sphinx_rtd_theme ipython pypng py2app networkx
$pip_install --upgrade --no-use-pep517 pyx
$pip_install "setuptools<71"  # Needed for compatibility with py2app as of 2024-11-27

export _PYTHON_HOST_PLATFORM="macosx-10.13-universal2"
export ARCHFLAGS="-arch arm64 -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=10.13

install_package () {
    UNIVERSAL="--platform=macosx_10_13_universal2 "
    BINARY="--only-binary :all: "
    TEST_PYPI="--extra-index-url https://test.pypi.org/simple"
    if [ "$1" == "binary" ] && [ "$2" == "test-pypi" ]; then
	$pip_install $UNIVERSAL $BINARY $TEST_PYPI $3
    elif [ "$1" == "binary" ]; then
	$pip_install $UNIVERSAL $BINARY $2
    else
        echo Building $1 from source:
        if [ ! -d $1 ]; then
	    git clone https://github.com/3-manifolds/$1.git
	    cd $1
        else
	    cd $1
            git pull
	    python3 setup.py clean
        fi
        python3 -m pip wheel --no-build-isolation --wheel-dir=../wheelhouse .
        python3 -m pip install --force-reinstall --no-index --no-cache-dir --no-deps --find-links ../wheelhouse ${@: -1}
	cd ..
    fi
    }

if [ "$USE_PYPI" == "yes" ]; then
    USE_BINARY="binary"
    USE_TEST="test-pypi"
fi

install_package binary notabot
install_package plink
install_package $USE_BINARY FXrays
install_package snappy_manifolds
install_package snappy_15_knots
install_package $USE_BINARY $USE_TEST cypari 
install_package $USE_BINARY knot_floer_homology
install_package $USE_BINARY low_index
$pip_install tkinter_gl
install_package spherogram
install_package snappy

# Build snappy docs and add to wheel
python3 snappy/doc_src/build_doc_add_to_wheel.py wheelhouse
python3 -m pip install --force-reinstall --no-index --no-cache-dir --no-deps --find-links ./wheelhouse snappy

# if frameworks/Frameworks.tgz does not exist, build it.
if [ ! -e frameworks/Frameworks-3.13.tgz ]; then
    if [ ! -d frameworks ]; then
	git clone https://github.com/3-manifolds/frameworks.git
	ln -s ../DEV_ID.txt frameworks
    fi
    cd frameworks/TclTk
    if [ ! -d Tk ] || [ ! -d Tcl ]; then
	. fetch_tcltk.sh
    fi
    cd ..
    make
    cd ..
fi
cd SnapPy/macOS_app
if [ ! -e Frameworks-3.13.tgz ]; then
    ln -s ../../frameworks/Frameworks-3.13.tgz .
fi
if [ ! -e notabot.cfg ]; then
    ln -s ../../notabot.cfg .
fi
python3 release.py --no-freshen --notarize
