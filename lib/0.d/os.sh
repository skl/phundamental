#!/bin/bash

##
# Detects the operating system
#
# @sets ${PH_OS}
#
function ph_os {
    local UNAME=`uname`

    case "${UNAME}" in \
    'Darwin')
        PH_OS='mac'
        PH_OS_FLAVOUR=`uname -r`
    ;;

    'Linux')
        PH_OS='linux'

        if [ -f /etc/arch-release ]; then
            PH_OS_FLAVOUR='arch'

        elif [ -f /etc/debian_version ]; then
            PH_OS_FLAVOUR='debian'

        elif [ -f /etc/SuSE-release ]; then
            PH_OS_FLAVOUR="suse"

        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            PH_OS_FLAVOUR=`echo ${DISTRIB_ID} | awk '{print tolower($0)}'`

        else
            echo "ph_os() - Linux distribution not recognised!"
        fi
    ;;

    CYGWIN*)
        PH_OS='windows'

        if [ "CYGWIN_NT-6.1" == ${UNAME} ]; then
            PH_OS_FLAVOUR='7 32bit'

        elif [ "CYGWIN_NT-6.1-WOW64" == ${UNAME} ]; then
            PH_OS_FLAVOUR='7 64bit'

        else
            echo "ph_os() - Windows distribution not regognised!"
        fi
    ;;

    *)
        echo "ph_os() - OS not recognised: ${UNAME}"
        exit
    esac
}

ph_os
