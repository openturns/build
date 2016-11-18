#!/bin/sh

user=$1

release=1.8
for _basename in openturns-${release} otfftw-0.3 otlhs-1.3 otmorris-0.1 otpmml-1.3 otrobopt-0.1 otsvm-0.2 otlm-0.2
do
  project=`echo "${_basename}" | cut -d '-' -f 1`
  version=`echo "${_basename}" | cut -d '-' -f 2`

  # source
  wget -c https://github.com/openturns/${project}/archive/v${version}.tar.gz -O /tmp/${_basename}.tar.gz
  if test "${project}" = "openturns"
  then
    scp /tmp/${_basename}.tar.gz ${user}@frs.sourceforge.net:/home/frs/project/openturns/openturns/openturns-${release}
  fi

  # exe
  for pybasever in 2.7 3.4 3.5
  do
    for _arch in i686 x86_64
    do
      _file=${_basename}-py${pybasever}-${_arch}.exe
      wget -c https://github.com/openturns/build/releases/download/v${release}/${_file} -P /tmp

      # upload openturns exe
      if test "${project}" = "openturns"
      then
        scp /tmp/${_file} $1@frs.sourceforge.net:/home/frs/project/openturns/openturns/openturns-${release}
      fi
    done
  done
done

sha256sum /tmp/*.exe
sha256sum /tmp/*.tar.gz
