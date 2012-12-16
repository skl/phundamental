#!/bin/bash

# Build tools required? @todo mac
if [ "${PH_OS}" != "mac" ] ; then
    read -p "Install build tools (make, libtool etc.)? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && ph_install_buildtools
fi

# Install other dependencies
# @todo move dependencies to relevant components
#ph_install_packages pcre-devel\
#    libbz2-devel\
#    libcurl-devel\
#    libjpeg-devel\
#    libmcrypt-devel\
#    libpng-devel\
#    libtiff-devel\
#    libxml2-devel\
#    mcrypt\
#    mhash-devel\
#    openssl-devel\
#    pcre-devel\
#    zlib-devel
