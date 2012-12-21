#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

NODEJS_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify node.js version (e.g. 0.8.16): " NODEJS_VERSION_STRING

read -p "Install node.js dependencies? [y/n]: " REPLY
[ "$REPLY" == "y" ] && ph_install_packages openssl

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
cd node-v-${NODEJS_VERSION_STRING}

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
fi


echo ""
echo "node.js ${NODEJS_VERSION_STRING} has been installed!"
