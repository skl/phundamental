#!/bin/bash

# Upgrade all packages
pacman -Syu

# Install build tools
pacman -Sy base-devel

# Install other dependencies
#pacman -S \
#    libbz2-devel \
#    libcurl-devel \
#    libjpeg-devel \
#    libmcrypt-devel \
#    libpng-devel \
#    libtiff-devel \
#    libxml2-devel \
#    mcrypt \
#    mhash-devel \
#    openssl-devel \
#    pcre-devel \
#    zlib-devel
