#!/bin/bash

PH_PHP_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_PHP_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify PHP version [5.5.11]: " PHP_VERSION_STRING
[ -z ${PHP_VERSION_STRING} ] && PHP_VERSION_STRING="5.5.11"

PHP_VERSION_INTEGER=`echo ${PHP_VERSION_STRING} | tr -d '.' | cut -c1-3`
PHP_VERSION_INTEGER_FULL=`echo ${PHP_VERSION_STRING} | tr -d '.'`
PHP_VERSION_MAJOR=`echo ${PHP_VERSION_STRING} | cut -d. -f1`
PHP_VERSION_MINOR=`echo ${PHP_VERSION_STRING} | cut -d. -f2`
PHP_VERSION_RELEASE=`echo ${PHP_VERSION_STRING} | cut -d. -f3`

read -p "Specify PHP installation directory [/usr/local/php-${PHP_VERSION_MAJOR}.${PHP_VERSION_MINOR}]: " PHP_PREFIX
[ -z ${PHP_PREFIX} ] && PHP_PREFIX="/usr/local/php-${PHP_VERSION_MAJOR}.${PHP_VERSION_MINOR}"

read -p "Specify php.ini installation directory [/etc/php-${PHP_VERSION_MAJOR}.${PHP_VERSION_MINOR}]: " PHP_INI_PATH
[ -z ${PHP_INI_PATH} ] && PHP_INI_PATH="/etc/php-${PHP_VERSION_MAJOR}.${PHP_VERSION_MINOR}"

PHP_DIRS="${PHP_PREFIX} ${PHP_INI_PATH}"
PHP_SYMLINKS="/usr/local/php"

# Remove bin links
[ -d ${PHP_PREFIX}/bin ] && {
    for i in `ls -1 ${PHP_PREFIX}/bin`; do
        [ -L /usr/local/bin/$i ] && rm -i /usr/local/bin/$i
    done
}

for i in ${PHP_SYMLINKS}; do
    [ -L ${i} ] && rm -i ${i}
done

for i in ${PHP_DIRS}; do
    [ -d ${i} ] && rm -rvf ${i}
done

case "${PH_OS}" in \
"linux")
    case "${PH_OS_FLAVOR}" in \
    "debian")
        update-rc.d php-${PHP_VERSION_STRING}-fpm remove
        ;;
    "suse")
        chkconfig php-${PHP_VERSION_STRING}-fpm off
        ;;
    esac

    if [ -f /etc/init.d/php-${PHP_VERSION_STRING}-fpm ]; then
        /etc/init.d/php-${PHP_VERSION_STRING}-fpm stop
        rm -f /etc/init.d/php-${PHP_VERSION_STRING}-fpm
    fi
    ;;

"mac")
    if [ -f /Library/LaunchAgents/org.php.php-fpm.plist ]; then
        launchctl unload /Library/LaunchAgents/org.php.php-fpm.plist
        rm -f /Library/LaunchAgents/org.php.php-fpm.plist
    fi
    ;;
esac

echo ""
echo "PHP ${PHP_VERSION_STRING} has been uninstalled."
