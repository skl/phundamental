#!/bin/bash
#####################################################
#      _             _                   _       _  #
#  ___| |_ _ _ ___ _| |___ _____ ___ ___| |_ ___| | #
# | . |   | | |   | . | .'|     | -_|   |  _| .'| | #
# |  _|_|_|___|_|_|___|__,|_|_|_|___|_|_|_| |__,|_| #
# |_|                                               #
#                                                   #
#####################################################

# Absolute path to current script http://stackoverflow.com/a/246128
PH_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

for i in `ls -1 ${PH_INSTALL_DIR}/modules`; do
    INSTALLER=${PH_INSTALL_DIR}/modules/$i/install.sh

    # Install module if there is an executable install.sh
    if [ -x $INSTALLER ]; then
        echo ''
        read -p "[phundamental/installer] Would you like to install '$i'? [y/n] " REPLY
        if [ "y" == $REPLY ]; then
            RESULT='with an unknown status'
            . ${INSTALLER} && RESULT='successfully' || RESULT='unsuccessfully'
            echo "[phundamental/$i] installation script finished ${RESULT}."
        fi
    fi
done

exit 0
