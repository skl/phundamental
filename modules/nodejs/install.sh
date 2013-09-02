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

read -p "Specify node.js version [0.10.17]: " NODEJS_VERSION_STRING
[ -z ${NODEJS_VERSION_STRING} ] && NODEJS_VERSION_STRING="0.10.17"

read -p "Specify node.js installation directory [/usr/local/nodejs-${NODEJS_VERSION_STRING}]: " NODEJS_PREFIX
[ -z ${NODEJS_PREFIX} ] && NODEJS_VERSION_STRING="/usr/local/nodejs-${NODEJS_VERSION_STRING}"

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

    CONFIGURE_ARGS=("--prefix=${NODEJS_PREFIX}");

    ph_autobuild "`pwd`" ${CONFIGURE_ARGS[@]} || return 1

    ph_symlink ${NODEJS_PREFIX} /usr/local/nodejs $NODEJS_OVERWRITE_SYMLINKS

    for i in `ls -1 ${NODEJS_PREFIX}/bin`; do
        ph_symlink ${NODEJS_PREFIX}/bin/$i /usr/local/bin/$i ${NODEJS_OVERWRITE_SYMLINKS}
    done
fi

echo -n "Deleting source files... "
rm -rf /usr/local/src/node-v${NODEJS_VERSION_STRING}

echo "Complete."
return 0 || exit 0
