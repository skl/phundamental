#!/bin/bash

# Upgrade all packages
pacman -Syu

# Install dependencies
pacman -S \
    gcc \
    gcc-c++ \
    cmake \
    libtool \
    libxml2-devel \
    openssl-devel \
    mcrypt \
    libmcrypt-devel \
    mhash-devel \
    pcre-devel \
    zlib-devel \
    libbz2-devel \
    libcurl-devel \
    libjpeg-devel \
    libpng-devel \
    libtiff-devel \
