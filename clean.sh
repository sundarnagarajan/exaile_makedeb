#!/bin/bash
PROG_DIR=$(readlink -e $(dirname $0))
source ${PROG_DIR}/config.sh || exit 1

oldpwd=$(pwd)
if [ -d "$DIST_PKGS_DIR" ]; then
    cd "$DIST_PKGS_DIR"
    rm -rf ${PACKAGE}
    cd "$oldpwd"
fi

cd "${PROG_DIR}"
rm -fv debian-binary control.tar.gz data.tar.gz DEBIAN/md5sums ${PACKAGE}_*_${ARCH}.deb
cd "$oldpwd"
