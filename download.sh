#!/bin/sh

user=$1

release=1.11rc1
for _basename in openturns-${release}
do
  project=`echo "${_basename}" | cut -d '-' -f 1`
  version=`echo "${_basename}" | cut -d '-' -f 2`

  # source
  wget -c https://github.com/openturns/${project}/archive/v${version}.tar.gz -O /tmp/${_basename}.tar.gz

  for pybasever in 2.7 3.5 3.6
  do
    for _arch in i686 x86_64
    do
      _file=${_basename}-py${pybasever}-${_arch}.exe
      wget -c https://github.com/openturns/build/releases/download/v${release}/${_file} -P /tmp
    done
  done
done

sha256sum /tmp/*.tar.gz
sha256sum /tmp/*.exe
