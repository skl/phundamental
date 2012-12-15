#!/bin/bash

PH_INSTALL_DIR="/usr/local/src/phundamental"

for i in `ls -1 ${PH_INSTALL_DIR}/functions.d`; do
    echo -n '.'
    . ${PH_INSTALL_DIR}/functions.d/$i
done

echo 'Bootstrap complete.'
