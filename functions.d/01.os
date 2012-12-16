#!/bin/bash

##
# @sets ${PH_OS}
#
function ph_os {
    local UNAME=`uname`

    case $UNAME in \
    'Darwin')
        PH_OS='mac'
        PH_OS_FLAVOUR=`uname -r`
    ;;

    'Linux')
        PH_OS='linux'

        if [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            PH_OS_FLAVOUR=`echo ${DISTRIB_ID} | awk '{print tolower($0)}'`
        elif [ -f /etc/arch-release ]; then
            PH_OS_FLAVOUR='arch'
        else
            echo "ph_os() - Linux distribution not recognised!"
        fi
    ;;

    *)
        echo "ph_os() - OS not recognised: ${UNAME}"
        exit
    esac
}

ph_os
