#!/bin/bash

# Build tools required? @todo mac
if [ "${PH_OS}" != "mac" ] ; then
    ph_install_buildtools
fi
