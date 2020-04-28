#!/bin/bash
PROG_DIR=$(readlink -e $(dirname $0))
source ${PROG_DIR}/config.sh || exit 1

oldpwd=$(pwd)
cd usr/lib/python3/dist-packages || exit 1
rm -rf ${PACKAGE}
cd $oldpwd

rm -fv control.tar.gz data.tar.gz ${PACKAGE}_*_${ARCH}.deb debian-binary
