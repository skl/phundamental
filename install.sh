#!/bin/bash
###############################################################################
#                                                                             #
# This script will install all modules                                        #
#                                                                             #
###############################################################################

read -p "Specify nginx version (e.g. 1.2.3): " NGINX_VERSION_STRING
read -p "Specify PHP version (e.g. 5.4.7): " PHP_VERSION_STRING
read -p "Specify MariaDB version (e.g. 5.5.27): " MARIADB_VERSION_STRING

BUILD_DIR=/usr/local/src/build

${BUILD_DIR}/system-dependencies/install.sh
${BUILD_DIR}/nginx/install.sh ${NGINX_VERSION_STRING}
${BUILD_DIR}/mariadb/install.sh ${MARIADB_VERSION_STRING}
${BUILD_DIR}/oracle-instantclient/install.sh
${BUILD_DIR}/php/install.sh ${PHP_VERSION_STRING}
${BUILD_DIR}/php-extensions/install.sh ${PHP_VERSION_STRING}
