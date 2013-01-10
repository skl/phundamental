#!/bin/bash
#####################################################
#      _             _                   _       _  #
#  ___| |_ _ _ ___ _| |___ _____ ___ ___| |_ ___| | #
# | . |   | | |   | . | .'|     | -_|   |  _| .'| | #
# |  _|_|_|___|_|_|___|__,|_|_|_|___|_|_|_| |__,|_| #
# |_|                                               #
#                                                   #
#####################################################

if [ 0 -ne `id -u` ]; then
    echo 'You must be root to run this script!'
    exit
fi

WHEREAMI=`dirname $0`
. ${WHEREAMI}/etc/phundamental.conf.sh

. ${PH_INSTALL_DIR}/bootstrap.sh

for i in `ls -1 ${PH_INSTALL_DIR}/modules`; do
    UNINSTALLER=${PH_INSTALL_DIR}/modules/$i/uninstall.sh

    # Uninstall module if there is an executable uninstall.sh
    if [ -x $UNINSTALLER ]; then
        echo ""
        read -p "Would you like to uninstall '$i'? [y/n] " REPLY
        [ "y" == $REPLY ] && . ${UNINSTALLER}
    fi
done
