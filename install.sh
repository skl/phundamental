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

# Check arguments are valid modules if they exists
for i in `echo $@ | tr " " "\n"`; do
    [ ! -d "${PH_INSTALL_DIR}/modules/$i" ] && { echo "[phundamental/installer] Module '$i' does not exist!" && exit 1; }
done

. ${PH_INSTALL_DIR}/bootstrap.sh

function ph_install_module() {
    local MODULE=$1
    local RESULT_MSG='with an unknown status'
    local INSTALLER=${PH_INSTALL_DIR}/modules/${MODULE}/install.sh

    . ${INSTALLER} && RESULT='successfully' || RESULT='unsuccessfully'
    echo "[phundamental/${MODULE}] installation script finished ${RESULT}."

    if [[ "${RESULT}" == "successfully" ]]; then
        return 0
    else
        return 1
    fi
}

for i in `ls -1 ${PH_INSTALL_DIR}/modules`; do
    if [ -x ${PH_INSTALL_DIR}/modules/$i/install.sh ]; then
        # Allow specific modules to be installed from an argument list
        if [ $# -gt 0 ]; then
            echo $@ | tr " " "\n" | grep "^${i}$" >/dev/null && ph_install_module $i

        # Ask use if they'd like to install the module
        else
            echo ''
            read -p "[phundamental/installer] Would you like to install '$i'? [y/n] " REPLY
            [ "y" == $REPLY ] && ph_install_module $i
        fi
    else
        echo "[phundamental/$i] Installer is not executable, skipping..."
    fi
done

exit 0
