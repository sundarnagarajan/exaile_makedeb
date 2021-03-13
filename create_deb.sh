#!/bin/bash
PROG_DIR=$(readlink -e $(dirname $0))
source ${PROG_DIR}/config.sh || exit 1
${PROG_DIR}/clean.sh || exit 1

GIT_URL_EXAILE='https://github.com/exaile/exaile.git'
MAX_TAG="4.1.0-alpha1"
LATEST_TAG=$(git ls-remote --tags --quiet --refs $GIT_URL_EXAILE | cut -d/ -f3| sort -V | awk -v MAX_TAG=$MAX_TAG '$1 <= MAX_TAG {print}' | tail -1)
# LATEST_TAG=$(git ls-remote --tags --quiet --refs $GIT_URL_EXAILE | tail -1 | cut -d/ -f3)

echo "Latest tag: $LATEST_TAG"

oldpwd=$(pwd)

mkdir -p "$DIST_PKGS_DIR" || exit 1
cd "$DIST_PKGS_DIR"
git clone --depth 1 --branch "$LATEST_TAG" 'https://github.com/exaile/exaile.git' $PACKAGE 2>/dev/null
cd $PACKAGE
ACTUAL_TAG=$(git describe --abbrev=0 2>/dev/null)
if [ "$LATEST_TAG" != "$ACTUAL_TAG" ]; then
    echo "Latest tag and actual tag of branch cloned do not match"
    cd ../
    rm -rf $PACKAGE
    exit 1
fi
VERSION=$ACTUAL_TAG

echo "Cloned tag: $ACTUAL_TAG"
rm -rf dist exaile.egg-info .git .github setup.py MANIFEST.in .gitignore INSTALL Makefile exaile.bat README.OSX README.Windows .travis.yml


cd "${PROG_DIR}"
sed -ie "s/^Package: .*$/Package: $PACKAGE/" DEBIAN/control
sed -ie "s/^Version: .*$/Version: $VERSION/" DEBIAN/control
find usr -type f -exec md5sum {} \; > DEBIAN/md5sums

tar cz -C DEBIAN -f control.tar.gz .
tar cz --exclude=DEBIAN -f data.tar.gz usr
echo "2.0" > debian-binary
DEB_FILENAME=${PACKAGE}_${VERSION}_${ARCH}.deb
echo "Generating ${DEB_FILENAME}"
ar rc ${DEB_FILENAME} debian-binary control.tar.gz data.tar.gz
\rm -f control.tar.gz data.tar.gz debian-binary DEBIAN/md5sums

dpkg-deb --field ${DEB_FILENAME}
cd $oldpwd
