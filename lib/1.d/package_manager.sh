#!/bin/bash

if ph_is_installed apt-get; then
    PH_PACKAGE_MANAGER='apt-get'
    $PH_INTERACTIVE && PH_PACKAGE_MANAGER_ARG='install -y' || PH_PACKAGE_MANAGER_ARG='install'
    PH_PACKAGE_MANAGER_UPDATE='update'
elif ph_is_installed zypper; then
    PH_PACKAGE_MANAGER='zypper'
    $PH_INTERACTIVE && PH_PACKAGE_MANAGER_ARG='-n install' || PH_PACKAGE_MANAGER_ARG='install'
    PH_PACKAGE_MANAGER_UPDATE='refresh'
elif ph_is_installed brew; then
    PH_PACKAGE_MANAGER='brew'
    PH_PACKAGE_MANAGER_ARG='install'
    PH_PACKAGE_MANAGER_UPDATE='update'
elif ph_is_installed yum; then
    PH_PACKAGE_MANAGER='yum'
    $PH_INTERACTIVE && PH_PACKAGE_MANAGER_ARG='-y install' || PH_PACKAGE_MANAGER_ARG='install'
elif ph_is_installed pacman; then
    PH_PACKAGE_MANAGER='pacman'
    PH_PACKAGE_MANAGER_ARG='-Sy'
elif ph_is_installed apt-cyg; then
    PH_PACKAGE_MANAGER='apt-cyg'
    PH_PACKAGE_MANAGER_ARG='install'
    # Fix required for cygwin when installing gcc
    PH_PACKAGE_MANAGER_POSTBUILD='for x in /etc/postinstall/{gcc.,gcc-[^tm]}* ; do . $x; done'
else
    echo 'Package manager not found!'
    exit 1
fi


##
# Installs all packages (passed as arguments)
# e.g. ph_install_packages mcrypt openssl pcre
#
# @arguments Space separated list of packages to install
#
function ph_install_packages {
    local i=0
    local CONF_PATH="${PH_INSTALL_DIR}/etc/package_map.conf"
    declare -a PH_PACKAGES

    for PACKAGE in "$@"; do
        # Search conf file for entry, take 3rd value on line as package name
        PACKAGE_MAP_PACKAGE_NAME=`grep "^${PACKAGE}:${PH_PACKAGE_MANAGER}" ${CONF_PATH} | cut -d: -f3`

        # Catch empty result of above search
        if [ -z "${PACKAGE_MAP_PACKAGE_NAME}" ]; then
            echo "ph_install_packages() - Package map not found for '${PACKAGE}:${PH_PACKAGE_MANAGER}' in ${CONF_PATH}!"
            exit

        # Count number of lines returned from above search, error if more than one
        elif [ `echo "${PACKAGE_MAP_PACKAGE_NAME}" | wc -l` -gt 1 ]; then
            echo "ph_install_packages() - Duplicate entry found for '${PACKAGE}:${PH_PACKAGE_MANAGER}' in ${CONF_PATH}!"
            exit
        fi

        # Skip package if so marked in conf file
        if [ "${PACKAGE_MAP_PACKAGE_NAME}" != "##SKIP##" ]; then

            # Detect packages that are already installed. This also supports
            # multiple entries such as "openssl-devel openssl"
            for j in `echo "${PACKAGE_MAP_PACKAGE_NAME}" | tr " " "\n"`; do
                if ph_is_installed $j ; then
                    echo "$j is already installed at `which $j`"
                else
                    PH_PACKAGES[$i]="$j"
                    ((i++))
                fi
            done
        fi
    done

    # Only run the package manager if more than 1 package made it through
    if [ ${#PH_PACKAGES[@]} -gt 0 ]; then
        # Homebrew doesn't like root
        if [ 'brew' == ${PH_PACKAGE_MANAGER} ]; then
            if [ -z ${SUDO_USER} ]; then
                read -p 'Homebrew requires your username please (not root): ' SUDO_USER
            fi
            sudo -u ${SUDO_USER} brew update
            sudo -u ${SUDO_USER} brew tap homebrew/dupes
            sudo -u ${SUDO_USER} brew install ${PH_PACKAGES[@]} || { \
                if ! ph_ask_yesno "[phundamental/package_manager] Do you wish to continue?"; then
                    exit 1
                fi
            }


        else
            # Update package list if required
            [ ! -z ${PH_PACKAGE_MANAGER_UPDATE} ] && ${PH_PACKAGE_MANAGER} ${PH_PACKAGE_MANAGER_UPDATE}

            $PH_PACKAGE_MANAGER $PH_PACKAGE_MANAGER_ARG ${PH_PACKAGES[@]} || { \
                if ! ph_ask_yesno "[phundamental/package_manager] Do you wish to continue?"; then
                    exit 1
                fi
            }
        fi
    fi
}
