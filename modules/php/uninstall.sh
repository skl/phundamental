#!/bin/bash

if test -z "$1"
then
    echo "PHP version must be specified! e.g. ./uninstall.sh 5.4.7"
    exit
fi

# e.g. 5.3.17
PHP_VERSION_STRING=$1

# e.g. 531 (truncated to three characters in order to construct a valid port number for fpm)
# So for PHP 5.4.7,  php-fpm will bind to 127.0.0.1:9547
# .. for PHP 5.3.17, php-fpm will bind to 127.0.0.1:9531
PHP_VERSION_INTEGER=`echo ${PHP_VERSION_STRING} | tr -d '.' | cut -c1-3`

chkconfig php-${PHP_VERSION_STRING}-fpm off

/etc/init.d/php-${PHP_VERSION_STRING}-fpm stop

rm -rf /usr/local/php-${PHP_VERSION_STRING}
rm -rf /usr/local/src/php-${PHP_VERSION_STRING}
rm -rf /etc/php-${PHP_VERSION_STRING}

rm /etc/nginx/global/php-${PHP_VERSION_STRING}.conf
rm /etc/init.d/php-${PHP_VERSION_STRING}-fpm

echo ""
echo "PHP ${PHP_VERSION_STRING} has been uninstalled."
