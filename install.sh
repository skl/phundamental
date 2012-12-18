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
. ${WHEREAMI}/conf.d/phundamental.conf

. ${PH_INSTALL_DIR}/bootstrap.sh

for i in `ls -1 ${PH_INSTALL_DIR}/modules`; do
    INSTALLER=${PH_INSTALL_DIR}/modules/$i/install.sh

    # Install module if there is an executable install.sh
    if [ -x $INSTALLER ]; then
        echo ""
        read -p "Would you like to install '$i'? [y/n] " REPLY
        [ "y" == $REPLY ] && . ${INSTALLER}
    fi
done
