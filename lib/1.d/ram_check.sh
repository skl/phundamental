#!/bin/bash

##
# Sets the number of threads that gcc should use
#
# This is based on the machine's total RAM divied by 150MiB, which is roughly a
# maximum amount that may be required by one compilation thread. Acts as a
# safeguard against the case where, for example, a quad core machine only has
# 256MiB RAM. Mac users just get the NUM_CPUS value verbatim as it's probably a
# dev machine with plently of RAM.
#
# @depends ${PH_OS}
# @depends ${PH_NUM_CPUS}
# @sets    ${PH_NUM_THREADS}
#
function ph_ram_check {
    case ${PH_OS} in \
    'linux' |\
    'windows')
        PH_NUM_THREADS=`expr $(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 153600`
    ;;

    'mac')
        PH_NUM_THREADS=${PH_NUM_CPUS}
    ;;

    *)
        echo "ph_ram_check(): OS not recognised, assuming 1 thread"
        PH_NUM_THREADS='1'
    esac
}

ph_ram_check
