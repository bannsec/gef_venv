#!/bin/bash

# TODO: install into current virtualenv 
# Figure out python version appropriately
# Move explotiable into virtualenv
# Add libdislocator to gdb startup line
# AFL_PRELOAD=/home/geeknik/aflfast/libdislocator/libdislocator.so afl-fuzz -t50+ -m none -i in -o out ./perl @@
# Use gdb to preload: (inside gdb) set environment LD_PRELOAD=./yourso.so 
# Grab major python version: pyVersion=$(gdb -q -x version.py)

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd . >/dev/null

# If we're not in venv, abort
if [ -z "$VIRTUAL_ENV" ]; then
    echo "You must be in a virtual environment."
    exit 1
fi

# Print out what virtual environment I've found
echo "In virtual environment: `basename $VIRTUAL_ENV`"

# Figure out real gdb
gdb=$(which gdb)

# Do we have gdb installed?
if [ -z "$gdb" ]; then
    echo "GDB not found. Need to install it."
    exit 1
fi

gdbVersion=$(gdb -q -x $SOURCEDIR/gdb_version.py)

echo "GDB Version: $gdbVersion"

# Figure out gdb's baked in python version
gdbPyVersion=$(gdb -q -x $SOURCEDIR/gdb_py_version.py)

echo "GDB Python Version: $gdbPyVersion"

# Check what version of python we're in right now
localPyVersion=$(python -c 'import sys; print(sys.version_info[0]);')

echo "Local Python Version: $localPyVersion"

if [ "$gdbPyVersion" != "$localPyVersion" ]; then
    echo "=============================================================================="
    echo "= WARNING: Python version mismatch! You may want to switch your environment! ="
    echo "=============================================================================="
fi

read -p "Continue? " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[yY]$ ]]; then
    echo "Aborting."
    exit 1
fi

# Create a working space
TMPDIR=$(mktemp -d)

echo -n "Downloading GEF ... "

# Download the latest gef
wget -O $VIRTUAL_ENV/bin/.gef.py -q https://github.com/hugsy/gef/raw/master/gef.py

echo "[ DONE ]"

# Install exploitable
echo -n "Installing exploitable ... "

cd $TMPDIR
wget -q "https://github.com/jfoote/exploitable/archive/master.tar.gz"
tar xf master.tar.gz
cd exploitable-master

# Patch up installer since it isn't properly finding pyenv
# https://github.com/jfoote/exploitable/issues/38
sed -i "s/hasattr(sys, 'real_prefix')/True/g" setup.py

# Pip install the library
pip -q install .

echo "[ DONE ]"

# Install Python Package
echo -n "Installing GEF python package ... "

cd $SOURCEDIR/gef
pip install .

echo "[ DONE ]"

# Compile and install libdislocators
echo -n "Installing libdislocator ... "

cd $TMPDIR
wget -q "http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz"
tar xf afl-latest.tgz
cd `ls -d afl-*/`
cd libdislocator

# Try to make both versions
CFLAGS="-O3 -funroll-loops -m64" make -s 2>/dev/null

if [ $? -ne 0 ]; then
    echo "WARNING: Couldn't compile 64bit libdislocator. Ensure you have the libc dev package."
else
    mv libdislocator.so $VIRTUAL_ENV/lib/libdislocator_64.so
fi

CFLAGS="-O3 -funroll-loops -m32" make -s 2>/dev/null

if [ $? -ne 0 ]; then
    echo "WARNING: Couldn't compile 32bit libdislocator. Ensure you have the libc dev package."
else
    mv libdislocator.so $VIRTUAL_ENV/lib/libdislocator_32.so
fi

echo "[ DONE ]"

# Remove our temp space
rm -rf $TMPDIR

popd >/dev/null
