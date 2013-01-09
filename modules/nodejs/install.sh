#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

if ph_is_installed node ; then
    echo "node is already installed!"
    ls -lh `which node` | awk '{print $9 $10 $11}'
    node -v

    read -p "Do you wish to continue with the node installation? [y/n] " REPLY
    [ $REPLY == "n" ] && return 1
fi

NODEJS_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify node.js version (e.g. 0.8.16): " NODEJS_VERSION_STRING

if [ "${PH_OS}" == "windows" ]; then
    ph_mkdirs /usr/local/src

    cd /usr/local/src

    if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
        wget http://nodejs.org/dist/v${NODEJS_VERSION_STRING}/node-v${NODEJS_VERSION_STRING}-x86.msi

        if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
            echo "node.js MSI installer download failed!"
            return 1
        fi
    fi

    msiexec /i node-v${NODEJS_VERSION_STRING}-x86.msi

else
    ph_install_packages\
        openssl\
        python\
        wget

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
            return 1
        fi
    fi

    tar xzf node-v${NODEJS_VERSION_STRING}.tar.gz
    cd node-v${NODEJS_VERSION_STRING}

    CONFIGURE_ARGS=("--prefix=/usr/local/nodejs-${NODEJS_VERSION_STRING}");

    ./configure ${CONFIGURE_ARGS[@]} && make -j ${PH_NUM_CPUS} && make install

    ph_symlink /etc/nodejs-${NODEJS_VERSION_STRING} /etc/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING} /usr/local/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING}/logs /var/log/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/node /usr/local/bin/node $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/node-waf /usr/local/bin/node-waf $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/npm /usr/local/bin/npm $NODEJS_OVERWRITE_SYMLINKS
fi

return 0
