#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_NODEJS_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_NODEJS_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

if ph_is_installed node ; then
    echo "node is already installed!"
    ls -l `which node` | awk '{print $9 $10 $11}'
    node -v

    if ! ph_ask_yesno "Do you wish to continue with the node installation?"; then
        return 1 || exit 1
    fi
fi

read -p "Specify node.js version (e.g. 0.10.9): " NODEJS_VERSION_STRING

if [ "${PH_OS}" == "windows" ]; then
    ph_mkdirs /usr/local/src

    cd /usr/local/src

    if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
        wget http://nodejs.org/dist/v${NODEJS_VERSION_STRING}/node-v${NODEJS_VERSION_STRING}-x86.msi

        if [ ! -f node-v${NODEJS_VERSION_STRING}-x86.msi ]; then
            echo "node.js MSI installer download failed!"
            return 1 || exit 1
        fi
    fi

    msiexec /i node-v${NODEJS_VERSION_STRING}-x86.msi

else
    ph_install_packages\
        gcc\
        make\
        openssl\
        python\
        wget

    if ph_ask_yesno "Overwrite existing symlinks in /usr/local?"; then
        NODEJS_OVERWRITE_SYMLINKS=true
    else
        NODEJS_OVERWRITE_SYMLINKS=false
    fi

    ph_mkdirs \
        /usr/local/src \
        /etc/nodejs-${NOEJS_VERSION_STRING} \
        /var/log/nodejs-${NODEJS_VERSION_STRING}

    ph_cd_archive tar xzf node-v${NODEJS_VERSION_STRING} .tar.gz \
        http://nodejs.org/dist/v${NODEJS_VERSION_STRING}/node-v${NODEJS_VERSION_STRING}.tar.gz

    CONFIGURE_ARGS=("--prefix=/usr/local/nodejs-${NODEJS_VERSION_STRING}");

    ph_autobuild "`pwd`" ${CONFIGURE_ARGS[@]} || return 1

    ph_symlink /etc/nodejs-${NODEJS_VERSION_STRING} /etc/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING} /usr/local/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs-${NODEJS_VERSION_STRING}/logs /var/log/nodejs $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/node /usr/local/bin/node $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/node-waf /usr/local/bin/node-waf $NODEJS_OVERWRITE_SYMLINKS
    ph_symlink /usr/local/nodejs/bin/npm /usr/local/bin/npm $NODEJS_OVERWRITE_SYMLINKS
fi

echo -n "Deleting source files... "
rm -rf /usr/local/src/node-v${NODEJS_VERSION_STRING}

echo "Complete."
return 0 || exit 0
