#!/bin/sh

set -xe

VERSION=$1
PYBASEVER=$2
PYMAJMIN=${PYBASEVER:0:1}${PYBASEVER:2:1}
ARCH=$3
MINGW_PREFIX=/usr/${ARCH}-w64-mingw32
uid=$4
gid=$5

cd
curl -L https://github.com/openturns/openturns/archive/v${VERSION}.tar.gz | tar xz && cd openturns-${VERSION}
tar xzf /io/openturns-developers-windeps.tar.gz -C distro/windows

# R wrapper
R_PATH=${PWD}/distro/windows/openturns-developers-windeps/opt/R-2.12.0
echo -e "#!/bin/sh\nset -e\n/usr/bin/${ARCH}-w64-mingw32-wine ${R_PATH}/bin/R.exe \"\$@\"" > ./${ARCH}-w64-mingw32-R-bin
chmod a+rx ./${ARCH}-w64-mingw32-R-bin
./${ARCH}-w64-mingw32-R-bin --version

PREFIX=$PWD/install
CXXFLAGS="-D_hypot=hypot" ${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib \
  -DPYTHON_INCLUDE_DIR=${MINGW_PREFIX}/include/python${PYMAJMIN} \
  -DPYTHON_LIBRARY=${MINGW_PREFIX}/lib/libpython${PYMAJMIN}.dll.a \
  -DPYTHON_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DPYTHON_SITE_PACKAGES=Lib/site-packages \
  -DR_EXECUTABLE=${PWD}/${ARCH}-w64-mingw32-R-bin \
  -DUSE_TBB=OFF \
  -DUSE_SPHINX=OFF \
  -DUSE_COTIRE=ON -DCOTIRE_MAXIMUM_NUMBER_OF_UNITY_INCLUDES="-j8" .

# reduce memusage of swig wrappers
find python/src/ -name flags.make|xargs sed -i "s|-O2 |-O1 |g"

make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/Lib/site-packages/openturns/*.pyd
cp ${MINGW_PREFIX}/bin/*.dll ${PREFIX}/bin
rm ${PREFIX}/bin/libboost*.dll ${PREFIX}/bin/python*.dll

cd distro/windows

# FIXME: R PATH replacement issue
sed -i "s|  value=|value_str=|g" openturns.nsi

tar cjf openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2 --directory ${PREFIX}/.. `basename ${PREFIX}`
sed "s|@version@|${VERSION}|g" OpenTURNSDoc.url.in > OpenTURNSDoc.url
makensis -DOPENTURNS_PREFIX=${PREFIX} -DPRODUCT_VERSION=${VERSION} -DPYBASEVER=${PYBASEVER} -DPYBASEVER_NODOT=${PYMAJMIN} -DARCH=${ARCH} openturns.nsi

if test -n "${uid}" -a -n "${gid}"
then
  sudo cp -v *.tar.bz2 *.exe /io
  sudo chown ${uid}:${gid} /io/openturns-${VERSION}-py${PYBASEVER}-${ARCH}.exe /io/openturns-mingw-${VERSION}-py${PYBASEVER}-${ARCH}.tar.bz2
fi
