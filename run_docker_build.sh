#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION PYBASEVER [uid] [gid]"
  exit 1
}

test $# -ge 2 || usage

VERSION=$1
PYBASEVER=$2
PYMAJMIN=${PYBASEVER:0:1}${PYBASEVER:2}
ARCH=x86_64
MINGW_PREFIX=/usr/${ARCH}-w64-mingw32
UID_GID=$3

cd
curl -L https://github.com/openturns/openturns/archive/v${VERSION}.tar.gz | tar xz && cd openturns-${VERSION}

PREFIX=$PWD/install
${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPython_INCLUDE_DIR=${MINGW_PREFIX}/include/python${PYMAJMIN} \
  -DPython_LIBRARY=${MINGW_PREFIX}/lib/libpython${PYMAJMIN}.dll.a \
  -DPython_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 \
  -DCMAKE_LINKER_TYPE=LLD \
  -DSWIG_COMPILE_FLAGS="-O1" \
  -DBLA_VENDOR=Generic \
  .

make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll ${PREFIX}/Lib/site-packages/openturns/*.pyd
cp ${MINGW_PREFIX}/bin/*.dll ${PREFIX}/bin
rm ${PREFIX}/bin/{python,libgraphblas}*.dll

cd distro/windows

tar cjf openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2 --directory ${PREFIX}/.. `basename ${PREFIX}`
makensis -DOPENTURNS_PREFIX=${PREFIX} -DPRODUCT_VERSION=${VERSION} -DPYBASEVER=${PYBASEVER} -DPYBASEVER_NODOT=${PYMAJMIN} -DARCH=${ARCH} openturns.nsi

if test -n "${UID_GID}"
then
  sudo cp -v openturns-${VERSION}-py${PYBASEVER}-${ARCH}.exe openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2 /io
  sudo chown ${UID_GID} /io/openturns-${VERSION}-py${PYBASEVER}-${ARCH}.exe /io/openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2
fi
