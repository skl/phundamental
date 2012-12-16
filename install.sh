#!/bin/bash
###############################################################################
#                                                                             #
# This script will install all modules                                        #
#                                                                             #
###############################################################################

WHEREAMI=`dirname $0`
. ${WHEREAMI}/bootstrap.sh

echo "Operating System: ${PH_OS} (${PH_OS_FLAVOUR})"
echo "    Architecture: ${PH_ARCH}"
echo "  Number of CPUs: ${PH_NUM_CPUS}"
echo " Package Manager: ${PH_PACKAGE_MANAGER}"

for i in \
    'system-dependencies' \
    'nginx'
    do
        . ${WHEREAMI}/$i/install.sh
done
