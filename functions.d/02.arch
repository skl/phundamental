#!/bin/bash

##
# Detects the CPU architecture
#
# @sets ${PH_ARCH}
#
function ph_arch {
    test `uname -m` == 'x86_64' && PH_ARCH='64bit' || PH_ARCH='32bit'
}

ph_arch
