#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION PYBASEVER ARCH [uid] [gid]"
  exit 1
}

test $# -ge 3 || usage

VERSION=$1
PYBASEVER=$2
PYMAJMIN=${PYBASEVER:0:1}${PYBASEVER:2:1}
ARCH=$3
MINGW_PREFIX=/usr/${ARCH}-w64-mingw32
uid=$4
gid=$5

cd
curl -L https://github.com/openturns/openturns/archive/v${VERSION}.tar.gz | tar xz && cd openturns-${VERSION}

PREFIX=$PWD/install
${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib \
  -DPYTHON_INCLUDE_DIR=${MINGW_PREFIX}/include/python${PYMAJMIN} \
  -DPYTHON_LIBRARY=${MINGW_PREFIX}/lib/libpython${PYMAJMIN}.dll.a \
  -DPYTHON_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DPYTHON_SITE_PACKAGES=Lib/site-packages \
  -DUSE_TBB=OFF \
  -DUSE_SPHINX=OFF \
  -DUSE_COTIRE=ON -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j16" \
  -DSWIG_COMPILE_FLAGS="-O1" \
  .

make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll ${PREFIX}/Lib/site-packages/openturns/*.pyd
cp ${MINGW_PREFIX}/bin/*.dll ${PREFIX}/bin
rm ${PREFIX}/bin/libboost*.dll ${PREFIX}/bin/python*.dll

cd distro/windows

tar cjf openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2 --directory ${PREFIX}/.. `basename ${PREFIX}`
makensis -DOPENTURNS_PREFIX=${PREFIX} -DPRODUCT_VERSION=${VERSION} -DPYBASEVER=${PYBASEVER} -DPYBASEVER_NODOT=${PYMAJMIN} -DARCH=${ARCH} openturns.nsi

if test -n "${uid}" -a -n "${gid}"
then
  sudo cp -v *.tar.bz2 *.exe /io
  sudo chown ${uid}:${gid} /io/openturns-${VERSION}-py${PYBASEVER}-${ARCH}.exe /io/openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2
fi
