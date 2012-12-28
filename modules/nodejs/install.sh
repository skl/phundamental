#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

NODEJS_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify node.js version (e.g. 0.8.16): " NODEJS_VERSION_STRING

if [ "${PH_OS}" == "windows" ]; then
    ph_mkdirs /usr/local/src

    cd /usr/local/src

    if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
        wget http://nodejs.org/dist/v${NODEJS_VERSION_STRING}/node-v${NODEJS_VERSION_STRING}-x86.msi

        if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
            echo "node.js MSI installer download failed!"
            exit 1
        fi
    fi

    msiexec /i node-v${NODEJS_VERSION_STRING}-x86.msi

else
    ph_install_packages\
        openssl\
        python

    read -p "Overwrite existing symlinks? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && NODEJS_OVERWRITE_SYMLINKS=true || NODEJS_OVERWRITE_SYMLINKS=false

    ph_mkdirs \
        /usr/local/src \
        /etc/nodejs-${NOEJS_VERSION_STRING} \
        /var/log/nodejs-${NODEJS_VERSION_STRING}

    cd /usr/local/src

    if [ ! -f node-v${NODEJS_VERSION_STRING}.tar.gz ]; then
        wget http://nodejs.org/dist/v${NODEJS_VERSION_STRING}/node-v${NODEJS_VERSION_STRING}.tar.gz

        if [ ! -f node-v${NODEJS_VERSION_STRING}.tar.gz ]; then
            echo "node.js source download failed!"
            exit 1
        fi
    fi

    tar xzf node-v${NODEJS_VERSION_STRING}.tar.gz
    cd node-v${NODEJS_VERSION_STRING}

    CONFIGURE_ARGS=("--prefix=/usr/local/nodejs-${NODEJS_VERSION_STRING}");

    if [[ "${PH_PACKAGE_MANAGER}" == "brew" ]]; then
        # Add homebrew include directories
        CONFIGURE_ARGS=("${CONFIGURE_ARGS[@]}" \
            "--with-cc-opt=-I/usr/local/include" \
            "--with-ld-opt=-L/usr/local/lib")
    fi

    ./configure ${CONFIGURE_ARGS[@]} && make -j ${PH_NUM_CPUS} && make install

    if $NODEJS_OVERWRITE_SYMLINKS ; then
        ph_symlink /etc/nodejs-${NODEJS_VERSION_STRING} /etc/nodejs
        ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING} /usr/local/nodejs
        ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING}/logs /var/log/nodejs
        ph_symlink /usr/local/nodejs/bin/node /usr/local/bin/node
        ph_symlink /usr/local/nodejs/bin/node-waf /usr/local/bin/node-waf
        ph_symlink /usr/local/nodejs/bin/npm /usr/local/bin/npm
    fi
fi
