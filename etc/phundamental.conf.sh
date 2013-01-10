#!/bin/bash

PH_INSTALL_DIR="/usr/local/src/phundamental"

if [ ! -d ${PH_INSTALL_DIR} ]; then
    echo "You must set PH_INSTALL_DIR to your phundamental installation path in ${WHEREAMI}/etc/phundamental.conf.sh"
    exit 1
fi
