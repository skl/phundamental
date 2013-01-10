#!/bin/bash

# Include lib, return early if not required
command -v ph_is_installed > /dev/null 2>&1 && return 0

cat <<EOA
     _             _                   _       _
 ___| |_ _ _ ___ _| |___ _____ ___ ___| |_ ___| |
| . |   | | |   | . | .'|     | -_|   |  _| .'| |
|  _|_|_|___|_|_|___|__,|_|_|_|___|_|_|_| |__,|_|
EOA
echo -n '|_|'

for i in `ls -1 ${PH_INSTALL_DIR}/lib`; do
    for j in `ls -1 ${PH_INSTALL_DIR}/lib/$i`; do
        echo -n '.'
        . ${PH_INSTALL_DIR}/lib/$i/$j
    done
done

echo -e "Bootstrap complete \n"

echo "Operating System: ${PH_OS} (${PH_OS_FLAVOUR})"
echo "    Architecture: ${PH_ARCH}"
echo "  Number of CPUs: ${PH_NUM_CPUS}"
echo " Package Manager: ${PH_PACKAGE_MANAGER}"
echo ""

if [ ${PH_OS} != "windows" ]; then
    if [ 0 -ne `id -u` ]; then
        echo '[phundamental/installer] You must be root to install phundamental modules!'
        exit 1
    fi
fi
