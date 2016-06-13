#!/bin/sh

release=1.8rc1
for _basename in openturns-${release} otmorris-0.0 otrobopt-0.0 otsvm-0.2
do
  for pybasever in 2.7 3.4 3.5
  do
    for _arch in i686 x86_64
    do
      _file=${_basename}-py${pybasever}-${_arch}.exe
      wget -c https://github.com/openturns/build/archive/v${release}/${_file} -P /tmp
      scp /tmp/${_file} $1@frs.sourceforge.net:/home/frs/project/openturns/openturns/openturns-${release}
    done
  done
done

