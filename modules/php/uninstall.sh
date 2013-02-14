#!/bin/bash

PH_PHP_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_PHP_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify PHP version (e.g. 5.4.11): " PHP_VERSION_STRING

# e.g. 531 (truncated to three characters in order to construct a valid port number for fpm)
# So for PHP 5.4.7,  php-fpm will bind to 127.0.0.1:9547
# .. for PHP 5.3.17, php-fpm will bind to 127.0.0.1:9531
PHP_VERSION_INTEGER=`echo ${PHP_VERSION_STRING} | tr -d '.' | cut -c1-3`

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOR}" in \
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

[ -d /usr/local/php-${PHP_VERSION_STRING} ]     && rm -rf /usr/local/php-${PHP_VERSION_STRING}
[ -d /usr/local/src/php-${PHP_VERSION_STRING} ] && rm -rf /usr/local/src/php-${PHP_VERSION_STRING}
[ -d /etc/php-${PHP_VERSION_STRING} ]           && rm -rf /etc/php-${PHP_VERSION_STRING}
[ -f /etc/nginx/global/php-${PHP_VERSION_STRING}.conf ] && rm -f /etc/nginx/global/php-${PHP_VERSION_STRING}.conf

echo ""
echo "PHP ${PHP_VERSION_STRING} has been uninstalled."
