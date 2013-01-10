#!/bin/bash

PH_BUILTOOLS_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_BUILDTOOLS_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

# Build tools required? @todo mac
if [ "${PH_OS}" != "mac" ] ; then
    ph_install_buildtools
fi
