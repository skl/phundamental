#!/bin/bash

##
# Detects the number of CPUs
#
# @depends ${PH_OS}
# @sets    ${PH_NUM_CPUS}
#
function ph_num_cpus {
    case ${PH_OS} in \
    'linux' |\
    'windows')
        PH_NUM_CPUS=`cat /proc/cpuinfo | grep processor | wc -l`
    ;;

    'mac')
        PH_NUM_CPUS=`sysctl -n hw.ncpu`
    ;;

    *)
        echo "ph_num_cpus(): OS not recognised, assuming 1 CPU"
        PH_NUM_CPUS='1'
    esac
}

ph_num_cpus
