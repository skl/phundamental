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
PH_UNINSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${PH_UNINSTALL_DIR}/bootstrap.sh

for i in `ls -1 ${PH_UNINSTALL_DIR}/modules`; do
    UNINSTALLER=${PH_UNINSTALL_DIR}/modules/$i/uninstall.sh

    # Install module if there is an executable uninstall.sh
    if [ -x $UNINSTALLER ]; then
        echo ''
        read -p "[phundamental/uninstaller] Would you like to uninstall '$i'? [y/n] " REPLY
        if [ "y" == $REPLY ]; then
            RESULT='with an unknown status'
            . ${UNINSTALLER} && RESULT='successfully' || RESULT='unsuccessfully'
            echo "[phundamental/$i] uninstallation script finished ${RESULT}."
        fi
    fi
done

exit 0
