#/bin/sh

#
# See: http://boinc.berkeley.edu/trac/wiki/AndroidBuildClient#
#

# Script to compile OpenSSL for Android

COMPILEOPENSSL="yes"
CONFIGURE="yes"
MAKECLEAN="yes"

OPENSSL="/home/boincadm/src/openssl-1.0.1c" #openSSL sources, requiered by BOINC

export ANDROIDTC="$HOME/androidmips-tc"
export TCBINARIES="$ANDROIDTC/bin"
export TCINCLUDES="$ANDROIDTC/mipsel-linux-android"
export TCSYSROOT="$ANDROIDTC/sysroot"
export STDCPPTC="$TCINCLUDES/lib/libstdc++.a"

export PATH="$PATH:$TCBINARIES:$TCINCLUDES/bin"
export CC=mipsel-linux-android-gcc
export CXX=mipsel-linux-android-g++
export LD=mipsel-linux-android-ld
export CFLAGS="--sysroot=$TCSYSROOT -DANDROID -Wall -I$TCINCLUDES/include -O3 -fomit-frame-pointer"
export CXXFLAGS="--sysroot=$TCSYSROOT -DANDROID -Wall -funroll-loops -fexceptions -O3 -fomit-frame-pointer"
export LDFLAGS="-L$TCSYSROOT/usr/lib -L$TCINCLUDES/lib -llog"
export GDB_CFLAGS="--sysroot=$TCSYSROOT -Wall -g -I$TCINCLUDES/include"

# Prepare android toolchain and environment
./build_androidtc_mips.sh

if [ -n "$COMPILEOPENSSL" ]; then
echo "================building openssl from $OPENSSL============================="
cd $OPENSSL
if [ -n "$MAKECLEAN" ]; then
make clean
fi
if [ -n "$CONFIGURE" ]; then
./Configure linux-generic32 no-shared no-dso -DL_ENDIAN --openssldir="$TCINCLUDES/ssl"
#override flags in Makefile
sed -e "s/^CFLAG=.*$/`grep -e \^CFLAG= Makefile` \$(CFLAGS)/g
s%^INSTALLTOP=.*%INSTALLTOP=$TCINCLUDES%g" Makefile > Makefile.out
mv Makefile.out Makefile
fi
make
make install_sw
echo "========================openssl DONE=================================="
fi
