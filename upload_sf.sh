#!/bin/sh

release=1.8rc2
for _basename in openturns-${release} otfftw-0.3 otlhs-1.3 otmorris-0.1 otpmml-1.3 otrobopt-0.1 otsvm-0.2
do
  for pybasever in 2.7 3.4 3.5
  do
    for _arch in i686 x86_64
    do
      _file=${_basename}-py${pybasever}-${_arch}.exe
      wget -c https://github.com/openturns/build/releases/download/v${release}/${_file} -P /tmp
    done
  done
done

#       scp /tmp/${_file} $1@frs.sourceforge.net:/home/frs/project/openturns/openturns/openturns-${release}
