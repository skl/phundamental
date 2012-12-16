#!/bin/bash

if [ "${PH_OS}" != "mac" ] ; then
    read -p "Install build tools (make, libtool etc.)? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && echo "I would: ${PH_PACKAGE_MANAGER_BUILDTOOLS}"
else
    echo "Build tools not required, you're on a Mac."
fi

exit

# Install other dependencies
$PACKAGE_MANAGER \
    pcre-devel

exit
    libbz2-devel \
    libcurl-devel \
    libjpeg-devel \
    libmcrypt-devel \
    libpng-devel \
    libtiff-devel \
    libxml2-devel \
    mcrypt \
    mhash-devel \
    openssl-devel \
    pcre-devel \
    zlib-devel
