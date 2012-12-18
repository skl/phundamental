#!/bin/bash
###############################################################################
#                                                                             #
# This script will install all modules                                        #
#                                                                             #
###############################################################################

if [ 0 -ne `id -u` ]; then
    echo 'You must be root to run this script!'
    exit
fi

WHEREAMI=`dirname $0`
. ${WHEREAMI}/conf.d/phundamental.conf

if [ ! -d ${PH_INSTALL_DIR} ]; then
    echo "You must set PH_INSTALL_DIR correctly in ${WHEREAMI}/conf.d/phundamental.conf"
    exit 1
fi

. ${PH_INSTALL_DIR}/bootstrap.sh

echo "Operating System: ${PH_OS} (${PH_OS_FLAVOUR})"
echo "    Architecture: ${PH_ARCH}"
echo "  Number of CPUs: ${PH_NUM_CPUS}"
echo " Package Manager: ${PH_PACKAGE_MANAGER}"

for i in `ls -1 ${PH_INSTALL_DIR}/modules`; do
    INSTALLER=${PH_INSTALL_DIR}/modules/$i/install.sh

    # Install module if there is an executable install.sh
    [ -x $INSTALLER ] && . ${INSTALLER}
done
