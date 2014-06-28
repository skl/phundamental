#!/bin/bash

PH_NODEJS_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_NODEJS_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify nodejs version [0.10.29]: " NODEJS_VERSION_STRING

# Default version
[ -z ${NODEJS_VERSION_STRING} ] && NODEJS_VERSION_STRING="0.10.29"

NODEJS_VERSION_INTEGER=`echo ${NODEJS_VERSION_STRING} | tr -d '.' | cut -c1-3`
NODEJS_VERSION_INTEGER_FULL=`echo ${NODEJS_VERSION_STRING} | tr -d '.'`
NODEJS_VERSION_MAJOR=`echo ${NODEJS_VERSION_STRING} | cut -d. -f1`
NODEJS_VERSION_MINOR=`echo ${NODEJS_VERSION_STRING} | cut -d. -f2`
NODEJS_VERSION_RELEASE=`echo ${NODEJS_VERSION_STRING} | cut -d. -f3`

read -p "Specify installation directory [/usr/local/nodejs-${NODEJS_VERSION_MAJOR}.${NODEJS_VERSION_MINOR}]: " NODEJS_PREFIX
[ -z ${NODEJS_PREFIX} ] && NODEJS_PREFIX="/usr/local/nodejs-${NODEJS_VERSION_MAJOR}.${NODEJS_VERSION_MINOR}"

NODEJS_DIRS="${NODEJS_PREFIX}"

for i in ${NODEJS_DIRS}; do
    [ -d ${i} ] && rm -rvf ${i}
done

NODEJS_SYMLINKS="/usr/local/bin/node /usr/local/bin/npm /usr/local/nodejs"

for i in ${NODEJS_SYMLINKS}; do
    [ -L ${i} ] && rm -i ${i}
done

echo
echo "nodejs ${NODEJS_VERSION_STRING} has been uninstalled."
