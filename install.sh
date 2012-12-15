#!/bin/bash
###############################################################################
#                                                                             #
# This script will install all modules                                        #
#                                                                             #
###############################################################################

. install.conf

read -p "Specify nginx version (e.g. 1.2.3): " NGINX_VERSION_STRING

${FW_INSTALL_DIR}/system-dependencies/install.sh
${FW_INSTALL_DIR}/nginx/install.sh ${NGINX_VERSION_STRING}
